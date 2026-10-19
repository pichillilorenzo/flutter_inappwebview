#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CREATION_ERROR_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CREATION_ERROR_H_

#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

// Captures the native operation and diagnostics for a failed WebView create.
struct WebViewCreationError {
  std::string stage;
  std::string message;
  std::optional<int> nativeCode;
  std::optional<std::string> nativeDomain;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CREATION_ERROR_H_
