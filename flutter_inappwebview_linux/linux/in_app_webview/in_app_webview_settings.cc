// WPE WebKit settings implementation

#include "in_app_webview_settings.h"

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview.h"

#ifdef HAVE_WPE_PLATFORM
#include <wpe/wpe-platform.h>
#endif

namespace flutter_inappwebview_plugin {

InAppWebViewSettings::InAppWebViewSettings() {
  // Default constructor - all defaults are set in the header
}

InAppWebViewSettings::InAppWebViewSettings(FlValue* map) : InAppWebViewSettings() {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  // === Event flags ===
  useShouldOverrideUrlLoading =
      get_fl_map_value(map, "useShouldOverrideUrlLoading", useShouldOverrideUrlLoading);
  useOnLoadResource = get_fl_map_value(map, "useOnLoadResource", useOnLoadResource);
  useOnDownloadStart = get_fl_map_value(map, "useOnDownloadStart", useOnDownloadStart);
  useOnNavigationResponse = get_fl_map_value(map, "useOnNavigationResponse", useOnNavigationResponse);
  useShouldInterceptRequest =
      get_fl_map_value(map, "useShouldInterceptRequest", useShouldInterceptRequest);
  useShouldInterceptAjaxRequest =
      get_fl_map_value(map, "useShouldInterceptAjaxRequest", useShouldInterceptAjaxRequest);
  useOnAjaxReadyStateChange =
      get_fl_map_value(map, "useOnAjaxReadyStateChange", useOnAjaxReadyStateChange);
  useOnAjaxProgress = get_fl_map_value(map, "useOnAjaxProgress", useOnAjaxProgress);
  useShouldInterceptFetchRequest =
      get_fl_map_value(map, "useShouldInterceptFetchRequest", useShouldInterceptFetchRequest);

  // === WebKit settings ===
  userAgent = get_fl_map_value(map, "userAgent", userAgent);
  javaScriptEnabled = get_fl_map_value(map, "javaScriptEnabled", javaScriptEnabled);
  javaScriptCanOpenWindowsAutomatically = get_fl_map_value(
      map, "javaScriptCanOpenWindowsAutomatically", javaScriptCanOpenWindowsAutomatically);
  mediaPlaybackRequiresUserGesture =
      get_fl_map_value(map, "mediaPlaybackRequiresUserGesture", mediaPlaybackRequiresUserGesture);
  minimumFontSize = static_cast<int>(
      get_fl_map_value<int64_t>(map, "minimumFontSize", static_cast<int64_t>(minimumFontSize)));
  transparentBackground = get_fl_map_value(map, "transparentBackground", transparentBackground);
  supportZoom = get_fl_map_value(map, "supportZoom", supportZoom);
  isInspectable = get_fl_map_value(map, "isInspectable", isInspectable);
  disableContextMenu = get_fl_map_value(map, "disableContextMenu", disableContextMenu);

  // === JavaScript bridge settings ===
  if (fl_map_contains_not_null(map, "javaScriptHandlersOriginAllowList")) {
    javaScriptHandlersOriginAllowList =
        get_fl_map_value<std::vector<std::string>>(map, "javaScriptHandlersOriginAllowList", {});
  }
  javaScriptHandlersForMainFrameOnly = get_fl_map_value(map, "javaScriptHandlersForMainFrameOnly",
                                                        javaScriptHandlersForMainFrameOnly);
  javaScriptBridgeEnabled =
      get_fl_map_value(map, "javaScriptBridgeEnabled", javaScriptBridgeEnabled);
  if (fl_map_contains_not_null(map, "javaScriptBridgeOriginAllowList")) {
    javaScriptBridgeOriginAllowList =
        get_fl_map_value<std::vector<std::string>>(map, "javaScriptBridgeOriginAllowList", {});
  }
  if (fl_map_contains_not_null(map, "javaScriptBridgeForMainFrameOnly")) {
    javaScriptBridgeForMainFrameOnly =
        get_fl_map_value(map, "javaScriptBridgeForMainFrameOnly", false);
  }
  if (fl_map_contains_not_null(map, "pluginScriptsOriginAllowList")) {
    pluginScriptsOriginAllowList =
        get_fl_map_value<std::vector<std::string>>(map, "pluginScriptsOriginAllowList", {});
  }
  pluginScriptsForMainFrameOnly =
      get_fl_map_value(map, "pluginScriptsForMainFrameOnly", pluginScriptsForMainFrameOnly);

  // === WPE WebKit specific settings ===
  enableDeveloperExtras = get_fl_map_value(map, "enableDeveloperExtras", enableDeveloperExtras);
  enableWriteConsoleMessagesToStdout = get_fl_map_value(map, "enableWriteConsoleMessagesToStdout",
                                                        enableWriteConsoleMessagesToStdout);
  enableMediaStream = get_fl_map_value(map, "enableMediaStream", enableMediaStream);
  enableMediaSource = get_fl_map_value(map, "enableMediaSource", enableMediaSource);
  enableWebAudio = get_fl_map_value(map, "enableWebAudio", enableWebAudio);
  enableWebGL = get_fl_map_value(map, "enableWebGL", enableWebGL);
  enableSmoothScrolling = get_fl_map_value(map, "enableSmoothScrolling", enableSmoothScrolling);
  allowsBackForwardNavigationGestures = get_fl_map_value(map, "allowsBackForwardNavigationGestures",
                                                         allowsBackForwardNavigationGestures);
  enableHyperlinkAuditing =
      get_fl_map_value(map, "enableHyperlinkAuditing", enableHyperlinkAuditing);
  enableDnsPrefetching = get_fl_map_value(map, "enableDnsPrefetching", enableDnsPrefetching);
  enableCaretBrowsing = get_fl_map_value(map, "enableCaretBrowsing", enableCaretBrowsing);
  isElementFullscreenEnabled = get_fl_map_value(map, "isElementFullscreenEnabled", isElementFullscreenEnabled);
  enableHtml5LocalStorage =
      get_fl_map_value(map, "domStorageEnabled", enableHtml5LocalStorage);
  enableHtml5Database = get_fl_map_value(map, "databaseEnabled", enableHtml5Database);
  enablePageCache = get_fl_map_value(map, "enablePageCache", enablePageCache);
  drawCompositingIndicators =
      get_fl_map_value(map, "drawCompositingIndicators", drawCompositingIndicators);
  enableResizableTextAreas =
      get_fl_map_value(map, "enableResizableTextAreas", enableResizableTextAreas);
  enableTabsToLinks = get_fl_map_value(map, "enableTabsToLinks", enableTabsToLinks);
  loadsImagesAutomatically =
      get_fl_map_value(map, "loadsImagesAutomatically", loadsImagesAutomatically);
  isSiteSpecificQuirksModeEnabled =
      get_fl_map_value(map, "isSiteSpecificQuirksModeEnabled", isSiteSpecificQuirksModeEnabled);
  printBackgrounds = get_fl_map_value(map, "printBackgrounds", printBackgrounds);
  enableSpatialNavigation =
      get_fl_map_value(map, "enableSpatialNavigation", enableSpatialNavigation);
  defaultTextEncodingName = get_fl_map_value(map, "defaultTextEncodingName", defaultTextEncodingName);
  standardFontFamily = get_fl_map_value(map, "standardFontFamily", standardFontFamily);
  fixedFontFamily = get_fl_map_value(map, "fixedFontFamily", fixedFontFamily);
  serifFontFamily = get_fl_map_value(map, "serifFontFamily", serifFontFamily);
  sansSerifFontFamily = get_fl_map_value(map, "sansSerifFontFamily", sansSerifFontFamily);
  cursiveFontFamily = get_fl_map_value(map, "cursiveFontFamily", cursiveFontFamily);
  fantasyFontFamily = get_fl_map_value(map, "fantasyFontFamily", fantasyFontFamily);
  pictographFontFamily = get_fl_map_value(map, "pictographFontFamily", pictographFontFamily);
  defaultFontSize = static_cast<int>(
      get_fl_map_value<int64_t>(map, "defaultFontSize", static_cast<int64_t>(defaultFontSize)));
  defaultFixedFontSize = static_cast<int>(get_fl_map_value<int64_t>(
      map, "defaultFixedFontSize", static_cast<int64_t>(defaultFixedFontSize)));
  minimumLogicalFontSize = static_cast<int>(get_fl_map_value<int64_t>(
      map, "minimumLogicalFontSize", static_cast<int64_t>(minimumLogicalFontSize)));

  // === Security settings ===
  allowFileAccessFromFileURLs = get_fl_map_value(map, "allowFileAccessFromFileURLs", allowFileAccessFromFileURLs);
  allowUniversalAccessFromFileURLs = get_fl_map_value(map, "allowUniversalAccessFromFileURLs", allowUniversalAccessFromFileURLs);
  disableWebSecurity = get_fl_map_value(map, "disableWebSecurity", disableWebSecurity);
  allowTopNavigationToDataUrls = get_fl_map_value(map, "allowTopNavigationToDataUrls", allowTopNavigationToDataUrls);

  // === Clipboard settings ===
  javaScriptCanAccessClipboard = get_fl_map_value(map, "javaScriptCanAccessClipboard", javaScriptCanAccessClipboard);

  // === WebRTC settings ===
  enableWebRTC = get_fl_map_value(map, "enableWebRTC", enableWebRTC);
  webRTCUdpPortsRange = get_fl_map_value(map, "webRTCUdpPortsRange", webRTCUdpPortsRange);

  // === Media settings ===
  allowsInlineMediaPlayback = get_fl_map_value(map, "allowsInlineMediaPlayback", allowsInlineMediaPlayback);
  enableMedia = get_fl_map_value(map, "enableMedia", enableMedia);
  enableEncryptedMedia = get_fl_map_value(map, "enableEncryptedMedia", enableEncryptedMedia);
  enableMediaCapabilities = get_fl_map_value(map, "enableMediaCapabilities", enableMediaCapabilities);
  enableMockCaptureDevices = get_fl_map_value(map, "enableMockCaptureDevices", enableMockCaptureDevices);
  mediaContentTypesRequiringHardwareSupport = get_fl_map_value(map, "mediaContentTypesRequiringHardwareSupport", mediaContentTypesRequiringHardwareSupport);

  // === Other settings ===
  enableJavaScriptMarkup = get_fl_map_value(map, "enableJavaScriptMarkup", enableJavaScriptMarkup);
  enable2DCanvasAcceleration = get_fl_map_value(map, "enable2DCanvasAcceleration", enable2DCanvasAcceleration);
  allowModalDialogs = get_fl_map_value(map, "allowModalDialogs", allowModalDialogs);

  // === WPE Platform settings ===
  if (fl_map_contains_not_null(map, "darkMode")) {
    darkMode = get_fl_map_value<bool>(map, "darkMode", false);
  }
  if (fl_map_contains_not_null(map, "disableAnimations")) {
    disableAnimations = get_fl_map_value<bool>(map, "disableAnimations", false);
  }
  if (fl_map_contains_not_null(map, "fontAntialias")) {
    fontAntialias = get_fl_map_value<bool>(map, "fontAntialias", true);
  }
  if (fl_map_contains_not_null(map, "fontHintingStyle")) {
    fontHintingStyle = static_cast<int>(
        get_fl_map_value<int64_t>(map, "fontHintingStyle", 0));
  }
  if (fl_map_contains_not_null(map, "fontSubpixelLayout")) {
    fontSubpixelLayout = static_cast<int>(
        get_fl_map_value<int64_t>(map, "fontSubpixelLayout", 0));
  }
  if (fl_map_contains_not_null(map, "fontDPI")) {
    fontDPI = get_fl_map_value<double>(map, "fontDPI", 96.0);
  }
  if (fl_map_contains_not_null(map, "cursorBlinkTime")) {
    cursorBlinkTime = static_cast<int>(
        get_fl_map_value<int64_t>(map, "cursorBlinkTime", 1200));
  }
  if (fl_map_contains_not_null(map, "doubleClickDistance")) {
    doubleClickDistance = static_cast<int>(
        get_fl_map_value<int64_t>(map, "doubleClickDistance", 5));
  }
  if (fl_map_contains_not_null(map, "doubleClickTime")) {
    doubleClickTime = static_cast<int>(
        get_fl_map_value<int64_t>(map, "doubleClickTime", 400));
  }
  if (fl_map_contains_not_null(map, "dragThreshold")) {
    dragThreshold = static_cast<int>(
        get_fl_map_value<int64_t>(map, "dragThreshold", 8));
  }
  if (fl_map_contains_not_null(map, "keyRepeatDelay")) {
    keyRepeatDelay = static_cast<int>(
        get_fl_map_value<int64_t>(map, "keyRepeatDelay", 400));
  }
  if (fl_map_contains_not_null(map, "keyRepeatInterval")) {
    keyRepeatInterval = static_cast<int>(
        get_fl_map_value<int64_t>(map, "keyRepeatInterval", 80));
  }

  // === Scroll settings ===
  scrollMultiplier = get_fl_map_value<int64_t>(map, "scrollMultiplier", scrollMultiplier);

  // === Custom Scheme Handler settings ===
  if (fl_map_contains_not_null(map, "resourceCustomSchemes")) {
    resourceCustomSchemes =
        get_fl_map_value<std::vector<std::string>>(map, "resourceCustomSchemes", {});
  }

  // === Incognito mode ===
  incognito = get_fl_map_value(map, "incognito", incognito);

  // === CORS allowlist ===
  if (fl_map_contains_not_null(map, "corsAllowlist")) {
    corsAllowlist =
        get_fl_map_value<std::vector<std::string>>(map, "corsAllowlist", {});
  }

  // === ITP (Intelligent Tracking Prevention) ===
  itpEnabled = get_fl_map_value(map, "itpEnabled", itpEnabled);

  // === Content Blockers ===
  // Store the raw FlValue for later use by ContentBlockerHandler
  if (fl_map_contains_not_null(map, "contentBlockers")) {
    FlValue* blockers = fl_value_lookup_string(map, "contentBlockers");
    if (blockers != nullptr && fl_value_get_type(blockers) == FL_VALUE_TYPE_LIST) {
      contentBlockers = fl_value_ref(blockers);
    }
  }
}

void InAppWebViewSettings::applyToWebView(WebKitWebView* webview) const {
  if (webview == nullptr) {
    return;
  }

  WebKitSettings* settings = webkit_web_view_get_settings(webview);
  if (settings == nullptr) {
    return;
  }

  // Apply user agent
  if (!userAgent.empty()) {
    webkit_settings_set_user_agent(settings, userAgent.c_str());
  }

  // JavaScript settings
  webkit_settings_set_enable_javascript(settings, javaScriptEnabled);
  webkit_settings_set_javascript_can_open_windows_automatically(
      settings, javaScriptCanOpenWindowsAutomatically);
  webkit_settings_set_media_playback_requires_user_gesture(settings,
                                                           mediaPlaybackRequiresUserGesture);

  // Font settings
  if (minimumFontSize > 0) {
    webkit_settings_set_minimum_font_size(settings, minimumFontSize);
  }
  if (defaultFontSize > 0) {
    webkit_settings_set_default_font_size(settings, defaultFontSize);
  }
  if (defaultFixedFontSize > 0) {
    webkit_settings_set_default_monospace_font_size(settings, defaultFixedFontSize);
  }
  // Note: webkit_settings_set_minimum_logical_font_size is not available in WPE 2.0 API

  // Font families
  if (!standardFontFamily.empty()) {
    webkit_settings_set_default_font_family(settings, standardFontFamily.c_str());
  }
  if (!fixedFontFamily.empty()) {
    webkit_settings_set_monospace_font_family(settings, fixedFontFamily.c_str());
  }
  if (!serifFontFamily.empty()) {
    webkit_settings_set_serif_font_family(settings, serifFontFamily.c_str());
  }
  if (!sansSerifFontFamily.empty()) {
    webkit_settings_set_sans_serif_font_family(settings, sansSerifFontFamily.c_str());
  }
  if (!cursiveFontFamily.empty()) {
    webkit_settings_set_cursive_font_family(settings, cursiveFontFamily.c_str());
  }
  if (!fantasyFontFamily.empty()) {
    webkit_settings_set_fantasy_font_family(settings, fantasyFontFamily.c_str());
  }
  if (!pictographFontFamily.empty()) {
    webkit_settings_set_pictograph_font_family(settings, pictographFontFamily.c_str());
  }

  // Charset
  if (!defaultTextEncodingName.empty()) {
    webkit_settings_set_default_charset(settings, defaultTextEncodingName.c_str());
  }

  // Media settings
  webkit_settings_set_enable_media_stream(settings, enableMediaStream);
  webkit_settings_set_enable_mediasource(settings, enableMediaSource);
  webkit_settings_set_enable_webaudio(settings, enableWebAudio);
  webkit_settings_set_enable_webgl(settings, enableWebGL);

  // Developer tools
  webkit_settings_set_enable_developer_extras(settings, enableDeveloperExtras);
  webkit_settings_set_enable_write_console_messages_to_stdout(settings,
                                                              enableWriteConsoleMessagesToStdout);

  // Navigation
  webkit_settings_set_enable_smooth_scrolling(settings, enableSmoothScrolling);
  // Note: Back-forward gestures not available in WPE (requires touch/gesture backend)
  webkit_settings_set_enable_caret_browsing(settings, enableCaretBrowsing);
  webkit_settings_set_enable_spatial_navigation(settings, enableSpatialNavigation);
  // Note: DNS prefetching and hyperlink auditing are deprecated in WPE 2.50+

  // Content settings
  webkit_settings_set_enable_fullscreen(settings, isElementFullscreenEnabled);
  webkit_settings_set_auto_load_images(settings, loadsImagesAutomatically);
  webkit_settings_set_enable_resizable_text_areas(settings, enableResizableTextAreas);
  webkit_settings_set_enable_tabs_to_links(settings, enableTabsToLinks);
  webkit_settings_set_enable_site_specific_quirks(settings, isSiteSpecificQuirksModeEnabled);
  webkit_settings_set_print_backgrounds(settings, printBackgrounds);
  webkit_settings_set_enable_page_cache(settings, enablePageCache);

  // HTML5 features
  // Note: offline web application cache is deprecated in WPE 2.50+
  webkit_settings_set_enable_html5_local_storage(settings, enableHtml5LocalStorage);
  webkit_settings_set_enable_html5_database(settings, enableHtml5Database);

  // Zoom settings
  webkit_settings_set_zoom_text_only(settings, !supportZoom);

  // Debugging
  webkit_settings_set_draw_compositing_indicators(settings, drawCompositingIndicators);

  // Set background color
  if (transparentBackground) {
    WebKitColor bg = {0.0, 0.0, 0.0, 0.0};
    webkit_web_view_set_background_color(webview, &bg);
  }

  // Apply CORS allowlist
  if (corsAllowlist.has_value()) {
    if (corsAllowlist->empty()) {
      // Empty list clears the allowlist
      webkit_web_view_set_cors_allowlist(webview, nullptr);
    } else {
      // Convert std::vector<std::string> to null-terminated array of C strings
      std::vector<const char*> allowlist_ptrs;
      allowlist_ptrs.reserve(corsAllowlist->size() + 1);
      for (const auto& pattern : *corsAllowlist) {
        allowlist_ptrs.push_back(pattern.c_str());
      }
      allowlist_ptrs.push_back(nullptr);  // NULL terminator
      webkit_web_view_set_cors_allowlist(webview, allowlist_ptrs.data());
    }
  }

  // Security settings
  webkit_settings_set_allow_file_access_from_file_urls(settings, allowFileAccessFromFileURLs);
  webkit_settings_set_allow_universal_access_from_file_urls(settings, allowUniversalAccessFromFileURLs);
  webkit_settings_set_disable_web_security(settings, disableWebSecurity);
  webkit_settings_set_allow_top_navigation_to_data_urls(settings, allowTopNavigationToDataUrls);

  // Clipboard
  webkit_settings_set_javascript_can_access_clipboard(settings, javaScriptCanAccessClipboard);

  // WebRTC
  webkit_settings_set_enable_webrtc(settings, enableWebRTC);
  if (!webRTCUdpPortsRange.empty()) {
    webkit_settings_set_webrtc_udp_ports_range(settings, webRTCUdpPortsRange.c_str());
  }

  // Media settings
  webkit_settings_set_media_playback_allows_inline(settings, allowsInlineMediaPlayback);
  webkit_settings_set_enable_media(settings, enableMedia);
  webkit_settings_set_enable_encrypted_media(settings, enableEncryptedMedia);
  webkit_settings_set_enable_media_capabilities(settings, enableMediaCapabilities);
  webkit_settings_set_enable_mock_capture_devices(settings, enableMockCaptureDevices);
  if (!mediaContentTypesRequiringHardwareSupport.empty()) {
    webkit_settings_set_media_content_types_requiring_hardware_support(settings, mediaContentTypesRequiringHardwareSupport.c_str());
  }

  // Other settings
  webkit_settings_set_enable_javascript_markup(settings, enableJavaScriptMarkup);
  webkit_settings_set_enable_2d_canvas_acceleration(settings, enable2DCanvasAcceleration);
  webkit_settings_set_allow_modal_dialogs(settings, allowModalDialogs);
}

#ifdef HAVE_WPE_PLATFORM
void InAppWebViewSettings::applyWpePlatformSettings(void* display_ptr) const {
  if (display_ptr == nullptr) {
    return;
  }

  WPEDisplay* display = static_cast<WPEDisplay*>(display_ptr);
  WPESettings* wpe_settings = wpe_display_get_settings(display);
  if (wpe_settings == nullptr) {
    return;
  }

  GError* error = nullptr;

  // Apply dark mode setting
  if (darkMode.has_value()) {
    wpe_settings_set_boolean(wpe_settings, WPE_SETTING_DARK_MODE,
                             darkMode.value(), WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply disable animations setting
  if (disableAnimations.has_value()) {
    wpe_settings_set_boolean(wpe_settings, WPE_SETTING_DISABLE_ANIMATIONS,
                             disableAnimations.value(), WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply font antialias setting
  if (fontAntialias.has_value()) {
    wpe_settings_set_boolean(wpe_settings, WPE_SETTING_FONT_ANTIALIAS,
                             fontAntialias.value(), WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply font hinting style
  if (fontHintingStyle.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_FONT_HINTING_STYLE,
                            static_cast<uint32_t>(fontHintingStyle.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply font subpixel layout
  if (fontSubpixelLayout.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_FONT_SUBPIXEL_LAYOUT,
                            static_cast<uint32_t>(fontSubpixelLayout.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply font DPI
  if (fontDPI.has_value()) {
    wpe_settings_set_double(wpe_settings, WPE_SETTING_FONT_DPI,
                            fontDPI.value(), WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply cursor blink time
  if (cursorBlinkTime.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_CURSOR_BLINK_TIME,
                            static_cast<uint32_t>(cursorBlinkTime.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply double-click distance
  if (doubleClickDistance.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_DOUBLE_CLICK_DISTANCE,
                            static_cast<uint32_t>(doubleClickDistance.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply double-click time
  if (doubleClickTime.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_DOUBLE_CLICK_TIME,
                            static_cast<uint32_t>(doubleClickTime.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply drag threshold
  if (dragThreshold.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_DRAG_THRESHOLD,
                            static_cast<uint32_t>(dragThreshold.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply key repeat delay
  if (keyRepeatDelay.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_KEY_REPEAT_DELAY,
                            static_cast<uint32_t>(keyRepeatDelay.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }

  // Apply key repeat interval
  if (keyRepeatInterval.has_value()) {
    wpe_settings_set_uint32(wpe_settings, WPE_SETTING_KEY_REPEAT_INTERVAL,
                            static_cast<uint32_t>(keyRepeatInterval.value()),
                            WPE_SETTINGS_SOURCE_APPLICATION, &error);
    g_clear_error(&error);
  }
}
#endif

FlValue* InAppWebViewSettings::toFlValue() const {
  return to_fl_map({
      // === Event flags ===
      {"useShouldOverrideUrlLoading", make_fl_value(useShouldOverrideUrlLoading)},
      {"useOnLoadResource", make_fl_value(useOnLoadResource)},
      {"useOnDownloadStart", make_fl_value(useOnDownloadStart)},
      {"useOnNavigationResponse", make_fl_value(useOnNavigationResponse)},
      {"useShouldInterceptRequest", make_fl_value(useShouldInterceptRequest)},
      {"useShouldInterceptAjaxRequest", make_fl_value(useShouldInterceptAjaxRequest)},
      {"useOnAjaxReadyStateChange", make_fl_value(useOnAjaxReadyStateChange)},
      {"useOnAjaxProgress", make_fl_value(useOnAjaxProgress)},
      {"useShouldInterceptFetchRequest", make_fl_value(useShouldInterceptFetchRequest)},

      // === WebKit settings ===
      {"userAgent", make_fl_value(userAgent)},
      {"javaScriptEnabled", make_fl_value(javaScriptEnabled)},
      {"javaScriptCanOpenWindowsAutomatically", make_fl_value(javaScriptCanOpenWindowsAutomatically)},
      {"mediaPlaybackRequiresUserGesture", make_fl_value(mediaPlaybackRequiresUserGesture)},
      {"minimumFontSize", make_fl_value(minimumFontSize)},
      {"transparentBackground", make_fl_value(transparentBackground)},
      {"supportZoom", make_fl_value(supportZoom)},
      {"isInspectable", make_fl_value(isInspectable)},
      {"disableContextMenu", make_fl_value(disableContextMenu)},

      // === JavaScript bridge settings ===
      {"javaScriptBridgeEnabled", make_fl_value(javaScriptBridgeEnabled)},
      {"javaScriptHandlersForMainFrameOnly", make_fl_value(javaScriptHandlersForMainFrameOnly)},
      {"pluginScriptsForMainFrameOnly", make_fl_value(pluginScriptsForMainFrameOnly)},

      // === WPE WebKit specific settings ===
      {"enableDeveloperExtras", make_fl_value(enableDeveloperExtras)},
      {"enableWriteConsoleMessagesToStdout", make_fl_value(enableWriteConsoleMessagesToStdout)},
      {"enableMediaStream", make_fl_value(enableMediaStream)},
      {"enableMediaSource", make_fl_value(enableMediaSource)},
      {"enableWebAudio", make_fl_value(enableWebAudio)},
      {"enableWebGL", make_fl_value(enableWebGL)},
      {"enableSmoothScrolling", make_fl_value(enableSmoothScrolling)},
      {"allowsBackForwardNavigationGestures", make_fl_value(allowsBackForwardNavigationGestures)},
      {"enableHyperlinkAuditing", make_fl_value(enableHyperlinkAuditing)},
      {"enableDnsPrefetching", make_fl_value(enableDnsPrefetching)},
      {"enableCaretBrowsing", make_fl_value(enableCaretBrowsing)},
      {"isElementFullscreenEnabled", make_fl_value(isElementFullscreenEnabled)},
      {"domStorageEnabled", make_fl_value(enableHtml5LocalStorage)},
      {"databaseEnabled", make_fl_value(enableHtml5Database)},
      {"enablePageCache", make_fl_value(enablePageCache)},
      {"drawCompositingIndicators", make_fl_value(drawCompositingIndicators)},
      {"enableResizableTextAreas", make_fl_value(enableResizableTextAreas)},
      {"enableTabsToLinks", make_fl_value(enableTabsToLinks)},
      {"loadsImagesAutomatically", make_fl_value(loadsImagesAutomatically)},
      {"isSiteSpecificQuirksModeEnabled", make_fl_value(isSiteSpecificQuirksModeEnabled)},
      {"printBackgrounds", make_fl_value(printBackgrounds)},
      {"enableSpatialNavigation", make_fl_value(enableSpatialNavigation)},
      {"defaultTextEncodingName", make_fl_value(defaultTextEncodingName)},
      {"standardFontFamily", make_fl_value(standardFontFamily)},
      {"fixedFontFamily", make_fl_value(fixedFontFamily)},
      {"serifFontFamily", make_fl_value(serifFontFamily)},
      {"sansSerifFontFamily", make_fl_value(sansSerifFontFamily)},
      {"cursiveFontFamily", make_fl_value(cursiveFontFamily)},
      {"fantasyFontFamily", make_fl_value(fantasyFontFamily)},
      {"pictographFontFamily", make_fl_value(pictographFontFamily)},
      {"defaultFontSize", make_fl_value(defaultFontSize)},
      {"defaultFixedFontSize", make_fl_value(defaultFixedFontSize)},
      {"minimumLogicalFontSize", make_fl_value(minimumLogicalFontSize)},

      // === Security settings ===
      {"allowFileAccessFromFileURLs", make_fl_value(allowFileAccessFromFileURLs)},
      {"allowUniversalAccessFromFileURLs", make_fl_value(allowUniversalAccessFromFileURLs)},
      {"disableWebSecurity", make_fl_value(disableWebSecurity)},
      {"allowTopNavigationToDataUrls", make_fl_value(allowTopNavigationToDataUrls)},

      // === Clipboard ===
      {"javaScriptCanAccessClipboard", make_fl_value(javaScriptCanAccessClipboard)},

      // === WebRTC ===
      {"enableWebRTC", make_fl_value(enableWebRTC)},
      {"webRTCUdpPortsRange", make_fl_value(webRTCUdpPortsRange)},

      // === Media settings ===
      {"allowsInlineMediaPlayback", make_fl_value(allowsInlineMediaPlayback)},
      {"enableMedia", make_fl_value(enableMedia)},
      {"enableEncryptedMedia", make_fl_value(enableEncryptedMedia)},
      {"enableMediaCapabilities", make_fl_value(enableMediaCapabilities)},
      {"enableMockCaptureDevices", make_fl_value(enableMockCaptureDevices)},
      {"mediaContentTypesRequiringHardwareSupport", make_fl_value(mediaContentTypesRequiringHardwareSupport)},

      // === Other settings ===
      {"enableJavaScriptMarkup", make_fl_value(enableJavaScriptMarkup)},
      {"enable2DCanvasAcceleration", make_fl_value(enable2DCanvasAcceleration)},
      {"allowModalDialogs", make_fl_value(allowModalDialogs)},

      // === Scroll settings ===
      {"scrollMultiplier", make_fl_value(scrollMultiplier)},

      // === Incognito mode ===
      {"incognito", make_fl_value(incognito)},

      // === CORS allowlist (handles std::optional automatically) ===
      {"corsAllowlist", make_fl_value(corsAllowlist)},

      // === ITP ===
      {"itpEnabled", make_fl_value(itpEnabled)},
  });
}

FlValue* InAppWebViewSettings::getRealSettings(const InAppWebView* inAppWebView) const {
  if (inAppWebView == nullptr || inAppWebView->webview() == nullptr) {
    return fl_value_new_map();
  }

  WebKitSettings* settings = webkit_web_view_get_settings(inAppWebView->webview());
  if (settings == nullptr) {
    return fl_value_new_map();
  }

  // Get actual settings from WebKit
  const gchar* ua = webkit_settings_get_user_agent(settings);

  return to_fl_map({
      {"userAgent", ua != nullptr ? make_fl_value(std::string(ua)) : fl_value_new_null()},
      {"javaScriptEnabled", make_fl_value(static_cast<bool>(webkit_settings_get_enable_javascript(settings)))},
      {"javaScriptCanOpenWindowsAutomatically", make_fl_value(static_cast<bool>(webkit_settings_get_javascript_can_open_windows_automatically(settings)))},
      {"mediaPlaybackRequiresUserGesture", make_fl_value(static_cast<bool>(webkit_settings_get_media_playback_requires_user_gesture(settings)))},
      {"minimumFontSize", make_fl_value(static_cast<int64_t>(webkit_settings_get_minimum_font_size(settings)))},
      {"defaultFontSize", make_fl_value(static_cast<int64_t>(webkit_settings_get_default_font_size(settings)))},
      {"defaultMonospaceFontSize", make_fl_value(static_cast<int64_t>(webkit_settings_get_default_monospace_font_size(settings)))},
      {"zoomLevel", make_fl_value(webkit_web_view_get_zoom_level(inAppWebView->webview()))},
  });
}

InAppWebViewSettings::~InAppWebViewSettings() {
  // Clean up contentBlockers FlValue if we own it
  if (contentBlockers != nullptr) {
    fl_value_unref(contentBlockers);
    contentBlockers = nullptr;
  }
}

}  // namespace flutter_inappwebview_plugin
