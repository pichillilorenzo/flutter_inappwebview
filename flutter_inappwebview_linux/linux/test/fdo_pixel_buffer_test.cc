#include "pixel_buffer_test_support.h"

namespace flutter_inappwebview_plugin {

class InAppWebView {
 public:
  void ReadPixelsFromEglImage(void*, uint32_t, uint32_t);
  void OnExportShmBuffer(wpe_fdo_shm_exported_buffer*);
  void TrimUnusedPixelBuffers();
  size_t GetPixelBufferSize(uint32_t*, uint32_t*) const;
  bool CopyPixelBufferTo(uint8_t*, size_t, uint32_t*, uint32_t*) const;

  void* egl_display_ = this;
  unsigned int readback_texture_ = 0;
  unsigned int fbo_ = 0;
  wpe_view_backend_exportable_fdo* exportable_ = nullptr;
  std::function<void()> on_frame_available_;

  // Keep the ring layout and synchronization fields identical to production.
#include "pixel_buffer_members_under_test.inc"
};

#include "fdo_pixels_under_test.inc"

}  // namespace flutter_inappwebview_plugin

using flutter_inappwebview_plugin::InAppWebView;

bool SubmitFrame(InAppWebView& view, bool shm, uint32_t width, uint32_t height,
                 uint8_t seed) {
  const size_t write_index = view.write_buffer_index_.load();
  const size_t previous_read = view.read_buffer_index_.load();
  const auto previous_frame = view.pixel_buffers_[previous_read].data;
  const uintptr_t address_before = reinterpret_cast<uintptr_t>(
      view.pixel_buffers_[write_index].data.data());
  Frame frame(width, height, seed);
  if (shm) {
    const auto source_before = frame.bgra;
    wl_shm_buffer source{&frame};
    wpe_fdo_shm_exported_buffer exported{&source};
    wpe_view_backend_exportable_fdo backend;
    size_t notifications = 0;
    view.exportable_ = &backend;
    view.on_frame_available_ = [&] {
      assert(exported.released && backend.completed == 1);
      ++notifications;
    };
    view.OnExportShmBuffer(&exported);
    assert(source.ended && exported.released);
    assert(backend.completed == 1 && notifications == 1);
    assert(frame.bgra == source_before);
    view.exportable_ = nullptr;
    view.on_frame_available_ = nullptr;
  } else {
    view.ReadPixelsFromEglImage(&frame, width, height);
    bound_frame = nullptr;
  }

  assert(view.read_buffer_index_.load() == write_index);
  assert(view.write_buffer_index_.load() == (write_index + 1) % view.kNumBuffers);
  assert(view.pixel_buffers_[previous_read].data == previous_frame);
  uint32_t actual_width = 0;
  uint32_t actual_height = 0;
  assert(view.GetPixelBufferSize(&actual_width, &actual_height) == frame.rgba.size());
  assert(actual_width == width && actual_height == height);
  std::vector<uint8_t> copied(frame.rgba.size());
  assert(view.CopyPixelBufferTo(copied.data(), copied.size(), &actual_width, &actual_height));
  assert(actual_width == width && actual_height == height);
  assert(copied == frame.rgba);
  assert(!view.CopyPixelBufferTo(copied.data(), copied.size() - 1, nullptr, nullptr));
  return address_before != reinterpret_cast<uintptr_t>(
      view.pixel_buffers_[write_index].data.data());
}

size_t TotalCapacity(const InAppWebView& view) {
  size_t capacity = 0;
  for (const auto& buffer : view.pixel_buffers_) capacity += buffer.data.capacity();
  return capacity;
}

void CheckProducer(bool shm) {
  InAppWebView view;
  uint8_t seed = 0;
  auto frames = [&](uint32_t width, uint32_t height, size_t count) {
    size_t reallocations = 0;
    for (size_t i = 0; i < count; ++i) {
      reallocations += SubmitFrame(view, shm, width, height, ++seed);
    }
    return reallocations;
  };

  assert(frames(4096, 2048, view.kNumBuffers) == view.kNumBuffers);
  const size_t large_capacity = TotalCapacity(view);
  assert(frames(3072, 2048, view.kNumBuffers) == 0);
  assert(TotalCapacity(view) == large_capacity);

  const size_t quarter_reallocations = frames(2048, 1024, view.kNumBuffers);
  const size_t quarter_capacity = TotalCapacity(view);
  std::printf("%s large=%zu moderate=%zu quarter=%zu quarter_reallocations=%zu\n",
              shm ? "SHM" : "EGL", large_capacity, large_capacity,
              quarter_capacity, quarter_reallocations);
  std::fflush(stdout);
  assert(quarter_reallocations == view.kNumBuffers);
  assert(quarter_capacity < large_capacity);
  for (const auto& buffer : view.pixel_buffers_) {
    assert(buffer.data.capacity() < large_capacity / view.kNumBuffers);
  }

  // Odd rows with Wayland padding exercise the conversion's scalar tail.
  assert(frames(511, 256, view.kNumBuffers) == view.kNumBuffers);
  const size_t small_capacity = TotalCapacity(view);
  assert(small_capacity < quarter_capacity);
  const size_t stable_reallocations = frames(511, 256, view.kNumBuffers * 10);
  assert(stable_reallocations == 0 && TotalCapacity(view) == small_capacity);
  assert(frames(1024, 512, view.kNumBuffers) == view.kNumBuffers);
  assert(frames(1024, 512, view.kNumBuffers * 2) == 0);
  std::printf("%s small=%zu stable_frames=%zu stable_reallocations=%zu; pixels, "
              "ring, regrowth and SHM ownership passed\n",
              shm ? "SHM" : "EGL", small_capacity, view.kNumBuffers * 10,
              stable_reallocations);
}

int main(int argc, char** argv) {
  const std::string producer = argc > 1 ? argv[1] : "both";
  if (producer != "shm") CheckProducer(false);
  if (producer != "egl") CheckProducer(true);
}
