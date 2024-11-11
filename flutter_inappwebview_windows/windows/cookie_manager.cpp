#include <ctime>
#include <nlohmann/json.hpp>
#include <Shlwapi.h>
#include <winrt/base.h>
#include <wrl/event.h>

#include "cookie_manager.h"
#include "types/callbacks_complete.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  CookieManager::CookieManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), CookieManager::METHOD_CHANNEL_NAME_PREFIX)
  {}

  std::string convertWcharToUTF8(const wchar_t* str) {
    int wideStrLen = static_cast<int>(wcslen(str) + 1);
    int mbStrLen = WideCharToMultiByte(CP_UTF8, 0, str, wideStrLen, NULL, 0, NULL, NULL);

    std::string mbStr(mbStrLen, 0);
    WideCharToMultiByte(CP_UTF8, 0, str, wideStrLen, &mbStr[0], mbStrLen, NULL, NULL);
    return mbStr;
  }
  
  void CookieManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto& arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto& methodName = method_call.method_name();

    auto webViewEnvironmentId = get_optional_fl_map_value<std::string>(arguments, "webViewEnvironmentId");

    auto webViewEnvironment = plugin && webViewEnvironmentId.has_value() && map_contains(plugin->webViewEnvironmentManager->webViewEnvironments, webViewEnvironmentId.value())
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
        else if (string_equals(methodName, "getCookie")) {
          auto url = get_fl_map_value<std::string>(arguments, "url");
          auto name = get_fl_map_value<std::string>(arguments, "name");
          getCookie(webViewEnvironment, url, name, [result_](const flutter::EncodableValue& cookie)
            {
              result_->Success(cookie);
            });
        }
        else if (string_equals(methodName, "getCookies")) {
          auto url = get_fl_map_value<std::string>(arguments, "url");
          getCookies(webViewEnvironment, url, [result_](const flutter::EncodableList& cookies)
            {
              result_->Success(cookies);
            });
        }
        else if (string_equals(methodName, "deleteCookie")) {
          auto url = get_fl_map_value<std::string>(arguments, "url");
          auto name = get_fl_map_value<std::string>(arguments, "name");
          auto path = get_fl_map_value<std::string>(arguments, "path");
          auto domain = get_optional_fl_map_value<std::string>(arguments, "domain");
          deleteCookie(webViewEnvironment, url, name, path, domain, [result_](const bool& deleted)
            {
              result_->Success(deleted);
            });
        }
        else if (string_equals(methodName, "deleteCookies")) {
          auto url = get_fl_map_value<std::string>(arguments, "url");
          auto path = get_fl_map_value<std::string>(arguments, "path");
          auto domain = get_optional_fl_map_value<std::string>(arguments, "domain");
          deleteCookies(webViewEnvironment, url, path, domain, [result_](const bool& deleted)
            {
              result_->Success(deleted);
            });
        }
        else if (string_equals(methodName, "deleteAllCookies")) {
          deleteAllCookies(webViewEnvironment, [result_](const bool& deleted)
            {
              result_->Success(deleted);
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

  void CookieManager::setCookie(WebViewEnvironment* webViewEnvironment, const flutter::EncodableMap& map, std::function<void(const bool&)> completionHandler) const
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

  void CookieManager::getCookie(WebViewEnvironment *webViewEnvironment, const std::string &url, const std::string &name, std::function<void(const flutter::EncodableValue &)> completionHandler) const
  {
    if (!plugin || !plugin->webViewEnvironmentManager)
    {
      if (completionHandler)
      {
        completionHandler(make_fl_value());
      }
      return;
    }

    ICoreWebView2 *webview2 = webViewEnvironment->getWebView().get();
    ICoreWebView2_2 *web_view2_2 = static_cast<ICoreWebView2_2 *>(webview2);
    ICoreWebView2CookieManager *m_cookieManager;
    web_view2_2->get_CookieManager(&m_cookieManager);
    std::wstring urlW = std::wstring(url.begin(), url.end());
    auto hr = m_cookieManager->GetCookies(
        urlW.c_str(),
        Callback<ICoreWebView2GetCookiesCompletedHandler>(
            [completionHandler, name](HRESULT errorCode, ICoreWebView2CookieList *cookieList)
            {
              UINT cookieCount;
              cookieList->get_Count(&cookieCount);

              for (UINT i = 0; i < cookieCount; ++i)
              {
                wil::com_ptr<ICoreWebView2Cookie> cookie;
                cookieList->GetValueAtIndex(i, &cookie);
                LPWSTR cookieName;
                cookie->get_Name(&cookieName);
                if (string_equals(name, cookieName))
                {
                  LPWSTR value, domain, path;
                  double expires;
                  BOOL isSecure, isHttpOnly, isSessionOnly;
                  COREWEBVIEW2_COOKIE_SAME_SITE_KIND sameSite;

                  cookie->get_Value(&value);
                  cookie->get_Domain(&domain);
                  cookie->get_Path(&path);
                  cookie->get_Expires(&expires);
                  cookie->get_IsSecure(&isSecure);
                  cookie->get_IsHttpOnly(&isHttpOnly);
                  cookie->get_IsSession(&isSessionOnly);
                  cookie->get_SameSite(&sameSite);

                  std::string sameSiteStr = "";
                  switch (sameSite)
                  {
                  case COREWEBVIEW2_COOKIE_SAME_SITE_KIND_NONE:
                    sameSiteStr = "None";
                    break;
                  case COREWEBVIEW2_COOKIE_SAME_SITE_KIND_LAX:
                    sameSiteStr = "Lax";
                    break;
                  case COREWEBVIEW2_COOKIE_SAME_SITE_KIND_STRICT:
                    sameSiteStr = "Strict";
                    break;
                  }

                  completionHandler(flutter::EncodableMap{
                      {"name", make_fl_value(convertWcharToUTF8(cookieName))},
                      {"value", make_fl_value(convertWcharToUTF8(value))},
                      {"domain", make_fl_value(convertWcharToUTF8(domain))},
                      {"path", make_fl_value(convertWcharToUTF8(path))},
                      {"expiresDate", make_fl_value(static_cast<int64_t>(expires))},
                      {"isHttpOnly", make_fl_value(static_cast<bool>(isHttpOnly))},
                      {"isSecure", make_fl_value(static_cast<bool>(isSecure))},
                      {"isSessionOnly", make_fl_value(static_cast<bool>(isSessionOnly))},
                      {"sameSite", make_fl_value(sameSiteStr)}});

                  CoTaskMemFree(cookieName);
                  CoTaskMemFree(value);
                  CoTaskMemFree(domain);
                  CoTaskMemFree(path);
                  return S_OK;
                }
              }

              if (completionHandler)
              {
                completionHandler(make_fl_value());
              }
              return S_OK;
            })
            .Get());

    if (failedAndLog(hr) && completionHandler)
    {
      completionHandler(make_fl_value());
    }
  }

  void CookieManager::getCookies(WebViewEnvironment *webViewEnvironment, const std::string &url, std::function<void(const flutter::EncodableList &)> completionHandler) const {
    if (!plugin || !plugin->webViewEnvironmentManager) {
        if (completionHandler) {
            completionHandler({});
        }
        return;
    }

    ICoreWebView2 *webview2 = webViewEnvironment->getWebView().get();
    ICoreWebView2_2 *web_view2_2 = static_cast<ICoreWebView2_2 *>(webview2);
    ICoreWebView2CookieManager *m_cookieManager;
    web_view2_2->get_CookieManager(&m_cookieManager);
    
    std::wstring urlW = std::wstring(url.begin(), url.end());
    auto hr = m_cookieManager->GetCookies(
        urlW.c_str(),
        Callback<ICoreWebView2GetCookiesCompletedHandler>(
            [completionHandler](HRESULT errorCode, ICoreWebView2CookieList *cookieList) {
                UINT cookieCount;
                cookieList->get_Count(&cookieCount);
                std::vector<flutter::EncodableValue> cookies;

                for (UINT i = 0; i < cookieCount; ++i) {
                    wil::com_ptr<ICoreWebView2Cookie> cookie;
                    cookieList->GetValueAtIndex(i, &cookie);

                    LPWSTR name, value, domain, path;
                    double expires;
                    BOOL isSecure, isHttpOnly, isSessionOnly;
                    COREWEBVIEW2_COOKIE_SAME_SITE_KIND sameSite;

                    cookie->get_Name(&name);
                    cookie->get_Value(&value);
                    cookie->get_Domain(&domain);
                    cookie->get_Path(&path);
                    cookie->get_Expires(&expires);
                    cookie->get_IsSecure(&isSecure);
                    cookie->get_IsHttpOnly(&isHttpOnly);
                    cookie->get_IsSession(&isSessionOnly);
                    cookie->get_SameSite(&sameSite);

                    std::string sameSiteStr = "";
                    switch (sameSite) {
                        case COREWEBVIEW2_COOKIE_SAME_SITE_KIND_NONE:
                            sameSiteStr = "None";
                            break;
                        case COREWEBVIEW2_COOKIE_SAME_SITE_KIND_LAX:
                            sameSiteStr = "Lax";
                            break;
                        case COREWEBVIEW2_COOKIE_SAME_SITE_KIND_STRICT:
                            sameSiteStr = "Strict";
                            break;
                    }

                    cookies.push_back(flutter::EncodableMap{
                        {"name", make_fl_value(convertWcharToUTF8(name))},
                        {"value", make_fl_value(convertWcharToUTF8(value))},
                        {"domain", make_fl_value(convertWcharToUTF8(domain))},
                        {"path", make_fl_value(convertWcharToUTF8(path))},
                        {"expiresDate", make_fl_value(static_cast<int64_t>(expires))},
                        {"isHttpOnly", make_fl_value(static_cast<bool>(isHttpOnly))},
                        {"isSecure", make_fl_value(static_cast<bool>(isSecure))},
                        {"isSessionOnly", make_fl_value(static_cast<bool>(isSessionOnly))},
                        {"sameSite", make_fl_value(sameSiteStr)}
                    });

                    CoTaskMemFree(name);
                    CoTaskMemFree(value);
                    CoTaskMemFree(domain);
                    CoTaskMemFree(path);
                }

                if (completionHandler) {
                    completionHandler(cookies);
                }
                return S_OK;
            }).Get());

    if (failedAndLog(hr) && completionHandler) {
      completionHandler({});
    }
  }

  void CookieManager::deleteCookie(WebViewEnvironment* webViewEnvironment, const std::string& url, const std::string& name, const std::string& path, const std::optional<std::string>& domain, std::function<void(const bool&)> completionHandler) const
  {
    if (!plugin || !plugin->webViewEnvironmentManager) {
      if (completionHandler) {
        completionHandler(false);
      }
      return;
    }

    nlohmann::json parameters = {
      {"url", url},
      {"name", name},
      {"path", path}
    };
    if (domain.has_value()) {
      parameters["domain"] = domain.value();
    }

    auto hr = webViewEnvironment->getWebView()->CallDevToolsProtocolMethod(L"Network.deleteCookies", utf8_to_wide(parameters.dump()).c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
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

  void CookieManager::deleteCookies(WebViewEnvironment* webViewEnvironment, const std::string& url, const std::string& path, const std::optional<std::string>& domain, std::function<void(const bool&)> completionHandler) const
  {
    if (!plugin || !plugin->webViewEnvironmentManager) {
      if (completionHandler) {
        completionHandler(false);
      }
      return;
    }

    getCookies(webViewEnvironment, url, [this, webViewEnvironment, url, path, domain, completionHandler](const flutter::EncodableList& cookies)
      {
        auto callbacksComplete = std::make_shared<CallbacksComplete<bool>>(
          [completionHandler](const std::vector<bool>& values)
          {
            if (completionHandler) {
              completionHandler(true);
            }
          });

        for (auto& cookie : cookies) {
          auto cookieMap = std::get<flutter::EncodableMap>(cookie);
          auto name = get_fl_map_value<std::string>(cookieMap, "name");
          deleteCookie(webViewEnvironment, url, name, path, domain, [callbacksComplete](const bool& deleted)
            {
              callbacksComplete->addValue(deleted);
            });
        }
      });
  }

  void CookieManager::deleteAllCookies(WebViewEnvironment* webViewEnvironment, std::function<void(const bool&)> completionHandler) const
  {
    if (!plugin || !plugin->webViewEnvironmentManager) {
      if (completionHandler) {
        completionHandler(false);
      }
      return;
    }

    auto hr = webViewEnvironment->getWebView()->CallDevToolsProtocolMethod(L"Network.clearBrowserCookies", L"{}", Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
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
