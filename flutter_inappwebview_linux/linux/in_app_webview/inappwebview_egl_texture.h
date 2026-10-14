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
 * Points an existing texture at another webview, or at none.
 *
 * populate() runs on Flutter's raster thread, so the webview it reads is
 * swapped under the texture's own mutex. Pass nullptr before releasing a
 * webview: the texture then serves its default frame instead of reaching into
 * a destroyed WPE view.
 *
 * @param texture The texture to retarget.
 * @param webview The webview to read frames from, or nullptr to detach.
 */
void inappwebview_egl_texture_set_webview(
    InAppWebViewEGLTexture* texture,
    flutter_inappwebview_plugin::WebViewType* webview);

G_END_DECLS

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_EGL_TEXTURE_H_
