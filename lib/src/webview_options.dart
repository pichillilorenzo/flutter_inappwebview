import 'dart:io';

import 'content_blocker.dart';
import 'types.dart';
import 'webview.dart';

class AndroidOptions {}

class IosOptions {}

class WebViewOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static WebViewOptions fromMap(Map<String, dynamic> map) {
    return null;
  }

  WebViewOptions copy() {
    return WebViewOptions.fromMap(this.toMap());
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class BrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static BrowserOptions fromMap(Map<String, dynamic> map) {
    return null;
  }

  BrowserOptions copy() {
    return BrowserOptions.fromMap(this.toMap());
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class ChromeSafariBrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static ChromeSafariBrowserOptions fromMap(Map<String, dynamic> map) {
    return null;
  }

  ChromeSafariBrowserOptions copy() {
    return ChromeSafariBrowserOptions.fromMap(this.toMap());
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///This class represents all the cross-platform WebView options available.
class InAppWebViewOptions
    implements WebViewOptions, BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to be able to listen at the [shouldOverrideUrlLoading] event. The default value is `false`.
  bool useShouldOverrideUrlLoading;

  ///Set to `true` to be able to listen at the [onLoadResource] event. The default value is `false`.
  bool useOnLoadResource;

  ///Set to `true` to be able to listen at the [onDownloadStart] event. The default value is `false`.
  bool useOnDownloadStart;

  ///Set to `true` to have all the browser's cache cleared before the new WebView is opened. The default value is `false`.
  bool clearCache;

  ///Sets the user-agent for the WebView.
  ///
  ///**NOTE**: available on iOS 9.0+.
  String userAgent;

  ///Append to the existing user-agent. Setting userAgent will override this.
  ///
  ///**NOTE**: available on Android 17+ and on iOS 9.0+.
  String applicationNameForUserAgent;

  ///Set to `true` to enable JavaScript. The default value is `true`.
  bool javaScriptEnabled;

  ///Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application.
  ///This flag can be enabled in order to facilitate debugging of web layouts and JavaScript code running inside WebViews. The default is `false`.
  ///
  ///**NOTE**: on iOS the debugging mode is always enabled.
  bool debuggingEnabled;

  ///Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  bool javaScriptCanOpenWindowsAutomatically;

  ///Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  ///
  ///**NOTE**: available on iOS 10.0+.
  bool mediaPlaybackRequiresUserGesture;

  ///Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
  int minimumFontSize;

  ///Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
  bool verticalScrollBarEnabled;

  ///Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
  bool horizontalScrollBarEnabled;

  ///List of custom schemes that the WebView must handle. Use the [onLoadResourceCustomScheme] event to intercept resource requests with custom scheme.
  ///
  ///**NOTE**: available on iOS 11.0+.
  List<String> resourceCustomSchemes;

  ///List of [ContentBlocker] that are a set of rules used to block content in the browser window.
  ///
  ///**NOTE**: available on iOS 11.0+.
  List<ContentBlocker> contentBlockers;

  ///Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is [UserPreferredContentMode.RECOMMENDED].
  ///
  ///**NOTE**: available on iOS 13.0+.
  UserPreferredContentMode preferredContentMode;

  ///Set to `true` to be able to listen at the [shouldInterceptAjaxRequest] event. The default value is `false`.
  bool useShouldInterceptAjaxRequest;

  ///Set to `true` to be able to listen at the [shouldInterceptFetchRequest] event. The default value is `false`.
  bool useShouldInterceptFetchRequest;

  ///Set to `true` to open a browser window with incognito mode. The default value is `false`.
  ///
  ///**NOTE**: available on iOS 9.0+.
  bool incognito;

  ///Sets whether WebView should use browser caching. The default value is `true`.
  ///
  ///**NOTE**: available on iOS 9.0+.
  bool cacheEnabled;

  ///Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
  bool transparentBackground;

  ///Set to `true` to disable vertical scroll. The default value is `false`.
  bool disableVerticalScroll;

  ///Set to `true` to disable horizontal scroll. The default value is `false`.
  bool disableHorizontalScroll;

  ///Set to `true` to disable context menu. The default value is `false`.
  bool disableContextMenu;

  ///Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  bool supportZoom;

  InAppWebViewOptions(
      {this.useShouldOverrideUrlLoading = false,
      this.useOnLoadResource = false,
      this.useOnDownloadStart = false,
      this.clearCache = false,
      this.userAgent = "",
      this.applicationNameForUserAgent = "",
      this.javaScriptEnabled = true,
      this.debuggingEnabled = false,
      this.javaScriptCanOpenWindowsAutomatically = false,
      this.mediaPlaybackRequiresUserGesture = true,
      this.minimumFontSize,
      this.verticalScrollBarEnabled = true,
      this.horizontalScrollBarEnabled = true,
      this.resourceCustomSchemes = const [],
      this.contentBlockers = const [],
      this.preferredContentMode = UserPreferredContentMode.RECOMMENDED,
      this.useShouldInterceptAjaxRequest = false,
      this.useShouldInterceptFetchRequest = false,
      this.incognito = false,
      this.cacheEnabled = true,
      this.transparentBackground = false,
      this.disableVerticalScroll = false,
      this.disableHorizontalScroll = false,
      this.disableContextMenu = false,
      this.supportZoom = true}) {
    if (this.minimumFontSize == null)
      this.minimumFontSize = Platform.isAndroid ? 8 : 0;
    assert(!this.resourceCustomSchemes.contains("http") &&
        !this.resourceCustomSchemes.contains("https"));
  }

  @override
  Map<String, dynamic> toMap() {
    List<Map<String, Map<String, dynamic>>> contentBlockersMapList = [];
    contentBlockers.forEach((contentBlocker) {
      contentBlockersMapList.add(contentBlocker.toMap());
    });

    return {
      "useShouldOverrideUrlLoading": useShouldOverrideUrlLoading,
      "useOnLoadResource": useOnLoadResource,
      "useOnDownloadStart": useOnDownloadStart,
      "clearCache": clearCache,
      "userAgent": userAgent,
      "applicationNameForUserAgent": applicationNameForUserAgent,
      "javaScriptEnabled": javaScriptEnabled,
      "debuggingEnabled": debuggingEnabled,
      "javaScriptCanOpenWindowsAutomatically":
          javaScriptCanOpenWindowsAutomatically,
      "mediaPlaybackRequiresUserGesture": mediaPlaybackRequiresUserGesture,
      "verticalScrollBarEnabled": verticalScrollBarEnabled,
      "horizontalScrollBarEnabled": horizontalScrollBarEnabled,
      "resourceCustomSchemes": resourceCustomSchemes,
      "contentBlockers": contentBlockersMapList,
      "preferredContentMode": preferredContentMode?.toValue(),
      "useShouldInterceptAjaxRequest": useShouldInterceptAjaxRequest,
      "useShouldInterceptFetchRequest": useShouldInterceptFetchRequest,
      "incognito": incognito,
      "cacheEnabled": cacheEnabled,
      "transparentBackground": transparentBackground,
      "disableVerticalScroll": disableVerticalScroll,
      "disableHorizontalScroll": disableHorizontalScroll,
      "disableContextMenu": disableContextMenu,
      "supportZoom": supportZoom
    };
  }

  static InAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<ContentBlocker> contentBlockers = [];
    List<dynamic> contentBlockersMapList = map["contentBlockers"];
    if (contentBlockersMapList != null) {
      contentBlockersMapList.forEach((contentBlocker) {
        contentBlockers.add(ContentBlocker.fromMap(
            Map<dynamic, Map<dynamic, dynamic>>.from(
                Map<dynamic, dynamic>.from(contentBlocker))));
      });
    }

    InAppWebViewOptions options = InAppWebViewOptions();
    options.useShouldOverrideUrlLoading = map["useShouldOverrideUrlLoading"];
    options.useOnLoadResource = map["useOnLoadResource"];
    options.useOnDownloadStart = map["useOnDownloadStart"];
    options.clearCache = map["clearCache"];
    options.userAgent = map["userAgent"];
    options.applicationNameForUserAgent = map["applicationNameForUserAgent"];
    options.javaScriptEnabled = map["javaScriptEnabled"];
    options.debuggingEnabled = map["debuggingEnabled"];
    options.javaScriptCanOpenWindowsAutomatically =
        map["javaScriptCanOpenWindowsAutomatically"];
    options.mediaPlaybackRequiresUserGesture =
        map["mediaPlaybackRequiresUserGesture"];
    options.verticalScrollBarEnabled = map["verticalScrollBarEnabled"];
    options.horizontalScrollBarEnabled = map["horizontalScrollBarEnabled"];
    options.resourceCustomSchemes =
        List<String>.from(map["resourceCustomSchemes"] ?? []);
    options.contentBlockers = contentBlockers;
    options.preferredContentMode =
        UserPreferredContentMode.fromValue(map["preferredContentMode"]);
    options.useShouldInterceptAjaxRequest =
        map["useShouldInterceptAjaxRequest"];
    options.useShouldInterceptFetchRequest =
        map["useShouldInterceptFetchRequest"];
    options.incognito = map["incognito"];
    options.cacheEnabled = map["cacheEnabled"];
    options.transparentBackground = map["transparentBackground"];
    options.disableVerticalScroll = map["disableVerticalScroll"];
    options.disableHorizontalScroll = map["disableHorizontalScroll"];
    options.disableContextMenu = map["disableContextMenu"];
    options.supportZoom = map["supportZoom"];
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
  InAppWebViewOptions copy() {
    return InAppWebViewOptions.fromMap(this.toMap());
  }
}

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
  AndroidMixedContentMode mixedContentMode;

  ///Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
  bool allowContentAccess;

  ///Enables or disables file access within WebView. Note that this enables or disables file system access only.
  ///Assets and resources are still accessible using \file:///android_asset` and `file:///android_res`. The default value is `true`.
  bool allowFileAccess;

  ///Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
  ///Note that the value of this setting is ignored if the value of [allowFileAccessFromFileURLs] is `true`.
  ///Note too, that this setting affects only JavaScript access to file scheme resources. The default value is `false`.
  bool allowFileAccessFromFileURLs;

  ///Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from any origin.
  ///Note that this setting affects only JavaScript access to file scheme resources.
  ///This includes access to content from other file scheme URLs. The default value is `false`.
  bool allowUniversalAccessFromFileURLs;

  ///Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
  ///This option is used one time: repeated calls are ignored.
  String appCachePath;

  ///Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
  bool blockNetworkImage;

  ///Sets whether the WebView should not load resources from the network. The default value is `false`.
  bool blockNetworkLoads;

  ///Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
  ///When navigating back, content is not revalidated, instead the content is just retrieved from the cache. The default value is [AndroidCacheMode.LOAD_DEFAULT].
  AndroidCacheMode cacheMode;

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
  AndroidActionModeMenuItem disabledActionModeMenuItems;

  ///Sets the fantasy font family name. The default value is `"fantasy"`.
  String fantasyFontFamily;

  ///Sets the fixed font family name. The default value is `"monospace"`.
  String fixedFontFamily;

  ///Set the force dark mode for this WebView. The default value is [AndroidForceDark.FORCE_DARK_OFF].
  ///
  ///**NOTE**: available on Android 29+.
  AndroidForceDark forceDark;

  ///Sets whether Geolocation API is enabled. The default value is `true`.
  bool geolocationEnabled;

  ///Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
  AndroidLayoutAlgorithm layoutAlgorithm;

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
  ///If set to `true`, [onCreateWindow] event must be implemented by the host application. The default value is `false`.
  bool supportMultipleWindows;

  ///Regular expression used by [shouldOverrideUrlLoading] event to cancel navigation requests for frames that are not the main frame.
  ///If the url request of a subframe matches the regular expression, then the request of that subframe is canceled.
  String regexToCancelSubFramesLoading;

  ///Set to `true` to be able to listen at the [WebView.androidShouldInterceptRequest] event. The default value is `false`.
  bool useShouldInterceptRequest;

  ///Set to `true` to be able to listen at the [WebView.androidOnRenderProcessGone] event. The default value is `false`.
  bool useOnRenderProcessGone;

  ///Sets the WebView's over-scroll mode.
  ///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
  ///The default value is [AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS].
  AndroidOverScrollMode overScrollMode;

  ///Informs WebView of the network state.
  ///This is used to set the JavaScript property `window.navigator.isOnline` and generates the online/offline event as specified in HTML5, sec. 5.7.7.
  bool networkAvailable;

  ///Specifies the style of the scrollbars. The scrollbars can be overlaid or inset.
  ///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
  ///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
  ///you can use SCROLLBARS_INSIDE_OVERLAY or SCROLLBARS_INSIDE_INSET. If you want them to appear at the edge of the view, ignoring the padding,
  ///then you can use SCROLLBARS_OUTSIDE_OVERLAY or SCROLLBARS_OUTSIDE_INSET.
  ///The default value is [AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY].
  AndroidScrollBarStyle scrollBarStyle;

  ///Sets the position of the vertical scroll bar.
  ///The default value is [AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT].
  AndroidVerticalScrollbarPosition verticalScrollbarPosition;

  ///Defines the delay in milliseconds that a scrollbar waits before fade out.
  int scrollBarDefaultDelayBeforeFade;

  ///Defines whether scrollbars will fade when the view is not scrolling.
  ///The default value is `true`.
  bool scrollbarFadingEnabled;

  ///Defines the scrollbar fade duration in milliseconds.
  int scrollBarFadeDuration;

  ///Sets the renderer priority policy for this WebView.
  RendererPriorityPolicy rendererPriorityPolicy;

  ///Sets whether the default Android error page should be disabled.
  ///The default value is `false`.
  bool disableDefaultErrorPage;

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
    this.allowFileAccessFromFileURLs = false,
    this.allowUniversalAccessFromFileURLs = false,
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
    this.disableDefaultErrorPage,
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
      "allowFileAccessFromFileURLs": allowFileAccessFromFileURLs,
      "allowUniversalAccessFromFileURLs": allowUniversalAccessFromFileURLs,
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
      "disableDefaultErrorPage": disableDefaultErrorPage
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
    options.allowFileAccessFromFileURLs = map["allowFileAccessFromFileURLs"];
    options.allowUniversalAccessFromFileURLs =
        map["allowUniversalAccessFromFileURLs"];
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

///This class represents all the iOS-only WebView options available.
class IOSInAppWebViewOptions
    implements WebViewOptions, BrowserOptions, IosOptions {
  ///Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  bool disallowOverScroll;

  ///Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  bool enableViewportScale;

  ///Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. The default value is `false`.
  bool suppressesIncrementalRendering;

  ///Set to `true` to allow AirPlay. The default value is `true`.
  bool allowsAirPlayForMediaPlayback;

  ///Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations. The default value is `true`.
  bool allowsBackForwardNavigationGestures;

  ///Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  ///
  ///**NOTE**: available on iOS 9.0+.
  bool allowsLinkPreview;

  ///Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent.
  ///The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  bool ignoresViewportScaleLimits;

  ///Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls.
  ///For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  bool allowsInlineMediaPlayback;

  ///Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
  ///
  ///**NOTE**: available on iOS 9.0+.
  bool allowsPictureInPictureMediaPlayback;

  ///A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware.
  ///According to the official documentation, this feature is currently available in the following region: China.
  ///The default value is `true`.
  ///
  ///**NOTE**: available on iOS 13.0+.
  bool isFraudulentWebsiteWarningEnabled;

  ///The level of granularity with which the user can interactively select content in the web view.
  ///The default value is [IOSWKSelectionGranularity.DYNAMIC]
  IOSWKSelectionGranularity selectionGranularity;

  ///Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
  ///For example, Safari adds a link to “apple.com” in the text “Visit apple.com” if the dataDetectorTypes property is set to [IOSWKDataDetectorTypes.LINK].
  ///The default value is [IOSWKDataDetectorTypes.NONE].
  ///
  ///**NOTE**: available on iOS 10.0+.
  List<IOSWKDataDetectorTypes> dataDetectorTypes;

  ///Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
  ///The default value is `false`.
  ///
  ///**NOTE**: available on iOS 11.0+.
  bool sharedCookiesEnabled;

  ///Configures whether the scroll indicator insets are automatically adjusted by the system.
  ///The default value is `false`.
  ///
  ///**NOTE**: available on iOS 13.0+.
  bool automaticallyAdjustsScrollIndicatorInsets;

  ///A Boolean value indicating whether the WebView ignores an accessibility request to invert its colors.
  ///The default value is `false`.
  ///
  ///**NOTE**: available on iOS 11.0+.
  bool accessibilityIgnoresInvertColors;

  ///A [IOSUIScrollViewDecelerationRate] value that determines the rate of deceleration after the user lifts their finger.
  ///The default value is [IOSUIScrollViewDecelerationRate.NORMAL].
  IOSUIScrollViewDecelerationRate decelerationRate;

  ///A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
  ///The default value is `false`.
  bool alwaysBounceVertical;

  ///A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
  ///The default value is `false`.
  bool alwaysBounceHorizontal;

  ///A Boolean value that controls whether the scroll-to-top gesture is enabled.
  ///The scroll-to-top gesture is a tap on the status bar. When a user makes this gesture,
  ///the system asks the scroll view closest to the status bar to scroll to the top.
  ///The default value is `true`.
  bool scrollsToTop;

  ///A Boolean value that determines whether paging is enabled for the scroll view.
  ///If the value of this property is true, the scroll view stops on multiples of the scroll view’s bounds when the user scrolls.
  ///The default value is `false`.
  bool isPagingEnabled;

  ///A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content.
  ///This value determines how large the content can be scaled.
  ///It must be greater than the minimum zoom scale for zooming to be enabled.
  ///The default value is `1.0`.
  double maximumZoomScale;

  ///A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content.
  ///This value determines how small the content can be scaled.
  ///The default value is `1.0`.
  double minimumZoomScale;

  ///Configures how safe area insets are added to the adjusted content inset.
  ///The default value is [IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER].
  IOSUIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior;

  IOSInAppWebViewOptions(
      {this.disallowOverScroll = false,
      this.enableViewportScale = false,
      this.suppressesIncrementalRendering = false,
      this.allowsAirPlayForMediaPlayback = true,
      this.allowsBackForwardNavigationGestures = true,
      this.allowsLinkPreview = true,
      this.ignoresViewportScaleLimits = false,
      this.allowsInlineMediaPlayback = false,
      this.allowsPictureInPictureMediaPlayback = true,
      this.isFraudulentWebsiteWarningEnabled = true,
      this.selectionGranularity = IOSWKSelectionGranularity.DYNAMIC,
      this.dataDetectorTypes = const [IOSWKDataDetectorTypes.NONE],
      this.sharedCookiesEnabled = false,
      this.automaticallyAdjustsScrollIndicatorInsets = false,
      this.accessibilityIgnoresInvertColors = false,
      this.decelerationRate = IOSUIScrollViewDecelerationRate.NORMAL,
      this.alwaysBounceVertical = false,
      this.alwaysBounceHorizontal = false,
      this.scrollsToTop = true,
      this.isPagingEnabled = false,
      this.maximumZoomScale = 1.0,
      this.minimumZoomScale = 1.0,
      this.contentInsetAdjustmentBehavior =
          IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER});

  @override
  Map<String, dynamic> toMap() {
    List<String> dataDetectorTypesList = [];
    dataDetectorTypes.forEach((dataDetectorType) {
      dataDetectorTypesList.add(dataDetectorType.toValue());
    });

    return {
      "disallowOverScroll": disallowOverScroll,
      "enableViewportScale": enableViewportScale,
      "suppressesIncrementalRendering": suppressesIncrementalRendering,
      "allowsAirPlayForMediaPlayback": allowsAirPlayForMediaPlayback,
      "allowsBackForwardNavigationGestures":
          allowsBackForwardNavigationGestures,
      "allowsLinkPreview": allowsLinkPreview,
      "ignoresViewportScaleLimits": ignoresViewportScaleLimits,
      "allowsInlineMediaPlayback": allowsInlineMediaPlayback,
      "allowsPictureInPictureMediaPlayback":
          allowsPictureInPictureMediaPlayback,
      "isFraudulentWebsiteWarningEnabled": isFraudulentWebsiteWarningEnabled,
      "selectionGranularity": selectionGranularity.toValue(),
      "dataDetectorTypes": dataDetectorTypesList,
      "sharedCookiesEnabled": sharedCookiesEnabled,
      "automaticallyAdjustsScrollIndicatorInsets":
          automaticallyAdjustsScrollIndicatorInsets,
      "accessibilityIgnoresInvertColors": accessibilityIgnoresInvertColors,
      "decelerationRate": decelerationRate.toValue(),
      "alwaysBounceVertical": alwaysBounceVertical,
      "alwaysBounceHorizontal": alwaysBounceHorizontal,
      "scrollsToTop": scrollsToTop,
      "isPagingEnabled": isPagingEnabled,
      "maximumZoomScale": maximumZoomScale,
      "minimumZoomScale": minimumZoomScale,
      "contentInsetAdjustmentBehavior": contentInsetAdjustmentBehavior.toValue()
    };
  }

  static IOSInAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<IOSWKDataDetectorTypes> dataDetectorTypes = [];
    List<String> dataDetectorTypesList =
        List<String>.from(map["dataDetectorTypes"] ?? []);
    dataDetectorTypesList.forEach((dataDetectorType) {
      dataDetectorTypes.add(IOSWKDataDetectorTypes.fromValue(dataDetectorType));
    });

    IOSInAppWebViewOptions options = IOSInAppWebViewOptions();
    options.disallowOverScroll = map["disallowOverScroll"];
    options.enableViewportScale = map["enableViewportScale"];
    options.suppressesIncrementalRendering =
        map["suppressesIncrementalRendering"];
    options.allowsAirPlayForMediaPlayback =
        map["allowsAirPlayForMediaPlayback"];
    options.allowsBackForwardNavigationGestures =
        map["allowsBackForwardNavigationGestures"];
    options.allowsLinkPreview = map["allowsLinkPreview"];
    options.ignoresViewportScaleLimits = map["ignoresViewportScaleLimits"];
    options.allowsInlineMediaPlayback = map["allowsInlineMediaPlayback"];
    options.allowsPictureInPictureMediaPlayback =
        map["allowsPictureInPictureMediaPlayback"];
    options.isFraudulentWebsiteWarningEnabled =
        map["isFraudulentWebsiteWarningEnabled"];
    options.selectionGranularity =
        IOSWKSelectionGranularity.fromValue(map["selectionGranularity"]);
    options.dataDetectorTypes = dataDetectorTypes;
    options.sharedCookiesEnabled = map["sharedCookiesEnabled"];
    options.automaticallyAdjustsScrollIndicatorInsets =
        map["automaticallyAdjustsScrollIndicatorInsets"];
    options.accessibilityIgnoresInvertColors =
        map["accessibilityIgnoresInvertColors"];
    options.decelerationRate =
        IOSUIScrollViewDecelerationRate.fromValue(map["decelerationRate"]);
    options.alwaysBounceVertical = map["alwaysBounceVertical"];
    options.alwaysBounceHorizontal = map["alwaysBounceHorizontal"];
    options.scrollsToTop = map["scrollsToTop"];
    options.isPagingEnabled = map["isPagingEnabled"];
    options.maximumZoomScale = map["maximumZoomScale"];
    options.minimumZoomScale = map["minimumZoomScale"];
    options.contentInsetAdjustmentBehavior =
        IOSUIScrollViewContentInsetAdjustmentBehavior.fromValue(
            map["contentInsetAdjustmentBehavior"]);
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
  IOSInAppWebViewOptions copy() {
    return IOSInAppWebViewOptions.fromMap(this.toMap());
  }
}

///This class represents all the cross-platform [InAppBrowser] options available.
class InAppBrowserOptions
    implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  bool hidden;

  ///Set to `false` to hide the toolbar at the top of the WebView. The default value is `true`.
  bool toolbarTop;

  ///Set the custom background color of the toolbar at the top.
  String toolbarTopBackgroundColor;

  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  bool hideUrlBar;

  InAppBrowserOptions(
      {this.hidden = false,
      this.toolbarTop = true,
      this.toolbarTopBackgroundColor = "",
      this.hideUrlBar = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hidden": hidden,
      "toolbarTop": toolbarTop,
      "toolbarTopBackgroundColor": toolbarTopBackgroundColor,
      "hideUrlBar": hideUrlBar
    };
  }

  static InAppBrowserOptions fromMap(Map<String, dynamic> map) {
    InAppBrowserOptions options = InAppBrowserOptions();
    options.hidden = map["hidden"];
    options.toolbarTop = map["toolbarTop"];
    options.toolbarTopBackgroundColor = map["toolbarTopBackgroundColor"];
    options.hideUrlBar = map["hideUrlBar"];
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
  InAppBrowserOptions copy() {
    return InAppBrowserOptions.fromMap(this.toMap());
  }
}

///This class represents all the Android-only [InAppBrowser] options available.
class AndroidInAppBrowserOptions implements BrowserOptions, AndroidOptions {
  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  bool hideTitleBar;

  ///Set the action bar's title.
  String toolbarTopFixedTitle;

  ///Set to `false` to not close the InAppBrowser when the user click on the back button and the WebView cannot go back to the history. The default value is `true`.
  bool closeOnCannotGoBack;

  ///Set to `false` to hide the progressz bar at the bottom of the toolbar at the top. The default value is `true`.
  bool progressBar;

  AndroidInAppBrowserOptions(
      {this.hideTitleBar = true,
      this.toolbarTopFixedTitle = "",
      this.closeOnCannotGoBack = true,
      this.progressBar = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hideTitleBar": hideTitleBar,
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "closeOnCannotGoBack": closeOnCannotGoBack,
      "progressBar": progressBar,
    };
  }

  static AndroidInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    AndroidInAppBrowserOptions options = AndroidInAppBrowserOptions();
    options.hideTitleBar = map["hideTitleBar"];
    options.toolbarTopFixedTitle = map["toolbarTopFixedTitle"];
    options.closeOnCannotGoBack = map["closeOnCannotGoBack"];
    options.progressBar = map["progressBar"];
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
  AndroidInAppBrowserOptions copy() {
    return AndroidInAppBrowserOptions.fromMap(this.toMap());
  }
}

///This class represents all the iOS-only [InAppBrowser] options available.
class IOSInAppBrowserOptions implements BrowserOptions, IosOptions {
  ///Set to `false` to hide the toolbar at the bottom of the WebView. The default value is `true`.
  bool toolbarBottom;

  ///Set the custom background color of the toolbar at the bottom.
  String toolbarBottomBackgroundColor;

  ///Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  bool toolbarBottomTranslucent;

  ///Set the custom text for the close button.
  String closeButtonCaption;

  ///Set the custom color for the close button.
  String closeButtonColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [IOSUIModalPresentationStyle.FULL_SCREEN].
  IOSUIModalPresentationStyle presentationStyle;

  ///Set to the custom transition style when presenting the WebView. The default value is [IOSUIModalTransitionStyle.COVER_VERTICAL].
  IOSUIModalTransitionStyle transitionStyle;

  ///Set to `false` to hide the spinner when the WebView is loading a page. The default value is `true`.
  bool spinner;

  IOSInAppBrowserOptions(
      {this.toolbarBottom = true,
      this.toolbarBottomBackgroundColor = "",
      this.toolbarBottomTranslucent = true,
      this.closeButtonCaption = "",
      this.closeButtonColor = "",
      this.presentationStyle = IOSUIModalPresentationStyle.FULL_SCREEN,
      this.transitionStyle = IOSUIModalTransitionStyle.COVER_VERTICAL,
      this.spinner = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      "toolbarBottom": toolbarBottom,
      "toolbarBottomBackgroundColor": toolbarBottomBackgroundColor,
      "toolbarBottomTranslucent": toolbarBottomTranslucent,
      "closeButtonCaption": closeButtonCaption,
      "closeButtonColor": closeButtonColor,
      "presentationStyle": presentationStyle.toValue(),
      "transitionStyle": transitionStyle.toValue(),
      "spinner": spinner
    };
  }

  static IOSInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    IOSInAppBrowserOptions options = IOSInAppBrowserOptions();
    options.toolbarBottom = map["toolbarBottom"];
    options.toolbarBottomBackgroundColor = map["toolbarBottomBackgroundColor"];
    options.toolbarBottomTranslucent = map["toolbarBottomTranslucent"];
    options.closeButtonCaption = map["closeButtonCaption"];
    options.closeButtonColor = map["closeButtonColor"];
    options.presentationStyle =
        IOSUIModalPresentationStyle.fromValue(map["presentationStyle"]);
    options.transitionStyle =
        IOSUIModalTransitionStyle.fromValue(map["transitionStyle"]);
    options.spinner = map["spinner"];
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
  IOSInAppBrowserOptions copy() {
    return IOSInAppBrowserOptions.fromMap(this.toMap());
  }
}

///This class represents all the Android-only [ChromeSafariBrowser] options available.
class AndroidChromeCustomTabsOptions
    implements ChromeSafariBrowserOptions, AndroidOptions {
  ///Set to `false` if you don't want the default share item to the menu. The default value is `true`.
  bool addDefaultShareMenuItem;

  ///Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  bool showTitle;

  ///Set the custom background color of the toolbar.
  String toolbarBackgroundColor;

  ///Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  bool enableUrlBarHiding;

  ///Set to `true` to enable Instant Apps. The default value is `false`.
  bool instantAppsEnabled;

  ///Set an explicit application package name that limits
  ///the components this Intent will resolve to.  If left to the default
  ///value of null, all components in all applications will considered.
  ///If non-null, the Intent can only match the components in the given
  ///application package.
  String packageName;

  ///Set to `true` to enable Keep Alive. The default value is `false`.
  bool keepAliveEnabled;

  AndroidChromeCustomTabsOptions(
      {this.addDefaultShareMenuItem = true,
      this.showTitle = true,
      this.toolbarBackgroundColor = "",
      this.enableUrlBarHiding = false,
      this.instantAppsEnabled = false,
      this.packageName,
      this.keepAliveEnabled = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "addDefaultShareMenuItem": addDefaultShareMenuItem,
      "showTitle": showTitle,
      "toolbarBackgroundColor": toolbarBackgroundColor,
      "enableUrlBarHiding": enableUrlBarHiding,
      "instantAppsEnabled": instantAppsEnabled,
      "packageName": packageName,
      "keepAliveEnabled": keepAliveEnabled
    };
  }

  static AndroidChromeCustomTabsOptions fromMap(Map<String, dynamic> map) {
    AndroidChromeCustomTabsOptions options =
        new AndroidChromeCustomTabsOptions();
    options.addDefaultShareMenuItem = map["addDefaultShareMenuItem"];
    options.showTitle = map["showTitle"];
    options.toolbarBackgroundColor = map["toolbarBackgroundColor"];
    options.enableUrlBarHiding = map["enableUrlBarHiding"];
    options.instantAppsEnabled = map["instantAppsEnabled"];
    options.packageName = map["packageName"];
    options.keepAliveEnabled = map["keepAliveEnabled"];
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
  AndroidChromeCustomTabsOptions copy() {
    return AndroidChromeCustomTabsOptions.fromMap(this.toMap());
  }
}

///This class represents all the iOS-only [ChromeSafariBrowser] options available.
class IOSSafariOptions implements ChromeSafariBrowserOptions, IosOptions {
  ///Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  bool entersReaderIfAvailable;

  ///Set to `true` to enable bar collapsing. The default value is `false`.
  bool barCollapsingEnabled;

  ///Set the custom style for the dismiss button. The default value is [IOSSafariDismissButtonStyle.DONE].
  ///
  ///**NOTE**: available on iOS 11.0+.
  IOSSafariDismissButtonStyle dismissButtonStyle;

  ///Set the custom background color of the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  String preferredBarTintColor;

  ///Set the custom color of the control buttons on the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  String preferredControlTintColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [IOSUIModalPresentationStyle.FULL_SCREEN].
  IOSUIModalPresentationStyle presentationStyle;

  ///Set to the custom transition style when presenting the WebView. The default value is [IOSUIModalTransitionStyle.COVER_VERTICAL].
  IOSUIModalTransitionStyle transitionStyle;

  IOSSafariOptions(
      {this.entersReaderIfAvailable = false,
      this.barCollapsingEnabled = false,
      this.dismissButtonStyle = IOSSafariDismissButtonStyle.DONE,
      this.preferredBarTintColor = "",
      this.preferredControlTintColor = "",
      this.presentationStyle = IOSUIModalPresentationStyle.FULL_SCREEN,
      this.transitionStyle = IOSUIModalTransitionStyle.COVER_VERTICAL});

  @override
  Map<String, dynamic> toMap() {
    return {
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": dismissButtonStyle.toValue(),
      "preferredBarTintColor": preferredBarTintColor,
      "preferredControlTintColor": preferredControlTintColor,
      "presentationStyle": presentationStyle.toValue(),
      "transitionStyle": transitionStyle.toValue()
    };
  }

  static IOSSafariOptions fromMap(Map<String, dynamic> map) {
    IOSSafariOptions options = IOSSafariOptions();
    options.entersReaderIfAvailable = map["entersReaderIfAvailable"];
    options.barCollapsingEnabled = map["barCollapsingEnabled"];
    options.dismissButtonStyle =
        IOSSafariDismissButtonStyle.fromValue(map["dismissButtonStyle"]);
    options.preferredBarTintColor = map["preferredBarTintColor"];
    options.preferredControlTintColor = map["preferredControlTintColor"];
    options.presentationStyle =
        IOSUIModalPresentationStyle.fromValue(map["presentationStyle"]);
    options.transitionStyle =
        IOSUIModalTransitionStyle.fromValue(map["transitionStyle"]);
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
  IOSSafariOptions copy() {
    return IOSSafariOptions.fromMap(this.toMap());
  }
}
