#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview.h"
#include "in_app_webview_settings.h"

#include <WebView2.h>
#include <wil/com.h>

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  InAppWebViewSettings::InAppWebViewSettings() {};

  InAppWebViewSettings::InAppWebViewSettings(const flutter::EncodableMap& encodableMap)
  {
    useShouldOverrideUrlLoading = get_fl_map_value(encodableMap, "useShouldOverrideUrlLoading", useShouldOverrideUrlLoading);
    useOnLoadResource = get_fl_map_value(encodableMap, "useOnLoadResource", useOnLoadResource);
    useOnDownloadStart = get_fl_map_value(encodableMap, "useOnDownloadStart", useOnDownloadStart);
    useShouldInterceptRequest = get_fl_map_value(encodableMap, "useShouldInterceptRequest", useShouldInterceptRequest);
    userAgent = get_fl_map_value(encodableMap, "userAgent", userAgent);
    javaScriptEnabled = get_fl_map_value(encodableMap, "javaScriptEnabled", javaScriptEnabled);
    transparentBackground = get_fl_map_value(encodableMap, "transparentBackground", transparentBackground);
    supportZoom = get_fl_map_value(encodableMap, "supportZoom", supportZoom);
    isInspectable = get_fl_map_value(encodableMap, "isInspectable", isInspectable);
    disableContextMenu = get_fl_map_value(encodableMap, "disableContextMenu", disableContextMenu);
    incognito = get_fl_map_value(encodableMap, "incognito", incognito);
    if (fl_map_contains_not_null(encodableMap, "javaScriptHandlersOriginAllowList")) {
      javaScriptHandlersOriginAllowList = get_optional_fl_map_value<std::vector<std::string>>(encodableMap, "javaScriptHandlersOriginAllowList");
    }
    javaScriptHandlersForMainFrameOnly = get_fl_map_value(encodableMap, "javaScriptHandlersForMainFrameOnly", javaScriptHandlersForMainFrameOnly);
    javaScriptBridgeEnabled = get_fl_map_value(encodableMap, "javaScriptBridgeEnabled", javaScriptBridgeEnabled);
    if (fl_map_contains_not_null(encodableMap, "javaScriptBridgeOriginAllowList")) {
      javaScriptBridgeOriginAllowList = get_optional_fl_map_value<std::vector<std::string>>(encodableMap, "javaScriptBridgeOriginAllowList");
    }
    if (fl_map_contains_not_null(encodableMap, "javaScriptBridgeForMainFrameOnly")) {
      javaScriptBridgeForMainFrameOnly = get_fl_map_value<bool>(encodableMap, "javaScriptBridgeForMainFrameOnly");
    }
    if (fl_map_contains_not_null(encodableMap, "pluginScriptsOriginAllowList")) {
      pluginScriptsOriginAllowList = get_optional_fl_map_value<std::vector<std::string>>(encodableMap, "pluginScriptsOriginAllowList");
    }
    pluginScriptsForMainFrameOnly = get_fl_map_value(encodableMap, "pluginScriptsForMainFrameOnly", pluginScriptsForMainFrameOnly);
    scrollMultiplier = get_fl_map_value(encodableMap, "scrollMultiplier", scrollMultiplier);
  }

  flutter::EncodableMap InAppWebViewSettings::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"useShouldOverrideUrlLoading", useShouldOverrideUrlLoading},
      {"useOnLoadResource", useOnLoadResource},
      {"useOnDownloadStart", useOnDownloadStart},
      {"useShouldInterceptRequest", useShouldInterceptRequest},
      {"userAgent", userAgent},
      {"javaScriptEnabled", javaScriptEnabled},
      {"transparentBackground", transparentBackground},
      {"supportZoom", supportZoom},
      {"isInspectable", isInspectable},
      {"disableContextMenu", disableContextMenu},
      {"incognito", incognito},
      {"javaScriptHandlersOriginAllowList", make_fl_value(javaScriptHandlersOriginAllowList)},
      {"javaScriptHandlersForMainFrameOnly", javaScriptHandlersForMainFrameOnly},
      {"javaScriptBridgeEnabled", javaScriptBridgeEnabled},
      {"javaScriptBridgeOriginAllowList", make_fl_value(javaScriptBridgeOriginAllowList)},
      {"javaScriptBridgeForMainFrameOnly", make_fl_value(javaScriptBridgeForMainFrameOnly)},
      {"pluginScriptsOriginAllowList", make_fl_value(pluginScriptsOriginAllowList)},
      {"pluginScriptsForMainFrameOnly", pluginScriptsForMainFrameOnly},
      {"scrollMultiplier", scrollMultiplier},
    };
  }

  flutter::EncodableMap InAppWebViewSettings::getRealSettings(const InAppWebView* inAppWebView) const
  {
    auto settingsMap = toEncodableMap();
    if (inAppWebView && inAppWebView->webView) {
      auto webView = inAppWebView->webView;
      wil::com_ptr<ICoreWebView2Settings> settings;
      if (succeededOrLog(webView->get_Settings(&settings))) {
        BOOL realJavaScriptEnabled;
        if (SUCCEEDED(settings->get_IsScriptEnabled(&realJavaScriptEnabled))) {
          settingsMap["javaScriptEnabled"] = (bool)realJavaScriptEnabled;
        }
        BOOL realSupportZoom;
        if (SUCCEEDED(settings->get_IsZoomControlEnabled(&realSupportZoom))) {
          settingsMap["supportZoom"] = (bool)realSupportZoom;
        }
        BOOL realIsInspectable;
        if (SUCCEEDED(settings->get_AreDevToolsEnabled(&realIsInspectable))) {
          settingsMap["isInspectable"] = (bool)realIsInspectable;
        }
        BOOL areDefaultContextMenusEnabled;
        if (SUCCEEDED(settings->get_AreDefaultContextMenusEnabled(&areDefaultContextMenusEnabled))) {
          settingsMap["disableContextMenu"] = !(bool)areDefaultContextMenusEnabled;
        }

        wil::com_ptr<ICoreWebView2Settings2> settings2;
        if (SUCCEEDED(settings->QueryInterface(IID_PPV_ARGS(&settings2)))) {
          wil::unique_cotaskmem_string realUserAgent;
          if (SUCCEEDED(settings2->get_UserAgent(&realUserAgent))) {
            settingsMap["userAgent"] = wide_to_utf8(realUserAgent.get());
          }
        }
      }
    }
    return settingsMap;
  }

  InAppWebViewSettings::~InAppWebViewSettings()
  {
    debugLog("dealloc InAppWebViewSettings");
  }
}
