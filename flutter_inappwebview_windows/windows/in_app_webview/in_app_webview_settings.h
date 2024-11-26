#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_

#include <optional>
#include <string>
#include <WebView2.h>

namespace flutter_inappwebview_plugin
{
  class InAppWebView;

  class InAppWebViewSettings
  {
  public:
    bool useShouldOverrideUrlLoading = false;
    bool useOnLoadResource = false;
    bool useOnDownloadStart = false;
    bool useShouldInterceptRequest = false;
    std::string userAgent;
    bool javaScriptEnabled = true;
    bool transparentBackground = false;
    bool supportZoom = true;
    bool isInspectable = true;
    bool disableContextMenu = false;
    bool incognito = false;
    std::optional<std::vector<std::string>> javaScriptHandlersOriginAllowList = std::optional<std::vector<std::string>>{};
    bool javaScriptHandlersForMainFrameOnly = false;
    bool javaScriptBridgeEnabled = true;
    std::optional<std::vector<std::string>> javaScriptBridgeOriginAllowList = std::optional<std::vector<std::string>>{};
    std::optional<bool> javaScriptBridgeForMainFrameOnly = std::optional<bool>{};
    std::optional<std::vector<std::string>> pluginScriptsOriginAllowList = std::optional<std::vector<std::string>>{};
    bool pluginScriptsForMainFrameOnly = false;
    int64_t scrollMultiplier = 1;
    bool disableDefaultErrorPage = false;
    bool statusBarEnabled = true;
    bool browserAcceleratorKeysEnabled = true;
    bool generalAutofillEnabled = true;
    bool passwordAutosaveEnabled = false;
    bool pinchZoomEnabled = true;
    bool allowsBackForwardNavigationGestures = true;
    int64_t hiddenPdfToolbarItems = COREWEBVIEW2_PDF_TOOLBAR_ITEMS::COREWEBVIEW2_PDF_TOOLBAR_ITEMS_NONE;
    bool reputationCheckingRequired = true;
    bool nonClientRegionSupportEnabled = false;
    bool handleAcceleratorKeyPressed = false;

    InAppWebViewSettings();
    InAppWebViewSettings(const flutter::EncodableMap& encodableMap);
    ~InAppWebViewSettings();

    flutter::EncodableMap toEncodableMap() const;
    flutter::EncodableMap getRealSettings(const InAppWebView* inAppWebView) const;
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_