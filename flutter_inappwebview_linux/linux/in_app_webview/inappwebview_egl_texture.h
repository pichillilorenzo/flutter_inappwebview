#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_EGL_TEXTURE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_EGL_TEXTURE_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

/**
 * Zero-copy EGL Image texture for InAppWebView.
 *
 * This implementation provides maximum performance by directly using the
 * EGL image exported from WPE WebKit without any CPU readback.
 *
 * The key insight is that FlTextureGL::populate() receives the GL texture ID
 * that we've already bound to the EGL image - no pixel copy needed!
 *
 * Performance benefits:
 * - Zero GPU → CPU → GPU round-trip
 * - Direct DMA-BUF sharing between WPE WebKit and Flutter
 * - Minimal latency for large textures
 */

#define INAPPWEBVIEW_TYPE_EGL_TEXTURE (inappwebview_egl_texture_get_type())

G_DECLARE_FINAL_TYPE(InAppWebViewEGLTexture, inappwebview_egl_texture, INAPPWEBVIEW, EGL_TEXTURE,
                     FlTextureGL)

// Forward declaration
namespace flutter_inappwebview_plugin {
class InAppWebView;
using WebViewType = InAppWebView;
}  // namespace flutter_inappwebview_plugin

/**
 * Creates a new InAppWebViewEGLTexture.
 *
 * This texture implementation directly uses EGL images from WPE WebKit,
 * avoiding expensive pixel readback operations.
 *
 * @param webview The webview to get frames from.
 * @return A new InAppWebViewEGLTexture instance.
 */
InAppWebViewEGLTexture* inappwebview_egl_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview);

/**
 * Updates the texture with a new EGL image.
 *
 * Call this from the WPE export callback when a new frame is available.
 * The texture will bind the EGL image to a GL texture without readback.
 *
 * @param self The texture instance.
 * @param egl_image The EGL image handle (EGLImageKHR).
 * @param width The image width.
 * @param height The image height.
 */
void inappwebview_egl_texture_set_egl_image(InAppWebViewEGLTexture* self,
                                            void* egl_image,
                                            uint32_t width,
                                            uint32_t height);

G_END_DECLS

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_EGL_TEXTURE_H_
