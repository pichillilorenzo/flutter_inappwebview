#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_

#include <flutter/standard_message_codec.h>
#include <string>

namespace flutter_inappwebview_plugin
{
  class InAppWebViewSettings
  {
  public:
    bool useShouldOverrideUrlLoading = false;
    bool useOnLoadResource = false;
    bool useOnDownloadStart = false;
    std::string userAgent;
    bool javaScriptEnabled = true;
    std::vector<std::string> resourceCustomSchemes;
    bool transparentBackground = false;
    bool supportZoom = true;

    InAppWebViewSettings();
    InAppWebViewSettings(const flutter::EncodableMap& encodableMap);
    ~InAppWebViewSettings();
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_