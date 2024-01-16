#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include "../in_app_webview/in_app_webview_settings.h"
#include "../types/url_request.h"
#include "../utils/flutter.h"
#include "in_app_browser_manager.h"
#include "in_app_browser_settings.h"

namespace flutter_inappwebview_plugin
{
  InAppBrowserManager::InAppBrowserManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), InAppBrowserManager::METHOD_CHANNEL_NAME)
  {}

  void InAppBrowserManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("open") == 0) {
      auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
      createInAppWebView(arguments);
      result->Success(flutter::EncodableValue(true));
    }
    else {
      result->NotImplemented();
    }
  }

  void InAppBrowserManager::createInAppWebView(const flutter::EncodableMap* arguments)
  {
    auto id = get_fl_map_value<std::string>(*arguments, "id");
    auto urlRequestMap = get_optional_fl_map_value<flutter::EncodableMap>(*arguments, "urlRequest");
    std::optional<URLRequest> urlRequest = urlRequestMap.has_value() ? std::make_optional<URLRequest>(urlRequestMap.value()) : std::optional<URLRequest>{};

    auto settingsMap = get_fl_map_value<flutter::EncodableMap>(*arguments, "settings");
    auto initialSettings = std::make_unique<InAppBrowserSettings>(settingsMap);
    auto initialWebViewSettings = std::make_unique<InAppWebViewSettings>(settingsMap);

    InAppBrowserCreationParams params = {
      id,
      urlRequest,
      std::move(initialSettings),
      std::move(initialWebViewSettings)
    };

    auto inAppBrowser = std::make_unique<InAppBrowser>(plugin, params);
    browsers.insert({ id, std::move(inAppBrowser) });
  }

  InAppBrowserManager::~InAppBrowserManager()
  {
    debugLog("dealloc InAppBrowserManager");
    browsers.clear();
    plugin = nullptr;
  }
}