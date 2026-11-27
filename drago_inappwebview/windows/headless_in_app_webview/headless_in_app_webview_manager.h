#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_MANAGER_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_MANAGER_H_

#include <flutter/method_channel.h>
#include <map>
#include <string>
#include <wil/com.h>
#include <winrt/base.h>

#include "../drago_inappwebview_plugin.h"
#include "../types/channel_delegate.h"
#include "headless_in_app_webview.h"

namespace drago_inappwebview_plugin
{
  class HeadlessInAppWebViewManager : public ChannelDelegate
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_headless_inappwebview";

    const DragoInappwebviewPlugin* plugin;
    std::map<std::string, std::unique_ptr<HeadlessInAppWebView>> webViews;

    HeadlessInAppWebViewManager(const DragoInappwebviewPlugin* plugin);
    ~HeadlessInAppWebViewManager();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    void run(const flutter::EncodableMap* arguments, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  private:
    WNDCLASS windowClass_ = {};
  };
}
#endif //DRAGO_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_MANAGER_H_