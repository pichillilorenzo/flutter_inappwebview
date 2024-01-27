#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_COOKIE_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_COOKIE_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <WebView2.h>
#include <wil/com.h>

#include "flutter_inappwebview_windows_plugin.h"
#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  class CookieManager : public ChannelDelegate
  {
  public:
    static inline const wchar_t* CLASS_NAME = L"CookieManager";
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_cookiemanager";

    const FlutterInappwebviewWindowsPlugin* plugin;

    CookieManager(const FlutterInappwebviewWindowsPlugin* plugin);
    ~CookieManager();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  private:
    wil::com_ptr<ICoreWebView2Environment> webViewEnv_;
    wil::com_ptr<ICoreWebView2Controller> webViewController_;
    wil::com_ptr<ICoreWebView2> webView_;
    WNDCLASS windowClass_ = {};
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_COOKIE_MANAGER_H_