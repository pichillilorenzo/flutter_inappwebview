import 'dart:io';

import 'types.dart';
import 'package:flutter_inappbrowser/src/content_blocker.dart';

class AndroidOptions {}
class IosOptions {}

class WebViewOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static WebViewOptions fromMap(Map<String, dynamic> map) {
    return null;
  }
}

class BrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static BrowserOptions fromMap(Map<String, dynamic> map) {
    return null;
  }
}

class ChromeSafariBrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static ChromeSafariBrowserOptions fromMap(Map<String, dynamic> map) {
    return null;
  }
}

///This class represents all the cross-platform WebView options available.
class InAppWebViewOptions implements WebViewOptions, BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to be able to listen at the [shouldOverrideUrlLoading] event. The default value is `false`.
  bool useShouldOverrideUrlLoading;
  ///Set to `true` to be able to listen at the [onLoadResource] event. The default value is `false`.
  bool useOnLoadResource;
  ///Set to `true` to be able to listen at the [onDownloadStart] event. The default value is `false`.
  bool useOnDownloadStart;
  ///Set to `true` to be able to listen at the [onTargetBlank] event. The default value is `false`.
  bool useOnTargetBlank;
  ///Set to `true` to have all the browser's cache cleared before the new window is opened. The default value is `false`.
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
  ///Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is [InAppWebViewUserPreferredContentMode.RECOMMENDED].
  ///
  ///**NOTE**: available on iOS 13.0+.
  InAppWebViewUserPreferredContentMode preferredContentMode;
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

  InAppWebViewOptions({this.useShouldOverrideUrlLoading = false, this.useOnLoadResource = false, this.useOnDownloadStart = false, this.useOnTargetBlank = false,
    this.clearCache = false, this.userAgent = "", this.applicationNameForUserAgent = "", this.javaScriptEnabled = true, this.debuggingEnabled = false, this.javaScriptCanOpenWindowsAutomatically = false,
    this.mediaPlaybackRequiresUserGesture = true, this.minimumFontSize, this.verticalScrollBarEnabled = true, this.horizontalScrollBarEnabled = true,
    this.resourceCustomSchemes = const [], this.contentBlockers = const [], this.preferredContentMode = InAppWebViewUserPreferredContentMode.RECOMMENDED,
    this.useShouldInterceptAjaxRequest = false, this.useShouldInterceptFetchRequest = false, this.incognito = false, this.cacheEnabled = true, this.transparentBackground = false,
    this.disableVerticalScroll = false, this.disableHorizontalScroll = false}) {
      if (this.minimumFontSize == null)
        this.minimumFontSize = Platform.isAndroid ? 8 : 0;
      assert(!this.resourceCustomSchemes.contains("http") && !this.resourceCustomSchemes.contains("https"));
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
      "useOnTargetBlank": useOnTargetBlank,
      "clearCache": clearCache,
      "userAgent": userAgent,
      "applicationNameForUserAgent": applicationNameForUserAgent,
      "javaScriptEnabled": javaScriptEnabled,
      "debuggingEnabled": debuggingEnabled,
      "javaScriptCanOpenWindowsAutomatically": javaScriptCanOpenWindowsAutomatically,
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
      "disableHorizontalScroll": disableHorizontalScroll
    };
  }

  @override
  static InAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<ContentBlocker> contentBlockers = [];
    List<dynamic> contentBlockersMapList = map["contentBlockers"];
    if (contentBlockersMapList != null) {
      contentBlockersMapList.forEach((contentBlocker) {
        contentBlockers.add(ContentBlocker.fromMap(
            Map<dynamic, Map<dynamic, dynamic>>.from(Map<dynamic, dynamic>.from(contentBlocker))
        ));
      });
    }

    InAppWebViewOptions options = new InAppWebViewOptions();
    options.useShouldOverrideUrlLoading = map["useShouldOverrideUrlLoading"];
    options.useOnLoadResource = map["useOnLoadResource"];
    options.useOnDownloadStart = map["useOnDownloadStart"];
    options.useOnTargetBlank = map["useOnTargetBlank"];
    options.clearCache = map["clearCache"];
    options.userAgent = map["userAgent"];
    options.applicationNameForUserAgent = map["applicationNameForUserAgent"];
    options.javaScriptEnabled = map["javaScriptEnabled"];
    options.debuggingEnabled = map["debuggingEnabled"];
    options.javaScriptCanOpenWindowsAutomatically = map["javaScriptCanOpenWindowsAutomatically"];
    options.mediaPlaybackRequiresUserGesture = map["mediaPlaybackRequiresUserGesture"];
    options.verticalScrollBarEnabled = map["verticalScrollBarEnabled"];
    options.horizontalScrollBarEnabled = map["horizontalScrollBarEnabled"];
    options.resourceCustomSchemes = List<String>.from(map["resourceCustomSchemes"] ?? []);
    options.contentBlockers = contentBlockers;
    options.preferredContentMode = InAppWebViewUserPreferredContentMode.fromValue(map["preferredContentMode"]);
    options.useShouldInterceptAjaxRequest = map["useShouldInterceptAjaxRequest"];
    options.useShouldInterceptFetchRequest = map["useShouldInterceptFetchRequest"];
    options.incognito = map["incognito"];
    options.cacheEnabled = map["cacheEnabled"];
    options.transparentBackground = map["transparentBackground"];
    options.disableVerticalScroll = map["disableVerticalScroll"];
    options.disableHorizontalScroll = map["disableHorizontalScroll"];
    return options;
  }
}

///This class represents all the Android-only WebView options available.
class AndroidInAppWebViewOptions implements WebViewOptions, BrowserOptions, AndroidOptions {
  ///Sets the text zoom of the page in percent. The default value is `100`.
  int textZoom;
  ///Set to `true` to have the session cookie cache cleared before the new window is opened.
  bool clearSessionCache;
  ///Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `false`.
  bool builtInZoomControls;
  ///Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  bool displayZoomControls;
  ///Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  bool supportZoom;
  ///Set to `true` if you want the database storage API is enabled. The default value is `false`.
  bool databaseEnabled;
  ///Set to `true` if you want the DOM storage API is enabled. The default value is `false`.
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
  AndroidInAppWebViewMixedContentMode mixedContentMode;
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
  ///When navigating back, content is not revalidated, instead the content is just retrieved from the cache. The default value is [AndroidInAppWebViewCacheMode.LOAD_DEFAULT].
  AndroidInAppWebViewCacheMode cacheMode;
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
  AndroidInAppWebViewModeMenuItem disabledActionModeMenuItems;
  ///Sets the fantasy font family name. The default value is `"fantasy"`.
  String fantasyFontFamily;
  ///Sets the fixed font family name. The default value is `"monospace"`.
  String fixedFontFamily;
  ///Set the force dark mode for this WebView. The default value is [AndroidInAppWebViewForceDark.FORCE_DARK_OFF].
  ///
  ///**NOTE**: available on Android 29+.
  AndroidInAppWebViewForceDark forceDark;
  ///Sets whether Geolocation API is enabled. The default value is `true`.
  bool geolocationEnabled;
  ///Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
  AndroidInAppWebViewLayoutAlgorithm layoutAlgorithm;
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

  AndroidInAppWebViewOptions({this.textZoom = 100, this.clearSessionCache = false, this.builtInZoomControls = false, this.displayZoomControls = false, this.supportZoom = true, this.databaseEnabled = false,
    this.domStorageEnabled = false, this.useWideViewPort = true, this.safeBrowsingEnabled = true, this.mixedContentMode,
    this.allowContentAccess = true, this.allowFileAccess = true, this.allowFileAccessFromFileURLs = false, this.allowUniversalAccessFromFileURLs = false,
    this.appCachePath, this.blockNetworkImage = false, this.blockNetworkLoads = false, this.cacheMode = AndroidInAppWebViewCacheMode.LOAD_DEFAULT,
    this.cursiveFontFamily = "cursive", this.defaultFixedFontSize = 16, this.defaultFontSize = 16, this.defaultTextEncodingName = "UTF-8",
    this.disabledActionModeMenuItems, this.fantasyFontFamily = "fantasy", this.fixedFontFamily = "monospace", this.forceDark = AndroidInAppWebViewForceDark.FORCE_DARK_OFF,
    this.geolocationEnabled = true, this.layoutAlgorithm, this.loadWithOverviewMode = true, this.loadsImagesAutomatically = true,
    this.minimumLogicalFontSize = 8, this.needInitialFocus = true, this.offscreenPreRaster = false, this.sansSerifFontFamily = "sans-serif", this.serifFontFamily = "sans-serif",
    this.standardFontFamily = "sans-serif", this.saveFormData = true, this.thirdPartyCookiesEnabled = true, this.hardwareAcceleration = true, this.initialScale = 0
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "textZoom": textZoom,
      "clearSessionCache": clearSessionCache,
      "builtInZoomControls": builtInZoomControls,
      "displayZoomControls": displayZoomControls,
      "supportZoom": supportZoom,
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
      "hardwareAcceleration": hardwareAcceleration
    };
  }

  @override
  static AndroidInAppWebViewOptions fromMap(Map<String, dynamic> map) {
    AndroidInAppWebViewOptions options = new AndroidInAppWebViewOptions();
    options.textZoom = map["textZoom"];
    options.clearSessionCache = map["clearSessionCache"];
    options.builtInZoomControls = map["builtInZoomControls"];
    options.displayZoomControls = map["displayZoomControls"];
    options.supportZoom = map["supportZoom"];
    options.databaseEnabled = map["databaseEnabled"];
    options.domStorageEnabled = map["domStorageEnabled"];
    options.useWideViewPort = map["useWideViewPort"];
    options.safeBrowsingEnabled = map["safeBrowsingEnabled"];
    options.mixedContentMode = AndroidInAppWebViewMixedContentMode.fromValue(map["mixedContentMode"]);
    options.allowContentAccess = map["allowContentAccess"];
    options.allowFileAccess = map["allowFileAccess"];
    options.allowFileAccessFromFileURLs = map["allowFileAccessFromFileURLs"];
    options.allowUniversalAccessFromFileURLs = map["allowUniversalAccessFromFileURLs"];
    options.appCachePath = map["appCachePath"];
    options.blockNetworkImage = map["blockNetworkImage"];
    options.blockNetworkLoads = map["blockNetworkLoads"];
    options.cacheMode = AndroidInAppWebViewCacheMode.fromValue(map["cacheMode"]);
    options.cursiveFontFamily = map["cursiveFontFamily"];
    options.defaultFixedFontSize = map["defaultFixedFontSize"];
    options.defaultFontSize = map["defaultFontSize"];
    options.defaultTextEncodingName = map["defaultTextEncodingName"];
    options.disabledActionModeMenuItems = AndroidInAppWebViewModeMenuItem.fromValue(map["disabledActionModeMenuItems"]);
    options.fantasyFontFamily = map["fantasyFontFamily"];
    options.fixedFontFamily = map["fixedFontFamily"];
    options.forceDark = AndroidInAppWebViewForceDark.fromValue(map["forceDark"]);
    options.geolocationEnabled = map["geolocationEnabled"];
    options.layoutAlgorithm = AndroidInAppWebViewLayoutAlgorithm.fromValue(map["layoutAlgorithm"]);
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
    return options;
  }
}

///This class represents all the iOS-only WebView options available.
class IosInAppWebViewOptions implements WebViewOptions, BrowserOptions, IosOptions {
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
  ///The default value is [IosInAppWebViewSelectionGranularity.DYNAMIC]
  IosInAppWebViewSelectionGranularity selectionGranularity;
  ///Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
  ///For example, Safari adds a link to “apple.com” in the text “Visit apple.com” if the dataDetectorTypes property is set to [IosInAppWebViewDataDetectorTypes.LINK].
  ///The default value is [IosInAppWebViewDataDetectorTypes.NONE].
  ///
  ///**NOTE**: available on iOS 10.0+.
  List<IosInAppWebViewDataDetectorTypes> dataDetectorTypes;
  ///Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
  ///The default value is `false`.
  ///
  ///**NOTE**: available on iOS 11.0+.
  bool sharedCookiesEnabled;

  IosInAppWebViewOptions({this.disallowOverScroll = false, this.enableViewportScale = false, this.suppressesIncrementalRendering = false, this.allowsAirPlayForMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true, this.allowsLinkPreview = true, this.ignoresViewportScaleLimits = false, this.allowsInlineMediaPlayback = false,
    this.allowsPictureInPictureMediaPlayback = true, this.isFraudulentWebsiteWarningEnabled = true,
    this.selectionGranularity = IosInAppWebViewSelectionGranularity.DYNAMIC, this.dataDetectorTypes = const [IosInAppWebViewDataDetectorTypes.NONE], this.sharedCookiesEnabled = false
  });

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
      "allowsBackForwardNavigationGestures": allowsBackForwardNavigationGestures,
      "allowsLinkPreview": allowsLinkPreview,
      "ignoresViewportScaleLimits": ignoresViewportScaleLimits,
      "allowsInlineMediaPlayback": allowsInlineMediaPlayback,
      "allowsPictureInPictureMediaPlayback": allowsPictureInPictureMediaPlayback,
      "isFraudulentWebsiteWarningEnabled": isFraudulentWebsiteWarningEnabled,
      "selectionGranularity": selectionGranularity.toValue(),
      "dataDetectorTypes": dataDetectorTypesList,
      "sharedCookiesEnabled": sharedCookiesEnabled
    };
  }

  @override
  static IosInAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<IosInAppWebViewDataDetectorTypes> dataDetectorTypes = [];
    List<String> dataDetectorTypesList = List<String>.from(map["dataDetectorTypes"] ?? []);
    dataDetectorTypesList.forEach((dataDetectorType) {
      dataDetectorTypes.add(IosInAppWebViewDataDetectorTypes.fromValue(dataDetectorType));
    });

    IosInAppWebViewOptions options = new IosInAppWebViewOptions();
    options.disallowOverScroll = map["disallowOverScroll"];
    options.enableViewportScale = map["enableViewportScale"];
    options.suppressesIncrementalRendering = map["suppressesIncrementalRendering"];
    options.allowsAirPlayForMediaPlayback = map["allowsAirPlayForMediaPlayback"];
    options.allowsBackForwardNavigationGestures = map["allowsBackForwardNavigationGestures"];
    options.allowsLinkPreview = map["allowsLinkPreview"];
    options.ignoresViewportScaleLimits = map["ignoresViewportScaleLimits"];
    options.allowsInlineMediaPlayback = map["allowsInlineMediaPlayback"];
    options.allowsPictureInPictureMediaPlayback = map["allowsPictureInPictureMediaPlayback"];
    options.isFraudulentWebsiteWarningEnabled = map["isFraudulentWebsiteWarningEnabled"];
    options.selectionGranularity = IosInAppWebViewSelectionGranularity.fromValue(map["selectionGranularity"]);
    options.dataDetectorTypes = dataDetectorTypes;
    options.sharedCookiesEnabled = map["sharedCookiesEnabled"];
    return options;
  }
}

///This class represents all the cross-platform [InAppBrowser] options available.
class InAppBrowserOptions implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  bool hidden;
  ///Set to `false` to hide the toolbar at the top of the WebView. The default value is `true`.
  bool toolbarTop;
  ///Set the custom background color of the toolbar at the top.
  String toolbarTopBackgroundColor;
  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  bool hideUrlBar;

  InAppBrowserOptions({this.hidden = false, this.toolbarTop = true, this.toolbarTopBackgroundColor = "", this.hideUrlBar = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hidden": hidden,
      "toolbarTop": toolbarTop,
      "toolbarTopBackgroundColor": toolbarTopBackgroundColor,
      "hideUrlBar": hideUrlBar
    };
  }

  @override
  static InAppBrowserOptions fromMap(Map<String, dynamic> map) {
    InAppBrowserOptions options = new InAppBrowserOptions();
    options.hidden = map["hidden"];
    options.toolbarTop = map["toolbarTop"];
    options.toolbarTopBackgroundColor = map["toolbarTopBackgroundColor"];
    options.hideUrlBar = map["hideUrlBar"];
    return options;
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
  ///Set to `false` to hide the progress bar at the bottom of the toolbar at the top. The default value is `true`.
  bool progressBar;

  AndroidInAppBrowserOptions({this.hideTitleBar = true, this.toolbarTopFixedTitle = "", this.closeOnCannotGoBack = true, this.progressBar = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hideTitleBar": hideTitleBar,
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "closeOnCannotGoBack": closeOnCannotGoBack,
      "progressBar": progressBar,
    };
  }

  @override
  static AndroidInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    AndroidInAppBrowserOptions options = new AndroidInAppBrowserOptions();
    options.hideTitleBar = map["hideTitleBar"];
    options.toolbarTopFixedTitle = map["toolbarTopFixedTitle"];
    options.closeOnCannotGoBack = map["closeOnCannotGoBack"];
    options.progressBar = map["progressBar"];
    return options;
  }
}

///This class represents all the iOS-only [InAppBrowser] options available.
class IosInAppBrowserOptions implements BrowserOptions, IosOptions {
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
  ///Set the custom modal presentation style when presenting the WebView. The default value is [IosWebViewOptionsPresentationStyle.FULL_SCREEN].
  IosWebViewOptionsPresentationStyle presentationStyle;
  ///Set to the custom transition style when presenting the WebView. The default value is [IosWebViewOptionsTransitionStyle.COVER_VERTICAL].
  IosWebViewOptionsTransitionStyle transitionStyle;
  ///Set to `false` to hide the spinner when the WebView is loading a page. The default value is `true`.
  bool spinner;

  IosInAppBrowserOptions({this.toolbarBottom = true, this.toolbarBottomBackgroundColor = "", this.toolbarBottomTranslucent = true, this.closeButtonCaption = "",
    this.closeButtonColor = "", this.presentationStyle = IosWebViewOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = IosWebViewOptionsTransitionStyle.COVER_VERTICAL, this.spinner = true});

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

  @override
  static IosInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    IosInAppBrowserOptions options = new IosInAppBrowserOptions();
    options.toolbarBottom = map["toolbarBottom"];
    options.toolbarBottomBackgroundColor = map["toolbarBottomBackgroundColor"];
    options.toolbarBottomTranslucent = map["toolbarBottomTranslucent"];
    options.closeButtonCaption = map["closeButtonCaption"];
    options.closeButtonColor = map["closeButtonColor"];
    options.presentationStyle = IosWebViewOptionsPresentationStyle.fromValue(map["presentationStyle"]);
    options.transitionStyle = IosWebViewOptionsTransitionStyle.fromValue(map["transitionStyle"]);
    options.spinner = map["spinner"];
    return options;
  }
}

///This class represents all the Android-only [ChromeSafariBrowser] options available.
class AndroidChromeCustomTabsOptions implements ChromeSafariBrowserOptions, AndroidOptions {
  ///Set to `false` if you don't want the default share button. The default value is `true`.
  bool addShareButton;
  ///Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  bool showTitle;
  ///Set the custom background color of the toolbar.
  String toolbarBackgroundColor;
  ///Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  bool enableUrlBarHiding;
  ///Set to `true` to enable Instant Apps. The default value is `false`.
  bool instantAppsEnabled;

  AndroidChromeCustomTabsOptions({this.addShareButton = true, this.showTitle = true, this.toolbarBackgroundColor = "", this.enableUrlBarHiding = false, this.instantAppsEnabled = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "addShareButton": addShareButton,
      "showTitle": showTitle,
      "toolbarBackgroundColor": toolbarBackgroundColor,
      "enableUrlBarHiding": enableUrlBarHiding,
      "instantAppsEnabled": instantAppsEnabled
    };
  }

  @override
  static AndroidChromeCustomTabsOptions fromMap(Map<String, dynamic> map) {
    AndroidChromeCustomTabsOptions options = new AndroidChromeCustomTabsOptions();
    options.addShareButton = map["addShareButton"];
    options.showTitle = map["showTitle"];
    options.toolbarBackgroundColor = map["toolbarBackgroundColor"];
    options.enableUrlBarHiding = map["enableUrlBarHiding"];
    options.instantAppsEnabled = map["instantAppsEnabled"];
    return options;
  }
}

///This class represents all the iOS-only [ChromeSafariBrowser] options available.
class IosSafariOptions implements ChromeSafariBrowserOptions, IosOptions {
  ///Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  bool entersReaderIfAvailable;
  ///Set to `true` to enable bar collapsing. The default value is `false`.
  bool barCollapsingEnabled;
  ///Set the custom style for the dismiss button. The default value is [IosSafariOptionsDismissButtonStyle.DONE].
  ///
  ///**NOTE**: available on iOS 11.0+.
  IosSafariOptionsDismissButtonStyle dismissButtonStyle;
  ///Set the custom background color of the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  String preferredBarTintColor;
  ///Set the custom color of the control buttons on the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  String preferredControlTintColor;
  ///Set the custom modal presentation style when presenting the WebView. The default value is [IosWebViewOptionsPresentationStyle.FULL_SCREEN].
  IosWebViewOptionsPresentationStyle presentationStyle;
  ///Set to the custom transition style when presenting the WebView. The default value is [IosWebViewOptionsTransitionStyle.COVER_VERTICAL].
  IosWebViewOptionsTransitionStyle transitionStyle;

  IosSafariOptions({this.entersReaderIfAvailable = false, this.barCollapsingEnabled = false, this.dismissButtonStyle = IosSafariOptionsDismissButtonStyle.DONE,
    this.preferredBarTintColor = "", this.preferredControlTintColor = "", this.presentationStyle = IosWebViewOptionsPresentationStyle.FULL_SCREEN,
    this.transitionStyle = IosWebViewOptionsTransitionStyle.COVER_VERTICAL});

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

  @override
  static IosSafariOptions fromMap(Map<String, dynamic> map) {
    IosSafariOptions options = new IosSafariOptions();
    options.entersReaderIfAvailable = map["entersReaderIfAvailable"];
    options.barCollapsingEnabled = map["barCollapsingEnabled"];
    options.dismissButtonStyle = IosSafariOptionsDismissButtonStyle.fromValue(map["dismissButtonStyle"]);
    options.preferredBarTintColor = map["preferredBarTintColor"];
    options.preferredControlTintColor = map["preferredControlTintColor"];
    options.presentationStyle = IosWebViewOptionsPresentationStyle.fromValue(map["presentationStyle"]);
    options.transitionStyle = IosWebViewOptionsTransitionStyle.fromValue(map["transitionStyle"]);
    return options;
  }
}