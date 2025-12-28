#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_GL_TEXTURE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_GL_TEXTURE_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

// Declare the custom GL texture type
#define INAPPWEBVIEW_TYPE_GL_TEXTURE (inappwebview_gl_texture_get_type())

G_DECLARE_FINAL_TYPE(InAppWebViewGLTexture, inappwebview_gl_texture, INAPPWEBVIEW,
                     GL_TEXTURE, FlTextureGL)

// Forward declaration - use WebViewType based on backend
#ifdef USE_WPE_WEBKIT
namespace flutter_inappwebview_plugin {
class InAppWebViewWpe;
using WebViewType = InAppWebViewWpe;
}
#else
namespace flutter_inappwebview_plugin {
class InAppWebView;
using WebViewType = InAppWebView;
}
#endif

// Create a new InAppWebViewGLTexture
InAppWebViewGLTexture* inappwebview_gl_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview);

G_END_DECLS

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_GL_TEXTURE_H_
