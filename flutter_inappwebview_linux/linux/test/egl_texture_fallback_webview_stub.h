#ifndef FLUTTER_INAPPWEBVIEW_LINUX_EGL_TEXTURE_FALLBACK_WEBVIEW_STUB_H_
#define FLUTTER_INAPPWEBVIEW_LINUX_EGL_TEXTURE_FALLBACK_WEBVIEW_STUB_H_

#include <array>
#include <cstring>
#include <vector>

#include "../in_app_webview/dma_buf_import_policy.h"
#include "../in_app_webview/texture_webview_api.h"

namespace flutter_inappwebview_plugin {

class InAppWebView : public TextureWebViewApi {
 public:
  enum class FrameKind { kNoFrame, kDmaBuf, kShm };

  mutable int imports = 0;
  FrameKind frame_kind = FrameKind::kDmaBuf;
  bool has_pixels = true;
  bool skip_pixel_readback = false;
  bool inline_texture_consumer = false;
  bool force_no_egl_display = false;
  InlineDmaBufImportState import_state;
  uint32_t frame_width = 2;
  uint32_t frame_height = 2;
  std::vector<uint8_t> pixels = {
      255, 0, 0, 255, 0, 255, 0, 255,
      0, 0, 255, 255, 255, 255, 255, 255};

  void SetFrameSize(uint32_t width, uint32_t height, uint8_t seed = 0) {
    frame_width = width;
    frame_height = height;
    pixels.resize(static_cast<size_t>(width) * height * 4);
    for (size_t i = 0; i < pixels.size(); ++i) {
      pixels[i] = static_cast<uint8_t>(i * 13 + seed);
    }
  }

  void SetInlineFlutterTextureConsumer(bool enabled) {
    inline_texture_consumer = enabled;
  }
  void SetInlineFlutterEglImportEnabled(bool enabled) {
    import_state.SetEnabled(enabled);
  }
  bool ShouldAttemptFlutterEglImport() const override {
    return inline_texture_consumer && import_state.ShouldAttemptImport();
  }
  void SetSkipPixelReadback(bool skip) { skip_pixel_readback = skip; }
  void ReportFlutterEglImageImportFailure(bool frame_is_dma_buf) override {
    if (inline_texture_consumer && import_state.ReportFailedImport(frame_is_dma_buf)) {
      SetSkipPixelReadback(false);
    }
  }
  bool HasCurrentDmaBufBuffer() const override {
    return frame_kind == FrameKind::kDmaBuf;
  }
  void* ImportCurrentBufferToEglImage(void* target_display, uint32_t*, uint32_t*,
                                      bool* out_is_dma_buf_frame) const override {
    imports++;
    const bool eligible_dma_buf = IsEligibleDmaBufFrame(
        frame_kind != FrameKind::kNoFrame, HasCurrentDmaBufBuffer(),
        out_is_dma_buf_frame);
    if (!eligible_dma_buf || force_no_egl_display || target_display == nullptr) {
      return nullptr;
    }
    return nullptr;
  }
  size_t GetPixelBufferSize(uint32_t* width, uint32_t* height) const override {
    *width = has_pixels && frame_kind != FrameKind::kNoFrame ? frame_width : 0;
    *height = has_pixels && frame_kind != FrameKind::kNoFrame ? frame_height : 0;
    return has_pixels ? pixels.size() : 0;
  }
  bool CopyPixelBufferTo(uint8_t* dst, size_t size, uint32_t* width,
                         uint32_t* height) const override {
    if (!has_pixels || frame_kind == FrameKind::kNoFrame || size < pixels.size())
      return false;
    *width = frame_width;
    *height = frame_height;
    std::memcpy(dst, pixels.data(), pixels.size());
    return true;
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_LINUX_EGL_TEXTURE_FALLBACK_WEBVIEW_STUB_H_
