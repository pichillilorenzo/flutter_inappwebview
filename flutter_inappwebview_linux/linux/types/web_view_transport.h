#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_VIEW_TRANSPORT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_VIEW_TRANSPORT_H_

#include <wpe/webkit.h>

#include <memory>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

class InAppWebView;

/**
 * Holds a WebView created for a new window (via onCreateWindow)
 * along with the initial URL request that triggered it.
 */
struct WebViewTransport {
  // The InAppWebView wrapper that owns the WebKitWebView
  std::unique_ptr<InAppWebView> inAppWebView;
  
  // The initial URL request that triggered the window creation
  std::optional<std::string> url;
  
  WebViewTransport(std::unique_ptr<InAppWebView> webView, const std::optional<std::string>& url)
      : inAppWebView(std::move(webView)), url(url) {}
  
  // Get the internal WebKitWebView* (for returning to WebKit create signal)
  WebKitWebView* getWebKitWebView() const;
  
  ~WebViewTransport() = default;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_VIEW_TRANSPORT_H_
