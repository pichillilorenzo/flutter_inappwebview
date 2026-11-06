#pragma once

// Narrow platform doubles for the production-method harness. Actual Direct3D
// shared-handle behavior is separately tested by the WARP CTest suite.
#include <algorithm>
#include <cstdint>
#include <functional>
#include <memory>
#include <mutex>
#include <optional>
#include <stdexcept>
#include <utility>
#include <vector>

using UINT = uint32_t;
using HANDLE = void*;
using DXGI_FORMAT = uint32_t;
constexpr int S_OK = 0;
constexpr int E_FAIL = -1;
inline bool FAILED(int hr) { return hr < 0; }
inline bool SUCCEEDED(int hr) { return hr >= 0; }
constexpr UINT D3D11_BIND_RENDER_TARGET = 1;
constexpr UINT D3D11_BIND_SHADER_RESOURCE = 2;
constexpr UINT D3D11_CPU_ACCESS_READ = 1;
constexpr UINT D3D11_RESOURCE_MISC_SHARED = 1;
constexpr UINT DXGI_FORMAT_B8G8R8A8_UNORM = 87;
constexpr UINT D3D11_USAGE_DEFAULT = 0;
constexpr UINT D3D11_USAGE_STAGING = 3;
constexpr UINT D3D11_MAP_READ = 1;
struct D3D11_TEXTURE2D_DESC {
  UINT Width = 0, Height = 0, MipLevels = 0, ArraySize = 0, Format = 0;
  struct { UINT Count = 0, Quality = 0; } SampleDesc;
  UINT Usage = 0, BindFlags = 0, CPUAccessFlags = 0, MiscFlags = 0;
};
struct D3D11_BOX { UINT left, top, front, right, bottom, back; };
struct D3D11_MAPPED_SUBRESOURCE { void* pData; UINT RowPitch; };

struct ID3D11Texture2D {
  D3D11_TEXTURE2D_DESC desc;
  uint32_t pixel = 0;
  size_t refs = 1;
  std::function<void()> on_destroy;
  explicit ID3D11Texture2D(D3D11_TEXTURE2D_DESC value) : desc(value) {}
  void AddRef() { ++refs; }
  void Release() { if (--refs == 0) delete this; }
  void GetDesc(D3D11_TEXTURE2D_DESC* out) { *out = desc; }
  int GetSharedHandle(HANDLE* out) { *out = this; return S_OK; }
  ~ID3D11Texture2D() { if (on_destroy) on_destroy(); }
};
using IDXGIResource = ID3D11Texture2D;
using ID3D11ShaderResourceView = ID3D11Texture2D;
using ID3D11ComputeShader = ID3D11Texture2D;
using ID3D11Buffer = ID3D11Texture2D;
using ID3D11UnorderedAccessView = ID3D11Texture2D;

namespace winrt {
template <typename T> class com_ptr {
 public:
  com_ptr() = default;
  com_ptr(std::nullptr_t) {}
  explicit com_ptr(T* value) : value_(value) { if (value_) value_->AddRef(); }
  com_ptr(const com_ptr& other) : com_ptr(other.value_) {}
  com_ptr(com_ptr&& other) noexcept : value_(std::exchange(other.value_, nullptr)) {}
  ~com_ptr() { if (value_) value_->Release(); }
  com_ptr& operator=(com_ptr other) noexcept {
    std::swap(value_, other.value_); return *this;
  }
  explicit operator bool() const { return value_ != nullptr; }
  T* get() const { return value_; }
  T* operator->() const { return value_; }
  T** put() { *this = nullptr; return &value_; }
  template <typename U> com_ptr<U> try_as() const {
    return com_ptr<U>(static_cast<U*>(value_));
  }
 private:
  T* value_ = nullptr;
};
}

struct ID3D11Device {
  bool fail = false;
  int allocations = 0;
  int CreateTexture2D(const D3D11_TEXTURE2D_DESC* desc, void*,
    ID3D11Texture2D** out) {
    if (fail) { *out = nullptr; return E_FAIL; }
    ++allocations;
    *out = new ID3D11Texture2D(*desc);
    return S_OK;
  }
};
struct ID3D11DeviceContext {
  std::vector<uint32_t> mapped;
  void CopyResource(ID3D11Texture2D* to, ID3D11Texture2D* from) {
    if (!to || !from) throw std::runtime_error("Copy used a null texture");
    to->pixel = from->pixel;
  }
  void CopySubresourceRegion(ID3D11Texture2D* to, UINT, UINT, UINT, UINT,
    ID3D11Texture2D* from, UINT, D3D11_BOX*) { CopyResource(to, from); }
  void Flush() {}
  int Map(ID3D11Texture2D* texture, UINT, UINT, UINT,
    D3D11_MAPPED_SUBRESOURCE* out) {
    if (!texture) throw std::runtime_error("Map used a null texture");
    mapped.assign(texture->desc.Width * texture->desc.Height, texture->pixel);
    out->pData = mapped.data();
    out->RowPitch = texture->desc.Width * 4;
    return S_OK;
  }
  void Unmap(ID3D11Texture2D*, UINT) {}
};
namespace ABI::Windows::UI::Composition { struct IVisual {}; }
constexpr int kFlutterDesktopPixelFormatNone = 0;
struct FlutterDesktopGpuSurfaceDescriptor {
  size_t struct_size = 0;
  HANDLE handle = nullptr;
  size_t width = 0, height = 0, visible_width = 0, visible_height = 0;
  int format = 0;
  void* release_context = nullptr;
  void (*release_callback)(void*) = nullptr;
};
struct FlutterDesktopPixelBuffer {
  const uint8_t* buffer = nullptr;
  size_t width = 0, height = 0;
  void* release_context = nullptr;
  void (*release_callback)(void*) = nullptr;
};
inline void RGBA_to_BGRA(uint32_t* to, const uint32_t* from, size_t height,
  size_t pitch, size_t width) {
  // Color conversion is unchanged by trim; this double copies row payloads.
  for (size_t y = 0; y < height; ++y) {
    std::copy_n(from + y * pitch, width, to + y * width);
  }
}

#include "delayed_texture_trim_test_cases.h"
#include "custom_platform_view/async_resource_build.h"
#include "custom_platform_view/frame_compare_gate.h"
#include "custom_platform_view/shared_texture_surface_pool.h"
#include "custom_platform_view/surface_pool_slot.h"

namespace flutter_inappwebview_plugin {
struct Size { size_t width; size_t height; };
struct GraphicsContext {
  mutable ID3D11Device device;
  mutable ID3D11DeviceContext context;
  mutable std::mutex context_mutex;
  test::delayed_texture_trim_test::TimerQueue timers;
  ID3D11Device* d3d_device() const { return &device; }
  ID3D11DeviceContext* d3d_device_context() const { return &context; }
  std::mutex& device_context_mutex() const { return context_mutex; }
};

// Only capture-session creation/closing is mocked. The source methods for
// Start, SetCaptureSuspended, Stop and ScheduleHiddenTrim are injected below.
class TextureBridge {
 public:
  TextureBridge(GraphicsContext* context, ABI::Windows::UI::Composition::IVisual*)
    : graphics_context_(context), hidden_trim_(context->timers.schedule(),
        context->timers.cancel(), context->timers.clock()) {}
  virtual ~TextureBridge() { Stop(); }
  bool Start();
  void Stop();
  void SetCaptureSuspended(bool suspended);
  bool is_running_ = false, capture_suspended_ = false, capture_item_ = true;
  bool capture_open = false, fail_capture = false;
  int capture_starts = 0;
  const GraphicsContext* graphics_context_;
  std::mutex mutex_;
  winrt::com_ptr<ID3D11Texture2D> last_frame_;
  virtual void StopInternal();
  virtual void OnCaptureSuspended() {}
  virtual bool TrimHiddenResources(std::vector<winrt::com_ptr<ID3D11Texture2D>>&);
  virtual bool AcceptFrame(const winrt::com_ptr<ID3D11Texture2D>&) { return true; }
  bool StartCapture() { ++capture_starts; return capture_open = !fail_capture; }
  void StopCapture() { capture_open = false; }
  void ScheduleHiddenTrim();
  static constexpr UINT kPixelFormat = DXGI_FORMAT_B8G8R8A8_UNORM;
  DelayedTextureTrim hidden_trim_;
};
}
