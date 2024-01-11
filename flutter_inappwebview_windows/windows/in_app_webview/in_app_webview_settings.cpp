#include "../utils/flutter.h"
#include "in_app_webview_settings.h"

namespace flutter_inappwebview_plugin
{
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
  }

  InAppWebViewSettings::~InAppWebViewSettings()
  {
    debugLog("dealloc InAppWebViewSettings");
  }
}
