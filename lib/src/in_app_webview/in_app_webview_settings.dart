import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'android/in_app_webview_settings.dart';
import 'ios/in_app_webview_settings.dart';
import '../content_blocker.dart';
import '../types.dart';
import '../in_app_browser/in_app_browser_options.dart';
import 'webview.dart';

class WebViewOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static WebViewOptions fromMap(Map<String, dynamic> map, {WebViewOptions? instance}) {
    return WebViewOptions();
  }

  static Map<String, dynamic> instanceToMap(WebViewOptions webViewOptions) {
    return webViewOptions.toMap();
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


///This class represents all the WebView settings available.
// ignore: deprecated_member_use_from_same_package
class InAppWebViewSettings extends InAppWebViewOptions implements AndroidInAppWebViewSettings, IOSInAppWebViewSettings {
  @override
  bool accessibilityIgnoresInvertColors;

  @override
  bool allowContentAccess;

  @override
  bool allowFileAccess;

  @override
  bool allowFileAccessFromFileURLs;

  @override
  bool allowUniversalAccessFromFileURLs;

  @override
  Uri? allowingReadAccessTo;

  @override
  bool allowsAirPlayForMediaPlayback;

  @override
  bool allowsBackForwardNavigationGestures;

  @override
  bool allowsInlineMediaPlayback;

  @override
  bool allowsLinkPreview;

  @override
  bool allowsPictureInPictureMediaPlayback;

  @override
  bool alwaysBounceHorizontal;

  @override
  bool alwaysBounceVertical;

  @override
  String? appCachePath;

  @override
  bool applePayAPIEnabled;

  @override
  String applicationNameForUserAgent;

  @override
  bool automaticallyAdjustsScrollIndicatorInsets;

  @override
  bool blockNetworkImage;

  @override
  bool blockNetworkLoads;

  @override
  bool builtInZoomControls;

  @override
  bool cacheEnabled;

  @override
  AndroidCacheMode? cacheMode;

  @override
  bool clearCache;

  @override
  bool clearSessionCache;

  @override
  List<ContentBlocker> contentBlockers;

  @override
  IOSUIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior;

  @override
  String cursiveFontFamily;

  @override
  List<IOSWKDataDetectorTypes> dataDetectorTypes;

  @override
  bool databaseEnabled;

  @override
  IOSUIScrollViewDecelerationRate decelerationRate;

  @override
  int defaultFixedFontSize;

  @override
  int defaultFontSize;

  @override
  String defaultTextEncodingName;

  @override
  bool disableContextMenu;

  @override
  bool disableDefaultErrorPage;

  @override
  bool disableHorizontalScroll;

  @override
  bool disableInputAccessoryView;

  @override
  bool disableLongPressContextMenuOnLinks;

  @override
  bool disableVerticalScroll;

  @override
  AndroidActionModeMenuItem? disabledActionModeMenuItems;

  @override
  bool disallowOverScroll;

  @override
  bool displayZoomControls;

  @override
  bool domStorageEnabled;

  @override
  bool enableViewportScale;

  @override
  String fantasyFontFamily;

  @override
  String fixedFontFamily;

  @override
  AndroidForceDark? forceDark;

  @override
  bool geolocationEnabled;

  @override
  bool hardwareAcceleration;

  @override
  bool horizontalScrollBarEnabled;

  @override
  Color? horizontalScrollbarThumbColor;

  @override
  Color? horizontalScrollbarTrackColor;

  @override
  bool ignoresViewportScaleLimits;

  @override
  bool incognito;

  @override
  int initialScale;

  @override
  bool isDirectionalLockEnabled;

  @override
  bool isFraudulentWebsiteWarningEnabled;

  @override
  bool isPagingEnabled;

  @override
  bool javaScriptCanOpenWindowsAutomatically;

  @override
  bool javaScriptEnabled;

  @override
  AndroidLayoutAlgorithm? layoutAlgorithm;

  @override
  bool limitsNavigationsToAppBoundDomains;

  @override
  bool loadWithOverviewMode;

  @override
  bool loadsImagesAutomatically;

  @override
  double maximumZoomScale;

  @override
  bool mediaPlaybackRequiresUserGesture;

  @override
  String? mediaType;

  @override
  int? minimumFontSize;

  @override
  int minimumLogicalFontSize;

  @override
  double minimumZoomScale;

  @override
  AndroidMixedContentMode? mixedContentMode;

  @override
  bool needInitialFocus;

  @override
  bool? networkAvailable;

  @override
  bool offscreenPreRaster;

  @override
  AndroidOverScrollMode? overScrollMode;

  @override
  double pageZoom;

  @override
  UserPreferredContentMode? preferredContentMode;

  @override
  String? regexToCancelSubFramesLoading;

  @override
  RendererPriorityPolicy? rendererPriorityPolicy;

  @override
  List<String> resourceCustomSchemes;

  @override
  bool safeBrowsingEnabled;

  @override
  String sansSerifFontFamily;

  @override
  bool saveFormData;

  @override
  int? scrollBarDefaultDelayBeforeFade;

  @override
  int? scrollBarFadeDuration;

  @override
  AndroidScrollBarStyle? scrollBarStyle;

  @override
  bool scrollbarFadingEnabled;

  @override
  bool scrollsToTop;

  @override
  IOSWKSelectionGranularity selectionGranularity;

  @override
  String serifFontFamily;

  @override
  bool sharedCookiesEnabled;

  @override
  String standardFontFamily;

  @override
  bool supportMultipleWindows;

  @override
  bool supportZoom;

  @override
  bool suppressesIncrementalRendering;

  @override
  int textZoom;

  @override
  bool thirdPartyCookiesEnabled;

  @override
  bool transparentBackground;

  @override
  bool useHybridComposition;

  @override
  bool useOnDownloadStart;

  @override
  bool useOnLoadResource;

  @override
  bool useOnNavigationResponse;

  @override
  bool useOnRenderProcessGone;

  @override
  bool useShouldInterceptAjaxRequest;

  @override
  bool useShouldInterceptFetchRequest;

  @override
  bool useShouldInterceptRequest;

  @override
  bool useShouldOverrideUrlLoading;

  @override
  bool useWideViewPort;

  @override
  String userAgent;

  @override
  bool verticalScrollBarEnabled;

  @override
  AndroidVerticalScrollbarPosition? verticalScrollbarPosition;

  @override
  Color? verticalScrollbarThumbColor;

  @override
  Color? verticalScrollbarTrackColor;

  InAppWebViewSettings(
      {this.useShouldOverrideUrlLoading = false,
        this.useOnLoadResource = false,
        this.useOnDownloadStart = false,
        this.clearCache = false,
        this.userAgent = "",
        this.applicationNameForUserAgent = "",
        this.javaScriptEnabled = true,
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
        this.supportZoom = true,
        this.allowFileAccessFromFileURLs = false,
        this.allowUniversalAccessFromFileURLs = false,
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
        this.disallowOverScroll = false,
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
            IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER,
        this.isDirectionalLockEnabled = false,
        this.mediaType,
        this.pageZoom = 1.0,
        this.limitsNavigationsToAppBoundDomains = false,
        this.useOnNavigationResponse = false,
        this.applePayAPIEnabled = false,
        this.allowingReadAccessTo,
        this.disableLongPressContextMenuOnLinks = false,
        this.disableInputAccessoryView = false}) {
    if (this.minimumFontSize == null)
      this.minimumFontSize =
      defaultTargetPlatform == TargetPlatform.android ? 8 : 0;
    assert(!this.resourceCustomSchemes.contains("http") &&
        !this.resourceCustomSchemes.contains("https"));
    assert(allowingReadAccessTo == null || allowingReadAccessTo!.isScheme("file"));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    // ignore: deprecated_member_use_from_same_package
    options.addAll(InAppWebViewOptions.instanceToMap(this));
    options.addAll(AndroidInAppWebViewSettings.instanceToMap(this));
    options.addAll(IOSInAppWebViewSettings.instanceToMap(this));
    return options;
  }

  static Map<String, dynamic> instanceToMap(InAppWebViewSettings settings) {
    return settings.toMap();
  }

  static InAppWebViewSettings fromMap(Map<String, dynamic> options, {InAppWebViewSettings? instance}) {
    if (instance == null) {
      instance = InAppWebViewSettings();
    }
    // ignore: deprecated_member_use_from_same_package
    InAppWebViewOptions.fromMap(options, instance: instance);
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidInAppWebViewSettings.fromMap(options, instance: instance);
    }
    else if (defaultTargetPlatform == TargetPlatform.iOS) {
      IOSInAppWebViewSettings.fromMap(options, instance: instance);
    }
    return instance;
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
  InAppWebViewSettings copy() {
    return InAppWebViewSettings.fromMap(this.toMap());
  }
}

///Class that represents the options that can be used for a [WebView].
///Use [InAppWebViewSettings] instead.
@Deprecated('Use InAppWebViewSettings instead')
class InAppWebViewGroupOptions {
  ///Cross-platform options.
  late InAppWebViewOptions crossPlatform;

  ///Android-specific options.
  late AndroidInAppWebViewOptions android;

  ///iOS-specific options.
  late IOSInAppWebViewOptions ios;

  InAppWebViewGroupOptions(
      {InAppWebViewOptions? crossPlatform,
      AndroidInAppWebViewOptions? android,
      IOSInAppWebViewOptions? ios}) {
    this.crossPlatform = crossPlatform ?? InAppWebViewOptions();
    this.android = android ?? AndroidInAppWebViewOptions();
    this.ios = ios ?? IOSInAppWebViewOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    options.addAll(this.crossPlatform.toMap());
    if (defaultTargetPlatform == TargetPlatform.android)
      options.addAll(this.android.toMap());
    else if (defaultTargetPlatform == TargetPlatform.iOS)
      options.addAll(this.ios.toMap());

    return options;
  }

  static InAppWebViewGroupOptions fromMap(Map<String, dynamic> options) {
    InAppWebViewGroupOptions inAppWebViewGroupOptions =
        InAppWebViewGroupOptions();

    inAppWebViewGroupOptions.crossPlatform =
        InAppWebViewOptions.fromMap(options);
    if (defaultTargetPlatform == TargetPlatform.android)
      inAppWebViewGroupOptions.android =
          AndroidInAppWebViewOptions.fromMap(options);
    else if (defaultTargetPlatform == TargetPlatform.iOS)
      inAppWebViewGroupOptions.ios = IOSInAppWebViewOptions.fromMap(options);

    return inAppWebViewGroupOptions;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  InAppWebViewGroupOptions copy() {
    return InAppWebViewGroupOptions.fromMap(this.toMap());
  }
}

///Use [InAppWebViewSettings] instead.
@Deprecated('Use InAppWebViewSettings instead')
class InAppWebViewOptions
    implements WebViewOptions, BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to be able to listen at the [WebView.shouldOverrideUrlLoading] event. The default value is `false`.
  bool useShouldOverrideUrlLoading;

  ///Set to `true` to be able to listen at the [WebView.onLoadResource] event. The default value is `false`.
  bool useOnLoadResource;

  ///Set to `true` to be able to listen at the [WebView.onDownloadStart] event. The default value is `false`.
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

  ///Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  bool javaScriptCanOpenWindowsAutomatically;

  ///Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  ///
  ///**NOTE**: available on iOS 10.0+.
  bool mediaPlaybackRequiresUserGesture;

  ///Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
  int? minimumFontSize;

  ///Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
  bool verticalScrollBarEnabled;

  ///Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
  bool horizontalScrollBarEnabled;

  ///List of custom schemes that the WebView must handle. Use the [WebView.onLoadResourceCustomScheme] event to intercept resource requests with custom scheme.
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
  UserPreferredContentMode? preferredContentMode;

  ///Set to `true` to be able to listen at the [WebView.shouldInterceptAjaxRequest] event. The default value is `false`.
  bool useShouldInterceptAjaxRequest;

  ///Set to `true` to be able to listen at the [WebView.shouldInterceptFetchRequest] event. The default value is `false`.
  bool useShouldInterceptFetchRequest;

  ///Set to `true` to open a browser window with incognito mode. The default value is `false`.
  ///
  ///**NOTE**: available on iOS 9.0+.
  ///On Android, by setting this option to `true`, it will clear all the cookies of all WebView instances,
  ///because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.
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

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
  ///Note that some accesses such as image HTML elements don't follow same-origin rules and aren't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to access arbitrary local files including WebView cookies and app private data.
  ///
  ///Note that the value of this setting is ignored if the value of [allowUniversalAccessFromFileURLs] is `true`.
  ///
  ///The default value is `false`.
  bool allowFileAccessFromFileURLs;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from any origin.
  ///This includes access to content from other file scheme URLs or web contexts.
  ///Note that some access such as image HTML elements doesn't follow same-origin rules and isn't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to launch cross-site scripting attacks,
  ///either accessing arbitrary local files including WebView cookies, app private data or even credentials used on arbitrary web sites.
  ///
  ///The default value is `false`.
  bool allowUniversalAccessFromFileURLs;

  InAppWebViewOptions(
      {this.useShouldOverrideUrlLoading = false,
      this.useOnLoadResource = false,
      this.useOnDownloadStart = false,
      this.clearCache = false,
      this.userAgent = "",
      this.applicationNameForUserAgent = "",
      this.javaScriptEnabled = true,
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
      this.supportZoom = true,
      this.allowFileAccessFromFileURLs = false,
      this.allowUniversalAccessFromFileURLs = false}) {
    if (this.minimumFontSize == null)
      this.minimumFontSize =
          defaultTargetPlatform == TargetPlatform.android ? 8 : 0;
    assert(!this.resourceCustomSchemes.contains("http") &&
        !this.resourceCustomSchemes.contains("https"));
  }

  static Map<String, dynamic> instanceToMap(InAppWebViewOptions options) {
    return options.toMap();
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
      "supportZoom": supportZoom,
      "allowFileAccessFromFileURLs": allowFileAccessFromFileURLs,
      "allowUniversalAccessFromFileURLs": allowUniversalAccessFromFileURLs
    };
  }

  static InAppWebViewOptions fromMap(Map<String, dynamic> map, {InAppWebViewOptions? instance}) {
    List<ContentBlocker> contentBlockers = [];
    List<dynamic>? contentBlockersMapList = map["contentBlockers"];
    if (contentBlockersMapList != null) {
      contentBlockersMapList.forEach((contentBlocker) {
        contentBlockers.add(ContentBlocker.fromMap(
            Map<dynamic, Map<dynamic, dynamic>>.from(
                Map<dynamic, dynamic>.from(contentBlocker))));
      });
    }
    
    if (instance == null) {
      instance = InAppWebViewOptions();
    }

    instance.useShouldOverrideUrlLoading = map["useShouldOverrideUrlLoading"];
    instance.useOnLoadResource = map["useOnLoadResource"];
    instance.useOnDownloadStart = map["useOnDownloadStart"];
    instance.clearCache = map["clearCache"];
    instance.userAgent = map["userAgent"];
    instance.applicationNameForUserAgent = map["applicationNameForUserAgent"];
    instance.javaScriptEnabled = map["javaScriptEnabled"];
    instance.javaScriptCanOpenWindowsAutomatically =
        map["javaScriptCanOpenWindowsAutomatically"];
    instance.mediaPlaybackRequiresUserGesture =
        map["mediaPlaybackRequiresUserGesture"];
    instance.verticalScrollBarEnabled = map["verticalScrollBarEnabled"];
    instance.horizontalScrollBarEnabled = map["horizontalScrollBarEnabled"];
    instance.resourceCustomSchemes =
        List<String>.from(map["resourceCustomSchemes"] ?? []);
    instance.contentBlockers = contentBlockers;
    instance.preferredContentMode =
        UserPreferredContentMode.fromValue(map["preferredContentMode"]);
    instance.useShouldInterceptAjaxRequest =
        map["useShouldInterceptAjaxRequest"];
    instance.useShouldInterceptFetchRequest =
        map["useShouldInterceptFetchRequest"];
    instance.incognito = map["incognito"];
    instance.cacheEnabled = map["cacheEnabled"];
    instance.transparentBackground = map["transparentBackground"];
    instance.disableVerticalScroll = map["disableVerticalScroll"];
    instance.disableHorizontalScroll = map["disableHorizontalScroll"];
    instance.disableContextMenu = map["disableContextMenu"];
    instance.supportZoom = map["supportZoom"];
    instance.allowFileAccessFromFileURLs = map["allowFileAccessFromFileURLs"];
    instance.allowUniversalAccessFromFileURLs =
        map["allowUniversalAccessFromFileURLs"];
    return instance;
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
