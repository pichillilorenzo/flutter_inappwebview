import 'dart:ui';

import 'package:flutter_inappwebview/src/util.dart';

import '../../types.dart';

import '../../in_app_browser/in_app_browser_options.dart';

import '../in_app_webview_options.dart';
import '../webview.dart';

class AndroidOptions {}

///This class represents all the Android-only WebView options available.
class AndroidInAppWebViewOptions
    implements WebViewOptions, BrowserOptions, AndroidOptions {
  ///Sets the text zoom of the page in percent. The default value is `100`.
  int textZoom;

  ///Set to `true` to have the session cookie cache cleared before the new window is opened.
  bool clearSessionCache;

  ///Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `true`.
  bool builtInZoomControls;

  ///Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  bool displayZoomControls;

  ///Set to `true` if you want the database storage API is enabled. The default value is `true`.
  bool databaseEnabled;

  ///Set to `true` if you want the DOM storage API is enabled. The default value is `true`.
  bool domStorageEnabled;

  ///Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
  ///When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels.
  ///When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used.
  ///If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  bool useWideViewPort;

  ///Sets whether Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links.
  ///Safe Browsing is enabled by default for devices which support it.
  ///
  ///**NOTE**: available on Android 26+.
  bool safeBrowsingEnabled;

  ///Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
  ///
  ///**NOTE**: available on Android 21+.
  AndroidMixedContentMode? mixedContentMode;

  ///Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
  bool allowContentAccess;

  ///Enables or disables file access within WebView. Note that this enables or disables file system access only.
  ///Assets and resources are still accessible using `file:///android_asset` and `file:///android_res`. The default value is `true`.
  bool allowFileAccess;

  ///Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
  ///This option is used one time: repeated calls are ignored.
  String? appCachePath;

  ///Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
  bool blockNetworkImage;

  ///Sets whether the WebView should not load resources from the network. The default value is `false`.
  bool blockNetworkLoads;

  ///Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
  ///When navigating back, content is not revalidated, instead the content is just retrieved from the cache. The default value is [AndroidCacheMode.LOAD_DEFAULT].
  AndroidCacheMode? cacheMode;

  ///Sets the cursive font family name. The default value is `"cursive"`.
  String cursiveFontFamily;

  ///Sets the default fixed font size. The default value is `16`.
  int defaultFixedFontSize;

  ///Sets the default font size. The default value is `16`.
  int defaultFontSize;

  ///Sets the default text encoding name to use when decoding html pages. The default value is `"UTF-8"`.
  String defaultTextEncodingName;

  ///Disables the action mode menu items according to menuItems flag.
  ///
  ///**NOTE**: available on Android 24+.
  AndroidActionModeMenuItem? disabledActionModeMenuItems;

  ///Sets the fantasy font family name. The default value is `"fantasy"`.
  String fantasyFontFamily;

  ///Sets the fixed font family name. The default value is `"monospace"`.
  String fixedFontFamily;

  ///Set the force dark mode for this WebView. The default value is [AndroidForceDark.FORCE_DARK_OFF].
  ///
  ///**NOTE**: available on Android 29+.
  AndroidForceDark? forceDark;

  ///Sets whether Geolocation API is enabled. The default value is `true`.
  bool geolocationEnabled;

  ///Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
  AndroidLayoutAlgorithm? layoutAlgorithm;

  ///Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
  ///This setting is taken into account when the content width is greater than the width of the WebView control, for example, when [useWideViewPort] is enabled.
  ///The default value is `false`.
  bool loadWithOverviewMode;

  ///Sets whether the WebView should load image resources. Note that this method controls loading of all images, including those embedded using the data URI scheme.
  ///Note that if the value of this setting is changed from false to true, all images resources referenced by content currently displayed by the WebView are loaded automatically.
  ///The default value is `true`.
  bool loadsImagesAutomatically;

  ///Sets the minimum logical font size. The default is `8`.
  int minimumLogicalFontSize;

  ///Sets the initial scale for this WebView. 0 means default. The behavior for the default scale depends on the state of [useWideViewPort] and [loadWithOverviewMode].
  ///If the content fits into the WebView control by width, then the zoom is set to 100%. For wide content, the behavior depends on the state of [loadWithOverviewMode].
  ///If its value is true, the content will be zoomed out to be fit by width into the WebView control, otherwise not.
  ///If initial scale is greater than 0, WebView starts with this value as initial scale.
  ///Please note that unlike the scale properties in the viewport meta tag, this method doesn't take the screen density into account.
  ///The default is `0`.
  int initialScale;

  ///Tells the WebView whether it needs to set a node. The default value is `true`.
  bool needInitialFocus;

  ///Sets whether this WebView should raster tiles when it is offscreen but attached to a window.
  ///Turning this on can avoid rendering artifacts when animating an offscreen WebView on-screen.
  ///Offscreen WebViews in this mode use more memory. The default value is `false`.
  ///
  ///**NOTE**: available on Android 23+.
  bool offscreenPreRaster;

  ///Sets the sans-serif font family name. The default value is `"sans-serif"`.
  String sansSerifFontFamily;

  ///Sets the serif font family name. The default value is `"sans-serif"`.
  String serifFontFamily;

  ///Sets the standard font family name. The default value is `"sans-serif"`.
  String standardFontFamily;

  ///Sets whether the WebView should save form data. In Android O, the platform has implemented a fully functional Autofill feature to store form data.
  ///Therefore, the Webview form data save feature is disabled. Note that the feature will continue to be supported on older versions of Android as before.
  ///The default value is `true`.
  bool saveFormData;

  ///Boolean value to enable third party cookies in the WebView.
  ///Used on Android Lollipop and above only as third party cookies are enabled by default on Android Kitkat and below and on iOS.
  ///The default value is `true`.
  ///
  ///**NOTE**: available on Android 21+.
  bool thirdPartyCookiesEnabled;

  ///Boolean value to enable Hardware Acceleration in the WebView.
  ///The default value is `true`.
  bool hardwareAcceleration;

  ///Sets whether the WebView supports multiple windows.
  ///If set to `true`, [WebView.onCreateWindow] event must be implemented by the host application. The default value is `false`.
  bool supportMultipleWindows;

  ///Regular expression used by [WebView.shouldOverrideUrlLoading] event to cancel navigation requests for frames that are not the main frame.
  ///If the url request of a subframe matches the regular expression, then the request of that subframe is canceled.
  String? regexToCancelSubFramesLoading;

  ///Set to `true` to enable Flutter's new Hybrid Composition. The default value is `false`.
  ///Hybrid Composition is supported starting with Flutter v1.20+.
  ///
  ///**NOTE**: It is recommended to use Hybrid Composition only on Android 10+ for a release app,
  ///as it can cause framerate drops on animations in Android 9 and lower (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).
  bool useHybridComposition;

  ///Set to `true` to be able to listen at the [WebView.androidShouldInterceptRequest] event. The default value is `false`.
  bool useShouldInterceptRequest;

  ///Set to `true` to be able to listen at the [WebView.androidOnRenderProcessGone] event. The default value is `false`.
  bool useOnRenderProcessGone;

  ///Sets the WebView's over-scroll mode.
  ///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
  ///The default value is [AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS].
  AndroidOverScrollMode? overScrollMode;

  ///Informs WebView of the network state.
  ///This is used to set the JavaScript property `window.navigator.isOnline` and generates the online/offline event as specified in HTML5, sec. 5.7.7.
  bool? networkAvailable;

  ///Specifies the style of the scrollbars. The scrollbars can be overlaid or inset.
  ///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
  ///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
  ///you can use SCROLLBARS_INSIDE_OVERLAY or SCROLLBARS_INSIDE_INSET. If you want them to appear at the edge of the view, ignoring the padding,
  ///then you can use SCROLLBARS_OUTSIDE_OVERLAY or SCROLLBARS_OUTSIDE_INSET.
  ///The default value is [AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY].
  AndroidScrollBarStyle? scrollBarStyle;

  ///Sets the position of the vertical scroll bar.
  ///The default value is [AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT].
  AndroidVerticalScrollbarPosition? verticalScrollbarPosition;

  ///Defines the delay in milliseconds that a scrollbar waits before fade out.
  int? scrollBarDefaultDelayBeforeFade;

  ///Defines whether scrollbars will fade when the view is not scrolling.
  ///The default value is `true`.
  bool scrollbarFadingEnabled;

  ///Defines the scrollbar fade duration in milliseconds.
  int? scrollBarFadeDuration;

  ///Sets the renderer priority policy for this WebView.
  RendererPriorityPolicy? rendererPriorityPolicy;

  ///Sets whether the default Android error page should be disabled.
  ///The default value is `false`.
  bool disableDefaultErrorPage;

  ///Sets the vertical scrollbar thumb color.
  ///
  ///**NOTE**: available on Android 29+.
  Color? verticalScrollbarThumbColor;

  ///Sets the vertical scrollbar track color.
  ///
  ///**NOTE**: available on Android 29+.
  Color? verticalScrollbarTrackColor;

  ///Sets the horizontal scrollbar thumb color.
  ///
  ///**NOTE**: available on Android 29+.
  Color? horizontalScrollbarThumbColor;

  ///Sets the horizontal scrollbar track color.
  ///
  ///**NOTE**: available on Android 29+.
  Color? horizontalScrollbarTrackColor;

  AndroidInAppWebViewOptions({
    this.textZoom = 100,
    this.clearSessionCache = false,
    this.builtInZoomControls = true,
    this.displayZoomControls = false,
    this.databaseEnabled = true,
    this.domStorageEnabled = true,
    this.useWideViewPort = true,
    this.safeBrowsingEnabled = true,
    this.mixedContentMode,
    this.allowContentAccess = true,
    this.allowFileAccess = true,
    this.appCachePath,
    this.blockNetworkImage = false,
    this.blockNetworkLoads = false,
    this.cacheMode = AndroidCacheMode.LOAD_DEFAULT,
    this.cursiveFontFamily = "cursive",
    this.defaultFixedFontSize = 16,
    this.defaultFontSize = 16,
    this.defaultTextEncodingName = "UTF-8",
    this.disabledActionModeMenuItems,
    this.fantasyFontFamily = "fantasy",
    this.fixedFontFamily = "monospace",
    this.forceDark = AndroidForceDark.FORCE_DARK_OFF,
    this.geolocationEnabled = true,
    this.layoutAlgorithm,
    this.loadWithOverviewMode = true,
    this.loadsImagesAutomatically = true,
    this.minimumLogicalFontSize = 8,
    this.needInitialFocus = true,
    this.offscreenPreRaster = false,
    this.sansSerifFontFamily = "sans-serif",
    this.serifFontFamily = "sans-serif",
    this.standardFontFamily = "sans-serif",
    this.saveFormData = true,
    this.thirdPartyCookiesEnabled = true,
    this.hardwareAcceleration = true,
    this.initialScale = 0,
    this.supportMultipleWindows = false,
    this.regexToCancelSubFramesLoading,
    this.useHybridComposition = false,
    this.useShouldInterceptRequest = false,
    this.useOnRenderProcessGone = false,
    this.overScrollMode = AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
    this.networkAvailable,
    this.scrollBarStyle = AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
    this.verticalScrollbarPosition =
        AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    this.scrollBarDefaultDelayBeforeFade,
    this.scrollbarFadingEnabled = true,
    this.scrollBarFadeDuration,
    this.rendererPriorityPolicy,
    this.disableDefaultErrorPage = false,
    this.verticalScrollbarThumbColor,
    this.verticalScrollbarTrackColor,
    this.horizontalScrollbarThumbColor,
    this.horizontalScrollbarTrackColor,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "textZoom": textZoom,
      "clearSessionCache": clearSessionCache,
      "builtInZoomControls": builtInZoomControls,
      "displayZoomControls": displayZoomControls,
      "databaseEnabled": databaseEnabled,
      "domStorageEnabled": domStorageEnabled,
      "useWideViewPort": useWideViewPort,
      "safeBrowsingEnabled": safeBrowsingEnabled,
      "mixedContentMode": mixedContentMode?.toValue(),
      "allowContentAccess": allowContentAccess,
      "allowFileAccess": allowFileAccess,
      "appCachePath": appCachePath,
      "blockNetworkImage": blockNetworkImage,
      "blockNetworkLoads": blockNetworkLoads,
      "cacheMode": cacheMode?.toValue(),
      "cursiveFontFamily": cursiveFontFamily,
      "defaultFixedFontSize": defaultFixedFontSize,
      "defaultFontSize": defaultFontSize,
      "defaultTextEncodingName": defaultTextEncodingName,
      "disabledActionModeMenuItems": disabledActionModeMenuItems?.toValue(),
      "fantasyFontFamily": fantasyFontFamily,
      "fixedFontFamily": fixedFontFamily,
      "forceDark": forceDark?.toValue(),
      "geolocationEnabled": geolocationEnabled,
      "layoutAlgorithm": layoutAlgorithm?.toValue(),
      "loadWithOverviewMode": loadWithOverviewMode,
      "loadsImagesAutomatically": loadsImagesAutomatically,
      "minimumLogicalFontSize": minimumLogicalFontSize,
      "initialScale": initialScale,
      "needInitialFocus": needInitialFocus,
      "offscreenPreRaster": offscreenPreRaster,
      "sansSerifFontFamily": sansSerifFontFamily,
      "serifFontFamily": serifFontFamily,
      "standardFontFamily": standardFontFamily,
      "saveFormData": saveFormData,
      "thirdPartyCookiesEnabled": thirdPartyCookiesEnabled,
      "hardwareAcceleration": hardwareAcceleration,
      "supportMultipleWindows": supportMultipleWindows,
      "useHybridComposition": useHybridComposition,
      "regexToCancelSubFramesLoading": regexToCancelSubFramesLoading,
      "useShouldInterceptRequest": useShouldInterceptRequest,
      "useOnRenderProcessGone": useOnRenderProcessGone,
      "overScrollMode": overScrollMode?.toValue(),
      "networkAvailable": networkAvailable,
      "scrollBarStyle": scrollBarStyle?.toValue(),
      "verticalScrollbarPosition": verticalScrollbarPosition?.toValue(),
      "scrollBarDefaultDelayBeforeFade": scrollBarDefaultDelayBeforeFade,
      "scrollbarFadingEnabled": scrollbarFadingEnabled,
      "scrollBarFadeDuration": scrollBarFadeDuration,
      "rendererPriorityPolicy": rendererPriorityPolicy?.toMap(),
      "disableDefaultErrorPage": disableDefaultErrorPage,
      "verticalScrollbarThumbColor": verticalScrollbarThumbColor?.toHex(),
      "verticalScrollbarTrackColor": verticalScrollbarTrackColor?.toHex(),
      "horizontalScrollbarThumbColor": horizontalScrollbarThumbColor?.toHex(),
      "horizontalScrollbarTrackColor": horizontalScrollbarTrackColor?.toHex(),
    };
  }

  static AndroidInAppWebViewOptions fromMap(Map<String, dynamic> map) {
    AndroidInAppWebViewOptions options = AndroidInAppWebViewOptions();
    options.textZoom = map["textZoom"];
    options.clearSessionCache = map["clearSessionCache"];
    options.builtInZoomControls = map["builtInZoomControls"];
    options.displayZoomControls = map["displayZoomControls"];
    options.databaseEnabled = map["databaseEnabled"];
    options.domStorageEnabled = map["domStorageEnabled"];
    options.useWideViewPort = map["useWideViewPort"];
    options.safeBrowsingEnabled = map["safeBrowsingEnabled"];
    options.mixedContentMode =
        AndroidMixedContentMode.fromValue(map["mixedContentMode"]);
    options.allowContentAccess = map["allowContentAccess"];
    options.allowFileAccess = map["allowFileAccess"];
    options.appCachePath = map["appCachePath"];
    options.blockNetworkImage = map["blockNetworkImage"];
    options.blockNetworkLoads = map["blockNetworkLoads"];
    options.cacheMode = AndroidCacheMode.fromValue(map["cacheMode"]);
    options.cursiveFontFamily = map["cursiveFontFamily"];
    options.defaultFixedFontSize = map["defaultFixedFontSize"];
    options.defaultFontSize = map["defaultFontSize"];
    options.defaultTextEncodingName = map["defaultTextEncodingName"];
    options.disabledActionModeMenuItems =
        AndroidActionModeMenuItem.fromValue(map["disabledActionModeMenuItems"]);
    options.fantasyFontFamily = map["fantasyFontFamily"];
    options.fixedFontFamily = map["fixedFontFamily"];
    options.forceDark = AndroidForceDark.fromValue(map["forceDark"]);
    options.geolocationEnabled = map["geolocationEnabled"];
    options.layoutAlgorithm =
        AndroidLayoutAlgorithm.fromValue(map["layoutAlgorithm"]);
    options.loadWithOverviewMode = map["loadWithOverviewMode"];
    options.loadsImagesAutomatically = map["loadsImagesAutomatically"];
    options.minimumLogicalFontSize = map["minimumLogicalFontSize"];
    options.initialScale = map["initialScale"];
    options.needInitialFocus = map["needInitialFocus"];
    options.offscreenPreRaster = map["offscreenPreRaster"];
    options.sansSerifFontFamily = map["sansSerifFontFamily"];
    options.serifFontFamily = map["serifFontFamily"];
    options.standardFontFamily = map["standardFontFamily"];
    options.saveFormData = map["saveFormData"];
    options.thirdPartyCookiesEnabled = map["thirdPartyCookiesEnabled"];
    options.hardwareAcceleration = map["hardwareAcceleration"];
    options.supportMultipleWindows = map["supportMultipleWindows"];
    options.regexToCancelSubFramesLoading =
        map["regexToCancelSubFramesLoading"];
    options.useHybridComposition = map["useHybridComposition"];
    options.useShouldInterceptRequest = map["useShouldInterceptRequest"];
    options.useOnRenderProcessGone = map["useOnRenderProcessGone"];
    options.overScrollMode =
        AndroidOverScrollMode.fromValue(map["overScrollMode"]);
    options.networkAvailable = map["networkAvailable"];
    options.scrollBarStyle =
        AndroidScrollBarStyle.fromValue(map["scrollBarStyle"]);
    options.verticalScrollbarPosition =
        AndroidVerticalScrollbarPosition.fromValue(
            map["verticalScrollbarPosition"]);
    options.scrollBarDefaultDelayBeforeFade =
        map["scrollBarDefaultDelayBeforeFade"];
    options.scrollbarFadingEnabled = map["scrollbarFadingEnabled"];
    options.scrollBarFadeDuration = map["scrollBarFadeDuration"];
    options.rendererPriorityPolicy = RendererPriorityPolicy.fromMap(
        map["rendererPriorityPolicy"]?.cast<String, dynamic>());
    options.disableDefaultErrorPage = map["disableDefaultErrorPage"];
    options.verticalScrollbarThumbColor =
        UtilColor.fromHex(map["verticalScrollbarThumbColor"]);
    options.verticalScrollbarTrackColor =
        UtilColor.fromHex(map["verticalScrollbarTrackColor"]);
    options.horizontalScrollbarThumbColor =
        UtilColor.fromHex(map["horizontalScrollbarThumbColor"]);
    options.horizontalScrollbarTrackColor =
        UtilColor.fromHex(map["horizontalScrollbarTrackColor"]);
    return options;
  }

  @override
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  AndroidInAppWebViewOptions copy() {
    return AndroidInAppWebViewOptions.fromMap(this.toMap());
  }
}
