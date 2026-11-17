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
      if (string_equals(method_call.method_name(), "getProcessInfos")) {
        result->Error("webview_environment_unavailable", "The WebView environment is unavailable.",
          make_fl_value(flutter::EncodableMap{ { "stage", make_fl_value("channelDelegate") },
            { "hresult", make_fl_value(static_cast<int64_t>(E_UNEXPECTED)) } }));
      }
      else {
        result->Success();
      }
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
      webViewEnvironment->getProcessInfos([result_ = std::move(result_)](ProcessInfosResult snapshot)
        {
          if (FAILED(snapshot.error)) {
            result_->Error(snapshot.code, "Cannot collect WebView2 processes: " + getHRMessage(snapshot.error),
              make_fl_value(flutter::EncodableMap{ { "stage", make_fl_value(snapshot.stage) },
                { "hresult", make_fl_value(static_cast<int64_t>(snapshot.error)) } }));
            return;
          }
          result_->Success(make_fl_value(functional_map(snapshot.infos, [](const std::shared_ptr<BrowserProcessInfo>& info) { return info->toEncodableMap(); })));
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
