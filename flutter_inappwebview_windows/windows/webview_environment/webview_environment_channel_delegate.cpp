#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/strconv.h"
#include "../utils/string.h"
#include "../utils/vector.h"
#include "webview_environment.h"
#include "webview_environment_channel_delegate.h"

#include "webview_environment_manager.h"

namespace flutter_inappwebview_plugin
{
  WebViewEnvironmentChannelDelegate::WebViewEnvironmentChannelDelegate(WebViewEnvironment* webViewEnv, flutter::BinaryMessenger* messenger)
    : webViewEnvironment(webViewEnv), ChannelDelegate(messenger, WebViewEnvironment::METHOD_CHANNEL_NAME_PREFIX + webViewEnv->id)
  {}

  void WebViewEnvironmentChannelDelegate::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (!webViewEnvironment) {
      result->Success();
      return;
    }

    auto& arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "dispose")) {
      if (webViewEnvironment->plugin && webViewEnvironment->plugin->webViewEnvironmentManager) {
        std::map<std::string, std::unique_ptr<WebViewEnvironment>>& webViewEnvironments = webViewEnvironment->plugin->webViewEnvironmentManager->webViewEnvironments;
        auto& id = webViewEnvironment->id;
        if (map_contains(webViewEnvironments, id)) {
          webViewEnvironments.erase(id);
        }
      }
      result->Success();
    }
    else if (string_equals(methodName, "isInterfaceSupported")) {
      auto interfaceName = get_fl_map_value<std::string>(arguments, "interface");
      result->Success(webViewEnvironment->isInterfaceSupported(interfaceName));
    }
    else if (string_equals(methodName, "getProcessInfos")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webViewEnvironment->getProcessInfos([result_ = std::move(result_)](std::vector<std::shared_ptr<BrowserProcessInfo>> processInfos)
        {
          result_->Success(make_fl_value(functional_map(processInfos, [](const std::shared_ptr<BrowserProcessInfo>& info) { return info->toEncodableMap(); })));
        });
    }
    else if (string_equals(methodName, "getFailureReportFolderPath")) {
      result->Success(make_fl_value(webViewEnvironment->getFailureReportFolderPath()));
    }
    else {
      result->NotImplemented();
    }
  }

  void WebViewEnvironmentChannelDelegate::onNewBrowserVersionAvailable() const
  {
    if (!channel) {
      return;
    }
    channel->InvokeMethod("onNewBrowserVersionAvailable", nullptr);
  }

  void WebViewEnvironmentChannelDelegate::onBrowserProcessExited(std::shared_ptr<BrowserProcessExitedDetail> detail) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(detail->toEncodableMap());
    channel->InvokeMethod("onBrowserProcessExited", std::move(arguments));
  }

  void WebViewEnvironmentChannelDelegate::onProcessInfosChanged(std::shared_ptr<BrowserProcessInfosChangedDetail> detail) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(detail->toEncodableMap());
    channel->InvokeMethod("onProcessInfosChanged", std::move(arguments));
  }

  WebViewEnvironmentChannelDelegate::~WebViewEnvironmentChannelDelegate()
  {
    debugLog("dealloc WebViewEnvironmentChannelDelegate");
    webViewEnvironment = nullptr;
  }
}
