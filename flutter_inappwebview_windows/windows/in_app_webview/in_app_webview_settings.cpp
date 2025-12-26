#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview.h"
#include "in_app_webview_settings.h"

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
    disableDefaultErrorPage = get_fl_map_value(encodableMap, "disableDefaultErrorPage", disableDefaultErrorPage);
    statusBarEnabled = get_fl_map_value(encodableMap, "statusBarEnabled", statusBarEnabled);
    browserAcceleratorKeysEnabled = get_fl_map_value(encodableMap, "browserAcceleratorKeysEnabled", browserAcceleratorKeysEnabled);
    generalAutofillEnabled = get_fl_map_value(encodableMap, "generalAutofillEnabled", generalAutofillEnabled);
    passwordAutosaveEnabled = get_fl_map_value(encodableMap, "passwordAutosaveEnabled", passwordAutosaveEnabled);
    pinchZoomEnabled = get_fl_map_value(encodableMap, "pinchZoomEnabled", pinchZoomEnabled);
    allowsBackForwardNavigationGestures = get_fl_map_value(encodableMap, "allowsBackForwardNavigationGestures", allowsBackForwardNavigationGestures);
    hiddenPdfToolbarItems = get_fl_map_value(encodableMap, "hiddenPdfToolbarItems", hiddenPdfToolbarItems);
    reputationCheckingRequired = get_fl_map_value(encodableMap, "reputationCheckingRequired", reputationCheckingRequired);
    nonClientRegionSupportEnabled = get_fl_map_value(encodableMap, "nonClientRegionSupportEnabled", nonClientRegionSupportEnabled);
    handleAcceleratorKeyPressed = get_fl_map_value(encodableMap, "handleAcceleratorKeyPressed", handleAcceleratorKeyPressed);
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
      {"disableDefaultErrorPage", disableDefaultErrorPage},
      {"statusBarEnabled", statusBarEnabled},
      {"browserAcceleratorKeysEnabled", browserAcceleratorKeysEnabled},
      {"generalAutofillEnabled", generalAutofillEnabled},
      {"passwordAutosaveEnabled", passwordAutosaveEnabled},
      {"pinchZoomEnabled", pinchZoomEnabled},
      {"allowsBackForwardNavigationGestures", allowsBackForwardNavigationGestures},
      {"hiddenPdfToolbarItems", hiddenPdfToolbarItems},
      {"reputationCheckingRequired", reputationCheckingRequired},
      {"nonClientRegionSupportEnabled", nonClientRegionSupportEnabled},
      {"handleAcceleratorKeyPressed", handleAcceleratorKeyPressed}
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
        BOOL isBuiltInErrorPageEnabled;
        if (SUCCEEDED(settings->get_IsBuiltInErrorPageEnabled(&isBuiltInErrorPageEnabled))) {
          settingsMap["disableDefaultErrorPage"] = !(bool)isBuiltInErrorPageEnabled;
        }
        BOOL isStatusBarEnabled;
        if (SUCCEEDED(settings->get_IsBuiltInErrorPageEnabled(&isStatusBarEnabled))) {
          settingsMap["statusBarEnabled"] = (bool)isStatusBarEnabled;
        }

        if (auto settings2 = settings.try_query<ICoreWebView2Settings2>()) {
          wil::unique_cotaskmem_string realUserAgent;
          if (SUCCEEDED(settings2->get_UserAgent(&realUserAgent))) {
            settingsMap["userAgent"] = wide_to_utf8(realUserAgent.get());
          }
        }

        if (auto settings3 = settings.try_query<ICoreWebView2Settings3>()) {
          BOOL areBrowserAcceleratorKeysEnabled;
          if (SUCCEEDED(settings3->get_AreBrowserAcceleratorKeysEnabled(&areBrowserAcceleratorKeysEnabled))) {
            settingsMap["browserAcceleratorKeysEnabled"] = (bool)areBrowserAcceleratorKeysEnabled;
          }
        }

        if (auto settings4 = settings.try_query<ICoreWebView2Settings4>()) {
          BOOL isGeneralAutofillEnabled;
          if (SUCCEEDED(settings4->get_IsGeneralAutofillEnabled(&isGeneralAutofillEnabled))) {
            settingsMap["generalAutofillEnabled"] = (bool)isGeneralAutofillEnabled;
          }
          BOOL isPasswordAutosaveEnabled;
          if (SUCCEEDED(settings4->get_IsPasswordAutosaveEnabled(&isPasswordAutosaveEnabled))) {
            settingsMap["passwordAutosaveEnabled"] = (bool)isPasswordAutosaveEnabled;
          }
        }

        if (auto settings5 = settings.try_query<ICoreWebView2Settings5>()) {
          BOOL isPinchZoomEnabled;
          if (SUCCEEDED(settings5->get_IsPinchZoomEnabled(&isPinchZoomEnabled))) {
            settingsMap["pinchZoomEnabled"] = (bool)isPinchZoomEnabled;
          }
        }

        if (auto settings6 = settings.try_query<ICoreWebView2Settings6>()) {
          BOOL isSwipeNavigationEnabled;
          if (SUCCEEDED(settings6->get_IsSwipeNavigationEnabled(&isSwipeNavigationEnabled))) {
            settingsMap["allowsBackForwardNavigationGestures"] = (bool)isSwipeNavigationEnabled;
          }
        }

        if (auto settings7 = settings.try_query<ICoreWebView2Settings7>()) {
          COREWEBVIEW2_PDF_TOOLBAR_ITEMS realHiddenPdfToolbarItems;
          if (SUCCEEDED(settings7->get_HiddenPdfToolbarItems(&realHiddenPdfToolbarItems))) {
            settingsMap["hiddenPdfToolbarItems"] = (int64_t)realHiddenPdfToolbarItems;
          }
        }

        if (auto settings8 = settings.try_query<ICoreWebView2Settings8>()) {
          BOOL isReputationCheckingRequired;
          if (SUCCEEDED(settings8->get_IsReputationCheckingRequired(&isReputationCheckingRequired))) {
            settingsMap["reputationCheckingRequired"] = (bool)isReputationCheckingRequired;
          }
        }

        if (auto settings9 = settings.try_query<ICoreWebView2Settings9>()) {
          BOOL isNonClientRegionSupportEnabled;
          if (SUCCEEDED(settings9->get_IsNonClientRegionSupportEnabled(&isNonClientRegionSupportEnabled))) {
            settingsMap["nonClientRegionSupportEnabled"] = (bool)isNonClientRegionSupportEnabled;
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
