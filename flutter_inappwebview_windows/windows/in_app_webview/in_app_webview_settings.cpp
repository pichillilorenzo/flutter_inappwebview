#include "../utils/flutter.h"
#include "../utils/log.h"
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
    userAgent = get_fl_map_value(encodableMap, "userAgent", userAgent);
    javaScriptEnabled = get_fl_map_value(encodableMap, "javaScriptEnabled", javaScriptEnabled);
    resourceCustomSchemes = get_fl_map_value(encodableMap, "resourceCustomSchemes", resourceCustomSchemes);
    transparentBackground = get_fl_map_value(encodableMap, "transparentBackground", transparentBackground);
    supportZoom = get_fl_map_value(encodableMap, "supportZoom", supportZoom);
    isInspectable = get_fl_map_value(encodableMap, "isInspectable", isInspectable);
    disableContextMenu = get_fl_map_value(encodableMap, "disableContextMenu", disableContextMenu);
  }

  flutter::EncodableMap InAppWebViewSettings::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"useShouldOverrideUrlLoading", useShouldOverrideUrlLoading},
      {"useOnLoadResource", useOnLoadResource},
      {"useOnDownloadStart", useOnDownloadStart},
      {"userAgent", userAgent},
      {"javaScriptEnabled", javaScriptEnabled},
      {"resourceCustomSchemes", make_fl_value(resourceCustomSchemes)},
      {"transparentBackground", transparentBackground},
      {"supportZoom", supportZoom},
      {"isInspectable", isInspectable},
      {"disableContextMenu", disableContextMenu},
    };
  }

  flutter::EncodableMap InAppWebViewSettings::getRealSettings(ICoreWebView2Settings* settings) const
  {
    auto settingsMap = toEncodableMap();
    if (settings) {
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
    return settingsMap;
  }

  InAppWebViewSettings::~InAppWebViewSettings()
  {
    debugLog("dealloc InAppWebViewSettings");
  }
}
