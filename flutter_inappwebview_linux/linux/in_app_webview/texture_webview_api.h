#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_TEXTURE_WEBVIEW_API_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_TEXTURE_WEBVIEW_API_H_

#include <cstddef>
#include <cstdint>

namespace flutter_inappwebview_plugin {

// The small surface used by the Flutter GL texture. Keeping it independent of
// GTK/WPE lets the fallback test compile its producer stub on other hosts.
class TextureWebViewApi {
 public:
  virtual ~TextureWebViewApi() = default;
  virtual void* ImportCurrentBufferToEglImage(void* target_display,
                                               uint32_t* out_width,
                                               uint32_t* out_height,
                                               bool* out_is_dma_buf_frame) const = 0;
  virtual bool HasCurrentDmaBufBuffer() const = 0;
  virtual bool ShouldAttemptFlutterEglImport() const = 0;
  virtual void ReportFlutterEglImageImportFailure(
      bool current_frame_is_dma_buf) = 0;
  virtual size_t GetPixelBufferSize(uint32_t* out_width,
                                    uint32_t* out_height) const = 0;
  virtual bool CopyPixelBufferTo(uint8_t* dst, size_t dst_size,
                                 uint32_t* out_width,
                                 uint32_t* out_height) const = 0;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_TEXTURE_WEBVIEW_API_H_
