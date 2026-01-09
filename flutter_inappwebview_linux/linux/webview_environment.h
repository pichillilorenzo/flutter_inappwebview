#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_

#include <flutter_linux/flutter_linux.h>

#include <string>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

/**
 * Manages WebView Environment operations for WPE WebKit.
 * Provides access to the WPE WebKit version information.
 */
class WebViewEnvironment : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_webview_environment";

  WebViewEnvironment(FlPluginRegistrar* registrar);
  ~WebViewEnvironment() override;

  void HandleMethodCall(FlMethodCall* method_call) override;

  /**
   * Get the WPE WebKit version string (e.g., "2.42.0").
   */
  static std::string getAvailableVersion();
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_
