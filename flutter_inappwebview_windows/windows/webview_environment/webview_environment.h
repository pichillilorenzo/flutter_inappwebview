#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_

#include <functional>
#include <WebView2.h>
#include <wil/com.h>

#include "../flutter_inappwebview_windows_plugin.h"
#include "webview_environment_channel_delegate.h"
#include "webview_environment_settings.h"

namespace flutter_inappwebview_plugin
{
  class WebViewEnvironment
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_webview_environment_";

    const FlutterInappwebviewWindowsPlugin* plugin;
    std::string id;
    wil::com_ptr<ICoreWebView2Environment> env;
    std::unique_ptr<WebViewEnvironmentChannelDelegate> channelDelegate;

    WebViewEnvironment(const FlutterInappwebviewWindowsPlugin* plugin, const std::string& id);
    ~WebViewEnvironment();

    void create(const std::unique_ptr<WebViewEnvironmentSettings> settings, const std::function<void(HRESULT)> completionHandler);
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_H_