// Included after the extracted production definitions by test_hidden_texture_trim.py.
#include <thread>

namespace flutter_inappwebview_plugin {
TextureBridgeGpu::TextureBridgeGpu(GraphicsContext* context,
  ABI::Windows::UI::Composition::IVisual* visual) : TextureBridge(context, visual) {}
TextureBridgeFallback::TextureBridgeFallback(GraphicsContext* context,
  ABI::Windows::UI::Composition::IVisual* visual) : TextureBridge(context, visual) {}
void TextureBridgeGpu::TakeBuiltComparer() { comparer_build_.reset(); }
bool TextureBridgeGpu::FramesDiffer(ID3D11Texture2D* a, ID3D11Texture2D* b,
  uint32_t, uint32_t) { return a->pixel != b->pixel; }

namespace test {
using delayed_texture_trim_test::Require;

winrt::com_ptr<ID3D11Texture2D> Frame(UINT width, UINT height, uint32_t pixel) {
  D3D11_TEXTURE2D_DESC desc;
  desc.Width = width;
  desc.Height = height;
  winrt::com_ptr<ID3D11Texture2D> frame;
  *frame.put() = new ID3D11Texture2D(desc);
  frame->pixel = pixel;
  return frame;
}

bool MutexIsAvailable(std::mutex& mutex) {
  bool available = false;
  std::thread raster([&] {
    available = mutex.try_lock();
    if (available) mutex.unlock();
  });
  raster.join();
  return available;
}

void FireTrim(GraphicsContext& context) {
  context.timers.Advance(30000);
  context.timers.Fire(context.timers.last_id);
}

void Release(const FlutterDesktopGpuSurfaceDescriptor* descriptor) {
  Require(descriptor != nullptr, "Expected a published GPU descriptor");
  descriptor->release_callback(descriptor->release_context);
}
void Release(const FlutterDesktopPixelBuffer* buffer) {
  Require(buffer != nullptr, "Expected a retained pixel buffer");
  buffer->release_callback(buffer->release_context);
}

void GpuLeaseRetryAndAllocationFailure() {
  GraphicsContext context;
  TextureBridgeGpu bridge(&context, nullptr);
  Require(bridge.Start(), "GPU start failed");
  Require(bridge.AcceptFrame(Frame(4, 3, 10)), "First frame was not published");
  const auto* older = bridge.GetSurfaceDescriptor(4, 3);
  Require(bridge.AcceptFrame(Frame(4, 3, 20)), "Second frame was not published");
  const auto* latest = bridge.GetSurfaceDescriptor(4, 3);
  auto pool = bridge.surface_pool_;
  bridge.SetCaptureSuspended(true);
  FireTrim(context);
  Require(pool->surfaces[0].texture && pool->surfaces[1].texture,
    "Trim detached a surface that Flutter had not opened yet");
  Release(older);
  FireTrim(context);
  Require(!pool->surfaces[0].texture && pool->surfaces[1].texture,
    "A released spare was not detached on the delayed retry");
  Require(static_cast<ID3D11Texture2D*>(latest->handle)->pixel == 20,
    "Trim invalidated the last published descriptor");
  Release(latest);
  const auto retained_handle = pool->surfaces[1].shared_handle;
  bridge.SetCaptureSuspended(false);
  context.device.fail = true;
  Require(!bridge.AcceptFrame(Frame(4, 3, 30)), "Failed refill published a frame");
  const auto* preserved = bridge.GetSurfaceDescriptor(4, 3);
  Require(preserved && preserved->handle == retained_handle,
    "Failed refill lost the last valid frame");
  Release(preserved);
  context.device.fail = false;
  Require(bridge.AcceptFrame(Frame(4, 3, 30)), "Refill could not recover");
  Require(context.device.allocations == 3, "Refill recreated the published slot");
  const auto* resumed = bridge.GetSurfaceDescriptor(4, 3);
  Require(resumed && static_cast<ID3D11Texture2D*>(resumed->handle)->pixel == 30,
    "Resume did not publish its first new frame");
  Release(resumed);
}

void GpuShortHideHasNoReallocationAndLongHideDoesNotLockRaster() {
  GraphicsContext context;
  TextureBridgeGpu bridge(&context, nullptr);
  bridge.Start();
  bridge.AcceptFrame(Frame(4, 3, 1));
  bridge.SetCaptureSuspended(true);
  const auto short_timer = context.timers.last_id;
  context.timers.Advance(1000);
  bridge.SetCaptureSuspended(false);
  context.timers.Fire(short_timer);
  Require(bridge.AcceptFrame(Frame(4, 3, 2)), "Short resume did not publish");
  Require(context.device.allocations == 2, "Short tab switch reallocated textures");
  const auto pool = bridge.surface_pool_;
  bool released_outside_locks = false;
  const size_t spare = 1 - pool->published_surface;
  pool->surfaces[spare].texture->on_destroy = [&] {
    released_outside_locks = MutexIsAvailable(pool->mutex) &&
      MutexIsAvailable(bridge.mutex_);
  };
  bridge.SetCaptureSuspended(true);
  FireTrim(context);
  Require(released_outside_locks, "Final GPU Release blocked a raster mutex");
}

void GpuResizeAndDisposeWithOutstandingConsumers() {
  GraphicsContext context;
  auto bridge = std::make_unique<TextureBridgeGpu>(&context, nullptr);
  bridge->Start();
  bridge->AcceptFrame(Frame(8, 6, 123));
  const auto* old_frame = bridge->GetSurfaceDescriptor(8, 6);
  std::weak_ptr<TextureBridgeGpu::SurfacePool> old_pool = bridge->surface_pool_;
  bridge->SetCaptureSuspended(true);
  FireTrim(context);
  bridge->SetCaptureSuspended(false);
  Require(bridge->AcceptFrame(Frame(19, 17, 456)), "Resized resume did not publish");
  const auto* new_frame = bridge->GetSurfaceDescriptor(19, 17);
  Require(new_frame && new_frame->width == 19 && new_frame->height == 17,
    "Resume reused hidden dimensions");
  std::weak_ptr<TextureBridgeGpu::SurfacePool> new_pool = bridge->surface_pool_;
  bridge->SetCaptureSuspended(true);
  const auto pending = context.timers.last_id;
  bridge.reset();
  context.timers.Advance(60000);
  context.timers.Fire(pending);
  Require(!old_pool.expired() && !new_pool.expired(),
    "Dispose released a pool still retained by a FrameLease");
  Require(static_cast<ID3D11Texture2D*>(old_frame->handle)->pixel == 123 &&
    static_cast<ID3D11Texture2D*>(new_frame->handle)->pixel == 456,
    "Dispose changed pixels held by a consumer");
  Release(old_frame);
  Release(new_frame);
  Require(old_pool.expired() && new_pool.expired(),
    "Release callbacks did not release the disposed pools");
}

void GpuNoPublishedFrameCanDetachBothSlots() {
  GraphicsContext context;
  TextureBridgeGpu bridge(&context, nullptr);
  bridge.Start();
  Require(bridge.EnsureSurfacePool(4, 3), "Pool allocation failed");
  bridge.SetCaptureSuspended(true);
  FireTrim(context);
  Require(!bridge.surface_pool_->surfaces[0].texture &&
    !bridge.surface_pool_->surfaces[1].texture,
    "A never-published pool retained its unused slots");
  Require(!bridge.GetSurfaceDescriptor(4, 3), "An empty pool yielded a descriptor");
  bridge.SetCaptureSuspended(false);
  Require(bridge.AcceptFrame(Frame(4, 3, 99)), "Empty pool did not refill");
  Release(bridge.GetSurfaceDescriptor(4, 3));
}

void GpuPublishesFirstResumedFrameEvenWhenItsPixelsMatch() {
  GraphicsContext context;
  TextureBridgeGpu bridge(&context, nullptr);
  // The platform double compares pixel payloads; AcceptFrame and the gate are
  // production code. Real shader bytecode has its separate existing WARP test.
  bridge.compare_shader_ = Frame(1, 1, 0);
  bridge.Start();
  Require(bridge.AcceptFrame(Frame(4, 3, 7)), "Initial comparison frame failed");
  Require(!bridge.AcceptFrame(Frame(4, 3, 7)), "Identical active frame was redrawn");
  const auto old_handle = bridge.surface_pool_->surfaces[
    bridge.surface_pool_->published_surface].shared_handle;
  bridge.SetCaptureSuspended(true);
  FireTrim(context);
  bridge.fail_capture = true;
  bridge.SetCaptureSuspended(false);
  Require(!bridge.capture_open, "Test did not simulate capture restart failure");
  const auto* retained = bridge.GetSurfaceDescriptor(4, 3);
  Require(retained && retained->handle == old_handle,
    "A failed capture restart lost the retained frame");
  Release(retained);
  bridge.SetCaptureSuspended(true);
  bridge.fail_capture = false;
  bridge.SetCaptureSuspended(false);
  Require(bridge.AcceptFrame(Frame(4, 3, 7)),
    "First resumed frame was suppressed by an old comparison reference");
  Release(bridge.GetSurfaceDescriptor(4, 3));
}

void CpuStagingTrimPreservesConsumerAndRecoversAtCurrentSize() {
  GraphicsContext context;
  TextureBridgeFallback bridge(&context, nullptr);
  bridge.Start();
  bridge.last_frame_ = Frame(4, 3, 17);
  const auto* held = bridge.CopyPixelBuffer(4, 3);
  Require(held && held->width == 4, "Initial CPU readback failed");
  const auto pixels = held->buffer;
  bool released_outside_lock = false;
  bridge.staging_texture_->on_destroy = [&] {
    released_outside_lock = MutexIsAvailable(bridge.mutex_);
  };
  bridge.SetCaptureSuspended(true);
  FireTrim(context); // Consumer still holds buffer_mutex_ here.
  Require(!bridge.staging_texture_ && released_outside_lock,
    "CPU staging was retained or released under the raster lock");
  Require(held->buffer == pixels && *reinterpret_cast<const uint32_t*>(pixels) == 17,
    "Trim invalidated a pixel buffer still owned by Flutter");
  Release(held);
  Release(bridge.CopyPixelBuffer(4, 3)); // Hidden last frame remains reusable.
  bridge.SetCaptureSuspended(false);
  bridge.last_frame_ = Frame(2, 2, 29);
  context.device.fail = true;
  const auto* failed = bridge.CopyPixelBuffer(2, 2);
  Require(failed && failed->width == 4 && failed->buffer == pixels,
    "Failed staging allocation did not keep the previous CPU frame");
  Release(failed);
  context.device.fail = false;
  const auto* resumed = bridge.CopyPixelBuffer(2, 2);
  Require(resumed && resumed->width == 2 && resumed->height == 2 &&
    *reinterpret_cast<const uint32_t*>(resumed->buffer) == 29,
    "CPU resume did not use current dimensions/pixels");
  Require(bridge.staging_texture_size_.width == 2 &&
    bridge.staging_texture_size_.height == 2, "CPU staging retained old dimensions");
  Release(resumed);
}

void HiddenStartRepeatedHideAndStopUseProductionScheduling() {
  GraphicsContext context;
  TextureBridgeGpu bridge(&context, nullptr);
  bridge.SetCaptureSuspended(true);
  Require(context.timers.entries.empty(), "A stopped bridge scheduled trim");
  Require(bridge.Start(), "Hidden start failed");
  const auto timer = context.timers.last_id;
  Require(timer != 0 && !bridge.capture_open, "Hidden start opened capture");
  bridge.SetCaptureSuspended(true);
  Require(context.timers.last_id == timer, "Repeated hide reset the quiet interval");
  bridge.Stop();
  context.timers.Advance(60000);
  context.timers.Fire(timer);
  Require(context.timers.cancelled.size() == 1, "Stop did not cancel hidden trim");
  bridge.SetCaptureSuspended(false);
  Require(bridge.Start(), "Restart after hidden Stop failed");
  Require(bridge.capture_open, "Visible restart did not open capture");
}
}
}

int main() {
  using namespace flutter_inappwebview_plugin::test;
  try {
    GpuLeaseRetryAndAllocationFailure();
    GpuShortHideHasNoReallocationAndLongHideDoesNotLockRaster();
    GpuResizeAndDisposeWithOutstandingConsumers();
    GpuNoPublishedFrameCanDetachBothSlots();
    GpuPublishesFirstResumedFrameEvenWhenItsPixelsMatch();
    CpuStagingTrimPreservesConsumerAndRecoversAtCurrentSize();
    HiddenStartRepeatedHideAndStopUseProductionScheduling();
    std::cout << "7 production bridge lifecycle/ownership tests passed (platform doubles)\n";
    return 0;
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << "\n";
    return 1;
  }
}
