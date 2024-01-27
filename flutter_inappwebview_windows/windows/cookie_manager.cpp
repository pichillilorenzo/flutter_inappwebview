#include <ctime>
#include <nlohmann/json.hpp>
#include <Shlwapi.h>
#include <winrt/base.h>
#include <wrl/event.h>

#include "cookie_manager.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  CookieManager::CookieManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), CookieManager::METHOD_CHANNEL_NAME_PREFIX)
  {}

  void CookieManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto& arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto& methodName = method_call.method_name();

    auto webViewEnvironmentId = get_optional_fl_map_value<std::string>(arguments, "webViewEnvironmentId");

    auto webViewEnvironment = webViewEnvironmentId.has_value() && map_contains(plugin->webViewEnvironmentManager->webViewEnvironments, webViewEnvironmentId.value())
      ? plugin->webViewEnvironmentManager->webViewEnvironments.at(webViewEnvironmentId.value()).get() : nullptr;

    auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    auto callback = [this, result_, methodName, arguments](WebViewEnvironment* webViewEnvironment)
      {
        if (!webViewEnvironment) {
          result_->Error("0", "Cannot obtain the WebViewEnvironment!");
          return;
        }

        if (string_equals(methodName, "setCookie")) {
          setCookie(webViewEnvironment, arguments, [result_](const bool& created)
            {
              result_->Success(created);
            });
        }
        else {
          result_->NotImplemented();
        }
      };

    if (webViewEnvironment) {
      callback(webViewEnvironment);
    }
    else {
      plugin->webViewEnvironmentManager->createOrGetDefaultWebViewEnvironment([callback](WebViewEnvironment* webViewEnvironment)
        {
          callback(webViewEnvironment);
        });
    }
  }

  void CookieManager::setCookie(WebViewEnvironment* webViewEnvironment, const flutter::EncodableMap& map, std::function<void(bool)> completionHandler) const
  {
    if (!plugin || !plugin->webViewEnvironmentManager) {
      if (completionHandler) {
        completionHandler(false);
      }
      return;
    }

    auto url = get_fl_map_value<std::string>(map, "url");
    auto name = get_fl_map_value<std::string>(map, "name");
    auto value = get_fl_map_value<std::string>(map, "value");
    auto path = get_fl_map_value<std::string>(map, "path");
    auto domain = get_optional_fl_map_value<std::string>(map, "domain");
    auto expiresDate = get_optional_fl_map_value<int64_t>(map, "expiresDate");
    auto maxAge = get_optional_fl_map_value<int64_t>(map, "maxAge");
    auto isSecure = get_optional_fl_map_value<bool>(map, "isSecure");
    auto isHttpOnly = get_optional_fl_map_value<bool>(map, "isHttpOnly");
    auto sameSite = get_optional_fl_map_value<std::string>(map, "sameSite");

    nlohmann::json parameters = {
      {"url", url},
      {"name", name},
      {"value", value},
      {"path", path}
    };
    if (domain.has_value()) {
      parameters["domain"] = domain.value();
    }
    if (expiresDate.has_value()) {
      parameters["expires"] = expiresDate.value() / 1000;
    }
    if (maxAge.has_value()) {
      // time(NULL) represents the current unix timestamp in seconds
      parameters["expires"] = time(NULL) + maxAge.value();
    }
    if (isSecure.has_value()) {
      parameters["secure"] = isSecure.value();
    }
    if (isHttpOnly.has_value()) {
      parameters["httpOnly"] = isHttpOnly.value();
    }
    if (sameSite.has_value()) {
      parameters["sameSite"] = sameSite.value();
    }

    auto hr = webViewEnvironment->getWebView()->CallDevToolsProtocolMethod(L"Network.setCookie", utf8_to_wide(parameters.dump()).c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [completionHandler](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        if (completionHandler) {
          completionHandler(succeededOrLog(errorCode));
        }
        return S_OK;
      }
    ).Get());

    if (failedAndLog(hr) && completionHandler) {
      completionHandler(false);
    }
  }

  CookieManager::~CookieManager()
  {
    debugLog("dealloc CookieManager");
    plugin = nullptr;
  }
}
