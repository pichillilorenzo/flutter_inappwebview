#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_CHANNEL_DELEGATE_H_

#include <flutter/method_channel.h>

#include "../types/browser_process_exited_detail.h"
#include "../types/browser_process_infos_changed_detail.h"
#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  class WebViewEnvironment;

  class WebViewEnvironmentChannelDelegate : public ChannelDelegate
  {
  public:
    WebViewEnvironment* webViewEnvironment;

    WebViewEnvironmentChannelDelegate(WebViewEnvironment* webViewEnv, flutter::BinaryMessenger* messenger);
    ~WebViewEnvironmentChannelDelegate();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    void onNewBrowserVersionAvailable() const;
    void onBrowserProcessExited(std::shared_ptr<BrowserProcessExitedDetail> detail) const;
    void onProcessInfosChanged(std::shared_ptr<BrowserProcessInfosChangedDetail> detail) const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_CHANNEL_DELEGATE_H_