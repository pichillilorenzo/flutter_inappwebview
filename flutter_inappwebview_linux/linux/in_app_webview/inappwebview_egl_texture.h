#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_EGL_TEXTURE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_EGL_TEXTURE_H_

#include <flutter_linux/flutter_linux.h>

namespace flutter_inappwebview_plugin {
class InAppWebView;
using WebViewType = InAppWebView;
}  // namespace flutter_inappwebview_plugin

G_BEGIN_DECLS

#define INAPPWEBVIEW_TYPE_EGL_TEXTURE (inappwebview_egl_texture_get_type())
G_DECLARE_FINAL_TYPE(InAppWebViewEGLTexture, inappwebview_egl_texture, INAPPWEBVIEW, EGL_TEXTURE,
                     FlTextureGL)

// Copies WPE frames on the GPU into a separate GL texture for Flutter.
// Pixel transfer is used only when importing or copying the GPU frame fails.
InAppWebViewEGLTexture* inappwebview_egl_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview);

// Waits for populate() before disconnecting the WebView during disposal.
void inappwebview_egl_texture_detach(InAppWebViewEGLTexture* self);

G_END_DECLS
#endif
