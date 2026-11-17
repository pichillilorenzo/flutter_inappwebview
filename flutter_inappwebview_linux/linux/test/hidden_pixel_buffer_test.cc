#include "pixel_buffer_test_support.h"
#include "../in_app_webview/dma_buf_import_policy.h"
#include "../in_app_webview/pending_webkit_javascript_calls.h"

#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <future>
#include <map>
#include <memory>
#include <new>
#include <thread>

// Fail the actual std::vector allocation, not a replacement implementation of
// the production buffer allocator. Also observe where retired storage is freed.
thread_local size_t fail_allocation_size = 0;
thread_local bool fail_next_allocation = false;
void (*observe_delete)(void*) = nullptr;
void* operator new(size_t size) {
  if (fail_next_allocation || (fail_allocation_size && size == fail_allocation_size)) {
    fail_next_allocation = false;
    fail_allocation_size = 0;
    throw std::bad_alloc();
  }
  if (void* data = std::malloc(size ? size : 1)) return data;
  throw std::bad_alloc();
}
void* operator new(size_t size, const std::nothrow_t&) noexcept {
  try { return ::operator new(size); } catch (const std::bad_alloc&) { return nullptr; }
}
void operator delete(void* data) noexcept {
  if (observe_delete) observe_delete(data);
  std::free(data);
}
void operator delete(void* data, size_t) noexcept { ::operator delete(data); }
void operator delete(void* data, const std::nothrow_t&) noexcept { ::operator delete(data); }

using guint = unsigned int;
using gulong = unsigned long;
using gsize = size_t;
using gpointer = void*;
using gboolean = int;
constexpr gboolean TRUE = 1;
constexpr gboolean G_SOURCE_REMOVE = 0;
constexpr int G_PRIORITY_DEFAULT = 0;
struct GError {};
void g_clear_error(GError** error) { delete *error; *error = nullptr; }
void* g_realloc(void* data, size_t size) { return std::realloc(data, size); }

// Removing a source removes it from the scheduler. A test can retain a source
// snapshot to invoke an already-stale callback adversarially, without using
// freed callback data. Real GLib will not dispatch a removed source.
struct Source {
  uint64_t due;
  gboolean (*callback)(gpointer);
  gpointer data;
  void (*destroy)(gpointer);
  ~Source() { destroy(data); }
};
std::map<guint, std::shared_ptr<Source>> sources;
uint64_t now_ms = 0;
guint next_source = 1;
guint g_timeout_add_full(int, guint delay, gboolean (*callback)(gpointer),
                         gpointer data, void (*destroy)(gpointer)) {
  const guint id = next_source++;
  sources.emplace(id, std::shared_ptr<Source>(new Source{now_ms + delay, callback, data, destroy}));
  return id;
}
gboolean g_source_remove(guint id) { return sources.erase(id) == 1; }
void AdvanceTime(uint64_t delta) {
  now_ms += delta;
  for (auto it = sources.begin(); it != sources.end();) {
    if (it->second->due > now_ms) { ++it; continue; }
    auto source = it->second;
    it = sources.erase(it);
    assert(source->callback(source->data) == G_SOURCE_REMOVE);
  }
}

struct GBytes { const uint8_t* data; size_t size; };
std::function<void()> before_native_pixels;
const void* g_bytes_get_data(GBytes* bytes, gsize* size) {
  if (before_native_pixels) before_native_pixels();
  *size = bytes->size;
  return bytes->data;
}

enum class Producer { kShm, kPixels, kEgl, kDmaBuf };
struct WPEBuffer {
  Frame* frame;
  Producer kind;
  unsigned int releases = 0;
  std::vector<uint8_t> packed_bgra;
  GBytes bytes;
  WPEBuffer(Frame* f, Producer k) : frame(f), kind(k), bytes{f->bgra.data(), f->bgra.size()} {
    if (kind == Producer::kPixels) {
      packed_bgra = frame->rgba;
      for (size_t i = 0; i < packed_bgra.size(); i += 4)
        std::swap(packed_bgra[i], packed_bgra[i + 2]);
      bytes = {packed_bgra.data(), packed_bgra.size()};
    }
  }
};
using WPEBufferSHM = WPEBuffer;
enum WPEPixelFormat { WPE_PIXEL_FORMAT_ARGB8888 };
struct WPEView { bool visible = true; bool mapped = true; size_t releases = 0; };
struct WPEToplevel { int width = 800; int height = 600; };
bool WPE_IS_BUFFER_DMA_BUF(WPEBuffer* b) { return b->kind == Producer::kDmaBuf; }
bool WPE_IS_BUFFER_SHM(WPEBuffer* b) { return b->kind == Producer::kShm; }
bool WPE_IS_BUFFER(WPEBuffer* b) { return b != nullptr; }
WPEBufferSHM* WPE_BUFFER_SHM(WPEBuffer* b) { return b; }
uint32_t wpe_buffer_get_width(WPEBuffer* b) { return b->frame->width; }
uint32_t wpe_buffer_get_height(WPEBuffer* b) { return b->frame->height; }
GBytes* wpe_buffer_shm_get_data(WPEBufferSHM* b) { return &b->bytes; }
guint wpe_buffer_shm_get_stride(WPEBufferSHM* b) { return b->frame->stride; }
WPEPixelFormat wpe_buffer_shm_get_format(WPEBufferSHM*) { return WPE_PIXEL_FORMAT_ARGB8888; }
GBytes* wpe_buffer_import_to_pixels(WPEBuffer* b, GError**) { return &b->bytes; }
void* wpe_buffer_import_to_egl_image(WPEBuffer* b, GError**) { return b->frame; }
void wpe_view_buffer_released(WPEView* view, WPEBuffer* buffer) {
  assert(buffer->releases == 0);
  ++buffer->releases;
  ++view->releases;
}
void wpe_view_set_visible(WPEView* view, bool visible) { view->visible = visible; }
void wpe_view_map(WPEView* view) { view->mapped = true; }
void wpe_view_unmap(WPEView* view) { view->mapped = false; }
void wpe_toplevel_resize(WPEToplevel* top, int width, int height) {
  top->width = width; top->height = height;
}

struct wpe_view_backend {
  uint32_t activity = 3;
  int width = 800;
  int height = 600;
};
constexpr uint32_t wpe_view_activity_state_visible = 1;
constexpr uint32_t wpe_view_activity_state_in_window = 2;
void wpe_view_backend_add_activity_state(wpe_view_backend* b, uint32_t flag) { b->activity |= flag; }
void wpe_view_backend_remove_activity_state(wpe_view_backend* b, uint32_t flag) { b->activity &= ~flag; }
void wpe_view_backend_dispatch_set_size(wpe_view_backend* b, int width, int height) {
  b->width = width; b->height = height;
}
struct wpe_fdo_egl_exported_image { Frame* frame; unsigned int releases = 0; };
uint32_t wpe_fdo_egl_exported_image_get_width(wpe_fdo_egl_exported_image* i) { return i->frame->width; }
uint32_t wpe_fdo_egl_exported_image_get_height(wpe_fdo_egl_exported_image* i) { return i->frame->height; }
EGLImageKHR wpe_fdo_egl_exported_image_get_egl_image(wpe_fdo_egl_exported_image* i) { return i->frame; }
void wpe_view_backend_exportable_fdo_egl_dispatch_release_exported_image(
    wpe_view_backend_exportable_fdo*, wpe_fdo_egl_exported_image* image) {
  assert(image->releases == 0);
  ++image->releases;
}

namespace flutter_inappwebview_plugin {
void debugLog(const char*) {}
class InAppWebView {
 public:
  ~InAppWebView();
  void setVisible(bool);
  void setSize(int, int);
  void ScheduleHiddenPixelBufferTrim();
  void CancelHiddenPixelBufferTrim();
  void TrimUnusedPixelBuffers();
  void ReadPixelsFromEglImage(void*, uint32_t, uint32_t);
  size_t GetPixelBufferSize(uint32_t*, uint32_t*) const;
  bool CopyPixelBufferTo(uint8_t*, size_t, uint32_t*, uint32_t*) const;
  void* GetCurrentEglImage(uint32_t*, uint32_t*) const;
  void HideAllPopups() {}
  void CancelHostBoundPopups() {}
#ifdef HAVE_WPE_PLATFORM
  void OnWpePlatformBufferRendered(WPEBuffer*);
  WPEView* wpe_view_ = nullptr;
  WPEToplevel* wpe_toplevel_ = nullptr;
  WPEBuffer* current_buffer_ = nullptr;
  void* current_egl_image_ = nullptr;
  uint32_t current_buffer_width_ = 0;
  uint32_t current_buffer_height_ = 0;
  mutable std::mutex wpe_buffer_mutex_;
#else
  void OnExportDmaBuf(wpe_fdo_egl_exported_image*);
  void OnExportShmBuffer(wpe_fdo_shm_exported_buffer*);
  wpe_view_backend* wpe_backend_ = nullptr;
  wpe_view_backend_exportable_fdo* exportable_ = nullptr;
  wpe_fdo_egl_exported_image* exported_image_ = nullptr;
  mutable std::mutex exported_image_mutex_;
#endif
  void* egl_display_ = this;
  unsigned int readback_texture_ = 0;
  unsigned int fbo_ = 0;
  std::atomic<bool> skip_pixel_readback_{false};
  std::atomic<bool> inline_flutter_texture_consumer_{false};
  std::atomic<bool> is_disposing_{false};
  std::shared_ptr<PendingWebKitJavaScriptCalls> pending_java_script_calls_ =
      std::make_shared<PendingWebKitJavaScriptCalls>();
  // Production teardown also clears console subscriptions in combined builds.
  bool has_console_message_listener_ = false;
  bool is_visible_ = true;
  int width_ = 800;
  int height_ = 600;
  std::function<void()> on_frame_available_;
  std::shared_ptr<int> lifetime_token_ = std::make_shared<int>(0);
#include "pixel_buffer_members_under_test.inc"
#include "hidden_pixel_timer_members_under_test.inc"
};
using WebViewType = InAppWebView;
#include "hidden_pixel_methods_under_test.inc"
}  // namespace flutter_inappwebview_plugin

using flutter_inappwebview_plugin::InAppWebView;
struct FlPixelBufferTexture {};
using InAppWebViewTexture = struct _InAppWebViewTexture;
#define INAPPWEBVIEW_TEXTURE(texture) reinterpret_cast<InAppWebViewTexture*>(texture)
#include "pixel_texture_under_test.inc"

struct Fixture {
  WPEView native_view;
  WPEToplevel top;
  wpe_view_backend legacy_view;
  wpe_view_backend_exportable_fdo exportable;
  std::vector<std::unique_ptr<Frame>> frames;
  std::vector<std::unique_ptr<WPEBuffer>> buffers;
  std::vector<std::unique_ptr<wpe_fdo_egl_exported_image>> images;
  size_t notifications = 0;
  std::unique_ptr<InAppWebView> view = std::make_unique<InAppWebView>();

  Fixture() {
#ifdef HAVE_WPE_PLATFORM
    view->wpe_view_ = &native_view;
    view->wpe_toplevel_ = &top;
#else
    view->wpe_backend_ = &legacy_view;
    view->exportable_ = &exportable;
#endif
  }
  const Frame& Submit(Producer producer, uint32_t width, uint32_t height,
                      uint8_t seed, bool fail = false) {
    frames.push_back(std::make_unique<Frame>(width, height, seed));
    Frame* frame = frames.back().get();
    const auto original = frame->bgra;
    const size_t before_notifications = notifications;
#ifdef HAVE_WPE_PLATFORM
    buffers.push_back(std::make_unique<WPEBuffer>(frame, producer));
    view->on_frame_available_ = [&] { ++notifications; };
    if (fail) fail_allocation_size = frame->rgba.size();
    view->OnWpePlatformBufferRendered(buffers.back().get());
    assert(notifications == before_notifications + (fail ? 0 : 1));
#else
    const size_t before_complete = exportable.completed;
    view->on_frame_available_ = [&, producer, before_complete] {
      // The callback ordering differs intentionally between the two exports.
      assert(exportable.completed == before_complete + (producer == Producer::kShm ? 1 : 0));
      ++notifications;
    };
    if (producer == Producer::kShm) {
      wl_shm_buffer shm{frame};
      wpe_fdo_shm_exported_buffer buffer{&shm};
      if (fail) fail_allocation_size = frame->rgba.size();
      view->OnExportShmBuffer(&buffer);
      assert(shm.ended && !shm.accessing && buffer.released);
    } else {
      images.push_back(std::make_unique<wpe_fdo_egl_exported_image>(wpe_fdo_egl_exported_image{frame}));
      if (fail) fail_allocation_size = frame->rgba.size();
      view->OnExportDmaBuf(images.back().get());
      assert(bound_texture == 0 && bound_framebuffer == 0);
    }
    assert(exportable.completed == before_complete + 1);
    assert(notifications == before_notifications + 1);
#endif
    assert(!fail || fail_allocation_size == 0);
    assert(frame->bgra == original);
    view->on_frame_available_ = nullptr;
    return *frame;
  }
  void Prime(Producer producer) {
    view->setSize(512, 256);
    for (uint8_t i = 0; i < 3; ++i) Submit(producer, 512, 256, i + 1);
  }
};

size_t Capacity(const InAppWebView& view) {
  size_t total = 0;
  for (const auto& buffer : view.pixel_buffers_) total += buffer.data.capacity();
  return total;
}
void CheckOnlyPublishedFrame(const InAppWebView& view) {
  const size_t read = view.read_buffer_index_.load();
  for (size_t i = 0; i < view.kNumBuffers; ++i) {
    if (i == read) continue;
    assert(view.pixel_buffers_[i].data.capacity() == 0);
    assert(view.pixel_buffers_[i].width == 0 && view.pixel_buffers_[i].height == 0);
  }
}
void CheckFrame(const InAppWebView& view, const Frame& frame) {
  uint32_t width = 0, height = 0;
  assert(view.GetPixelBufferSize(&width, &height) == frame.rgba.size());
  assert(width == frame.width && height == frame.height);
  std::vector<uint8_t> copy(frame.rgba.size());
  assert(view.CopyPixelBufferTo(copy.data(), copy.size(), &width, &height));
  assert(copy == frame.rgba && width == frame.width && height == frame.height);
}
const uint8_t* CopyTexture(InAppWebViewTexture& texture, const Frame& frame) {
  const uint8_t* result = nullptr;
  uint32_t width = 0, height = 0;
  assert(inappwebview_texture_copy_pixels(&texture.parent_instance, &result, &width, &height, nullptr));
  assert(width == frame.width && height == frame.height);
  assert(std::memcmp(result, frame.rgba.data(), frame.rgba.size()) == 0);
  return result;
}

void CheckDelayResumeAndLateFrames(Producer producer) {
  Fixture fixture;
  auto& view = *fixture.view;
  fixture.Prime(producer);
  const auto& first_frame = *fixture.frames.back();
  const size_t warm_capacity = Capacity(view);
  const size_t front = view.read_buffer_index_.load();
  const auto* front_address = view.pixel_buffers_[front].data.data();
  InAppWebViewTexture texture{};
  texture.webview = &view;
  const uint8_t* staging = CopyTexture(texture, first_frame);

  view.setVisible(false);
  const guint initial_source = view.hidden_pixel_buffer_trim_source_;
  auto stale = sources.at(initial_source);
  view.setSize(901, 503);
#ifdef HAVE_WPE_PLATFORM
  assert(!fixture.native_view.visible && !fixture.native_view.mapped);
  assert(fixture.top.width == 901 && fixture.top.height == 503);
#else
  assert(fixture.legacy_view.activity == 0);
  assert(fixture.legacy_view.width == 901 && fixture.legacy_view.height == 503);
#endif
  CheckFrame(view, first_frame);
  AdvanceTime(29999);
  view.setVisible(false);
  assert(view.hidden_pixel_buffer_trim_source_ == initial_source);
  assert(Capacity(view) == warm_capacity);
  view.setVisible(true);
  assert(sources.empty() && !view.trim_unused_pixel_buffers_.load());
  view.setVisible(false);
  const guint current_source = view.hidden_pixel_buffer_trim_source_;
  assert(stale->callback(stale->data) == G_SOURCE_REMOVE);
  assert(view.hidden_pixel_buffer_trim_source_ == current_source);
  AdvanceTime(29999);
  assert(Capacity(view) == warm_capacity);
  AdvanceTime(1);
  assert(sources.empty() && view.hidden_pixel_buffer_trim_source_ == 0);
  CheckOnlyPublishedFrame(view);
  assert(view.pixel_buffers_[front].data.data() == front_address);
  assert(Capacity(view) < warm_capacity);
  CheckFrame(view, first_frame);
  assert(texture.staging_buffer == staging);
  assert(std::memcmp(staging, first_frame.rgba.data(), first_frame.rgba.size()) == 0);
  assert(CopyTexture(texture, first_frame) == staging);

  // A late export after unmapping must not repopulate the spare ring forever.
  const auto& late = fixture.Submit(producer, 511, 255, 9);
  CheckOnlyPublishedFrame(view);
  CheckFrame(view, late);
  view.setVisible(false);
  assert(sources.empty());

  view.setSize(73, 37);
  CheckFrame(view, late);  // Last frame stays available until its replacement.
  const size_t hidden_capacity = Capacity(view);
  view.setVisible(true);
  assert(Capacity(view) == hidden_capacity);
  assert(!view.trim_unused_pixel_buffers_.load());
  const auto& resumed = fixture.Submit(producer, 73, 37, 12);
  CheckFrame(view, resumed);
  CopyTexture(texture, resumed);
  for (int i = 0; i < 3; ++i) fixture.Submit(producer, 73, 37, 20 + i);
  for (const auto& buffer : view.pixel_buffers_) assert(!buffer.data.empty());
  std::free(texture.staging_buffer);
}

void CheckAllocationFailure(Producer producer) {
  Fixture fixture;
  auto& view = *fixture.view;
  fixture.Prime(producer);
  const auto& previous = *fixture.frames.back();
  view.setVisible(false);
  AdvanceTime(30000);
  const auto read = view.read_buffer_index_.load();
  const auto* address = view.pixel_buffers_[read].data.data();
  fixture.Submit(producer, 73, 37, 42, true);
  assert(view.read_buffer_index_.load() == read);
  assert(view.pixel_buffers_[read].data.data() == address);
  CheckOnlyPublishedFrame(view);
  CheckFrame(view, previous);
  view.setSize(73, 37);
  view.setVisible(true);
  CheckFrame(view, fixture.Submit(producer, 73, 37, 43));
}

void CheckNativeImageLease(bool inline_consumer) {
  Fixture fixture;
  auto& view = *fixture.view;
  view.skip_pixel_readback_.store(true);
  view.inline_flutter_texture_consumer_.store(inline_consumer);
  fixture.Submit(Producer::kDmaBuf, 512, 256, 1);
  uint32_t width = 0, height = 0;
  void* image = view.GetCurrentEglImage(&width, &height);
#ifdef HAVE_WPE_PLATFORM
  auto* lease = view.current_buffer_;
  if (inline_consumer) assert(image == nullptr);
  else assert(image != nullptr && width == 512 && height == 256);
#else
  auto* lease = view.exported_image_;
  assert(image != nullptr && width == 512 && height == 256);
#endif
  view.setVisible(false);
  AdvanceTime(30000);
  view.setSize(71, 35);
  assert(lease->releases == 0);
  assert(view.GetCurrentEglImage(nullptr, nullptr) == image);
  view.setVisible(true);
  assert(lease->releases == 0);
  fixture.Submit(Producer::kDmaBuf, 71, 35, 2);
  assert(lease->releases == 1);
  assert(Capacity(view) == 0);
}

void CheckDisposeAndTimerAllocationFailure(Producer producer) {
  Fixture fixture;
  fixture.Prime(producer);
  auto& view = *fixture.view;
  const size_t warm = Capacity(view);
  fail_next_allocation = true;
  view.setVisible(false);
  assert(!fail_next_allocation && view.hidden_pixel_buffer_trim_source_ == 0);
  assert(Capacity(view) == warm && sources.empty());
  view.setVisible(true);
  view.setVisible(false);
  auto pending = sources.at(view.hidden_pixel_buffer_trim_source_);
  InAppWebViewTexture texture{};
  texture.webview = &view;
  const auto& frame = *fixture.frames.back();
  const uint8_t* leased_staging = CopyTexture(texture, frame);
  fixture.view.reset();
  assert(sources.empty());
  assert(pending->callback(pending->data) == G_SOURCE_REMOVE);
  assert(std::memcmp(leased_staging, frame.rgba.data(), frame.rgba.size()) == 0);
  // A registrar must stop future copy_pixels calls before destroying the view;
  // an already-returned staging copy remains owned by the texture until finalization.
  texture.webview = nullptr;
  std::free(texture.staging_buffer);
}

void CheckClosingPeerPreservesVisibleConsumer(Producer producer) {
  Fixture closing;
  Fixture surviving;
  closing.Prime(producer);
  surviving.Prime(producer);
  auto& peer = *surviving.view;
  const auto& published = *surviving.frames.back();
  const size_t peer_capacity = Capacity(peer);
  const size_t peer_read = peer.read_buffer_index_.load();
  const auto* peer_pixels = peer.pixel_buffers_[peer_read].data.data();
  InAppWebViewTexture texture{};
  texture.webview = &peer;
  const auto* staging = CopyTexture(texture, published);

  closing.view->setVisible(false);
  auto late = sources.at(closing.view->hidden_pixel_buffer_trim_source_);
  AdvanceTime(30000);
  CheckOnlyPublishedFrame(*closing.view);
  assert(peer.is_visible_ && peer.hidden_pixel_buffer_trim_source_ == 0);
#ifdef HAVE_WPE_PLATFORM
  assert(surviving.native_view.visible && surviving.native_view.mapped);
#else
  assert(surviving.legacy_view.activity ==
      (wpe_view_activity_state_visible | wpe_view_activity_state_in_window));
#endif
  assert(!peer.trim_unused_pixel_buffers_.load());
  assert(Capacity(peer) == peer_capacity);
  assert(peer.pixel_buffers_[peer_read].data.data() == peer_pixels);
  CheckFrame(peer, published);

  closing.view.reset();
  // A callback retained before disposal must reject the dead owner without
  // changing a live peer's frame, timer or texture's independent staging copy.
  assert(late->callback(late->data) == G_SOURCE_REMOVE);
  assert(CopyTexture(texture, published) == staging);
  assert(Capacity(peer) == peer_capacity);
  const size_t notifications = surviving.notifications;
  CheckFrame(peer, surviving.Submit(producer, 73, 37, 61));
  assert(surviving.notifications == notifications + 1);
  CopyTexture(texture, *surviving.frames.back());
  assert(sources.empty());
  std::free(texture.staging_buffer);
}

void CheckPeerTimerSurvivesResumeAndClose(Producer producer) {
  Fixture first;
  Fixture second;
  first.Prime(producer);
  second.Prime(producer);
  const auto& second_frame = *second.frames.back();
  const size_t second_capacity = Capacity(*second.view);
  first.view->setVisible(false);
  auto canceled = sources.at(first.view->hidden_pixel_buffer_trim_source_);
  second.view->setVisible(false);
  const guint peer_source = second.view->hidden_pixel_buffer_trim_source_;
  assert(sources.size() == 2);

  first.view->setVisible(true);
  assert(sources.size() == 1 && sources.count(peer_source) == 1);
#ifdef HAVE_WPE_PLATFORM
  assert(!second.native_view.visible && !second.native_view.mapped);
#else
  assert(second.legacy_view.activity == 0);
#endif
  assert(canceled->callback(canceled->data) == G_SOURCE_REMOVE);
  assert(second.view->hidden_pixel_buffer_trim_source_ == peer_source);
  assert(!second.view->trim_unused_pixel_buffers_.load());
  first.view->setVisible(false);
  auto disposed = sources.at(first.view->hidden_pixel_buffer_trim_source_);
  first.view.reset();  // Runs the real destructor's timer/lifetime prologue.
  assert(sources.size() == 1 && sources.count(peer_source) == 1);
  assert(disposed->callback(disposed->data) == G_SOURCE_REMOVE);
  assert(second.view->hidden_pixel_buffer_trim_source_ == peer_source);

  AdvanceTime(29999);
  assert(Capacity(*second.view) == second_capacity);
  AdvanceTime(1);
  assert(sources.empty() && second.view->hidden_pixel_buffer_trim_source_ == 0);
  assert(second.view->trim_unused_pixel_buffers_.load());
  CheckOnlyPublishedFrame(*second.view);
  CheckFrame(*second.view, second_frame);
  second.view->setVisible(true);
  CheckFrame(*second.view, second.Submit(producer, 71, 35, 62));
  assert(!second.view->trim_unused_pixel_buffers_.load());
}

InAppWebView* deallocation_view = nullptr;
std::array<void*, 3> retired_addresses{};
size_t observed_retirements = 0;
void ObserveRetirement(void* address) {
  for (auto& expected : retired_addresses) {
    if (!expected || expected != address) continue;
    expected = nullptr;
    bool writer_available = false, raster_available = false;
    std::thread consumer([&] {
      writer_available = deallocation_view->pixel_buffer_write_mutex_.try_lock();
      if (writer_available) deallocation_view->pixel_buffer_write_mutex_.unlock();
      raster_available = deallocation_view->buffer_swap_mutex_.try_lock();
      if (raster_available) deallocation_view->buffer_swap_mutex_.unlock();
    });
    consumer.join();
    assert(writer_available && raster_available);
    ++observed_retirements;
  }
}
void CheckFreeOutsideRasterLock(Producer producer) {
  Fixture fixture;
  fixture.Prime(producer);
  auto& view = *fixture.view;
  const size_t read = view.read_buffer_index_.load();
  for (size_t i = 0; i < view.kNumBuffers; ++i)
    if (i != read) retired_addresses[i] = view.pixel_buffers_[i].data.data();
  deallocation_view = &view;
  observe_delete = ObserveRetirement;
  view.setVisible(false);
  AdvanceTime(30000);
  observe_delete = nullptr;
  assert(observed_retirements == 2);
  observed_retirements = 0;
  deallocation_view = nullptr;
}

void CheckActiveProducerAndConsumer(Producer producer) {
  Fixture fixture;
  fixture.Prime(producer);
  auto& view = *fixture.view;
  std::mutex gate_mutex;
  std::condition_variable gate;
  bool entered = false, resume = false;
  auto block_producer = [&] {
    std::unique_lock<std::mutex> lock(gate_mutex);
    entered = true;
    gate.notify_one();
    gate.wait(lock, [&] { return resume; });
  };
#ifdef HAVE_WPE_PLATFORM
  before_native_pixels = block_producer;
#else
  before_gl_read_pixels = block_producer;
#endif
  std::thread producer_thread([&] { fixture.Submit(producer, 73, 37, 24); });
  {
    std::unique_lock<std::mutex> lock(gate_mutex);
    gate.wait(lock, [&] { return entered; });
  }
  view.trim_unused_pixel_buffers_.store(true);
  auto trim = std::async(std::launch::async, [&] { view.TrimUnusedPixelBuffers(); });
  assert(trim.wait_for(std::chrono::milliseconds(10)) == std::future_status::timeout);
  {
    std::lock_guard<std::mutex> lock(gate_mutex);
    resume = true;
  }
  gate.notify_one();
  producer_thread.join();
  trim.get();
  before_native_pixels = nullptr;
  before_gl_read_pixels = nullptr;
  CheckOnlyPublishedFrame(view);
  CheckFrame(view, *fixture.frames.back());

  // A trim may wait for an active copy; it must retain that published vector.
  std::unique_lock<std::mutex> active_copy(view.buffer_swap_mutex_);
  const auto* published = view.pixel_buffers_[view.read_buffer_index_.load()].data.data();
  auto waiting_trim = std::async(std::launch::async, [&] { view.TrimUnusedPixelBuffers(); });
  assert(waiting_trim.wait_for(std::chrono::milliseconds(10)) == std::future_status::timeout);
  assert(published[3] == 255);
  active_copy.unlock();
  waiting_trim.get();
  assert(view.pixel_buffers_[view.read_buffer_index_.load()].data.data() == published);

  std::atomic<bool> stop{false};
  std::atomic<size_t> copies{0};
  std::thread consumer([&] {
    std::vector<uint8_t> pixels(512 * 256 * 4);
    while (!stop.load()) {
      uint32_t width = 0, height = 0;
      if (!view.CopyPixelBufferTo(pixels.data(), pixels.size(), &width, &height)) continue;
      const uint8_t seed = pixels[0];
      for (uint32_t y = 0; y < height; ++y) {
        for (uint32_t x = 0; x < width; ++x) {
          const size_t offset = (static_cast<size_t>(y) * width + x) * 4;
          assert(pixels[offset] == static_cast<uint8_t>(x + seed));
          assert(pixels[offset + 1] == static_cast<uint8_t>(y + seed));
          assert(pixels[offset + 2] == static_cast<uint8_t>(x + y + seed));
          assert(pixels[offset + 3] == 255);
        }
      }
      ++copies;
    }
  });
  while (copies.load() == 0) std::this_thread::yield();
  for (int i = 0; i < 40; ++i) fixture.Submit(producer, 71 + i % 3, 35 + i % 3, i);
  stop.store(true);
  consumer.join();
  CheckOnlyPublishedFrame(view);
  assert(copies.load() > 0);
}

int main() {
#ifdef HAVE_WPE_PLATFORM
  const std::array<Producer, 2> producers{Producer::kShm, Producer::kPixels};
  constexpr auto concurrent_producer = Producer::kShm;
  const char* backend = "WPEPlatform";
#else
  const std::array<Producer, 2> producers{Producer::kShm, Producer::kEgl};
  constexpr auto concurrent_producer = Producer::kEgl;
  const char* backend = "FDO";
#endif
  for (auto producer : producers) {
    CheckDelayResumeAndLateFrames(producer);
    CheckAllocationFailure(producer);
    CheckDisposeAndTimerAllocationFailure(producer);
    CheckClosingPeerPreservesVisibleConsumer(producer);
    CheckPeerTimerSurvivesResumeAndClose(producer);
    CheckFreeOutsideRasterLock(producer);
    assert(sources.empty());
  }
  CheckNativeImageLease(false);
  CheckNativeImageLease(true);
  CheckActiveProducerAndConsumer(concurrent_producer);
  {
    Fixture empty;
    empty.view->setVisible(false);
    AdvanceTime(30000);
    assert(Capacity(*empty.view) == 0);
    empty.view->setVisible(true);
    CheckFrame(*empty.view, empty.Submit(concurrent_producer, 73, 37, 5));
  }
  assert(sources.empty());
  std::printf("%s: delay/cancel/stale/dispose, last frame, resize/resume, allocation "
              "failure, late exports, native leases, two-view isolation and concurrent consumers passed\n", backend);
}
