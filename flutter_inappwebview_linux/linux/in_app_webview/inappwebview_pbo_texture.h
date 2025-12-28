#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_PBO_TEXTURE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_PBO_TEXTURE_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

// Declare the PBO-optimized GL texture type
#define INAPPWEBVIEW_TYPE_PBO_TEXTURE (inappwebview_pbo_texture_get_type())

G_DECLARE_FINAL_TYPE(InAppWebViewPBOTexture, inappwebview_pbo_texture, INAPPWEBVIEW,
                     PBO_TEXTURE, FlTextureGL)

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

/**
 * Create a new InAppWebViewPBOTexture.
 * 
 * This texture implementation uses OpenGL Pixel Buffer Objects (PBOs) for
 * asynchronous DMA texture uploads, providing better performance than
 * synchronous glTexImage2D calls.
 * 
 * Features:
 * - Double-buffered PBOs for async upload
 * - glTexSubImage2D for faster updates when size unchanged
 * - Persistent buffer mapping where available
 */
InAppWebViewPBOTexture* inappwebview_pbo_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview);

G_END_DECLS

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_INAPPWEBVIEW_PBO_TEXTURE_H_
