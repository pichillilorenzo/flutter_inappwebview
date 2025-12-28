#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_

#include <flutter_linux/flutter_linux.h>

// Use the appropriate WebKit header based on backend
#ifdef USE_WPE_WEBKIT
#include <wpe/webkit.h>
#else
#include <webkit2/webkit2.h>
#endif

#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

class InAppWebView;

/**
 * InAppWebViewSettings for Linux (WebKitGTK)
 *
 * This class maps Dart-side InAppWebViewSettings to WebKitGTK settings.
 * Settings are parsed from FlValue maps received via method channels.
 */
class InAppWebViewSettings {
 public:
  // === Event flags ===
  bool useShouldOverrideUrlLoading = false;
  bool useOnLoadResource = false;
  bool useOnDownloadStart = false;
  bool useShouldInterceptRequest = false;

  // === WebKit settings ===
  std::string userAgent;
  bool javaScriptEnabled = true;
  bool javaScriptCanOpenWindowsAutomatically = false;
  bool mediaPlaybackRequiresUserGesture = true;
  int minimumFontSize = 0;
  bool transparentBackground = false;
  bool supportZoom = true;
  bool isInspectable = true;
  bool disableContextMenu = false;

  // === JavaScript bridge settings ===
  std::optional<std::vector<std::string>> javaScriptHandlersOriginAllowList =
      std::optional<std::vector<std::string>>{};
  bool javaScriptHandlersForMainFrameOnly = false;
  bool javaScriptBridgeEnabled = true;
  std::optional<std::vector<std::string>> javaScriptBridgeOriginAllowList =
      std::optional<std::vector<std::string>>{};
  std::optional<bool> javaScriptBridgeForMainFrameOnly = std::optional<bool>{};
  std::optional<std::vector<std::string>> pluginScriptsOriginAllowList =
      std::optional<std::vector<std::string>>{};
  bool pluginScriptsForMainFrameOnly = false;

  // === WebKitGTK specific settings ===
  bool enableDeveloperExtras = true;  // Enable web inspector
  bool enableWriteConsoleMessagesToStdout = false;
  bool enableMediaStream = true;
  bool enableMediaSource = true;
  bool enableWebAudio = true;
  bool enableWebGL = true;
  bool enableSmoothScrolling = true;
  bool enableBackForwardNavigationGestures = false;
  bool enableHyperlinkAuditing = false;
  bool enableDnsPrefetching = true;
  bool enableCaretBrowsing = false;
  bool enableFullscreen = true;
  bool enableHtml5LocalStorage = true;
  bool enableHtml5Database = true;
  bool enableXssAuditor = true;
  bool enablePageCache = true;
  bool drawCompositingIndicators = false;
  bool enableResizableTextAreas = true;
  bool enableTabsToLinks = true;
  bool loadImagesAutomatically = true;
  bool enableSiteSpecificQuirks = true;
  bool enableJavaApplet = false;
  bool printBackgrounds = true;
  bool enableSpatialNavigation = false;
  std::string defaultCharset = "UTF-8";
  std::string defaultFontFamily;
  std::string monospaceFontFamily;
  std::string serifFontFamily;
  std::string sansSerifFontFamily;
  std::string cursiveFontFamily;
  std::string fantasyFontFamily;
  std::string pictographFontFamily;
  int defaultFontSize = 16;
  int defaultMonospaceFontSize = 13;
  int minimumLogicalFontSize = 0;

  // === Hardware acceleration ===
  bool hardwareAccelerationEnabled = true;  // Read from environment

  // === Snapshot/texture settings ===
  int64_t scrollMultiplier = 1;

  InAppWebViewSettings();
  explicit InAppWebViewSettings(FlValue* map);
  ~InAppWebViewSettings();

  /**
   * Apply these settings to a WebKitWebView.
   */
  void applyToWebView(WebKitWebView* webview) const;

  /**
   * Convert to FlValue map.
   */
  FlValue* toFlValue() const;

  /**
   * Get the actual settings from a WebKitWebView.
   */
  FlValue* getRealSettings(const InAppWebView* inAppWebView) const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_
