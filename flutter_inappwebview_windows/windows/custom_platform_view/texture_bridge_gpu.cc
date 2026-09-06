#include "texture_bridge_gpu.h"

#include <d3dcompiler.h>

#include <cassert>
#include <cstdint>
#include <iostream>
#include <mutex>

#include "util/direct3d11.interop.h"

namespace flutter_inappwebview_plugin
{
  namespace
  {
    // Writes 1 into a raw buffer if any pixel of |a| differs from |b|. Both
    // textures are B8G8R8A8_UNORM of the same size; unorm loads of equal bytes
    // yield equal floats, so the comparison is exact.
    constexpr char kCompareShader[] = R"hlsl(
Texture2D<float4> a : register(t0);
Texture2D<float4> b : register(t1);
RWByteAddressBuffer result : register(u0);

[numthreads(16, 16, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint width, height;
  a.GetDimensions(width, height);
  if (id.x >= width || id.y >= height) {
    return;
  }
  if (any(a.Load(int3(id.xy, 0)) != b.Load(int3(id.xy, 0)))) {
    result.Store(0, 1u);
  }
}
)hlsl";

    typedef HRESULT(WINAPI* D3DCompileFn)(LPCVOID, SIZE_T, LPCSTR,
      const D3D_SHADER_MACRO*, ID3DInclude*, LPCSTR, LPCSTR, UINT, UINT,
      ID3DBlob**, ID3DBlob**);

    constexpr UINT kCompareResultBytes = 16;
  }

  TextureBridgeGpu::TextureBridgeGpu(
    GraphicsContext* graphics_context,
    ABI::Windows::UI::Composition::IVisual* visual)
    : TextureBridge(graphics_context, visual)
  {
    surface_descriptor_.struct_size = sizeof(FlutterDesktopGpuSurfaceDescriptor);
    surface_descriptor_.format =
      kFlutterDesktopPixelFormatNone;  // no format required for DXGI surfaces
    if (!InitComparer()) {
      std::cerr << "WebView frame compare unavailable; every captured frame "
        "is forwarded to Flutter." << std::endl;
    }
  }

  bool TextureBridgeGpu::InitComparer()
  {
    auto device = graphics_context_->d3d_device();
    if (!device || device->GetFeatureLevel() < D3D_FEATURE_LEVEL_11_0) {
      return false;
    }

    // d3dcompiler_47.dll ships with Windows 8.1 and later. Loaded on demand so
    // the plugin has no link-time dependency on it.
    const HMODULE compiler = LoadLibraryW(L"d3dcompiler_47.dll");
    if (!compiler) {
      return false;
    }
    const auto compile = reinterpret_cast<D3DCompileFn>(
      GetProcAddress(compiler, "D3DCompile"));
    winrt::com_ptr<ID3DBlob> code;
    winrt::com_ptr<ID3DBlob> errors;
    const HRESULT compiled = compile
      ? compile(kCompareShader, sizeof(kCompareShader) - 1, "frame_compare",
        nullptr, nullptr, "main", "cs_5_0", 0, 0, code.put(), errors.put())
      : E_FAIL;
    FreeLibrary(compiler);
    if (FAILED(compiled) || !code) {
      if (errors) {
        std::cerr << "frame compare shader: "
          << static_cast<const char*>(errors->GetBufferPointer())
          << std::endl;
      }
      return false;
    }
    if (FAILED(device->CreateComputeShader(code->GetBufferPointer(),
      code->GetBufferSize(), nullptr, compare_shader_.put()))) {
      return false;
    }

    D3D11_BUFFER_DESC result_desc = {};
    result_desc.ByteWidth = kCompareResultBytes;
    result_desc.Usage = D3D11_USAGE_DEFAULT;
    result_desc.BindFlags = D3D11_BIND_UNORDERED_ACCESS;
    result_desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;
    if (FAILED(device->CreateBuffer(&result_desc, nullptr,
      compare_result_.put()))) {
      compare_shader_ = nullptr;
      return false;
    }
    D3D11_UNORDERED_ACCESS_VIEW_DESC uav_desc = {};
    uav_desc.Format = DXGI_FORMAT_R32_TYPELESS;
    uav_desc.ViewDimension = D3D11_UAV_DIMENSION_BUFFER;
    uav_desc.Buffer.FirstElement = 0;
    uav_desc.Buffer.NumElements = kCompareResultBytes / 4;
    uav_desc.Buffer.Flags = D3D11_BUFFER_UAV_FLAG_RAW;
    if (FAILED(device->CreateUnorderedAccessView(compare_result_.get(),
      &uav_desc, compare_result_uav_.put()))) {
      compare_shader_ = nullptr;
      return false;
    }
    D3D11_BUFFER_DESC staging_desc = {};
    staging_desc.ByteWidth = kCompareResultBytes;
    staging_desc.Usage = D3D11_USAGE_STAGING;
    staging_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    if (FAILED(device->CreateBuffer(&staging_desc, nullptr,
      compare_staging_.put()))) {
      compare_shader_ = nullptr;
      return false;
    }
    return true;
  }

  bool TextureBridgeGpu::FramesDiffer(ID3D11Texture2D* a, ID3D11Texture2D* b,
    uint32_t width, uint32_t height)
  {
    if (!compare_shader_) {
      return true;
    }
    auto device = graphics_context_->d3d_device();
    auto context = graphics_context_->d3d_device_context();

    winrt::com_ptr<ID3D11ShaderResourceView> view_a;
    winrt::com_ptr<ID3D11ShaderResourceView> view_b;
    if (FAILED(device->CreateShaderResourceView(a, nullptr, view_a.put())) ||
      FAILED(device->CreateShaderResourceView(b, nullptr, view_b.put()))) {
      return true;
    }

    const UINT zeros[4] = { 0, 0, 0, 0 };
    context->ClearUnorderedAccessViewUint(compare_result_uav_.get(), zeros);
    ID3D11ShaderResourceView* views[2] = { view_a.get(), view_b.get() };
    ID3D11UnorderedAccessView* uavs[1] = { compare_result_uav_.get() };
    context->CSSetShader(compare_shader_.get(), nullptr, 0);
    context->CSSetShaderResources(0, 2, views);
    context->CSSetUnorderedAccessViews(0, 1, uavs, nullptr);
    context->Dispatch((width + 15) / 16, (height + 15) / 16, 1);
    ID3D11ShaderResourceView* no_views[2] = { nullptr, nullptr };
    ID3D11UnorderedAccessView* no_uavs[1] = { nullptr };
    context->CSSetShaderResources(0, 2, no_views);
    context->CSSetUnorderedAccessViews(0, 1, no_uavs, nullptr);
    context->CSSetShader(nullptr, nullptr, 0);

    // Reading the 4-byte flag waits for the compare to finish on the GPU.
    // The work is tiny; this is well under a millisecond and runs on the
    // capture thread, not on Flutter's threads.
    context->CopyResource(compare_staging_.get(), compare_result_.get());
    D3D11_MAPPED_SUBRESOURCE mapped;
    if (FAILED(context->Map(compare_staging_.get(), 0, D3D11_MAP_READ, 0,
      &mapped))) {
      return true;
    }
    const bool differ = *static_cast<const uint32_t*>(mapped.pData) != 0;
    context->Unmap(compare_staging_.get(), 0);
    return differ;
  }

  bool TextureBridgeGpu::AcceptFrame(
    const winrt::com_ptr<ID3D11Texture2D>& frame)
  {
    D3D11_TEXTURE2D_DESC desc;
    frame->GetDesc(&desc);
    const bool surface_created = EnsureSurface(desc.Width, desc.Height);
    if (!surface_) {
      return false;
    }
    // Several WebViews share one immediate context, and with the free-threaded
    // frame pool their frames arrive on different threads.
    const std::lock_guard<std::mutex> context_lock(
      graphics_context_->device_context_mutex());
    auto context = graphics_context_->d3d_device_context();

    bool changed = true;
    if (!surface_created && compare_shader_ &&
      EnsureIncoming(desc.Width, desc.Height)) {
      context->CopyResource(incoming_.get(), frame.get());
      changed = FramesDiffer(incoming_.get(), surface_.get(), desc.Width,
        desc.Height);
      if (changed) {
        context->CopyResource(surface_.get(), incoming_.get());
      }
    }
    else {
      // First frame for this surface, or no compare available.
      context->CopyResource(surface_.get(), frame.get());
    }
    if (changed) {
      context->Flush();
    }
    return changed;
  }

  bool TextureBridgeGpu::EnsureSurface(uint32_t width, uint32_t height)
  {
    if (surface_ && surface_size_.width == width &&
      surface_size_.height == height) {
      return false;
    }
    D3D11_TEXTURE2D_DESC dstDesc = {};
    dstDesc.ArraySize = 1;
    dstDesc.MipLevels = 1;
    dstDesc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
    dstDesc.CPUAccessFlags = 0;
    dstDesc.Format = static_cast<DXGI_FORMAT>(kPixelFormat);
    dstDesc.Width = width;
    dstDesc.Height = height;
    dstDesc.MiscFlags = D3D11_RESOURCE_MISC_SHARED;
    dstDesc.SampleDesc.Count = 1;
    dstDesc.SampleDesc.Quality = 0;
    dstDesc.Usage = D3D11_USAGE_DEFAULT;

    surface_ = nullptr;
    dxgi_surface_ = nullptr;
    surface_size_ = { 0, 0 };
    if (!SUCCEEDED(graphics_context_->d3d_device()->CreateTexture2D(
      &dstDesc, nullptr, surface_.put()))) {
      std::cerr << "Creating intermediate texture failed" << std::endl;
      return false;
    }

    HANDLE shared_handle;
    surface_.try_as(dxgi_surface_);
    assert(dxgi_surface_);
    dxgi_surface_->GetSharedHandle(&shared_handle);

    surface_descriptor_.handle = shared_handle;
    surface_descriptor_.width = surface_descriptor_.visible_width = width;
    surface_descriptor_.height = surface_descriptor_.visible_height = height;
    surface_descriptor_.release_context = surface_.get();
    surface_descriptor_.release_callback = [](void* release_context)
      {
        auto texture = reinterpret_cast<ID3D11Texture2D*>(release_context);
        texture->Release();
      };
    surface_size_ = { width, height };
    return true;
  }

  bool TextureBridgeGpu::EnsureIncoming(uint32_t width, uint32_t height)
  {
    if (incoming_ && incoming_size_.width == width &&
      incoming_size_.height == height) {
      return true;
    }
    D3D11_TEXTURE2D_DESC desc = {};
    desc.ArraySize = 1;
    desc.MipLevels = 1;
    desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    desc.Format = static_cast<DXGI_FORMAT>(kPixelFormat);
    desc.Width = width;
    desc.Height = height;
    desc.SampleDesc.Count = 1;
    desc.Usage = D3D11_USAGE_DEFAULT;
    incoming_ = nullptr;
    incoming_size_ = { 0, 0 };
    if (FAILED(graphics_context_->d3d_device()->CreateTexture2D(
      &desc, nullptr, incoming_.put()))) {
      return false;
    }
    incoming_size_ = { width, height };
    return true;
  }

  const FlutterDesktopGpuSurfaceDescriptor*
    TextureBridgeGpu::GetSurfaceDescriptor(size_t width, size_t height)
  {
    const std::lock_guard<std::mutex> lock(mutex_);
    if (!is_running_ || !surface_) {
      return nullptr;
    }
    // Gets released in the SurfaceDescriptor's release callback.
    surface_->AddRef();
    return &surface_descriptor_;
  }

  void TextureBridgeGpu::StopInternal()
  {
    TextureBridge::StopInternal();
    // For some reason, the destination surface needs to be recreated upon
    // resuming. Force |EnsureSurface| to create a new one by resetting it here.
    surface_ = nullptr;
    dxgi_surface_ = nullptr;
    surface_size_ = { 0, 0 };
    incoming_ = nullptr;
    incoming_size_ = { 0, 0 };
  }
}
