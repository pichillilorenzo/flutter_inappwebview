#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_SETTINGS_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

class InAppWebView;

/**
 * InAppWebViewSettings for Linux (WPE WebKit)
 *
 * This class maps Dart-side InAppWebViewSettings to WPE WebKit settings.
 * WPE WebKit shares most of its API with WebKitGTK, but this separate class
 * allows for WPE-specific optimizations and settings.
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

  // === WPE WebKit specific settings ===
  bool enableDeveloperExtras = true;
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
  bool enablePageCache = true;
  bool drawCompositingIndicators = false;
  bool enableResizableTextAreas = true;
  bool enableTabsToLinks = true;
  bool loadImagesAutomatically = true;
  bool enableSiteSpecificQuirks = true;
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

  // === WPE-specific rendering settings ===
  // WPE always uses hardware acceleration via its backend
  bool useDmaBufExport = true;  // Use DMA-BUF for zero-copy texture sharing
  bool enableWebInspector = false;  // Remote web inspector
  int webInspectorPort = 9222;  // Default inspector port
  
  // === Frame rate and performance settings ===
  int targetFrameRate = 60;  // Target FPS for rendering
  bool enableOffscreenRendering = true;  // Always true for WPE in Flutter

  // === Scroll settings ===
  int64_t scrollMultiplier = 1;

  InAppWebViewSettings();
  explicit InAppWebViewSettings(FlValue* map);
  ~InAppWebViewSettings();

  /**
   * Apply these settings to a WPE WebKitWebView.
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
