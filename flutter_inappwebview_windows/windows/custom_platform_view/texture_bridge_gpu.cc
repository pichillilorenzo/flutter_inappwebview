#include "texture_bridge_gpu.h"

#include <d3dcompiler.h>

#include <cassert>
#include <cstdint>
#include <iostream>
#include <memory>
#include <mutex>
#include <vector>

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
    constexpr size_t kSurfacePoolSize = 2;
  }

  struct TextureBridgeGpu::SurfacePool {
    struct Surface {
      winrt::com_ptr<ID3D11Texture2D> texture;
      HANDLE shared_handle = nullptr;
      bool is_leased = false;
    };

    std::mutex mutex;
    Size size = { 0, 0 };
    std::vector<Surface> surfaces;
    size_t published_surface = 0;
    bool has_published_surface = false;
  };

  struct TextureBridgeGpu::FrameLease {
    std::shared_ptr<SurfacePool> pool;
    size_t surface_index = 0;
    FlutterDesktopGpuSurfaceDescriptor descriptor = {};
  };

  TextureBridgeGpu::TextureBridgeGpu(
    GraphicsContext* graphics_context,
    ABI::Windows::UI::Composition::IVisual* visual)
    : TextureBridge(graphics_context, visual)
  {
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
        std::cerr << "frame compare shader: ";
        std::cerr.write(static_cast<const char*>(errors->GetBufferPointer()),
          static_cast<std::streamsize>(errors->GetBufferSize()));
        std::cerr << std::endl;
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

    // Never block the capture dispatcher waiting for the GPU. When the flag
    // is not ready, fail open and forward the frame, which is the previous
    // behaviour and preserves correctness under GPU pressure.
    context->CopyResource(compare_staging_.get(), compare_result_.get());
    D3D11_MAPPED_SUBRESOURCE mapped;
    if (FAILED(context->Map(compare_staging_.get(), 0, D3D11_MAP_READ,
      D3D11_MAP_FLAG_DO_NOT_WAIT, &mapped))) {
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
    const bool reference_created = !reference_ ||
      reference_size_.width != desc.Width ||
      reference_size_.height != desc.Height;
    if (!EnsureSurfacePool(desc.Width, desc.Height) ||
      (compare_shader_ && !EnsureReference(desc.Width, desc.Height))) {
      return false;
    }
    // Several WebViews share one immediate context, and with the free-threaded
    // frame pool their frames arrive on different threads.
    const std::lock_guard<std::mutex> context_lock(
      graphics_context_->device_context_mutex());
    auto context = graphics_context_->d3d_device_context();

    std::shared_ptr<SurfacePool> pool = surface_pool_;
    size_t writable_surface;
    {
      const std::lock_guard<std::mutex> pool_lock(pool->mutex);
      writable_surface = pool->surfaces.size();
      for (size_t i = 0; i < pool->surfaces.size(); ++i) {
        if (!pool->surfaces[i].is_leased) {
          writable_surface = i;
          break;
        }
      }
    }
    // Flutter is still using every shared texture. Keep the reference frame
    // unchanged so the next capture can publish the newest frame once a
    // buffer is released.
    if (writable_surface == pool->surfaces.size()) {
      return false;
    }

    bool changed = true;
    if (compare_shader_ && EnsureIncoming(desc.Width, desc.Height)) {
      context->CopyResource(incoming_.get(), frame.get());
      changed = !reference_created && FramesDiffer(incoming_.get(),
        reference_.get(), desc.Width, desc.Height);
      if (changed) {
        context->CopyResource(reference_.get(), incoming_.get());
        context->CopyResource(pool->surfaces[writable_surface].texture.get(),
          incoming_.get());
      }
    }
    else {
      // First frame, or no compare available.
      if (compare_shader_) {
        context->CopyResource(reference_.get(), frame.get());
      }
      context->CopyResource(pool->surfaces[writable_surface].texture.get(),
        frame.get());
    }
    if (changed) {
      context->Flush();
      const std::lock_guard<std::mutex> pool_lock(pool->mutex);
      pool->published_surface = writable_surface;
      pool->has_published_surface = true;
    }
    return changed;
  }

  bool TextureBridgeGpu::EnsureSurfacePool(uint32_t width, uint32_t height)
  {
    if (surface_pool_ && surface_pool_->size.width == width &&
      surface_pool_->size.height == height) {
      return true;
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

    auto pool = std::make_shared<SurfacePool>();
    pool->size = { width, height };
    pool->surfaces.resize(kSurfacePoolSize);
    for (auto& surface : pool->surfaces) {
      if (FAILED(graphics_context_->d3d_device()->CreateTexture2D(
        &dstDesc, nullptr, surface.texture.put()))) {
        std::cerr << "Creating intermediate texture failed" << std::endl;
        return false;
      }
      winrt::com_ptr<IDXGIResource> dxgi_surface;
      surface.texture.try_as(dxgi_surface);
      assert(dxgi_surface);
      if (FAILED(dxgi_surface->GetSharedHandle(&surface.shared_handle)) ||
        !surface.shared_handle) {
        std::cerr << "Creating shared texture handle failed" << std::endl;
        return false;
      }
    }
    surface_pool_ = std::move(pool);
    return true;
  }

  bool TextureBridgeGpu::EnsureReference(uint32_t width, uint32_t height)
  {
    if (reference_ && reference_size_.width == width &&
      reference_size_.height == height) {
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
    reference_ = nullptr;
    reference_size_ = { 0, 0 };
    if (FAILED(graphics_context_->d3d_device()->CreateTexture2D(
      &desc, nullptr, reference_.put()))) {
      std::cerr << "Creating frame reference texture failed" << std::endl;
      return false;
    }
    reference_size_ = { width, height };
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
    TextureBridgeGpu::GetSurfaceDescriptor(size_t, size_t)
  {
    const std::lock_guard<std::mutex> lock(mutex_);
    if (!is_running_ || !surface_pool_) {
      return nullptr;
    }
    auto pool = surface_pool_;
    const std::lock_guard<std::mutex> pool_lock(pool->mutex);
    if (!pool->has_published_surface ||
      pool->surfaces[pool->published_surface].is_leased) {
      return nullptr;
    }

    auto* lease = new FrameLease();
    lease->pool = std::move(pool);
    lease->surface_index = lease->pool->published_surface;
    const auto& surface = lease->pool->surfaces[lease->surface_index];
    lease->descriptor.struct_size = sizeof(FlutterDesktopGpuSurfaceDescriptor);
    lease->descriptor.handle = surface.shared_handle;
    lease->descriptor.width = lease->descriptor.visible_width =
      lease->pool->size.width;
    lease->descriptor.height = lease->descriptor.visible_height =
      lease->pool->size.height;
    lease->descriptor.format = kFlutterDesktopPixelFormatNone;
    lease->descriptor.release_context = lease;
    lease->descriptor.release_callback = ReleaseSurface;
    lease->pool->surfaces[lease->surface_index].is_leased = true;
    return &lease->descriptor;
  }

  void TextureBridgeGpu::ReleaseSurface(void* release_context)
  {
    std::unique_ptr<FrameLease> lease(
      static_cast<FrameLease*>(release_context));
    const std::lock_guard<std::mutex> pool_lock(lease->pool->mutex);
    lease->pool->surfaces[lease->surface_index].is_leased = false;
  }

  void TextureBridgeGpu::StopInternal()
  {
    TextureBridge::StopInternal();
    // Outstanding Flutter leases retain the old pool until their release
    // callbacks run; a resumed capture creates a new pool.
    surface_pool_.reset();
    reference_ = nullptr;
    reference_size_ = { 0, 0 };
    incoming_ = nullptr;
    incoming_size_ = { 0, 0 };
  }
}
