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
  bool useOnNavigationResponse = false;
  bool useShouldInterceptRequest = false;
  bool useShouldInterceptAjaxRequest = false;
  bool useOnAjaxReadyStateChange = false;
  bool useOnAjaxProgress = false;
  bool useShouldInterceptFetchRequest = false;

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
  bool allowsBackForwardNavigationGestures = false;
  bool enableHyperlinkAuditing = false;
  bool enableDnsPrefetching = true;
  bool enableCaretBrowsing = false;
  bool isElementFullscreenEnabled = true;
  bool enableHtml5LocalStorage = true;
  bool enableHtml5Database = true;
  bool enablePageCache = true;
  bool drawCompositingIndicators = false;
  bool enableResizableTextAreas = true;
  bool enableTabsToLinks = true;
  bool loadsImagesAutomatically = true;
  bool isSiteSpecificQuirksModeEnabled = true;
  bool printBackgrounds = true;
  bool enableSpatialNavigation = false;
  std::string defaultTextEncodingName = "UTF-8";
  std::string standardFontFamily;
  std::string fixedFontFamily;
  std::string serifFontFamily;
  std::string sansSerifFontFamily;
  std::string cursiveFontFamily;
  std::string fantasyFontFamily;
  std::string pictographFontFamily;
  int defaultFontSize = 16;
  int defaultFixedFontSize = 13;
  int minimumLogicalFontSize = 0;

  // === Security settings ===
  bool allowFileAccessFromFileURLs = false;  // Security: default false
  bool allowUniversalAccessFromFileURLs = false;  // Security: default false
  bool disableWebSecurity = false;  // Security: default false
  bool allowTopNavigationToDataUrls = false;  // Security: default false

  // === Clipboard settings ===
  bool javaScriptCanAccessClipboard = false;  // Security: default false

  // === WebRTC settings ===
  bool enableWebRTC = true;  // Enable by default for video chat apps
  std::string webRTCUdpPortsRange;  // Format: "minPort:maxPort"

  // === Media settings ===
  bool allowsInlineMediaPlayback = true;  // Desktop default
  bool enableMedia = true;
  bool enableEncryptedMedia = false;  // DRM - requires setup
  bool enableMediaCapabilities = true;
  bool enableMockCaptureDevices = false;  // Testing only
  std::string mediaContentTypesRequiringHardwareSupport;  // Semicolon-separated MIME types

  // === Other settings ===
  bool enableJavaScriptMarkup = true;
  bool enable2DCanvasAcceleration = true;  // Performance
  bool allowModalDialogs = true;

  // === WPE Platform settings ===
  // These settings use the WPE Platform API (available when HAVE_WPE_PLATFORM is defined)
  std::optional<bool> darkMode;              // Dark mode for websites (prefers-color-scheme)
  std::optional<bool> disableAnimations;     // Reduce motion for accessibility
  std::optional<bool> fontAntialias;         // Font antialiasing
  std::optional<int> fontHintingStyle;       // Font hinting (0=none, 1=slight, 2=medium, 3=full)
  std::optional<int> fontSubpixelLayout;     // Subpixel layout (0=RGB, 1=BGR, 2=VRGB, 3=VBGR)
  std::optional<double> fontDPI;             // Font DPI (default 96.0)
  std::optional<int> cursorBlinkTime;        // Cursor blink time in ms
  std::optional<int> doubleClickDistance;    // Double-click threshold in px
  std::optional<int> doubleClickTime;        // Double-click timeout in ms
  std::optional<int> dragThreshold;          // Drag gesture threshold in px
  std::optional<int> keyRepeatDelay;         // Key repeat delay in ms
  std::optional<int> keyRepeatInterval;      // Key repeat interval in ms

  // === Scroll settings ===
  int64_t scrollMultiplier = 1;

  // === Custom Scheme Handler settings ===
  std::vector<std::string> resourceCustomSchemes;

  // === Incognito mode ===
  // When true, creates an ephemeral network session (no persistent storage)
  bool incognito = false;

  // === CORS allowlist ===
  // List of URI patterns for which CORS checks are disabled
  // Pattern format: [protocol]://[host]:[port]
  std::optional<std::vector<std::string>> corsAllowlist;

  // === ITP (Intelligent Tracking Prevention) ===
  // When true, enables ITP which collects resource load statistics
  // to decide whether to allow/block third-party cookies
  // Note: This is a session-level setting applied during WebView creation
  bool itpEnabled = false;

  // === Content Blockers ===
  // Raw FlValue* list of content blocker rules (stored for later application)
  // Each rule is a map with "trigger" and "action" keys
  FlValue* contentBlockers = nullptr;

  InAppWebViewSettings();
  explicit InAppWebViewSettings(FlValue* map);
  ~InAppWebViewSettings();

  /**
   * Apply these settings to a WPE WebKitWebView.
   */
  void applyToWebView(WebKitWebView* webview) const;

#ifdef HAVE_WPE_PLATFORM
  /**
   * Apply WPE Platform settings using the WPE Settings API.
   * @param display The WPE display to get settings from
   */
  void applyWpePlatformSettings(void* display) const;
#endif

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
