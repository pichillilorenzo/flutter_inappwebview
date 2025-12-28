#include "in_app_webview_settings.h"

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview.h"

#include <cstdlib>

namespace flutter_inappwebview_plugin {

InAppWebViewSettings::InAppWebViewSettings() {
  // Check environment variable for hardware acceleration
  const char* hw_accel_env =
      std::getenv("FLUTTER_INAPPWEBVIEW_LINUX_WEBKIT_HW_ACCEL");
  if (hw_accel_env != nullptr) {
    hardwareAccelerationEnabled = (std::string(hw_accel_env) == "1");
  }
}

InAppWebViewSettings::InAppWebViewSettings(FlValue* map) : InAppWebViewSettings() {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  // === Event flags ===
  useShouldOverrideUrlLoading = get_fl_map_value(
      map, "useShouldOverrideUrlLoading", useShouldOverrideUrlLoading);
  useOnLoadResource =
      get_fl_map_value(map, "useOnLoadResource", useOnLoadResource);
  useOnDownloadStart =
      get_fl_map_value(map, "useOnDownloadStart", useOnDownloadStart);
  useShouldInterceptRequest =
      get_fl_map_value(map, "useShouldInterceptRequest", useShouldInterceptRequest);

  // === WebKit settings ===
  userAgent = get_fl_map_value(map, "userAgent", userAgent);
  javaScriptEnabled =
      get_fl_map_value(map, "javaScriptEnabled", javaScriptEnabled);
  javaScriptCanOpenWindowsAutomatically = get_fl_map_value(
      map, "javaScriptCanOpenWindowsAutomatically",
      javaScriptCanOpenWindowsAutomatically);
  mediaPlaybackRequiresUserGesture = get_fl_map_value(
      map, "mediaPlaybackRequiresUserGesture", mediaPlaybackRequiresUserGesture);
  minimumFontSize =
      static_cast<int>(get_fl_map_value<int64_t>(map, "minimumFontSize",
                                                  static_cast<int64_t>(minimumFontSize)));
  transparentBackground =
      get_fl_map_value(map, "transparentBackground", transparentBackground);
  supportZoom = get_fl_map_value(map, "supportZoom", supportZoom);
  isInspectable = get_fl_map_value(map, "isInspectable", isInspectable);
  disableContextMenu =
      get_fl_map_value(map, "disableContextMenu", disableContextMenu);

  // === JavaScript bridge settings ===
  if (fl_map_contains_not_null(map, "javaScriptHandlersOriginAllowList")) {
    javaScriptHandlersOriginAllowList =
        get_optional_fl_map_value<std::vector<std::string>>(
            map, "javaScriptHandlersOriginAllowList");
  }
  javaScriptHandlersForMainFrameOnly = get_fl_map_value(
      map, "javaScriptHandlersForMainFrameOnly", javaScriptHandlersForMainFrameOnly);
  javaScriptBridgeEnabled =
      get_fl_map_value(map, "javaScriptBridgeEnabled", javaScriptBridgeEnabled);
  if (fl_map_contains_not_null(map, "javaScriptBridgeOriginAllowList")) {
    javaScriptBridgeOriginAllowList =
        get_optional_fl_map_value<std::vector<std::string>>(
            map, "javaScriptBridgeOriginAllowList");
  }
  if (fl_map_contains_not_null(map, "javaScriptBridgeForMainFrameOnly")) {
    javaScriptBridgeForMainFrameOnly =
        get_optional_fl_map_value<bool>(map, "javaScriptBridgeForMainFrameOnly");
  }
  if (fl_map_contains_not_null(map, "pluginScriptsOriginAllowList")) {
    pluginScriptsOriginAllowList =
        get_optional_fl_map_value<std::vector<std::string>>(
            map, "pluginScriptsOriginAllowList");
  }
  pluginScriptsForMainFrameOnly = get_fl_map_value(
      map, "pluginScriptsForMainFrameOnly", pluginScriptsForMainFrameOnly);

  // === WebKitGTK specific settings ===
  enableDeveloperExtras =
      get_fl_map_value(map, "enableDeveloperExtras", enableDeveloperExtras);
  enableWriteConsoleMessagesToStdout = get_fl_map_value(
      map, "enableWriteConsoleMessagesToStdout", enableWriteConsoleMessagesToStdout);
  enableMediaStream =
      get_fl_map_value(map, "enableMediaStream", enableMediaStream);
  enableMediaSource =
      get_fl_map_value(map, "enableMediaSource", enableMediaSource);
  enableWebAudio = get_fl_map_value(map, "enableWebAudio", enableWebAudio);
  enableWebGL = get_fl_map_value(map, "enableWebGL", enableWebGL);
  enableSmoothScrolling =
      get_fl_map_value(map, "enableSmoothScrolling", enableSmoothScrolling);
  enableBackForwardNavigationGestures = get_fl_map_value(
      map, "enableBackForwardNavigationGestures",
      enableBackForwardNavigationGestures);
  enableHyperlinkAuditing =
      get_fl_map_value(map, "enableHyperlinkAuditing", enableHyperlinkAuditing);
  enableDnsPrefetching =
      get_fl_map_value(map, "enableDnsPrefetching", enableDnsPrefetching);
  enableCaretBrowsing =
      get_fl_map_value(map, "enableCaretBrowsing", enableCaretBrowsing);
  enableFullscreen =
      get_fl_map_value(map, "enableFullscreen", enableFullscreen);
  enableHtml5LocalStorage =
      get_fl_map_value(map, "enableHtml5LocalStorage", enableHtml5LocalStorage);
  enableHtml5Database =
      get_fl_map_value(map, "enableHtml5Database", enableHtml5Database);
  enableXssAuditor =
      get_fl_map_value(map, "enableXssAuditor", enableXssAuditor);
  enablePageCache = get_fl_map_value(map, "enablePageCache", enablePageCache);
  drawCompositingIndicators =
      get_fl_map_value(map, "drawCompositingIndicators", drawCompositingIndicators);
  enableResizableTextAreas =
      get_fl_map_value(map, "enableResizableTextAreas", enableResizableTextAreas);
  enableTabsToLinks =
      get_fl_map_value(map, "enableTabsToLinks", enableTabsToLinks);
  loadImagesAutomatically =
      get_fl_map_value(map, "loadImagesAutomatically", loadImagesAutomatically);
  enableSiteSpecificQuirks =
      get_fl_map_value(map, "enableSiteSpecificQuirks", enableSiteSpecificQuirks);
  enableJavaApplet =
      get_fl_map_value(map, "enableJavaApplet", enableJavaApplet);
  printBackgrounds =
      get_fl_map_value(map, "printBackgrounds", printBackgrounds);
  enableSpatialNavigation =
      get_fl_map_value(map, "enableSpatialNavigation", enableSpatialNavigation);
  defaultCharset = get_fl_map_value(map, "defaultCharset", defaultCharset);
  defaultFontFamily =
      get_fl_map_value(map, "defaultFontFamily", defaultFontFamily);
  monospaceFontFamily =
      get_fl_map_value(map, "monospaceFontFamily", monospaceFontFamily);
  serifFontFamily = get_fl_map_value(map, "serifFontFamily", serifFontFamily);
  sansSerifFontFamily =
      get_fl_map_value(map, "sansSerifFontFamily", sansSerifFontFamily);
  cursiveFontFamily =
      get_fl_map_value(map, "cursiveFontFamily", cursiveFontFamily);
  fantasyFontFamily =
      get_fl_map_value(map, "fantasyFontFamily", fantasyFontFamily);
  pictographFontFamily =
      get_fl_map_value(map, "pictographFontFamily", pictographFontFamily);
  defaultFontSize =
      static_cast<int>(get_fl_map_value<int64_t>(map, "defaultFontSize",
                                                  static_cast<int64_t>(defaultFontSize)));
  defaultMonospaceFontSize = static_cast<int>(get_fl_map_value<int64_t>(
      map, "defaultMonospaceFontSize",
      static_cast<int64_t>(defaultMonospaceFontSize)));
  minimumLogicalFontSize = static_cast<int>(get_fl_map_value<int64_t>(
      map, "minimumLogicalFontSize",
      static_cast<int64_t>(minimumLogicalFontSize)));

  // === Hardware acceleration ===
  hardwareAccelerationEnabled = get_fl_map_value(
      map, "hardwareAccelerationEnabled", hardwareAccelerationEnabled);

  // === Scroll multiplier ===
  scrollMultiplier =
      get_fl_map_value(map, "scrollMultiplier", scrollMultiplier);
}

void InAppWebViewSettings::applyToWebView(WebKitWebView* webview) const {
  if (webview == nullptr) {
    return;
  }

  WebKitSettings* settings = webkit_web_view_get_settings(webview);
  if (settings == nullptr) {
    return;
  }

  // User agent
  if (!userAgent.empty()) {
    webkit_settings_set_user_agent(settings, userAgent.c_str());
  }

  // JavaScript
  webkit_settings_set_enable_javascript(settings, javaScriptEnabled);
  webkit_settings_set_javascript_can_open_windows_automatically(
      settings, javaScriptCanOpenWindowsAutomatically);

  // Media
  webkit_settings_set_media_playback_requires_user_gesture(
      settings, mediaPlaybackRequiresUserGesture);
  webkit_settings_set_enable_media_stream(settings, enableMediaStream);
  webkit_settings_set_enable_mediasource(settings, enableMediaSource);
  webkit_settings_set_enable_webaudio(settings, enableWebAudio);

  // WebGL
  webkit_settings_set_enable_webgl(settings, enableWebGL);

  // Developer tools
  webkit_settings_set_enable_developer_extras(settings, enableDeveloperExtras && isInspectable);
  webkit_settings_set_enable_write_console_messages_to_stdout(
      settings, enableWriteConsoleMessagesToStdout);

  // Navigation
  webkit_settings_set_enable_smooth_scrolling(settings, enableSmoothScrolling);
  webkit_settings_set_enable_back_forward_navigation_gestures(
      settings, enableBackForwardNavigationGestures);
  webkit_settings_set_enable_caret_browsing(settings, enableCaretBrowsing);
  webkit_settings_set_enable_fullscreen(settings, enableFullscreen);
  webkit_settings_set_enable_spatial_navigation(settings, enableSpatialNavigation);

  // Storage
  webkit_settings_set_enable_html5_local_storage(settings, enableHtml5LocalStorage);
  webkit_settings_set_enable_html5_database(settings, enableHtml5Database);
  webkit_settings_set_enable_page_cache(settings, enablePageCache);

  // Security - some of these are deprecated in newer WebKitGTK versions
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  // XSS auditor was removed in WebKitGTK 2.38 but we still support older versions
  webkit_settings_set_enable_xss_auditor(settings, enableXssAuditor);
  // Hyperlink auditing deprecated in newer versions
  webkit_settings_set_enable_hyperlink_auditing(settings, enableHyperlinkAuditing);
  // DNS prefetching deprecated but still functional
  webkit_settings_set_enable_dns_prefetching(settings, enableDnsPrefetching);
#pragma GCC diagnostic pop
  webkit_settings_set_enable_site_specific_quirks(settings, enableSiteSpecificQuirks);

  // UI
  webkit_settings_set_enable_resizable_text_areas(settings, enableResizableTextAreas);
  webkit_settings_set_enable_tabs_to_links(settings, enableTabsToLinks);
  webkit_settings_set_draw_compositing_indicators(settings, drawCompositingIndicators);
  webkit_settings_set_auto_load_images(settings, loadImagesAutomatically);
  webkit_settings_set_print_backgrounds(settings, printBackgrounds);

  // Zoom (using zoom-text-only as a proxy for supportZoom)
  // WebKitGTK doesn't have a direct "disable zoom" setting, but we can control zoom level
  webkit_settings_set_zoom_text_only(settings, !supportZoom);

  // Java applet (deprecated in WebKitGTK 2.38+)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  webkit_settings_set_enable_java(settings, enableJavaApplet);
#pragma GCC diagnostic pop

  // Fonts
  webkit_settings_set_default_charset(settings, defaultCharset.c_str());
  if (!defaultFontFamily.empty()) {
    webkit_settings_set_default_font_family(settings, defaultFontFamily.c_str());
  }
  if (!monospaceFontFamily.empty()) {
    webkit_settings_set_monospace_font_family(settings, monospaceFontFamily.c_str());
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

  // Font sizes
  webkit_settings_set_default_font_size(settings, defaultFontSize);
  webkit_settings_set_default_monospace_font_size(settings, defaultMonospaceFontSize);
  webkit_settings_set_minimum_font_size(settings, minimumFontSize);

  // Transparent background
  if (transparentBackground) {
    GdkRGBA color = {0.0, 0.0, 0.0, 0.0};
    webkit_web_view_set_background_color(webview, &color);
  }

  // Context menu (handled separately in event handlers)
  // disableContextMenu is used in the context menu signal handler
}

FlValue* InAppWebViewSettings::toFlValue() const {
  FlValue* map = fl_value_new_map();

  // === Event flags ===
  fl_value_set_string_take(map, "useShouldOverrideUrlLoading",
                           fl_value_new_bool(useShouldOverrideUrlLoading));
  fl_value_set_string_take(map, "useOnLoadResource",
                           fl_value_new_bool(useOnLoadResource));
  fl_value_set_string_take(map, "useOnDownloadStart",
                           fl_value_new_bool(useOnDownloadStart));
  fl_value_set_string_take(map, "useShouldInterceptRequest",
                           fl_value_new_bool(useShouldInterceptRequest));

  // === WebKit settings ===
  fl_value_set_string_take(map, "userAgent", make_fl_value(userAgent));
  fl_value_set_string_take(map, "javaScriptEnabled",
                           fl_value_new_bool(javaScriptEnabled));
  fl_value_set_string_take(map, "javaScriptCanOpenWindowsAutomatically",
                           fl_value_new_bool(javaScriptCanOpenWindowsAutomatically));
  fl_value_set_string_take(map, "mediaPlaybackRequiresUserGesture",
                           fl_value_new_bool(mediaPlaybackRequiresUserGesture));
  fl_value_set_string_take(map, "minimumFontSize",
                           fl_value_new_int(minimumFontSize));
  fl_value_set_string_take(map, "transparentBackground",
                           fl_value_new_bool(transparentBackground));
  fl_value_set_string_take(map, "supportZoom",
                           fl_value_new_bool(supportZoom));
  fl_value_set_string_take(map, "isInspectable",
                           fl_value_new_bool(isInspectable));
  fl_value_set_string_take(map, "disableContextMenu",
                           fl_value_new_bool(disableContextMenu));

  // === JavaScript bridge settings ===
  fl_value_set_string_take(map, "javaScriptHandlersOriginAllowList",
                           make_fl_value(javaScriptHandlersOriginAllowList));
  fl_value_set_string_take(map, "javaScriptHandlersForMainFrameOnly",
                           fl_value_new_bool(javaScriptHandlersForMainFrameOnly));
  fl_value_set_string_take(map, "javaScriptBridgeEnabled",
                           fl_value_new_bool(javaScriptBridgeEnabled));
  fl_value_set_string_take(map, "javaScriptBridgeOriginAllowList",
                           make_fl_value(javaScriptBridgeOriginAllowList));
  fl_value_set_string_take(map, "javaScriptBridgeForMainFrameOnly",
                           make_fl_value(javaScriptBridgeForMainFrameOnly));
  fl_value_set_string_take(map, "pluginScriptsOriginAllowList",
                           make_fl_value(pluginScriptsOriginAllowList));
  fl_value_set_string_take(map, "pluginScriptsForMainFrameOnly",
                           fl_value_new_bool(pluginScriptsForMainFrameOnly));

  // === WebKitGTK specific settings ===
  fl_value_set_string_take(map, "enableDeveloperExtras",
                           fl_value_new_bool(enableDeveloperExtras));
  fl_value_set_string_take(map, "enableWriteConsoleMessagesToStdout",
                           fl_value_new_bool(enableWriteConsoleMessagesToStdout));
  fl_value_set_string_take(map, "enableMediaStream",
                           fl_value_new_bool(enableMediaStream));
  fl_value_set_string_take(map, "enableMediaSource",
                           fl_value_new_bool(enableMediaSource));
  fl_value_set_string_take(map, "enableWebAudio",
                           fl_value_new_bool(enableWebAudio));
  fl_value_set_string_take(map, "enableWebGL",
                           fl_value_new_bool(enableWebGL));
  fl_value_set_string_take(map, "enableSmoothScrolling",
                           fl_value_new_bool(enableSmoothScrolling));
  fl_value_set_string_take(map, "enableBackForwardNavigationGestures",
                           fl_value_new_bool(enableBackForwardNavigationGestures));
  fl_value_set_string_take(map, "enableHyperlinkAuditing",
                           fl_value_new_bool(enableHyperlinkAuditing));
  fl_value_set_string_take(map, "enableDnsPrefetching",
                           fl_value_new_bool(enableDnsPrefetching));
  fl_value_set_string_take(map, "enableCaretBrowsing",
                           fl_value_new_bool(enableCaretBrowsing));
  fl_value_set_string_take(map, "enableFullscreen",
                           fl_value_new_bool(enableFullscreen));
  fl_value_set_string_take(map, "enableHtml5LocalStorage",
                           fl_value_new_bool(enableHtml5LocalStorage));
  fl_value_set_string_take(map, "enableHtml5Database",
                           fl_value_new_bool(enableHtml5Database));
  fl_value_set_string_take(map, "enableXssAuditor",
                           fl_value_new_bool(enableXssAuditor));
  fl_value_set_string_take(map, "enablePageCache",
                           fl_value_new_bool(enablePageCache));
  fl_value_set_string_take(map, "drawCompositingIndicators",
                           fl_value_new_bool(drawCompositingIndicators));
  fl_value_set_string_take(map, "enableResizableTextAreas",
                           fl_value_new_bool(enableResizableTextAreas));
  fl_value_set_string_take(map, "enableTabsToLinks",
                           fl_value_new_bool(enableTabsToLinks));
  fl_value_set_string_take(map, "loadImagesAutomatically",
                           fl_value_new_bool(loadImagesAutomatically));
  fl_value_set_string_take(map, "enableSiteSpecificQuirks",
                           fl_value_new_bool(enableSiteSpecificQuirks));
  fl_value_set_string_take(map, "enableJavaApplet",
                           fl_value_new_bool(enableJavaApplet));
  fl_value_set_string_take(map, "printBackgrounds",
                           fl_value_new_bool(printBackgrounds));
  fl_value_set_string_take(map, "enableSpatialNavigation",
                           fl_value_new_bool(enableSpatialNavigation));
  fl_value_set_string_take(map, "defaultCharset", make_fl_value(defaultCharset));
  fl_value_set_string_take(map, "defaultFontFamily", make_fl_value(defaultFontFamily));
  fl_value_set_string_take(map, "monospaceFontFamily", make_fl_value(monospaceFontFamily));
  fl_value_set_string_take(map, "serifFontFamily", make_fl_value(serifFontFamily));
  fl_value_set_string_take(map, "sansSerifFontFamily", make_fl_value(sansSerifFontFamily));
  fl_value_set_string_take(map, "cursiveFontFamily", make_fl_value(cursiveFontFamily));
  fl_value_set_string_take(map, "fantasyFontFamily", make_fl_value(fantasyFontFamily));
  fl_value_set_string_take(map, "pictographFontFamily", make_fl_value(pictographFontFamily));
  fl_value_set_string_take(map, "defaultFontSize",
                           fl_value_new_int(defaultFontSize));
  fl_value_set_string_take(map, "defaultMonospaceFontSize",
                           fl_value_new_int(defaultMonospaceFontSize));
  fl_value_set_string_take(map, "minimumLogicalFontSize",
                           fl_value_new_int(minimumLogicalFontSize));

  // === Hardware acceleration ===
  fl_value_set_string_take(map, "hardwareAccelerationEnabled",
                           fl_value_new_bool(hardwareAccelerationEnabled));

  // === Scroll multiplier ===
  fl_value_set_string_take(map, "scrollMultiplier",
                           fl_value_new_int(scrollMultiplier));

  return map;
}

FlValue* InAppWebViewSettings::getRealSettings(const InAppWebView* inAppWebView) const {
  FlValue* settingsMap = toFlValue();

  if (inAppWebView == nullptr || inAppWebView->webview() == nullptr) {
    return settingsMap;
  }

  WebKitWebView* webview = inAppWebView->webview();
  WebKitSettings* settings = webkit_web_view_get_settings(webview);
  if (settings == nullptr) {
    return settingsMap;
  }

  // Read actual settings from WebKitGTK
  fl_value_set_string_take(settingsMap, "javaScriptEnabled",
                           fl_value_new_bool(webkit_settings_get_enable_javascript(settings)));

  fl_value_set_string_take(
      settingsMap, "javaScriptCanOpenWindowsAutomatically",
      fl_value_new_bool(
          webkit_settings_get_javascript_can_open_windows_automatically(settings)));

  fl_value_set_string_take(
      settingsMap, "mediaPlaybackRequiresUserGesture",
      fl_value_new_bool(
          webkit_settings_get_media_playback_requires_user_gesture(settings)));

  const gchar* realUserAgent = webkit_settings_get_user_agent(settings);
  if (realUserAgent != nullptr) {
    fl_value_set_string_take(settingsMap, "userAgent",
                             fl_value_new_string(realUserAgent));
  }

  fl_value_set_string_take(settingsMap, "enableWebGL",
                           fl_value_new_bool(webkit_settings_get_enable_webgl(settings)));

  fl_value_set_string_take(
      settingsMap, "enableDeveloperExtras",
      fl_value_new_bool(webkit_settings_get_enable_developer_extras(settings)));

  fl_value_set_string_take(settingsMap, "minimumFontSize",
                           fl_value_new_int(webkit_settings_get_minimum_font_size(settings)));

  fl_value_set_string_take(settingsMap, "defaultFontSize",
                           fl_value_new_int(webkit_settings_get_default_font_size(settings)));

  fl_value_set_string_take(
      settingsMap, "defaultMonospaceFontSize",
      fl_value_new_int(webkit_settings_get_default_monospace_font_size(settings)));

  fl_value_set_string_take(
      settingsMap, "enableSmoothScrolling",
      fl_value_new_bool(webkit_settings_get_enable_smooth_scrolling(settings)));

  fl_value_set_string_take(
      settingsMap, "loadImagesAutomatically",
      fl_value_new_bool(webkit_settings_get_auto_load_images(settings)));

  return settingsMap;
}

InAppWebViewSettings::~InAppWebViewSettings() {
  debugLog("dealloc InAppWebViewSettings");
}

}  // namespace flutter_inappwebview_plugin
