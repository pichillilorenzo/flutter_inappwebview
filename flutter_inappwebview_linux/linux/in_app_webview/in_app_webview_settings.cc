// WPE WebKit settings implementation

#include "in_app_webview_settings.h"

#include <cstdlib>

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview.h"

namespace flutter_inappwebview_plugin {

InAppWebViewSettings::InAppWebViewSettings() {
  // Check environment variable for DMA-BUF export preference
  const char* dmabuf_env = std::getenv("FLUTTER_INAPPWEBVIEW_LINUX_WPE_DMABUF");
  if (dmabuf_env != nullptr) {
    useDmaBufExport = (std::string(dmabuf_env) == "1" || std::string(dmabuf_env) == "true");
  }

  // Check for web inspector settings
  const char* inspector_env = std::getenv("FLUTTER_INAPPWEBVIEW_LINUX_WPE_INSPECTOR");
  if (inspector_env != nullptr) {
    enableWebInspector =
        (std::string(inspector_env) == "1" || std::string(inspector_env) == "true");
  }

  const char* inspector_port_env = std::getenv("FLUTTER_INAPPWEBVIEW_LINUX_WPE_INSPECTOR_PORT");
  if (inspector_port_env != nullptr) {
    webInspectorPort = std::atoi(inspector_port_env);
  }
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

  // === WPE-specific rendering settings ===
  useDmaBufExport = get_fl_map_value(map, "useDmaBufExport", useDmaBufExport);
  enableWebInspector = get_fl_map_value(map, "enableWebInspector", enableWebInspector);
  webInspectorPort = static_cast<int>(
      get_fl_map_value<int64_t>(map, "webInspectorPort", static_cast<int64_t>(webInspectorPort)));
  targetFrameRate = static_cast<int>(
      get_fl_map_value<int64_t>(map, "targetFrameRate", static_cast<int64_t>(targetFrameRate)));

  // === Scroll settings ===
  scrollMultiplier = get_fl_map_value<int64_t>(map, "scrollMultiplier", scrollMultiplier);

  // === Custom Scheme Handler settings ===
  if (fl_map_contains_not_null(map, "resourceCustomSchemes")) {
    resourceCustomSchemes =
        get_fl_map_value<std::vector<std::string>>(map, "resourceCustomSchemes", {});
  }

  // === Incognito mode ===
  incognito = get_fl_map_value(map, "incognito", incognito);
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
}

FlValue* InAppWebViewSettings::toFlValue() const {
  FlValue* map = fl_value_new_map();

  // === Event flags ===
  fl_value_set_string_take(map, "useShouldOverrideUrlLoading",
                           fl_value_new_bool(useShouldOverrideUrlLoading));
  fl_value_set_string_take(map, "useOnLoadResource", fl_value_new_bool(useOnLoadResource));
  fl_value_set_string_take(map, "useOnDownloadStart", fl_value_new_bool(useOnDownloadStart));
  fl_value_set_string_take(map, "useShouldInterceptRequest",
                           fl_value_new_bool(useShouldInterceptRequest));
  fl_value_set_string_take(map, "useShouldInterceptAjaxRequest",
                           fl_value_new_bool(useShouldInterceptAjaxRequest));
  fl_value_set_string_take(map, "useOnAjaxReadyStateChange",
                           fl_value_new_bool(useOnAjaxReadyStateChange));
  fl_value_set_string_take(map, "useOnAjaxProgress", fl_value_new_bool(useOnAjaxProgress));
  fl_value_set_string_take(map, "useShouldInterceptFetchRequest",
                           fl_value_new_bool(useShouldInterceptFetchRequest));

  // === WebKit settings ===
  fl_value_set_string_take(map, "userAgent", fl_value_new_string(userAgent.c_str()));
  fl_value_set_string_take(map, "javaScriptEnabled", fl_value_new_bool(javaScriptEnabled));
  fl_value_set_string_take(map, "javaScriptCanOpenWindowsAutomatically",
                           fl_value_new_bool(javaScriptCanOpenWindowsAutomatically));
  fl_value_set_string_take(map, "mediaPlaybackRequiresUserGesture",
                           fl_value_new_bool(mediaPlaybackRequiresUserGesture));
  fl_value_set_string_take(map, "minimumFontSize", fl_value_new_int(minimumFontSize));
  fl_value_set_string_take(map, "transparentBackground", fl_value_new_bool(transparentBackground));
  fl_value_set_string_take(map, "supportZoom", fl_value_new_bool(supportZoom));
  fl_value_set_string_take(map, "isInspectable", fl_value_new_bool(isInspectable));
  fl_value_set_string_take(map, "disableContextMenu", fl_value_new_bool(disableContextMenu));

  // === JavaScript bridge settings ===
  fl_value_set_string_take(map, "javaScriptBridgeEnabled",
                           fl_value_new_bool(javaScriptBridgeEnabled));
  fl_value_set_string_take(map, "javaScriptHandlersForMainFrameOnly",
                           fl_value_new_bool(javaScriptHandlersForMainFrameOnly));
  fl_value_set_string_take(map, "pluginScriptsForMainFrameOnly",
                           fl_value_new_bool(pluginScriptsForMainFrameOnly));

  // === WPE WebKit specific settings ===
  fl_value_set_string_take(map, "enableDeveloperExtras", fl_value_new_bool(enableDeveloperExtras));
  fl_value_set_string_take(map, "enableWriteConsoleMessagesToStdout",
                           fl_value_new_bool(enableWriteConsoleMessagesToStdout));
  fl_value_set_string_take(map, "enableMediaStream", fl_value_new_bool(enableMediaStream));
  fl_value_set_string_take(map, "enableMediaSource", fl_value_new_bool(enableMediaSource));
  fl_value_set_string_take(map, "enableWebAudio", fl_value_new_bool(enableWebAudio));
  fl_value_set_string_take(map, "enableWebGL", fl_value_new_bool(enableWebGL));
  fl_value_set_string_take(map, "enableSmoothScrolling", fl_value_new_bool(enableSmoothScrolling));
  fl_value_set_string_take(map, "allowsBackForwardNavigationGestures",
                           fl_value_new_bool(allowsBackForwardNavigationGestures));
  fl_value_set_string_take(map, "enableHyperlinkAuditing",
                           fl_value_new_bool(enableHyperlinkAuditing));
  fl_value_set_string_take(map, "enableDnsPrefetching", fl_value_new_bool(enableDnsPrefetching));
  fl_value_set_string_take(map, "enableCaretBrowsing", fl_value_new_bool(enableCaretBrowsing));
  fl_value_set_string_take(map, "isElementFullscreenEnabled", fl_value_new_bool(isElementFullscreenEnabled));
  fl_value_set_string_take(map, "domStorageEnabled",
                           fl_value_new_bool(enableHtml5LocalStorage));
  fl_value_set_string_take(map, "databaseEnabled", fl_value_new_bool(enableHtml5Database));
  fl_value_set_string_take(map, "enablePageCache", fl_value_new_bool(enablePageCache));
  fl_value_set_string_take(map, "drawCompositingIndicators",
                           fl_value_new_bool(drawCompositingIndicators));
  fl_value_set_string_take(map, "enableResizableTextAreas",
                           fl_value_new_bool(enableResizableTextAreas));
  fl_value_set_string_take(map, "enableTabsToLinks", fl_value_new_bool(enableTabsToLinks));
  fl_value_set_string_take(map, "loadsImagesAutomatically",
                           fl_value_new_bool(loadsImagesAutomatically));
  fl_value_set_string_take(map, "isSiteSpecificQuirksModeEnabled",
                           fl_value_new_bool(isSiteSpecificQuirksModeEnabled));
  fl_value_set_string_take(map, "printBackgrounds", fl_value_new_bool(printBackgrounds));
  fl_value_set_string_take(map, "enableSpatialNavigation",
                           fl_value_new_bool(enableSpatialNavigation));
  fl_value_set_string_take(map, "defaultTextEncodingName", fl_value_new_string(defaultTextEncodingName.c_str()));
  fl_value_set_string_take(map, "standardFontFamily",
                           fl_value_new_string(standardFontFamily.c_str()));
  fl_value_set_string_take(map, "fixedFontFamily",
                           fl_value_new_string(fixedFontFamily.c_str()));
  fl_value_set_string_take(map, "serifFontFamily", fl_value_new_string(serifFontFamily.c_str()));
  fl_value_set_string_take(map, "sansSerifFontFamily",
                           fl_value_new_string(sansSerifFontFamily.c_str()));
  fl_value_set_string_take(map, "cursiveFontFamily",
                           fl_value_new_string(cursiveFontFamily.c_str()));
  fl_value_set_string_take(map, "fantasyFontFamily",
                           fl_value_new_string(fantasyFontFamily.c_str()));
  fl_value_set_string_take(map, "pictographFontFamily",
                           fl_value_new_string(pictographFontFamily.c_str()));
  fl_value_set_string_take(map, "defaultFontSize", fl_value_new_int(defaultFontSize));
  fl_value_set_string_take(map, "defaultFixedFontSize",
                           fl_value_new_int(defaultFixedFontSize));
  fl_value_set_string_take(map, "minimumLogicalFontSize", fl_value_new_int(minimumLogicalFontSize));

  // === WPE-specific rendering settings ===
  fl_value_set_string_take(map, "useDmaBufExport", fl_value_new_bool(useDmaBufExport));
  fl_value_set_string_take(map, "enableWebInspector", fl_value_new_bool(enableWebInspector));
  fl_value_set_string_take(map, "webInspectorPort", fl_value_new_int(webInspectorPort));
  fl_value_set_string_take(map, "targetFrameRate", fl_value_new_int(targetFrameRate));
  fl_value_set_string_take(map, "enableOffscreenRendering",
                           fl_value_new_bool(enableOffscreenRendering));

  // === Scroll settings ===
  fl_value_set_string_take(map, "scrollMultiplier", fl_value_new_int(scrollMultiplier));

  // === Incognito mode ===
  fl_value_set_string_take(map, "incognito", fl_value_new_bool(incognito));

  return map;
}

FlValue* InAppWebViewSettings::getRealSettings(const InAppWebView* inAppWebView) const {
  FlValue* map = fl_value_new_map();

  if (inAppWebView == nullptr || inAppWebView->webview() == nullptr) {
    return map;
  }

  WebKitSettings* settings = webkit_web_view_get_settings(inAppWebView->webview());
  if (settings == nullptr) {
    return map;
  }

  // Get actual settings from WebKit
  const gchar* ua = webkit_settings_get_user_agent(settings);
  if (ua != nullptr) {
    fl_value_set_string_take(map, "userAgent", fl_value_new_string(ua));
  }

  fl_value_set_string_take(map, "javaScriptEnabled",
                           fl_value_new_bool(webkit_settings_get_enable_javascript(settings)));
  fl_value_set_string_take(
      map, "javaScriptCanOpenWindowsAutomatically",
      fl_value_new_bool(webkit_settings_get_javascript_can_open_windows_automatically(settings)));
  fl_value_set_string_take(
      map, "mediaPlaybackRequiresUserGesture",
      fl_value_new_bool(webkit_settings_get_media_playback_requires_user_gesture(settings)));
  fl_value_set_string_take(map, "minimumFontSize",
                           fl_value_new_int(webkit_settings_get_minimum_font_size(settings)));
  fl_value_set_string_take(map, "defaultFontSize",
                           fl_value_new_int(webkit_settings_get_default_font_size(settings)));
  fl_value_set_string_take(
      map, "defaultMonospaceFontSize",
      fl_value_new_int(webkit_settings_get_default_monospace_font_size(settings)));

  // Get current zoom level
  fl_value_set_string_take(
      map, "zoomLevel",
      fl_value_new_float(webkit_web_view_get_zoom_level(inAppWebView->webview())));

  return map;
}

InAppWebViewSettings::~InAppWebViewSettings() {
  // Nothing to clean up
}

}  // namespace flutter_inappwebview_plugin
