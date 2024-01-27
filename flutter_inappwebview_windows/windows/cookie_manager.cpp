#include <nlohmann/json.hpp>
#include <Shlwapi.h>
#include <time.h>
#include <winrt/base.h>
#include <wrl/event.h>

#include "cookie_manager.h"
#include "in_app_webview/in_app_webview.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  CookieManager::CookieManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : ChannelDelegate(plugin->registrar->messenger(), CookieManager::METHOD_CHANNEL_NAME_PREFIX)
  {
    windowClass_.lpszClassName = CookieManager::CLASS_NAME;
    windowClass_.lpfnWndProc = &DefWindowProc;

    RegisterClass(&windowClass_);

    auto hwnd = CreateWindowEx(0, windowClass_.lpszClassName, L"", 0, 0,
      0, 0, 0,
      plugin->registrar->GetView()->GetNativeWindow(),
      nullptr,
      windowClass_.hInstance, nullptr);

    InAppWebView::createInAppWebViewEnv(hwnd, false, nullptr,
      [=](wil::com_ptr<ICoreWebView2Environment> webViewEnv,
        wil::com_ptr<ICoreWebView2Controller> webViewController,
        wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)
      {
        if (webViewEnv && webViewController) {
          webViewEnv_ = std::move(webViewEnv);
          webViewController_ = std::move(webViewController);
          webViewController_->get_CoreWebView2(&webView_);
          webViewController_->put_IsVisible(false);
        }
      });
  }

  void CookieManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto& arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "setCookie")) {
      if (!webView_) {
        result->Success(false);
        return;
      }

      auto url = get_fl_map_value<std::string>(arguments, "url");
      auto name = get_fl_map_value<std::string>(arguments, "name");
      auto value = get_fl_map_value<std::string>(arguments, "value");
      auto path = get_fl_map_value<std::string>(arguments, "path");
      auto domain = get_optional_fl_map_value<std::string>(arguments, "domain");
      auto expiresDate = get_optional_fl_map_value<int64_t>(arguments, "expiresDate");
      auto maxAge = get_optional_fl_map_value<int64_t>(arguments, "maxAge");
      auto isSecure = get_optional_fl_map_value<bool>(arguments, "isSecure");
      auto isHttpOnly = get_optional_fl_map_value<bool>(arguments, "isHttpOnly");
      auto sameSite = get_optional_fl_map_value<std::string>(arguments, "sameSite");

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

      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      auto hr = webView_->CallDevToolsProtocolMethod(L"Network.setCookie", utf8_to_wide(parameters.dump()).c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
        [this, result_](HRESULT errorCode, LPCWSTR returnObjectAsJson)
        {
          result_->Success(succeededOrLog(errorCode));
          return S_OK;
        }
      ).Get());

      if (failedAndLog(hr)) {
        result_->Success(false);
      }
    }
    else {
      result->NotImplemented();
    }
  }

  CookieManager::~CookieManager()
  {
    debugLog("dealloc CookieManager");
  }
}