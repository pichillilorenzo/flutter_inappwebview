// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings}
///This class represents all the WebView settings available.
///{@endtemplate}
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView
///- iOS WKWebView
///- macOS WKWebView
///- Web \<iframe\>
///- Windows WebView2
class InAppWebViewSettings {
  ///A Boolean value indicating whether the WebView ignores an accessibility request to invert its colors.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIView.accessibilityIgnoresInvertColors](https://developer.apple.com/documentation/uikit/uiview/2865843-accessibilityignoresinvertcolors))
  bool? accessibilityIgnoresInvertColors;

  ///Control whether algorithmic darkening is allowed.
  ///
  ///WebView always sets the media query `prefers-color-scheme` according to the app's theme attribute `isLightTheme`,
  ///i.e. `prefers-color-scheme` is light if `isLightTheme` is `true` or not specified, otherwise it is `dark`.
  ///This means that the web content's light or dark style will be applied automatically to match the app's theme if the content supports it.
  ///
  ///Algorithmic darkening is disallowed by default.
  ///
  ///If the app's theme is dark and it allows algorithmic darkening,
  ///WebView will attempt to darken web content using an algorithm,
  ///if the content doesn't define its own dark styles and doesn't explicitly disable darkening.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - WebSettingsCompat.setAlgorithmicDarkeningAllowed](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAlgorithmicDarkeningAllowed(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.ALGORITHMIC_DARKENING] feature is supported.
  bool? algorithmicDarkeningAllowed;

  ///Set to `true` to allow audio playing when the app goes in background or the screen is locked or another app is opened.
  ///However, there will be no controls in the notification bar or on the lockscreen.
  ///Also, make sure to not call [PlatformInAppWebViewController.pause], otherwise it will stop audio playing.
  ///The default value is `false`.
  ///
  ///**IMPORTANT NOTE**: if you use this setting, your app could be rejected by the Google Play Store.
  ///For example, if you allow background playing of YouTube videos, which is a violation of the YouTube API Terms of Service.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? allowBackgroundAudioPlaying;

  ///Enables or disables content URL access within WebView. Content URL access allows WebView to load content from a content provider installed in the system. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowContentAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowContentAccess(boolean)))
  bool? allowContentAccess;

  ///Enables or disables file access within WebView. Note that this enables or disables file system access only.
  ///Assets and resources are still accessible using `file:///android_asset` and `file:///android_res`. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccess(boolean)))
  bool? allowFileAccess;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from other file scheme URLs.
  ///Note that some accesses such as image HTML elements don't follow same-origin rules and aren't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to access arbitrary local files including WebView cookies and app private data.
  ///
  ///Note that the value of this setting is ignored if the value of [allowUniversalAccessFromFileURLs] is `true`.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccessFromFileURLs(boolean)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? allowFileAccessFromFileURLs;

  ///Sets whether cross-origin requests in the context of a file scheme URL should be allowed to access content from any origin.
  ///This includes access to content from other file scheme URLs or web contexts.
  ///Note that some access such as image HTML elements doesn't follow same-origin rules and isn't affected by this setting.
  ///
  ///Don't enable this setting if you open files that may be created or altered by external sources.
  ///Enabling this setting allows malicious scripts loaded in a `file://` context to launch cross-site scripting attacks,
  ///either accessing arbitrary local files including WebView cookies, app private data or even credentials used on arbitrary web sites.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowUniversalAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowUniversalAccessFromFileURLs(boolean)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? allowUniversalAccessFromFileURLs;

  ///Used in combination with [PlatformWebViewCreationParams.initialUrlRequest] or [PlatformWebViewCreationParams.initialData] (using the `file://` scheme), it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [URLRequest.url] if you are using it with the [PlatformWebViewCreationParams.initialUrlRequest] parameter or
  ///the [InAppWebViewInitialData.baseUrl] if you are using it with the [PlatformWebViewCreationParams.initialData] parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  WebUri? allowingReadAccessTo;

  ///Set to `true` to allow AirPlay. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsAirPlayForMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback))
  ///- macOS WKWebView ([Official API - WKWebViewConfiguration.allowsAirPlayForMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback))
  bool? allowsAirPlayForMediaPlayback;

  ///Set to `true` to allow the horizontal swipe gestures trigger back-forward list navigations.
  ///
  ///**NOTE for Windows**: Swiping down to refresh is off by default and not exposed via API currently,
  ///it requires the "--pull-to-refresh" option to be included in
  ///the additional browser arguments to be configured.
  ///(See [WebViewEnvironmentSettings.additionalBrowserArguments].).
  ///When set to `false`, the end user cannot swipe to navigate or pull to refresh.
  ///This API only affects the overscrolling navigation functionality and has
  ///no effect on the scrolling interaction used to explore the web content shown in WebView2.
  ///Disabling/Enabling [allowsBackForwardNavigationGestures] takes effect after the next navigation.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsBackForwardNavigationGestures](https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu))
  ///- macOS WKWebView ([Official API - WKWebView.allowsBackForwardNavigationGestures](https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu))
  ///- Windows WebView2 1.0.992.28+ ([Official API - ICoreWebView2Settings6.put_IsSwipeNavigationEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings6?view=webview2-1.0.2849.39#put_isswipenavigationenabled))
  bool? allowsBackForwardNavigationGestures;

  ///Set to `true` to allow HTML5 media playback to appear inline within the screen layout, using browser-supplied controls rather than native controls.
  ///For this to work, add the `webkit-playsinline` attribute to any `<video>` elements. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsInlineMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614793-allowsinlinemediaplayback))
  bool? allowsInlineMediaPlayback;

  ///Set to `true` to allow that pressing on a link displays a preview of the destination for the link. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsLinkPreview](https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview))
  ///- macOS WKWebView ([Official API - WKWebView.allowsLinkPreview](https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview))
  bool? allowsLinkPreview;

  ///Set to `true` to allow HTML5 videos play picture-in-picture. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsPictureInPictureMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614792-allowspictureinpicturemediaplayb))
  bool? allowsPictureInPictureMediaPlayback;

  ///The view’s alpha value. The value of this property is a floating-point number
  ///in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents totally opaque.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setAlpha](https://developer.android.com/reference/android/view/View#setAlpha(float)))
  ///- iOS WKWebView ([Official API - UIView.alpha](https://developer.apple.com/documentation/uikit/uiview/1622417-alpha))
  ///- macOS WKWebView ([Official API - NSView.alphaValue](https://developer.apple.com/documentation/appkit/nsview/1483560-alphavalue))
  double? alpha;

  ///A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///horizontal dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceHorizontal](https://developer.apple.com/documentation/uikit/uiscrollview/1619393-alwaysbouncehorizontal))
  bool? alwaysBounceHorizontal;

  ///A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
  ///If this property is set to `true` and [InAppWebViewSettings.disallowOverScroll] is `false`,
  ///vertical dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceVertical](https://developer.apple.com/documentation/uikit/uiscrollview/1619383-alwaysbouncevertical))
  bool? alwaysBounceVertical;

  ///Sets the path to the Application Caches files. In order for the Application Caches API to be enabled, this option must be set a path to which the application can write.
  ///This option is used one time: repeated calls are ignored.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView (Official API - WebSettings.setAppCachePath)
  String? appCachePath;

  ///Set to `true` to enable Apple Pay API for the `WebView` at its first page load or on the next page load (using [PlatformInAppWebViewController.setOptions]). The default value is `false`.
  ///
  ///**IMPORTANT NOTE**: As written in the official [Safari 13 Release Notes](https://developer.apple.com/documentation/safari-release-notes/safari-13-release-notes#Payment-Request-API),
  ///it won't work if any script injection APIs are used (such as [PlatformInAppWebViewController.evaluateJavascript] or [UserScript]).
  ///So, when this attribute is `true`, all the methods, options, and events implemented using JavaScript won't be called or won't do anything and the result will always be `null`.
  ///
  ///Methods affected:
  ///- [PlatformInAppWebViewController.addUserScript]
  ///- [PlatformInAppWebViewController.addUserScripts]
  ///- [PlatformInAppWebViewController.removeUserScript]
  ///- [PlatformInAppWebViewController.removeUserScripts]
  ///- [PlatformInAppWebViewController.removeAllUserScripts]
  ///- [PlatformInAppWebViewController.evaluateJavascript]
  ///- [PlatformInAppWebViewController.callAsyncJavaScript]
  ///- [PlatformInAppWebViewController.injectJavascriptFileFromUrl]
  ///- [PlatformInAppWebViewController.injectJavascriptFileFromAsset]
  ///- [PlatformInAppWebViewController.injectCSSCode]
  ///- [PlatformInAppWebViewController.injectCSSFileFromUrl]
  ///- [PlatformInAppWebViewController.injectCSSFileFromAsset]
  ///- [PlatformInAppWebViewController.findAllAsync]
  ///- [PlatformInAppWebViewController.findNext]
  ///- [PlatformInAppWebViewController.clearMatches]
  ///- [PlatformInAppWebViewController.pauseTimers]
  ///- [PlatformInAppWebViewController.getSelectedText]
  ///- [PlatformInAppWebViewController.getHitTestResult]
  ///- [PlatformInAppWebViewController.requestFocusNodeHref]
  ///- [PlatformInAppWebViewController.requestImageRef]
  ///- [PlatformInAppWebViewController.postWebMessage]
  ///- [PlatformInAppWebViewController.createWebMessageChannel]
  ///- [PlatformInAppWebViewController.addWebMessageListener]
  ///
  ///Also, on MacOS:
  ///- [PlatformInAppWebViewController.getScrollX]
  ///- [PlatformInAppWebViewController.getScrollY]
  ///- [PlatformInAppWebViewController.scrollTo]
  ///- [PlatformInAppWebViewController.scrollBy]
  ///- [PlatformInAppWebViewController.getContentHeight]
  ///- [PlatformInAppWebViewController.getContentWidth]
  ///- [PlatformInAppWebViewController.canScrollVertically]
  ///- [PlatformInAppWebViewController.canScrollHorizontally]
  ///
  ///Settings affected:
  ///- [PlatformWebViewCreationParams.initialUserScripts]
  ///- [InAppWebViewSettings.supportZoom]
  ///- [InAppWebViewSettings.useOnLoadResource]
  ///- [InAppWebViewSettings.useShouldInterceptAjaxRequest]
  ///- [InAppWebViewSettings.useShouldInterceptFetchRequest]
  ///- [InAppWebViewSettings.enableViewportScale]
  ///
  ///Events affected:
  ///- the `hitTestResult` argument of [PlatformWebViewCreationParams.onLongPressHitTestResult] will be empty
  ///- the `hitTestResult` argument of [ContextMenu.onCreateContextMenu] will be empty
  ///- [PlatformWebViewCreationParams.onLoadResource]
  ///- [PlatformWebViewCreationParams.shouldInterceptAjaxRequest]
  ///- [PlatformWebViewCreationParams.onAjaxReadyStateChange]
  ///- [PlatformWebViewCreationParams.onAjaxProgress]
  ///- [PlatformWebViewCreationParams.shouldInterceptFetchRequest]
  ///- [PlatformWebViewCreationParams.onConsoleMessage]
  ///- [PlatformWebViewCreationParams.onPrintRequest]
  ///- [PlatformWebViewCreationParams.onWindowFocus]
  ///- [PlatformWebViewCreationParams.onWindowBlur]
  ///- [PlatformWebViewCreationParams.onFindResultReceived]
  ///- [FindInteractionController.onFindResultReceived]
  ///
  ///Also, on MacOS:
  ///- [PlatformWebViewCreationParams.onScrollChanged]
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+
  ///- macOS WKWebView 10.15+
  bool? applePayAPIEnabled;

  ///Append to the existing user-agent. Setting userAgent will override this.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.applicationNameForUserAgent](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent))
  ///- macOS WKWebView ([Official API - WKWebViewConfiguration.applicationNameForUserAgent](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent))
  String? applicationNameForUserAgent;

  ///Configures whether the scroll indicator insets are automatically adjusted by the system.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - UIScrollView.automaticallyAdjustsScrollIndicatorInsets](https://developer.apple.com/documentation/uikit/uiscrollview/3198043-automaticallyadjustsscrollindica))
  bool? automaticallyAdjustsScrollIndicatorInsets;

  ///Sets whether the WebView should not load image resources from the network (resources accessed via http and https URI schemes). The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkImage](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkImage(boolean)))
  bool? blockNetworkImage;

  ///Sets whether the WebView should not load resources from the network. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkLoads](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkLoads(boolean)))
  bool? blockNetworkLoads;

  ///When this setting is set to `false`, it disables all accelerator keys
  ///that access features specific to a web browser, including but not limited to:
  ///- Ctrl-F and F3 for Find on Page
  ///- Ctrl-P for Print
  ///- Ctrl-R and F5 for Reload
  ///- Ctrl-Plus and Ctrl-Minus for zooming
  ///- Ctrl-Shift-C and F12 for DevTools
  ///Special keys for browser functions, such as Back, Forward, and Search
  ///It does not disable accelerator keys related to movement and text editing, such as:
  ///- Home, End, Page Up, and Page Down
  ///- Ctrl-X, Ctrl-C, Ctrl-V
  ///- Ctrl-A for Select All
  ///- Ctrl-Z for Undo
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.864.35+ ([Official API - ICoreWebView2Settings3.put_IsBuiltInErrorPageEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings3?view=webview2-1.0.2849.39#put_arebrowseracceleratorkeysenabled))
  bool? browserAcceleratorKeysEnabled;

  ///Set to `true` if the WebView should use its built-in zoom mechanisms. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBuiltInZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setBuiltInZoomControls(boolean)))
  bool? builtInZoomControls;

  ///Sets whether WebView should use browser caching. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? cacheEnabled;

  ///Overrides the way the cache is used. The way the cache is used is based on the navigation type. For a normal page load, the cache is checked and content is re-validated as needed.
  ///When navigating back, content is not revalidated, instead the content is just retrieved from the cache. The default value is [CacheMode.LOAD_DEFAULT].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCacheMode](https://developer.android.com/reference/android/webkit/WebSettings#setCacheMode(int)))
  CacheMode? cacheMode;

  ///Use [PlatformInAppWebViewController.clearAllCache] instead.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  @Deprecated('Use InAppWebViewController.clearAllCache instead')
  bool? clearCache;

  ///Use [PlatformCookieManager.removeSessionCookies] instead.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  @Deprecated('Use CookieManager.removeSessionCookies instead')
  bool? clearSessionCache;

  ///List of [ContentBlocker] that are a set of rules used to block content in the browser window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.13+
  List<ContentBlocker>? contentBlockers;

  ///Configures how safe area insets are added to the adjusted content inset.
  ///The default value is [ScrollViewContentInsetAdjustmentBehavior.NEVER].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIScrollView.contentInsetAdjustmentBehavior](https://developer.apple.com/documentation/uikit/uiscrollview/2902261-contentinsetadjustmentbehavior))
  ScrollViewContentInsetAdjustmentBehavior? contentInsetAdjustmentBehavior;

  ///Sets the cursive font family name. The default value is `"cursive"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCursiveFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setCursiveFontFamily(java.lang.String)))
  String? cursiveFontFamily;

  ///Specifying a dataDetectoryTypes value adds interactivity to web content that matches the value.
  ///For example, Safari adds a link to “apple.com” in the text “Visit apple.com” if the dataDetectorTypes property is set to [DataDetectorTypes.LINK].
  ///The default value is [DataDetectorTypes.NONE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 10+ ([Official API - WKWebViewConfiguration.dataDetectorTypes](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1641937-datadetectortypes))
  List<DataDetectorTypes>? dataDetectorTypes;

  ///Set to `true` if you want the database storage API is enabled. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDatabaseEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDatabaseEnabled(boolean)))
  bool? databaseEnabled;

  ///A [ScrollViewDecelerationRate] value that determines the rate of deceleration after the user lifts their finger.
  ///The default value is [ScrollViewDecelerationRate.NORMAL].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.decelerationRate](https://developer.apple.com/documentation/uikit/uiscrollview/1619438-decelerationrate))
  ScrollViewDecelerationRate? decelerationRate;

  ///Sets the default fixed font size. The default value is `16`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFixedFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFixedFontSize(int)))
  int? defaultFixedFontSize;

  ///Sets the default font size. The default value is `16`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFontSize(int)))
  int? defaultFontSize;

  ///Sets the default text encoding name to use when decoding html pages. The default value is `"UTF-8"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultTextEncodingName](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultTextEncodingName(java.lang.String)))
  String? defaultTextEncodingName;

  ///When not playing, video elements are represented by a 'poster' image.
  ///The image to use can be specified by the poster attribute of the video tag in HTML.
  ///If the attribute is absent, then a default poster will be used.
  ///This property allows the WebView to provide that default image.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  Uint8List? defaultVideoPoster;

  ///Set to `true` to disable context menu. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_AreDefaultContextMenusEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_aredefaultcontextmenusenabled))
  bool? disableContextMenu;

  ///Sets whether the default Android WebView’s internal error page should be suppressed or displayed for bad navigations.
  ///`true` means suppressed (not shown), `false` means it will be displayed. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsBuiltInErrorPageEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2849.39#put_isbuiltinerrorpageenabled))
  bool? disableDefaultErrorPage;

  ///Set to `true` to disable horizontal scroll. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Web \<iframe\> but requires same origin
  bool? disableHorizontalScroll;

  ///Set to `true` to disable the [inputAccessoryView](https://developer.apple.com/documentation/uikit/uiresponder/1621119-inputaccessoryview) above system keyboard.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? disableInputAccessoryView;

  ///Set to `true` to disable the context menu (copy, select, etc.) that is shown when the user emits a long press event on a HTML link.
  ///This is implemented using also JavaScript, so it must be enabled or it won't work.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? disableLongPressContextMenuOnLinks;

  ///Set to `true` to disable vertical scroll. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Web \<iframe\> but requires same origin
  bool? disableVerticalScroll;

  ///Disables the action mode menu items according to menuItems flag.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 24+ ([Official API - WebSettings.setDisabledActionModeMenuItems](https://developer.android.com/reference/android/webkit/WebSettings#setDisabledActionModeMenuItems(int)))
  ActionModeMenuItem? disabledActionModeMenuItems;

  ///Set to `true` to disable the bouncing of the WebView when the scrolling has reached an edge of the content. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? disallowOverScroll;

  ///Set to `true` if the WebView should display on-screen zoom controls when using the built-in zoom mechanisms. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDisplayZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDisplayZoomControls(boolean)))
  bool? displayZoomControls;

  ///Set to `true` if you want the DOM storage API is enabled. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDomStorageEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDomStorageEnabled(boolean)))
  bool? domStorageEnabled;

  ///Set to `true` to allow a viewport meta tag to either disable or restrict the range of user scaling. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? enableViewportScale;

  ///Sets whether EnterpriseAuthenticationAppLinkPolicy if set by admin is allowed to have any
  ///effect on WebView.
  ///
  ///EnterpriseAuthenticationAppLinkPolicy in WebView allows admins to specify authentication
  ///urls. When WebView is redirected to authentication url, and an app on the device has
  ///registered as the default handler for the url, that app is launched.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY] feature is supported.
  bool? enterpriseAuthenticationAppLinkPolicyEnabled;

  ///Sets the fantasy font family name. The default value is `"fantasy"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFantasyFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFantasyFontFamily(java.lang.String)))
  String? fantasyFontFamily;

  ///Sets the fixed font family name. The default value is `"monospace"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFixedFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFixedFontFamily(java.lang.String)))
  String? fixedFontFamily;

  ///Use [algorithmicDarkeningAllowed] instead.
  ///
  ///Set the force dark mode for this WebView. The default value is [ForceDark.OFF].
  ///
  ///Deprecated - The "force dark" model previously implemented by WebView was complex and didn't
  ///interoperate well with current Web standards for `prefers-color-scheme` and `color-scheme`.
  ///In apps with `targetSdkVersion` ≥ `android.os.Build.VERSION_CODES.TIRAMISU` this API is a no-op and
  ///WebView will always use the dark style defined by web content authors if the app's theme is dark.
  ///To customize the behavior, refer to [algorithmicDarkeningAllowed].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - WebSettings.setForceDark](https://developer.android.com/reference/android/webkit/WebSettings#setForceDark(int)))
  @Deprecated('Use algorithmicDarkeningAllowed instead')
  ForceDark? forceDark;

  ///Use [algorithmicDarkeningAllowed] instead.
  ///
  ///Set how WebView content should be darkened.
  ///The default value is [ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING].
  ///
  ///Deprecated - The "force dark" model previously implemented by WebView was complex and didn't
  ///interoperate well with current Web standards for `prefers-color-scheme` and `color-scheme`.
  ///In apps with `targetSdkVersion` ≥ `android.os.Build.VERSION_CODES.TIRAMISU` this API is a no-op and
  ///WebView will always use the dark style defined by web content authors if the app's theme is dark.
  ///To customize the behavior, refer to [algorithmicDarkeningAllowed].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setForceDarkStrategy](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setForceDarkStrategy(android.webkit.WebSettings,int))):
  ///    - it will take effect only if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.FORCE_DARK_STRATEGY].
  @Deprecated('Use algorithmicDarkeningAllowed instead')
  ForceDarkStrategy? forceDarkStrategy;

  ///Specifies whether autofill for information like names, street and email addresses, phone numbers, and arbitrary input is enabled.
  ///
  ///This excludes password and credit card information.
  ///When [generalAutofillEnabled] is `false`, no suggestions appear, and no new information is saved.
  ///When [generalAutofillEnabled] is `true`, information is saved, suggestions appear
  ///and clicking on one will populate the form fields.
  ///It will take effect immediately after setting.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.902.49+ ([Official API - ICoreWebView2Settings4.put_IsGeneralAutofillEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings4?view=webview2-1.0.2849.39#put_isgeneralautofillenabled))
  bool? generalAutofillEnabled;

  ///Sets whether Geolocation is enabled. The default is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setGeolocationEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setGeolocationEnabled(boolean))):
  ///    - Please note that in order for the Geolocation API to be usable by a page in the WebView, the following requirements must be met: - an application must have permission to access the device location, see [Manifest.permission.ACCESS_COARSE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_COARSE_LOCATION), [Manifest.permission.ACCESS_FINE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_FINE_LOCATION); - an application must provide an implementation of the [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt] callback to receive notifications that a page is requesting access to location via the JavaScript Geolocation API.
  bool? geolocationEnabled;

  ///A Boolean value that determines whether to listen and handle the
  ///[PlatformWebViewCreationParams.onAcceleratorKeyPressed] event.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  bool? handleAcceleratorKeyPressed;

  ///Boolean value to enable Hardware Acceleration in the WebView.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setLayerType](https://developer.android.com/reference/android/webkit/WebView#setLayerType(int,%20android.graphics.Paint)))
  bool? hardwareAcceleration;

  ///This property is used to customize the PDF toolbar items.
  ///
  ///By default, it is [PdfToolbarItems.NONE] and so it displays all of the items.
  ///Changes to this property apply to all CoreWebView2s in the same environment and using the same profile.
  ///Changes to this setting apply only after the next navigation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1185.39+ ([Official API - ICoreWebView2Settings7.put_HiddenPdfToolbarItems](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings7?view=webview2-1.0.2849.39#put_hiddenpdftoolbaritems))
  PdfToolbarItems? hiddenPdfToolbarItems;

  ///Define whether the horizontal scrollbar should be drawn or not. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setHorizontalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setHorizontalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsHorizontalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619380-showshorizontalscrollindicator))
  ///- Web \<iframe\> but requires same origin:
  ///    - It must have the same value of [verticalScrollBarEnabled] to take effect.
  bool? horizontalScrollBarEnabled;

  ///Sets the horizontal scrollbar thumb color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  Color? horizontalScrollbarThumbColor;

  ///Sets the horizontal scrollbar track color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  Color? horizontalScrollbarTrackColor;

  ///Specifies a feature policy for the `<iframe>`.
  ///The policy defines what features are available to the `<iframe>` based on the origin of the request
  ///(e.g. access to the microphone, camera, battery, web-share API, etc.).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.allow](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-allow))
  String? iframeAllow;

  ///Set to true if the `<iframe>` can activate fullscreen mode by calling the `requestFullscreen()` method.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.allowfullscreen](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-allowfullscreen))
  bool? iframeAllowFullscreen;

  ///A string that reflects the `aria-hidden` HTML attribute, indicating whether the element is exposed to an accessibility API.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.ariaHidden](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden))
  String? iframeAriaHidden;

  ///A Content Security Policy enforced for the embedded resource.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.csp](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-csp))
  String? iframeCsp;

  ///A string that reflects the `name` HTML attribute, containing a name by which to refer to the frame.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.name](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-name))
  String? iframeName;

  ///A string that reflects the `referrerpolicy` HTML attribute indicating which referrer to use when fetching the linked resource.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.referrerpolicy](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-referrerpolicy))
  ReferrerPolicy? iframeReferrerPolicy;

  ///A string that reflects the `role` HTML attribute, containing a WAI-ARIA role for the element.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.role](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles))
  String? iframeRole;

  ///Applies extra restrictions to the content in the frame.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.sandbox](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-sandbox))
  Set<Sandbox>? iframeSandbox;

  ///Set to `true` if you want that the WebView should always allow scaling of the webpage, regardless of the author's intent.
  ///The ignoresViewportScaleLimits property overrides the `user-scalable` HTML property in a webpage. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.ignoresViewportScaleLimits](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/2274633-ignoresviewportscalelimits))
  bool? ignoresViewportScaleLimits;

  ///Set to `true` to open a browser window with incognito mode. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - setting this to `true`, it will clear all the cookies of all WebView instances, because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2ControllerOptions.put_IsInPrivateModeEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controlleroptions?view=webview2-1.0.2792.45#put_isinprivatemodeenabled))
  bool? incognito;

  ///Sets the initial scale for this WebView. 0 means default. The behavior for the default scale depends on the state of [useWideViewPort] and [loadWithOverviewMode].
  ///If the content fits into the WebView control by width, then the zoom is set to 100%. For wide content, the behavior depends on the state of [loadWithOverviewMode].
  ///If its value is true, the content will be zoomed out to be fit by width into the WebView control, otherwise not.
  ///If initial scale is greater than 0, WebView starts with this value as initial scale.
  ///Please note that unlike the scale properties in the viewport meta tag, this method doesn't take the screen density into account.
  ///The default is `0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setInitialScale](https://developer.android.com/reference/android/webkit/WebView#setInitialScale(int)))
  int? initialScale;

  ///Set to `false` to be able to listen to also sync `XMLHttpRequest`s at the
  ///[PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event.
  ///
  ///**NOTE**: Using `false` will cause the `XMLHttpRequest.send()` method for sync
  ///requests to not wait on the JavaScript code the response synchronously,
  ///as if it was an async `XMLHttpRequest`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? interceptOnlyAsyncAjaxRequests;

  ///A Boolean value that determines whether scrolling is disabled in a particular direction.
  ///If this property is `false`, scrolling is permitted in both horizontal and vertical directions.
  ///If this property is `true` and the user begins dragging in one general direction (horizontally or vertically),
  ///the scroll view disables scrolling in the other direction.
  ///If the drag direction is diagonal, then scrolling will not be locked and the user can drag in any direction until the drag completes.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isDirectionalLockEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619390-isdirectionallockenabled))
  bool? isDirectionalLockEnabled;

  ///Sets whether fullscreen API is enabled or not.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isElementFullscreenEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled))
  ///- macOS WKWebView 12.3+ ([Official API - WKPreferences.isElementFullscreenEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled))
  bool? isElementFullscreenEnabled;

  ///Sets whether the web view's built-in find interaction native UI is enabled or not.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.0+ ([Official API - WKWebView.isFindInteractionEnabled](https://developer.apple.com/documentation/webkit/wkwebview/4002044-isfindinteractionenabled/))
  bool? isFindInteractionEnabled;

  ///A Boolean value indicating whether warnings should be shown for suspected fraudulent content such as phishing or malware.
  ///According to the official documentation, this feature is currently available in the following region: China.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - WKPreferences.isFraudulentWebsiteWarningEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable))
  ///- macOS WKWebView 10.15+ ([Official API - WKPreferences.isFraudulentWebsiteWarningEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable))
  bool? isFraudulentWebsiteWarningEnabled;

  ///Controls whether this WebView is inspectable in Web Inspector.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.isInspectable](https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable))
  ///- macOS WKWebView 13.3+ ([Official API - WKWebView.isInspectable](https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable))
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_AreDevToolsEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_aredevtoolsenabled))
  bool? isInspectable;

  ///A Boolean value that determines whether paging is enabled for the scroll view.
  ///If the value of this property is true, the scroll view stops on multiples of the scroll view’s bounds when the user scrolls.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isPagingEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619432-ispagingenabled))
  bool? isPagingEnabled;

  ///A Boolean value indicating whether WebKit will apply built-in workarounds (quirks)
  ///to improve compatibility with certain known websites. You can disable site-specific quirks
  ///to help test your website without these workarounds. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isSiteSpecificQuirksModeEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled))
  ///- macOS WKWebView 12.3+ ([Official API - WKPreferences.isSiteSpecificQuirksModeEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled))
  bool? isSiteSpecificQuirksModeEnabled;

  ///A Boolean value indicating whether text interaction is enabled or not.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKPreferences.isTextInteractionEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled))
  ///- macOS WKWebView 11.3+ ([Official API - WKPreferences.isTextInteractionEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled))
  bool? isTextInteractionEnabled;

  ///A Boolean value that determines whether user events are ignored and removed from the event queue.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIView.isUserInteractionEnabled](https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled))
  bool? isUserInteractionEnabled;

  ///Set to `false` to disable the JavaScript Bridge completely.
  ///This will affect also all the internal plugin [UserScript]s
  ///that are using the JavaScript Bridge to work.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Web \<iframe\> but requires same origin
  bool? javaScriptBridgeEnabled;

  ///Set to `true` to allow the JavaScript Bridge only on the main frame.
  ///If [pluginScriptsForMainFrameOnly] is present, then this value will override
  ///it only for the JavaScript Bridge internal plugin.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  bool? javaScriptBridgeForMainFrameOnly;

  ///A [Set] of patterns that will be used to match the allowed origins where
  ///the JavaScript Bridge could be used.
  ///If [pluginScriptsOriginAllowList] is present, then this value will override
  ///it only for the JavaScript Bridge internal plugin.
  ///Adding `'*'` as an allowed origin or setting this to `null`, it means it will allow every origin.
  ///Instead, an empty [Set] will block every origin and, in this case,
  ///it will force the behaviour of the [javaScriptBridgeEnabled] parameter,
  ///as it was set to `false`.
  ///
  ///**NOTE**: setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///**NOTE for Android**: each origin pattern MUST follow the table rule of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**NOTE for iOS, macOS, Windows**: each origin pattern will be used as a
  ///Regular Expression Pattern that will be used on JavaScript side using [RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).
  ///
  ///The default value is `null` and will allow every origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Web \<iframe\> but requires same origin
  Set<String>? javaScriptBridgeOriginAllowList;

  ///Set to `true` to allow JavaScript open windows without user interaction. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptCanOpenWindowsAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptCanOpenWindowsAutomatically(boolean)))
  ///- iOS WKWebView ([Official API - WKPreferences.javaScriptCanOpenWindowsAutomatically](https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/))
  ///- macOS WKWebView ([Official API - WKPreferences.javaScriptCanOpenWindowsAutomatically](https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/))
  ///- Web \<iframe\> but requires same origin
  bool? javaScriptCanOpenWindowsAutomatically;

  ///Set to `true` to enable JavaScript. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptEnabled(boolean)))
  ///- iOS WKWebView ([Official API - WKWebpagePreferences.allowsContentJavaScript](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/))
  ///- macOS WKWebView ([Official API - WKWebpagePreferences.allowsContentJavaScript](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/))
  ///- Web \<iframe\>
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsScriptEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_isscriptenabled))
  bool? javaScriptEnabled;

  ///Set to `true` to allow to execute the JavaScript Handlers only on the main frame.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  bool? javaScriptHandlersForMainFrameOnly;

  ///A [Set] of Regular Expression Patterns that will be used on native side to match the allowed origins
  ///that are able to execute the JavaScript Handlers defined for the current WebView.
  ///This will affect also the internal JavaScript Handlers used by the plugin itself.
  ///
  ///An empty [Set] will block every origin.
  ///
  ///The default value is `null` and will allow every origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Web \<iframe\> but requires same origin
  Set<String>? javaScriptHandlersOriginAllowList;

  ///Sets the underlying layout algorithm. This will cause a re-layout of the WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLayoutAlgorithm](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLayoutAlgorithm(android.webkit.WebSettings.LayoutAlgorithm)))
  LayoutAlgorithm? layoutAlgorithm;

  ///A Boolean value that indicates whether the web view limits navigation to pages within the app’s domain.
  ///Check [App-Bound Domains](https://webkit.org/blog/10882/app-bound-domains/) for more details.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebViewConfiguration.limitsNavigationsToAppBoundDomains](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebViewConfiguration.limitsNavigationsToAppBoundDomains](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai))
  bool? limitsNavigationsToAppBoundDomains;

  ///Sets whether the WebView loads pages in overview mode, that is, zooms out the content to fit on screen by width.
  ///This setting is taken into account when the content width is greater than the width of the WebView control, for example, when [useWideViewPort] is enabled.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadWithOverviewMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadWithOverviewMode(boolean)))
  bool? loadWithOverviewMode;

  ///Sets whether the WebView should load image resources. Note that this method controls loading of all images, including those embedded using the data URI scheme.
  ///Note that if the value of this setting is changed from false to true, all images resources referenced by content currently displayed by the WebView are loaded automatically.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadsImagesAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadsImagesAutomatically(boolean)))
  bool? loadsImagesAutomatically;

  ///Set maximum viewport inset to the largest inset a webpage may experience in your app's maximally expanded UI configuration.
  ///Values must be either zero or positive. It must be larger than [minimumViewportInset].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  EdgeInsets? maximumViewportInset;

  ///A floating-point value that specifies the maximum scale factor that can be applied to the scroll view's content.
  ///This value determines how large the content can be scaled.
  ///It must be greater than the minimum zoom scale for zooming to be enabled.
  ///The default value is `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.maximumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619408-maximumzoomscale))
  double? maximumZoomScale;

  ///Set to `true` to prevent HTML5 audio or video from autoplaying. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMediaPlaybackRequiresUserGesture](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMediaPlaybackRequiresUserGesture(boolean)))
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor))
  ///- macOS WKWebView 10.12+ ([Official API - WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor))
  bool? mediaPlaybackRequiresUserGesture;

  ///The media type for the contents of the web view.
  ///When the value of this property is `null`, the web view derives the current media type from the CSS media property of its content.
  ///If you assign a value other than `null` to this property, the web view uses the value you provide instead.
  ///The default value of this property is `null`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.mediaType](https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebView.mediaType](https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype))
  String? mediaType;

  ///Sets the minimum font size. The default value is `8` for Android, `0` for iOS.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumFontSize(int)))
  ///- iOS WKWebView ([Official API - WKPreferences.minimumFontSize](https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/))
  ///- macOS WKWebView ([Official API - WKPreferences.minimumFontSize](https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/))
  int? minimumFontSize;

  ///Sets the minimum logical font size. The default is `8`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumLogicalFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumLogicalFontSize(int)))
  int? minimumLogicalFontSize;

  ///Set minimum viewport inset to the smallest inset a webpage may experience in your app's maximally collapsed UI configuration.
  ///Values must be either zero or positive. It must be smaller than [maximumViewportInset].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  EdgeInsets? minimumViewportInset;

  ///A floating-point value that specifies the minimum scale factor that can be applied to the scroll view's content.
  ///This value determines how small the content can be scaled.
  ///The default value is `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.minimumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619428-minimumzoomscale))
  double? minimumZoomScale;

  ///Configures the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebSettings.setMixedContentMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMixedContentMode(int)))
  MixedContentMode? mixedContentMode;

  ///Tells the WebView whether it needs to set a node. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setNeedInitialFocus](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setNeedInitialFocus(boolean)))
  bool? needInitialFocus;

  ///Informs WebView of the network state.
  ///This is used to set the JavaScript property `window.navigator.isOnline` and generates the online/offline event as specified in HTML5, sec. 5.7.7.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setNetworkAvailable](https://developer.android.com/reference/android/webkit/WebView#setNetworkAvailable(boolean)))
  bool? networkAvailable;

  ///Enables web pages to use the `app-region` CSS style.
  ///
  ///Disabling/Enabling the [nonClientRegionSupportEnabled] takes effect after the next navigation.
  ///
  ///When this property is `true`, then all the non-client region features will be enabled:
  ///Draggable Regions will be enabled, they are regions on a webpage that are marked with the CSS attribute `app-region: drag/no-drag`.
  ///When set to drag, these regions will be treated like the window's title bar,
  ///supporting dragging of the entire WebView and its host app window;
  ///the system menu shows upon right click, and a double click will trigger maximizing/restoration of the window size.
  ///
  ///When set to `false`, all non-client region support will be disabled.
  ///The `app-region` CSS style will be ignored on web pages.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2420.47+ ([Official API - ICoreWebView2Settings9.put_IsNonClientRegionSupportEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings9?view=webview2-1.0.2849.39#put_isnonclientregionsupportenabled))
  bool? nonClientRegionSupportEnabled;

  ///Sets whether this WebView should raster tiles when it is offscreen but attached to a window.
  ///Turning this on can avoid rendering artifacts when animating an offscreen WebView on-screen.
  ///Offscreen WebViews in this mode use more memory. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+ ([Official API - WebSettings.setOffscreenPreRaster](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setOffscreenPreRaster(boolean)))
  bool? offscreenPreRaster;

  ///Sets the WebView's over-scroll mode.
  ///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
  ///The default value is [OverScrollMode.IF_CONTENT_SCROLLS].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setOverScrollMode](https://developer.android.com/reference/android/view/View#setOverScrollMode(int)))
  OverScrollMode? overScrollMode;

  ///The scale factor by which the web view scales content relative to its bounds.
  ///The default value of this property is `1.0`, which displays the content without any scaling.
  ///Changing the value of this property is equivalent to setting the CSS `zoom` property on all page content.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.pageZoom](https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebView.pageZoom](https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom))
  double? pageZoom;

  ///Specifies whether autosave for password information is enabled.
  ///
  ///The [passwordAutosaveEnabled] property behaves independently of the IsGeneralAutofillEnabled property.
  ///When [passwordAutosaveEnabled] is `false`, no new password data is saved and no Save/Update Password prompts are displayed.
  ///However, if there was password data already saved before disabling this setting, then that password
  ///information is auto-populated, suggestions are shown and clicking on one will populate the fields.
  ///When [passwordAutosaveEnabled] is `true`, password information is auto-populated,
  ///suggestions are shown and clicking on one will populate the fields,
  ///new data is saved, and a Save/Update Password prompt is displayed.
  ///It will take effect immediately after setting.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.902.49+ ([Official API - ICoreWebView2Settings4.put_IsPasswordAutosaveEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings4?view=webview2-1.0.2849.39#put_ispasswordautosaveenabled))
  bool? passwordAutosaveEnabled;

  ///Pinch-zoom, referred to as "Page Scale" zoom, is performed as a post-rendering step,
  ///it changes the page scale factor property and scales the surface the web page
  ///is rendered onto when user performs a pinch zooming action.
  ///
  ///It does not change the layout but rather changes the viewport and clips the
  ///web content, the content outside of the viewport isn't visible onscreen and users can't reach this content using mouse.
  ///
  ///The [pinchZoomEnabled] property enables or disables the ability of the end user
  ///to use a pinching motion on touch input enabled devices to scale the web content in the WebView2.
  ///When set to `false`, the end user cannot pinch zoom after the next navigation.
  ///Disabling/Enabling [pinchZoomEnabled] only affects the end user's ability to
  ///use pinch motions and does not change the page scale factor.
  ///This API only affects the Page Scale zoom and has no effect on the existing
  ///browser zoom properties or other end user mechanisms for zooming.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.902.49+ ([Official API - ICoreWebView2Settings5.put_IsPinchZoomEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings5?view=webview2-1.0.2849.39#put_ispinchzoomenabled))
  bool? pinchZoomEnabled;

  ///Set to `true` to allow internal plugin [UserScript]s only on the main frame.
  ///
  ///**NOTE**: If [javaScriptBridgeForMainFrameOnly] is not present, this value will affect also the JavaScript Bridge internal plugin.
  ///Also, setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  bool? pluginScriptsForMainFrameOnly;

  ///A [Set] of patterns that will be used to match the allowed origins
  ///that are able to load all the internal plugin [UserScript]s used by the plugin itself.
  ///Adding `'*'` as an allowed origin or setting this to `null`, it means it will allow every origin.
  ///Instead, an empty [Set] will block every origin.
  ///
  ///**NOTE**: If [javaScriptBridgeOriginAllowList] is not present, this value will affect also the JavaScript Bridge internal plugin.
  ///Also, setting or changing this value after the WebView has been created won't have any effect.
  ///It should be set when initializing the WebView through [PlatformWebViewCreationParams.initialSettings] parameter.
  ///
  ///**NOTE for Android**: each origin pattern MUST follow the table rule of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**NOTE for iOS, macOS, Windows**: each origin pattern will be used as a
  ///Regular Expression Pattern that will be used on JavaScript side using [RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).
  ///
  ///The default value is `null` and will allow every origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  Set<String>? pluginScriptsOriginAllowList;

  ///Sets the content mode that the WebView needs to use when loading and rendering a webpage. The default value is [UserPreferredContentMode.RECOMMENDED].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 13.0+ ([Official API - WKWebpagePreferences.preferredContentMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/))
  ///- macOS WKWebView 10.15+ ([Official API - WKWebpagePreferences.preferredContentMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/))
  UserPreferredContentMode? preferredContentMode;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to allow navigation requests synchronously.
  ///If the url request match the regular expression, then the request is allowed automatically,
  ///and the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event will not be fired.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String? regexToAllowSyncUrlLoading;

  ///Regular expression used on native side by the [PlatformWebViewCreationParams.shouldOverrideUrlLoading]
  ///event to cancel navigation requests for frames that are not the main frame.
  ///If the url request of a sub-frame matches the regular expression, then the request of that sub-frame is canceled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String? regexToCancelSubFramesLoading;

  ///Sets the renderer priority policy for this WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setRendererPriorityPolicy](https://developer.android.com/reference/android/webkit/WebView#setRendererPriorityPolicy(int,%20boolean)))
  RendererPriorityPolicy? rendererPriorityPolicy;

  ///[reputationCheckingRequired] is used to control whether SmartScreen enabled or not.
  ///
  ///SmartScreen helps webviews identify reported phishing and malware websites and also helps users make informed decisions about downloads.
  ///SmartScreen is enabled or disabled for all CoreWebView2s using the same user data folder.
  ///If [reputationCheckingRequired] is true for any CoreWebView2 using the same user data folder, then SmartScreen is enabled.
  ///If [reputationCheckingRequired] is false for all CoreWebView2 using the same user data folder, then SmartScreen is disabled.
  ///When it is changed, the change will be applied to all WebViews using the same user data folder on the next navigation or download.
  ///If the newly created CoreWebview2 does not set SmartScreen to `false`,
  ///when navigating(Such as Navigate(), LoadDataUrl(), ExecuteScript(), etc.), the default value will be applied to all CoreWebview2 using the same user data folder.
  ///SmartScreen of WebView2 apps can be controlled by Windows system setting "SmartScreen for Microsoft Edge", specially,
  ///for WebView2 in Windows Store apps, SmartScreen is controlled by another Windows system setting "SmartScreen for Microsoft Store apps".
  ///When the Windows setting is enabled, the SmartScreen operates under the control of the [reputationCheckingRequired].
  ///When the Windows setting is disabled, the SmartScreen will be disabled regardless of the [reputationCheckingRequired] value set in WebView2 apps.
  ///In other words, under this circumstance the value of [reputationCheckingRequired] will be saved but overridden by system setting.
  ///Upon re-enabling the Windows setting, the CoreWebview2 will reference the [reputationCheckingRequired] to determine the SmartScreen status.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1722.45+ ([Official API - ICoreWebView2Settings8.put_IsReputationCheckingRequired](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings8?view=webview2-1.0.2849.39#put_isreputationcheckingrequired))
  bool? reputationCheckingRequired;

  ///Set an allow-list of origins to receive the X-Requested-With HTTP header from the WebView owning the passed [InAppWebViewSettings].
  ///
  ///Historically, this header was sent on all requests from WebView, containing the app package name of the embedding app. Depending on the version of installed WebView, this may no longer be the case, as the header was deprecated in late 2022, and its use discontinued.
  ///
  ///Apps can use this method to restore the legacy behavior for servers that still rely on the deprecated header, but it should not be used to identify the webview to first-party servers under the control of the app developer.
  ///
  ///The format of the strings in the allow-list follows the origin rules of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setRequestedWithHeaderOriginAllowList](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setRequestedWithHeaderOriginAllowList(android.webkit.WebSettings,java.util.Set%3Cjava.lang.String%3E))):
  ///    - available on Android only if [WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST] feature is supported.
  Set<String>? requestedWithHeaderOriginAllowList;

  ///List of custom schemes that the WebView must handle. Use the [PlatformWebViewCreationParams.onLoadResourceWithCustomScheme] event to intercept resource requests with custom scheme.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.13+
  List<String>? resourceCustomSchemes;

  ///Sets whether Safe Browsing is enabled. Safe Browsing allows WebView to protect against malware and phishing attacks by verifying the links.
  ///Safe Browsing is enabled by default for devices which support it.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 26+ ([Official API - WebSettings.setSafeBrowsingEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSafeBrowsingEnabled(boolean)))
  bool? safeBrowsingEnabled;

  ///Sets the sans-serif font family name. The default value is `"sans-serif"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSansSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSansSerifFontFamily(java.lang.String)))
  String? sansSerifFontFamily;

  ///Sets whether the WebView should save form data. In Android O, the platform has implemented a fully functional Autofill feature to store form data.
  ///Therefore, the Webview form data save feature is disabled. Note that the feature will continue to be supported on older versions of Android as before.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSaveFormData](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSaveFormData(boolean)))
  @Deprecated('')
  bool? saveFormData;

  ///Defines the delay in milliseconds that a scrollbar waits before fade out.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarDefaultDelayBeforeFade](https://developer.android.com/reference/android/view/View#setScrollBarDefaultDelayBeforeFade(int)))
  int? scrollBarDefaultDelayBeforeFade;

  ///Defines the scrollbar fade duration in milliseconds.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarFadeDuration](https://developer.android.com/reference/android/view/View#setScrollBarFadeDuration(int)))
  int? scrollBarFadeDuration;

  ///Specifies the style of the scrollbars. The scrollbars can be overlaid or inset.
  ///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
  ///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
  ///you can use SCROLLBARS_INSIDE_OVERLAY or SCROLLBARS_INSIDE_INSET. If you want them to appear at the edge of the view, ignoring the padding,
  ///then you can use SCROLLBARS_OUTSIDE_OVERLAY or SCROLLBARS_OUTSIDE_INSET.
  ///The default value is [ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setScrollBarStyle](https://developer.android.com/reference/android/webkit/WebView#setScrollBarStyle(int)))
  ScrollBarStyle? scrollBarStyle;

  ///The multiplier applied to the scroll amount for the WebView.
  ///
  ///This value determines how much the content will scroll in response to user input.
  ///A higher value means faster scrolling, while a lower value means slower scrolling.
  ///
  ///The default value is `1`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  int? scrollMultiplier;

  ///Defines whether scrollbars will fade when the view is not scrolling.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollbarFadingEnabled](https://developer.android.com/reference/android/view/View#setScrollbarFadingEnabled(boolean)))
  bool? scrollbarFadingEnabled;

  ///A Boolean value that controls whether the scroll-to-top gesture is enabled.
  ///The scroll-to-top gesture is a tap on the status bar. When a user makes this gesture,
  ///the system asks the scroll view closest to the status bar to scroll to the top.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.scrollsToTop](https://developer.apple.com/documentation/uikit/uiscrollview/1619421-scrollstotop))
  bool? scrollsToTop;

  ///The level of granularity with which the user can interactively select content in the web view.
  ///The default value is [SelectionGranularity.DYNAMIC].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.selectionGranularity](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614756-selectiongranularity))
  SelectionGranularity? selectionGranularity;

  ///Sets the serif font family name. The default value is `"sans-serif"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSerifFontFamily(java.lang.String)))
  String? serifFontFamily;

  ///Set `true` if shared cookies from `HTTPCookieStorage.shared` should used for every load request in the WebView.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.13+
  bool? sharedCookiesEnabled;

  ///A Boolean value that indicates whether to include any background color or graphics when printing content.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.shouldPrintBackgrounds](https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds))
  ///- macOS WKWebView 13.3+ ([Official API - WKWebView.shouldPrintBackgrounds](https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds))
  bool? shouldPrintBackgrounds;

  ///Sets the standard font family name. The default value is `"sans-serif"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setStandardFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setStandardFontFamily(java.lang.String)))
  String? standardFontFamily;

  ///Specifies whether the status bar is displayed.
  ///
  ///The status bar is usually displayed in the lower left of the WebView and
  ///shows things such as the URI of a link when the user hovers over it and other information.
  ///The status bar UI can be altered by web content and should not be considered secure.
  ///
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsStatusBarEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2849.39#put_isstatusbarenabled))
  bool? statusBarEnabled;

  ///Sets whether the WebView supports multiple windows.
  ///If set to `true`, [PlatformWebViewCreationParams.onCreateWindow] event must be implemented by the host application. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportMultipleWindows](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportMultipleWindows(boolean)))
  bool? supportMultipleWindows;

  ///Set to `false` if the WebView should not support zooming using its on-screen zoom controls and gestures. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportZoom(boolean)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsZoomControlEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_iszoomcontrolenabled))
  bool? supportZoom;

  ///Set to `true` if you want the WebView suppresses content rendering until it is fully loaded into memory. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.suppressesIncrementalRendering](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering))
  ///- macOS WKWebView ([Official API - WKWebViewConfiguration.suppressesIncrementalRendering](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering))
  bool? suppressesIncrementalRendering;

  ///Sets the text zoom of the page in percent. The default value is `100`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setTextZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setTextZoom(int)))
  int? textZoom;

  ///Boolean value to enable third party cookies in the WebView.
  ///Used on Android Lollipop and above only as third party cookies are enabled by default on Android Kitkat and below and on iOS.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - CookieManager.setAcceptThirdPartyCookies](https://developer.android.com/reference/android/webkit/CookieManager#setAcceptThirdPartyCookies(android.webkit.WebView,%20boolean)))
  bool? thirdPartyCookiesEnabled;

  ///Set to `true` to make the background of the WebView transparent. If your app has a dark theme, this can prevent a white flash on initialization. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView 12.0+
  ///- Windows WebView2 1.0.774.44+ ([Official API - ICoreWebView2Controller2.put_DefaultBackgroundColor](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller2?view=webview2-1.0.2210.55#put_defaultbackgroundcolor))
  bool? transparentBackground;

  ///The color the web view displays behind the active page, visible when the user scrolls beyond the bounds of the page.
  ///
  ///The web view derives the default value of this property from the content of the page,
  ///using the background colors of the `<html>` and `<body>` elements with the background color of the web view.
  ///To override the default color, set this property to a new color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.underPageBackgroundColor](https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.underPageBackgroundColor](https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor))
  Color? underPageBackgroundColor;

  ///A Boolean value indicating whether HTTP requests to servers known to support HTTPS should be automatically upgraded to HTTPS requests.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebViewConfiguration.upgradeKnownHostsToHTTPS](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps))
  ///- macOS WKWebView 11.3+ ([Official API - WKWebViewConfiguration.upgradeKnownHostsToHTTPS](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps))
  bool? upgradeKnownHostsToHTTPS;

  ///Set to `false` to disable Flutter Hybrid Composition. The default value is `true`.
  ///Hybrid Composition is supported starting with Flutter v1.20+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - It is recommended to use Hybrid Composition only on Android 10+ for a release app, as it can cause framerate drops on animations in Android 9 and lower (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).
  bool? useHybridComposition;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onAjaxProgress] event.
  ///Also, [useShouldInterceptAjaxRequest] must be set to `true` to take effect.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.onAjaxProgress] event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.onAjaxProgress] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? useOnAjaxProgress;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onAjaxReadyStateChange] event.
  ///Also, [useShouldInterceptAjaxRequest] must be set to `true` to take effect.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.onAjaxReadyStateChange] event implementation,
  ///using it could cause some issues, so, be careful when using it.
  ///In this case, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.onAjaxReadyStateChange] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? useOnAjaxReadyStateChange;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onDownloadStartRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.onDownloadStartRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? useOnDownloadStart;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onLoadResource] event.
  ///
  ///If the [PlatformWebViewCreationParams.onLoadResource] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? useOnLoadResource;

  ///Set to `true` to be able to listen to the [PlatformWebViewCreationParams.onNavigationResponse] event.
  ///
  ///If the [PlatformWebViewCreationParams.onNavigationResponse] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? useOnNavigationResponse;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onRenderProcessGone] event.
  ///
  ///If the [PlatformWebViewCreationParams.onRenderProcessGone] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? useOnRenderProcessGone;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.onShowFileChooser] event.
  ///
  ///If the [PlatformWebViewCreationParams.onShowFileChooser] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? useOnShowFileChooser;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event.
  ///
  ///Due to the async nature of [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event implementation,
  ///it will intercept only async `XMLHttpRequest`s ([AjaxRequest.isAsync] with `true`).
  ///To be able to intercept sync `XMLHttpRequest`s, use [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] to `false`.
  ///If necessary, you should implement your own logic using for example an [UserScript] overriding the
  ///[XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) JavaScript object.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptAjaxRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? useShouldInterceptAjaxRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptFetchRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  bool? useShouldInterceptFetchRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldInterceptRequest] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldInterceptRequest] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? useShouldInterceptRequest;

  ///Set to `true` to be able to listen at the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
  ///
  ///If the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event is implemented and this value is `null`,
  ///it will be automatically inferred as `true`, otherwise, the default value is `false`.
  ///This logic will not be applied for [PlatformInAppBrowser], where you must set the value manually.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  bool? useShouldOverrideUrlLoading;

  ///Set to `true` if the WebView should enable support for the "viewport" HTML meta tag or should use a wide viewport.
  ///When the value of the setting is false, the layout width is always set to the width of the WebView control in device-independent (CSS) pixels.
  ///When the value is true and the page contains the viewport meta tag, the value of the width specified in the tag is used.
  ///If the page does not contain the tag or does not provide a width, then a wide viewport will be used. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUseWideViewPort](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUseWideViewPort(boolean)))
  bool? useWideViewPort;

  ///Sets the user-agent for the WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUserAgentString](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUserAgentString(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKWebView.customUserAgent](https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent))
  ///- macOS WKWebView ([Official API - WKWebView.customUserAgent](https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent))
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings2.put_UserAgent](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings2?view=webview2-1.0.2210.55#put_useragent))
  String? userAgent;

  ///Define whether the vertical scrollbar should be drawn or not. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setVerticalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsVerticalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619405-showsverticalscrollindicator/))
  ///- Web \<iframe\> but requires same origin:
  ///    - It must have the same value of [horizontalScrollBarEnabled] to take effect.
  bool? verticalScrollBarEnabled;

  ///Sets the position of the vertical scroll bar.
  ///The default value is [VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollbarPosition](https://developer.android.com/reference/android/view/View#setVerticalScrollbarPosition(int)))
  VerticalScrollbarPosition? verticalScrollbarPosition;

  ///Sets the vertical scrollbar thumb color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  Color? verticalScrollbarThumbColor;

  ///Sets the vertical scrollbar track color.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  Color? verticalScrollbarTrackColor;

  ///Use a [WebViewAssetLoader] instance to load local files including application's static assets and resources using http(s):// URLs.
  ///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  WebViewAssetLoader? webViewAssetLoader;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  InAppWebViewSettings(
      {this.useShouldOverrideUrlLoading,
      this.useOnLoadResource,
      this.useOnDownloadStart,
      @Deprecated("Use InAppWebViewController.clearAllCache instead")
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
      this.useShouldInterceptAjaxRequest,
      this.useOnAjaxReadyStateChange,
      this.useOnAjaxProgress,
      this.interceptOnlyAsyncAjaxRequests = true,
      this.useShouldInterceptFetchRequest,
      this.incognito = false,
      this.cacheEnabled = true,
      this.transparentBackground = false,
      this.disableVerticalScroll = false,
      this.disableHorizontalScroll = false,
      this.disableContextMenu = false,
      this.supportZoom = true,
      this.allowFileAccessFromFileURLs = false,
      this.allowUniversalAccessFromFileURLs = false,
      this.textZoom,
      @Deprecated("Use CookieManager.removeSessionCookies instead")
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
      this.cacheMode = CacheMode.LOAD_DEFAULT,
      this.cursiveFontFamily = "cursive",
      this.defaultFixedFontSize = 16,
      this.defaultFontSize = 16,
      this.defaultTextEncodingName = "UTF-8",
      this.disabledActionModeMenuItems,
      this.fantasyFontFamily = "fantasy",
      this.fixedFontFamily = "monospace",
      @Deprecated("Use algorithmicDarkeningAllowed instead") this.forceDark,
      @Deprecated("Use algorithmicDarkeningAllowed instead")
      this.forceDarkStrategy,
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
      @Deprecated('') this.saveFormData = true,
      this.thirdPartyCookiesEnabled = true,
      this.hardwareAcceleration = true,
      this.initialScale = 0,
      this.supportMultipleWindows = false,
      this.regexToCancelSubFramesLoading,
      this.regexToAllowSyncUrlLoading,
      this.useHybridComposition = true,
      this.useShouldInterceptRequest,
      this.useOnRenderProcessGone,
      this.overScrollMode = OverScrollMode.IF_CONTENT_SCROLLS,
      this.networkAvailable,
      this.scrollBarStyle = ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
      this.verticalScrollbarPosition =
          VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
      this.scrollBarDefaultDelayBeforeFade,
      this.scrollbarFadingEnabled = true,
      this.scrollBarFadeDuration,
      this.rendererPriorityPolicy,
      this.disableDefaultErrorPage = false,
      this.verticalScrollbarThumbColor,
      this.verticalScrollbarTrackColor,
      this.horizontalScrollbarThumbColor,
      this.horizontalScrollbarTrackColor,
      this.algorithmicDarkeningAllowed = false,
      this.enterpriseAuthenticationAppLinkPolicyEnabled = true,
      this.defaultVideoPoster,
      this.requestedWithHeaderOriginAllowList,
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
      this.selectionGranularity = SelectionGranularity.DYNAMIC,
      this.dataDetectorTypes = const [DataDetectorTypes.NONE],
      this.sharedCookiesEnabled = false,
      this.automaticallyAdjustsScrollIndicatorInsets = false,
      this.accessibilityIgnoresInvertColors = false,
      this.decelerationRate = ScrollViewDecelerationRate.NORMAL,
      this.alwaysBounceVertical = false,
      this.alwaysBounceHorizontal = false,
      this.scrollsToTop = true,
      this.isPagingEnabled = false,
      this.maximumZoomScale = 1.0,
      this.minimumZoomScale = 1.0,
      this.contentInsetAdjustmentBehavior =
          ScrollViewContentInsetAdjustmentBehavior.NEVER,
      this.isDirectionalLockEnabled = false,
      this.mediaType,
      this.pageZoom = 1.0,
      this.limitsNavigationsToAppBoundDomains = false,
      this.useOnNavigationResponse,
      this.applePayAPIEnabled = false,
      this.allowingReadAccessTo,
      this.disableLongPressContextMenuOnLinks = false,
      this.disableInputAccessoryView = false,
      this.underPageBackgroundColor,
      this.isTextInteractionEnabled = true,
      this.isSiteSpecificQuirksModeEnabled = true,
      this.upgradeKnownHostsToHTTPS = true,
      this.isElementFullscreenEnabled = true,
      this.isFindInteractionEnabled = false,
      this.minimumViewportInset,
      this.maximumViewportInset,
      this.isInspectable = false,
      this.shouldPrintBackgrounds = false,
      this.allowBackgroundAudioPlaying = false,
      this.webViewAssetLoader,
      this.javaScriptHandlersOriginAllowList,
      this.javaScriptHandlersForMainFrameOnly,
      this.javaScriptBridgeEnabled = true,
      this.javaScriptBridgeOriginAllowList,
      this.javaScriptBridgeForMainFrameOnly,
      this.pluginScriptsOriginAllowList,
      this.pluginScriptsForMainFrameOnly = false,
      this.scrollMultiplier = 1,
      this.statusBarEnabled = true,
      this.browserAcceleratorKeysEnabled = true,
      this.generalAutofillEnabled = true,
      this.passwordAutosaveEnabled = false,
      this.pinchZoomEnabled = true,
      this.hiddenPdfToolbarItems = PdfToolbarItems.NONE,
      this.reputationCheckingRequired = true,
      this.nonClientRegionSupportEnabled = false,
      this.isUserInteractionEnabled = true,
      this.handleAcceleratorKeyPressed = false,
      this.alpha,
      this.useOnShowFileChooser,
      this.iframeAllow,
      this.iframeAllowFullscreen,
      this.iframeSandbox,
      this.iframeReferrerPolicy,
      this.iframeName,
      this.iframeCsp,
      this.iframeRole,
      this.iframeAriaHidden}) {
    if (this.minimumFontSize == null)
      this.minimumFontSize = Util.isAndroid ? 8 : 0;
    assert(this.resourceCustomSchemes == null ||
        (this.resourceCustomSchemes != null &&
            !this.resourceCustomSchemes!.contains("http") &&
            !this.resourceCustomSchemes!.contains("https")));
    assert(
        allowingReadAccessTo == null || allowingReadAccessTo!.isScheme("file"));
    assert(
        (minimumViewportInset == null && maximumViewportInset == null) ||
            minimumViewportInset != null &&
                maximumViewportInset != null &&
                minimumViewportInset!.isNonNegative &&
                maximumViewportInset!.isNonNegative &&
                minimumViewportInset!.vertical <=
                    maximumViewportInset!.vertical &&
                minimumViewportInset!.horizontal <=
                    maximumViewportInset!.horizontal,
        "minimumViewportInset cannot be larger than maximumViewportInset");
  }

  ///Gets a possible [InAppWebViewSettings] instance from a [Map] value.
  static InAppWebViewSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = InAppWebViewSettings(
      allowingReadAccessTo: map['allowingReadAccessTo'] != null
          ? WebUri(map['allowingReadAccessTo'])
          : null,
      alpha: map['alpha'],
      appCachePath: map['appCachePath'],
      defaultVideoPoster: map['defaultVideoPoster'] != null
          ? Uint8List.fromList(map['defaultVideoPoster'].cast<int>())
          : null,
      disabledActionModeMenuItems: switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => ActionModeMenuItem.fromNativeValue(
            map['disabledActionModeMenuItems']),
        EnumMethod.value =>
          ActionModeMenuItem.fromValue(map['disabledActionModeMenuItems']),
        EnumMethod.name =>
          ActionModeMenuItem.byName(map['disabledActionModeMenuItems'])
      },
      forceDark: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => ForceDark.fromNativeValue(map['forceDark']),
        EnumMethod.value => ForceDark.fromValue(map['forceDark']),
        EnumMethod.name => ForceDark.byName(map['forceDark'])
      },
      forceDarkStrategy: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          ForceDarkStrategy.fromNativeValue(map['forceDarkStrategy']),
        EnumMethod.value =>
          ForceDarkStrategy.fromValue(map['forceDarkStrategy']),
        EnumMethod.name => ForceDarkStrategy.byName(map['forceDarkStrategy'])
      },
      horizontalScrollbarThumbColor:
          map['horizontalScrollbarThumbColor'] != null
              ? UtilColor.fromStringRepresentation(
                  map['horizontalScrollbarThumbColor'])
              : null,
      horizontalScrollbarTrackColor:
          map['horizontalScrollbarTrackColor'] != null
              ? UtilColor.fromStringRepresentation(
                  map['horizontalScrollbarTrackColor'])
              : null,
      iframeAllow: map['iframeAllow'],
      iframeAllowFullscreen: map['iframeAllowFullscreen'],
      iframeAriaHidden: map['iframeAriaHidden'],
      iframeCsp: map['iframeCsp'],
      iframeName: map['iframeName'],
      iframeReferrerPolicy: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          ReferrerPolicy.fromNativeValue(map['iframeReferrerPolicy']),
        EnumMethod.value =>
          ReferrerPolicy.fromValue(map['iframeReferrerPolicy']),
        EnumMethod.name => ReferrerPolicy.byName(map['iframeReferrerPolicy'])
      },
      iframeRole: map['iframeRole'],
      iframeSandbox: map['iframeSandbox'] != null
          ? Set<Sandbox>.from(map['iframeSandbox']
              .map((e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                    EnumMethod.nativeValue => Sandbox.fromNativeValue(e),
                    EnumMethod.value => Sandbox.fromValue(e),
                    EnumMethod.name => Sandbox.byName(e)
                  }!))
          : null,
      javaScriptBridgeForMainFrameOnly: map['javaScriptBridgeForMainFrameOnly'],
      javaScriptBridgeOriginAllowList:
          map['javaScriptBridgeOriginAllowList'] != null
              ? Set<String>.from(
                  map['javaScriptBridgeOriginAllowList']!.cast<String>())
              : null,
      javaScriptHandlersForMainFrameOnly:
          map['javaScriptHandlersForMainFrameOnly'],
      javaScriptHandlersOriginAllowList:
          map['javaScriptHandlersOriginAllowList'] != null
              ? Set<String>.from(
                  map['javaScriptHandlersOriginAllowList']!.cast<String>())
              : null,
      layoutAlgorithm: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          LayoutAlgorithm.fromNativeValue(map['layoutAlgorithm']),
        EnumMethod.value => LayoutAlgorithm.fromValue(map['layoutAlgorithm']),
        EnumMethod.name => LayoutAlgorithm.byName(map['layoutAlgorithm'])
      },
      maximumViewportInset: MapEdgeInsets.fromMap(
          map['maximumViewportInset']?.cast<String, dynamic>()),
      mediaType: map['mediaType'],
      minimumFontSize: map['minimumFontSize'],
      minimumViewportInset: MapEdgeInsets.fromMap(
          map['minimumViewportInset']?.cast<String, dynamic>()),
      mixedContentMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          MixedContentMode.fromNativeValue(map['mixedContentMode']),
        EnumMethod.value => MixedContentMode.fromValue(map['mixedContentMode']),
        EnumMethod.name => MixedContentMode.byName(map['mixedContentMode'])
      },
      networkAvailable: map['networkAvailable'],
      pluginScriptsOriginAllowList: map['pluginScriptsOriginAllowList'] != null
          ? Set<String>.from(
              map['pluginScriptsOriginAllowList']!.cast<String>())
          : null,
      regexToAllowSyncUrlLoading: map['regexToAllowSyncUrlLoading'],
      regexToCancelSubFramesLoading: map['regexToCancelSubFramesLoading'],
      rendererPriorityPolicy: RendererPriorityPolicy.fromMap(
          map['rendererPriorityPolicy']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      requestedWithHeaderOriginAllowList:
          map['requestedWithHeaderOriginAllowList'] != null
              ? Set<String>.from(
                  map['requestedWithHeaderOriginAllowList']!.cast<String>())
              : null,
      scrollBarDefaultDelayBeforeFade: map['scrollBarDefaultDelayBeforeFade'],
      scrollBarFadeDuration: map['scrollBarFadeDuration'],
      textZoom: map['textZoom'],
      underPageBackgroundColor: map['underPageBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['underPageBackgroundColor'])
          : null,
      useOnAjaxProgress: map['useOnAjaxProgress'],
      useOnAjaxReadyStateChange: map['useOnAjaxReadyStateChange'],
      useOnDownloadStart: map['useOnDownloadStart'],
      useOnLoadResource: map['useOnLoadResource'],
      useOnNavigationResponse: map['useOnNavigationResponse'],
      useOnRenderProcessGone: map['useOnRenderProcessGone'],
      useOnShowFileChooser: map['useOnShowFileChooser'],
      useShouldInterceptAjaxRequest: map['useShouldInterceptAjaxRequest'],
      useShouldInterceptFetchRequest: map['useShouldInterceptFetchRequest'],
      useShouldInterceptRequest: map['useShouldInterceptRequest'],
      useShouldOverrideUrlLoading: map['useShouldOverrideUrlLoading'],
      verticalScrollbarThumbColor: map['verticalScrollbarThumbColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['verticalScrollbarThumbColor'])
          : null,
      verticalScrollbarTrackColor: map['verticalScrollbarTrackColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['verticalScrollbarTrackColor'])
          : null,
      webViewAssetLoader: WebViewAssetLoader.fromMap(
          map['webViewAssetLoader']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
    );
    instance.accessibilityIgnoresInvertColors =
        map['accessibilityIgnoresInvertColors'];
    instance.algorithmicDarkeningAllowed = map['algorithmicDarkeningAllowed'];
    instance.allowBackgroundAudioPlaying = map['allowBackgroundAudioPlaying'];
    instance.allowContentAccess = map['allowContentAccess'];
    instance.allowFileAccess = map['allowFileAccess'];
    instance.allowFileAccessFromFileURLs = map['allowFileAccessFromFileURLs'];
    instance.allowUniversalAccessFromFileURLs =
        map['allowUniversalAccessFromFileURLs'];
    instance.allowsAirPlayForMediaPlayback =
        map['allowsAirPlayForMediaPlayback'];
    instance.allowsBackForwardNavigationGestures =
        map['allowsBackForwardNavigationGestures'];
    instance.allowsInlineMediaPlayback = map['allowsInlineMediaPlayback'];
    instance.allowsLinkPreview = map['allowsLinkPreview'];
    instance.allowsPictureInPictureMediaPlayback =
        map['allowsPictureInPictureMediaPlayback'];
    instance.alwaysBounceHorizontal = map['alwaysBounceHorizontal'];
    instance.alwaysBounceVertical = map['alwaysBounceVertical'];
    instance.applePayAPIEnabled = map['applePayAPIEnabled'];
    instance.applicationNameForUserAgent = map['applicationNameForUserAgent'];
    instance.automaticallyAdjustsScrollIndicatorInsets =
        map['automaticallyAdjustsScrollIndicatorInsets'];
    instance.blockNetworkImage = map['blockNetworkImage'];
    instance.blockNetworkLoads = map['blockNetworkLoads'];
    instance.browserAcceleratorKeysEnabled =
        map['browserAcceleratorKeysEnabled'];
    instance.builtInZoomControls = map['builtInZoomControls'];
    instance.cacheEnabled = map['cacheEnabled'];
    instance.cacheMode = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => CacheMode.fromNativeValue(map['cacheMode']),
      EnumMethod.value => CacheMode.fromValue(map['cacheMode']),
      EnumMethod.name => CacheMode.byName(map['cacheMode'])
    };
    instance.clearCache = map['clearCache'];
    instance.clearSessionCache = map['clearSessionCache'];
    instance.contentBlockers = _deserializeContentBlockers(
        map['contentBlockers'],
        enumMethod: enumMethod);
    instance.contentInsetAdjustmentBehavior =
        switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ScrollViewContentInsetAdjustmentBehavior.fromNativeValue(
            map['contentInsetAdjustmentBehavior']),
      EnumMethod.value => ScrollViewContentInsetAdjustmentBehavior.fromValue(
          map['contentInsetAdjustmentBehavior']),
      EnumMethod.name => ScrollViewContentInsetAdjustmentBehavior.byName(
          map['contentInsetAdjustmentBehavior'])
    };
    instance.cursiveFontFamily = map['cursiveFontFamily'];
    instance.dataDetectorTypes = map['dataDetectorTypes'] != null
        ? List<DataDetectorTypes>.from(map['dataDetectorTypes']
            .map((e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                  EnumMethod.nativeValue =>
                    DataDetectorTypes.fromNativeValue(e),
                  EnumMethod.value => DataDetectorTypes.fromValue(e),
                  EnumMethod.name => DataDetectorTypes.byName(e)
                }!))
        : null;
    instance.databaseEnabled = map['databaseEnabled'];
    instance.decelerationRate = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ScrollViewDecelerationRate.fromNativeValue(map['decelerationRate']),
      EnumMethod.value =>
        ScrollViewDecelerationRate.fromValue(map['decelerationRate']),
      EnumMethod.name =>
        ScrollViewDecelerationRate.byName(map['decelerationRate'])
    };
    instance.defaultFixedFontSize = map['defaultFixedFontSize'];
    instance.defaultFontSize = map['defaultFontSize'];
    instance.defaultTextEncodingName = map['defaultTextEncodingName'];
    instance.disableContextMenu = map['disableContextMenu'];
    instance.disableDefaultErrorPage = map['disableDefaultErrorPage'];
    instance.disableHorizontalScroll = map['disableHorizontalScroll'];
    instance.disableInputAccessoryView = map['disableInputAccessoryView'];
    instance.disableLongPressContextMenuOnLinks =
        map['disableLongPressContextMenuOnLinks'];
    instance.disableVerticalScroll = map['disableVerticalScroll'];
    instance.disallowOverScroll = map['disallowOverScroll'];
    instance.displayZoomControls = map['displayZoomControls'];
    instance.domStorageEnabled = map['domStorageEnabled'];
    instance.enableViewportScale = map['enableViewportScale'];
    instance.enterpriseAuthenticationAppLinkPolicyEnabled =
        map['enterpriseAuthenticationAppLinkPolicyEnabled'];
    instance.fantasyFontFamily = map['fantasyFontFamily'];
    instance.fixedFontFamily = map['fixedFontFamily'];
    instance.generalAutofillEnabled = map['generalAutofillEnabled'];
    instance.geolocationEnabled = map['geolocationEnabled'];
    instance.handleAcceleratorKeyPressed = map['handleAcceleratorKeyPressed'];
    instance.hardwareAcceleration = map['hardwareAcceleration'];
    instance.hiddenPdfToolbarItems =
        switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        PdfToolbarItems.fromNativeValue(map['hiddenPdfToolbarItems']),
      EnumMethod.value =>
        PdfToolbarItems.fromValue(map['hiddenPdfToolbarItems']),
      EnumMethod.name => PdfToolbarItems.byName(map['hiddenPdfToolbarItems'])
    };
    instance.horizontalScrollBarEnabled = map['horizontalScrollBarEnabled'];
    instance.ignoresViewportScaleLimits = map['ignoresViewportScaleLimits'];
    instance.incognito = map['incognito'];
    instance.initialScale = map['initialScale'];
    instance.interceptOnlyAsyncAjaxRequests =
        map['interceptOnlyAsyncAjaxRequests'];
    instance.isDirectionalLockEnabled = map['isDirectionalLockEnabled'];
    instance.isElementFullscreenEnabled = map['isElementFullscreenEnabled'];
    instance.isFindInteractionEnabled = map['isFindInteractionEnabled'];
    instance.isFraudulentWebsiteWarningEnabled =
        map['isFraudulentWebsiteWarningEnabled'];
    instance.isInspectable = map['isInspectable'];
    instance.isPagingEnabled = map['isPagingEnabled'];
    instance.isSiteSpecificQuirksModeEnabled =
        map['isSiteSpecificQuirksModeEnabled'];
    instance.isTextInteractionEnabled = map['isTextInteractionEnabled'];
    instance.isUserInteractionEnabled = map['isUserInteractionEnabled'];
    instance.javaScriptBridgeEnabled = map['javaScriptBridgeEnabled'];
    instance.javaScriptCanOpenWindowsAutomatically =
        map['javaScriptCanOpenWindowsAutomatically'];
    instance.javaScriptEnabled = map['javaScriptEnabled'];
    instance.limitsNavigationsToAppBoundDomains =
        map['limitsNavigationsToAppBoundDomains'];
    instance.loadWithOverviewMode = map['loadWithOverviewMode'];
    instance.loadsImagesAutomatically = map['loadsImagesAutomatically'];
    instance.maximumZoomScale = map['maximumZoomScale'];
    instance.mediaPlaybackRequiresUserGesture =
        map['mediaPlaybackRequiresUserGesture'];
    instance.minimumLogicalFontSize = map['minimumLogicalFontSize'];
    instance.minimumZoomScale = map['minimumZoomScale'];
    instance.needInitialFocus = map['needInitialFocus'];
    instance.nonClientRegionSupportEnabled =
        map['nonClientRegionSupportEnabled'];
    instance.offscreenPreRaster = map['offscreenPreRaster'];
    instance.overScrollMode = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        OverScrollMode.fromNativeValue(map['overScrollMode']),
      EnumMethod.value => OverScrollMode.fromValue(map['overScrollMode']),
      EnumMethod.name => OverScrollMode.byName(map['overScrollMode'])
    };
    instance.pageZoom = map['pageZoom'];
    instance.passwordAutosaveEnabled = map['passwordAutosaveEnabled'];
    instance.pinchZoomEnabled = map['pinchZoomEnabled'];
    instance.pluginScriptsForMainFrameOnly =
        map['pluginScriptsForMainFrameOnly'];
    instance.preferredContentMode =
        switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        UserPreferredContentMode.fromNativeValue(map['preferredContentMode']),
      EnumMethod.value =>
        UserPreferredContentMode.fromValue(map['preferredContentMode']),
      EnumMethod.name =>
        UserPreferredContentMode.byName(map['preferredContentMode'])
    };
    instance.reputationCheckingRequired = map['reputationCheckingRequired'];
    instance.resourceCustomSchemes = map['resourceCustomSchemes'] != null
        ? List<String>.from(map['resourceCustomSchemes']!.cast<String>())
        : null;
    instance.safeBrowsingEnabled = map['safeBrowsingEnabled'];
    instance.sansSerifFontFamily = map['sansSerifFontFamily'];
    instance.saveFormData = map['saveFormData'];
    instance.scrollBarStyle = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ScrollBarStyle.fromNativeValue(map['scrollBarStyle']),
      EnumMethod.value => ScrollBarStyle.fromValue(map['scrollBarStyle']),
      EnumMethod.name => ScrollBarStyle.byName(map['scrollBarStyle'])
    };
    instance.scrollMultiplier = map['scrollMultiplier'];
    instance.scrollbarFadingEnabled = map['scrollbarFadingEnabled'];
    instance.scrollsToTop = map['scrollsToTop'];
    instance.selectionGranularity =
        switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        SelectionGranularity.fromNativeValue(map['selectionGranularity']),
      EnumMethod.value =>
        SelectionGranularity.fromValue(map['selectionGranularity']),
      EnumMethod.name =>
        SelectionGranularity.byName(map['selectionGranularity'])
    };
    instance.serifFontFamily = map['serifFontFamily'];
    instance.sharedCookiesEnabled = map['sharedCookiesEnabled'];
    instance.shouldPrintBackgrounds = map['shouldPrintBackgrounds'];
    instance.standardFontFamily = map['standardFontFamily'];
    instance.statusBarEnabled = map['statusBarEnabled'];
    instance.supportMultipleWindows = map['supportMultipleWindows'];
    instance.supportZoom = map['supportZoom'];
    instance.suppressesIncrementalRendering =
        map['suppressesIncrementalRendering'];
    instance.thirdPartyCookiesEnabled = map['thirdPartyCookiesEnabled'];
    instance.transparentBackground = map['transparentBackground'];
    instance.upgradeKnownHostsToHTTPS = map['upgradeKnownHostsToHTTPS'];
    instance.useHybridComposition = map['useHybridComposition'];
    instance.useWideViewPort = map['useWideViewPort'];
    instance.userAgent = map['userAgent'];
    instance.verticalScrollBarEnabled = map['verticalScrollBarEnabled'];
    instance.verticalScrollbarPosition =
        switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => VerticalScrollbarPosition.fromNativeValue(
          map['verticalScrollbarPosition']),
      EnumMethod.value =>
        VerticalScrollbarPosition.fromValue(map['verticalScrollbarPosition']),
      EnumMethod.name =>
        VerticalScrollbarPosition.byName(map['verticalScrollbarPosition'])
    };
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(InAppWebViewSettingsProperty property,
          {TargetPlatform? platform}) =>
      _InAppWebViewSettingsPropertySupported.isPropertySupported(property,
          platform: platform);

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "accessibilityIgnoresInvertColors": accessibilityIgnoresInvertColors,
      "algorithmicDarkeningAllowed": algorithmicDarkeningAllowed,
      "allowBackgroundAudioPlaying": allowBackgroundAudioPlaying,
      "allowContentAccess": allowContentAccess,
      "allowFileAccess": allowFileAccess,
      "allowFileAccessFromFileURLs": allowFileAccessFromFileURLs,
      "allowUniversalAccessFromFileURLs": allowUniversalAccessFromFileURLs,
      "allowingReadAccessTo": allowingReadAccessTo?.toString(),
      "allowsAirPlayForMediaPlayback": allowsAirPlayForMediaPlayback,
      "allowsBackForwardNavigationGestures":
          allowsBackForwardNavigationGestures,
      "allowsInlineMediaPlayback": allowsInlineMediaPlayback,
      "allowsLinkPreview": allowsLinkPreview,
      "allowsPictureInPictureMediaPlayback":
          allowsPictureInPictureMediaPlayback,
      "alpha": alpha,
      "alwaysBounceHorizontal": alwaysBounceHorizontal,
      "alwaysBounceVertical": alwaysBounceVertical,
      "appCachePath": appCachePath,
      "applePayAPIEnabled": applePayAPIEnabled,
      "applicationNameForUserAgent": applicationNameForUserAgent,
      "automaticallyAdjustsScrollIndicatorInsets":
          automaticallyAdjustsScrollIndicatorInsets,
      "blockNetworkImage": blockNetworkImage,
      "blockNetworkLoads": blockNetworkLoads,
      "browserAcceleratorKeysEnabled": browserAcceleratorKeysEnabled,
      "builtInZoomControls": builtInZoomControls,
      "cacheEnabled": cacheEnabled,
      "cacheMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => cacheMode?.toNativeValue(),
        EnumMethod.value => cacheMode?.toValue(),
        EnumMethod.name => cacheMode?.name()
      },
      "clearCache": clearCache,
      "clearSessionCache": clearSessionCache,
      "contentBlockers":
          contentBlockers?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "contentInsetAdjustmentBehavior": switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          contentInsetAdjustmentBehavior?.toNativeValue(),
        EnumMethod.value => contentInsetAdjustmentBehavior?.toValue(),
        EnumMethod.name => contentInsetAdjustmentBehavior?.name()
      },
      "cursiveFontFamily": cursiveFontFamily,
      "dataDetectorTypes": dataDetectorTypes
          ?.map((e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                EnumMethod.nativeValue => e.toNativeValue(),
                EnumMethod.value => e.toValue(),
                EnumMethod.name => e.name()
              })
          .toList(),
      "databaseEnabled": databaseEnabled,
      "decelerationRate": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => decelerationRate?.toNativeValue(),
        EnumMethod.value => decelerationRate?.toValue(),
        EnumMethod.name => decelerationRate?.name()
      },
      "defaultFixedFontSize": defaultFixedFontSize,
      "defaultFontSize": defaultFontSize,
      "defaultTextEncodingName": defaultTextEncodingName,
      "defaultVideoPoster": defaultVideoPoster,
      "disableContextMenu": disableContextMenu,
      "disableDefaultErrorPage": disableDefaultErrorPage,
      "disableHorizontalScroll": disableHorizontalScroll,
      "disableInputAccessoryView": disableInputAccessoryView,
      "disableLongPressContextMenuOnLinks": disableLongPressContextMenuOnLinks,
      "disableVerticalScroll": disableVerticalScroll,
      "disabledActionModeMenuItems": switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => disabledActionModeMenuItems?.toNativeValue(),
        EnumMethod.value => disabledActionModeMenuItems?.toValue(),
        EnumMethod.name => disabledActionModeMenuItems?.name()
      },
      "disallowOverScroll": disallowOverScroll,
      "displayZoomControls": displayZoomControls,
      "domStorageEnabled": domStorageEnabled,
      "enableViewportScale": enableViewportScale,
      "enterpriseAuthenticationAppLinkPolicyEnabled":
          enterpriseAuthenticationAppLinkPolicyEnabled,
      "fantasyFontFamily": fantasyFontFamily,
      "fixedFontFamily": fixedFontFamily,
      "forceDark": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => forceDark?.toNativeValue(),
        EnumMethod.value => forceDark?.toValue(),
        EnumMethod.name => forceDark?.name()
      },
      "forceDarkStrategy": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => forceDarkStrategy?.toNativeValue(),
        EnumMethod.value => forceDarkStrategy?.toValue(),
        EnumMethod.name => forceDarkStrategy?.name()
      },
      "generalAutofillEnabled": generalAutofillEnabled,
      "geolocationEnabled": geolocationEnabled,
      "handleAcceleratorKeyPressed": handleAcceleratorKeyPressed,
      "hardwareAcceleration": hardwareAcceleration,
      "hiddenPdfToolbarItems": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => hiddenPdfToolbarItems?.toNativeValue(),
        EnumMethod.value => hiddenPdfToolbarItems?.toValue(),
        EnumMethod.name => hiddenPdfToolbarItems?.name()
      },
      "horizontalScrollBarEnabled": horizontalScrollBarEnabled,
      "horizontalScrollbarThumbColor": horizontalScrollbarThumbColor?.toHex(),
      "horizontalScrollbarTrackColor": horizontalScrollbarTrackColor?.toHex(),
      "iframeAllow": iframeAllow,
      "iframeAllowFullscreen": iframeAllowFullscreen,
      "iframeAriaHidden": iframeAriaHidden,
      "iframeCsp": iframeCsp,
      "iframeName": iframeName,
      "iframeReferrerPolicy": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => iframeReferrerPolicy?.toNativeValue(),
        EnumMethod.value => iframeReferrerPolicy?.toValue(),
        EnumMethod.name => iframeReferrerPolicy?.name()
      },
      "iframeRole": iframeRole,
      "iframeSandbox": iframeSandbox
          ?.map((e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                EnumMethod.nativeValue => e.toNativeValue(),
                EnumMethod.value => e.toValue(),
                EnumMethod.name => e.name()
              })
          .toList(),
      "ignoresViewportScaleLimits": ignoresViewportScaleLimits,
      "incognito": incognito,
      "initialScale": initialScale,
      "interceptOnlyAsyncAjaxRequests": interceptOnlyAsyncAjaxRequests,
      "isDirectionalLockEnabled": isDirectionalLockEnabled,
      "isElementFullscreenEnabled": isElementFullscreenEnabled,
      "isFindInteractionEnabled": isFindInteractionEnabled,
      "isFraudulentWebsiteWarningEnabled": isFraudulentWebsiteWarningEnabled,
      "isInspectable": isInspectable,
      "isPagingEnabled": isPagingEnabled,
      "isSiteSpecificQuirksModeEnabled": isSiteSpecificQuirksModeEnabled,
      "isTextInteractionEnabled": isTextInteractionEnabled,
      "isUserInteractionEnabled": isUserInteractionEnabled,
      "javaScriptBridgeEnabled": javaScriptBridgeEnabled,
      "javaScriptBridgeForMainFrameOnly": javaScriptBridgeForMainFrameOnly,
      "javaScriptBridgeOriginAllowList":
          javaScriptBridgeOriginAllowList?.toList(),
      "javaScriptCanOpenWindowsAutomatically":
          javaScriptCanOpenWindowsAutomatically,
      "javaScriptEnabled": javaScriptEnabled,
      "javaScriptHandlersForMainFrameOnly": javaScriptHandlersForMainFrameOnly,
      "javaScriptHandlersOriginAllowList":
          javaScriptHandlersOriginAllowList?.toList(),
      "layoutAlgorithm": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => layoutAlgorithm?.toNativeValue(),
        EnumMethod.value => layoutAlgorithm?.toValue(),
        EnumMethod.name => layoutAlgorithm?.name()
      },
      "limitsNavigationsToAppBoundDomains": limitsNavigationsToAppBoundDomains,
      "loadWithOverviewMode": loadWithOverviewMode,
      "loadsImagesAutomatically": loadsImagesAutomatically,
      "maximumViewportInset": maximumViewportInset?.toMap(),
      "maximumZoomScale": maximumZoomScale,
      "mediaPlaybackRequiresUserGesture": mediaPlaybackRequiresUserGesture,
      "mediaType": mediaType,
      "minimumFontSize": minimumFontSize,
      "minimumLogicalFontSize": minimumLogicalFontSize,
      "minimumViewportInset": minimumViewportInset?.toMap(),
      "minimumZoomScale": minimumZoomScale,
      "mixedContentMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => mixedContentMode?.toNativeValue(),
        EnumMethod.value => mixedContentMode?.toValue(),
        EnumMethod.name => mixedContentMode?.name()
      },
      "needInitialFocus": needInitialFocus,
      "networkAvailable": networkAvailable,
      "nonClientRegionSupportEnabled": nonClientRegionSupportEnabled,
      "offscreenPreRaster": offscreenPreRaster,
      "overScrollMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => overScrollMode?.toNativeValue(),
        EnumMethod.value => overScrollMode?.toValue(),
        EnumMethod.name => overScrollMode?.name()
      },
      "pageZoom": pageZoom,
      "passwordAutosaveEnabled": passwordAutosaveEnabled,
      "pinchZoomEnabled": pinchZoomEnabled,
      "pluginScriptsForMainFrameOnly": pluginScriptsForMainFrameOnly,
      "pluginScriptsOriginAllowList": pluginScriptsOriginAllowList?.toList(),
      "preferredContentMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => preferredContentMode?.toNativeValue(),
        EnumMethod.value => preferredContentMode?.toValue(),
        EnumMethod.name => preferredContentMode?.name()
      },
      "regexToAllowSyncUrlLoading": regexToAllowSyncUrlLoading,
      "regexToCancelSubFramesLoading": regexToCancelSubFramesLoading,
      "rendererPriorityPolicy":
          rendererPriorityPolicy?.toMap(enumMethod: enumMethod),
      "reputationCheckingRequired": reputationCheckingRequired,
      "requestedWithHeaderOriginAllowList":
          requestedWithHeaderOriginAllowList?.toList(),
      "resourceCustomSchemes": resourceCustomSchemes,
      "safeBrowsingEnabled": safeBrowsingEnabled,
      "sansSerifFontFamily": sansSerifFontFamily,
      "saveFormData": saveFormData,
      "scrollBarDefaultDelayBeforeFade": scrollBarDefaultDelayBeforeFade,
      "scrollBarFadeDuration": scrollBarFadeDuration,
      "scrollBarStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => scrollBarStyle?.toNativeValue(),
        EnumMethod.value => scrollBarStyle?.toValue(),
        EnumMethod.name => scrollBarStyle?.name()
      },
      "scrollMultiplier": scrollMultiplier,
      "scrollbarFadingEnabled": scrollbarFadingEnabled,
      "scrollsToTop": scrollsToTop,
      "selectionGranularity": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => selectionGranularity?.toNativeValue(),
        EnumMethod.value => selectionGranularity?.toValue(),
        EnumMethod.name => selectionGranularity?.name()
      },
      "serifFontFamily": serifFontFamily,
      "sharedCookiesEnabled": sharedCookiesEnabled,
      "shouldPrintBackgrounds": shouldPrintBackgrounds,
      "standardFontFamily": standardFontFamily,
      "statusBarEnabled": statusBarEnabled,
      "supportMultipleWindows": supportMultipleWindows,
      "supportZoom": supportZoom,
      "suppressesIncrementalRendering": suppressesIncrementalRendering,
      "textZoom": textZoom,
      "thirdPartyCookiesEnabled": thirdPartyCookiesEnabled,
      "transparentBackground": transparentBackground,
      "underPageBackgroundColor": underPageBackgroundColor?.toHex(),
      "upgradeKnownHostsToHTTPS": upgradeKnownHostsToHTTPS,
      "useHybridComposition": useHybridComposition,
      "useOnAjaxProgress": useOnAjaxProgress,
      "useOnAjaxReadyStateChange": useOnAjaxReadyStateChange,
      "useOnDownloadStart": useOnDownloadStart,
      "useOnLoadResource": useOnLoadResource,
      "useOnNavigationResponse": useOnNavigationResponse,
      "useOnRenderProcessGone": useOnRenderProcessGone,
      "useOnShowFileChooser": useOnShowFileChooser,
      "useShouldInterceptAjaxRequest": useShouldInterceptAjaxRequest,
      "useShouldInterceptFetchRequest": useShouldInterceptFetchRequest,
      "useShouldInterceptRequest": useShouldInterceptRequest,
      "useShouldOverrideUrlLoading": useShouldOverrideUrlLoading,
      "useWideViewPort": useWideViewPort,
      "userAgent": userAgent,
      "verticalScrollBarEnabled": verticalScrollBarEnabled,
      "verticalScrollbarPosition": switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => verticalScrollbarPosition?.toNativeValue(),
        EnumMethod.value => verticalScrollbarPosition?.toValue(),
        EnumMethod.name => verticalScrollbarPosition?.name()
      },
      "verticalScrollbarThumbColor": verticalScrollbarThumbColor?.toHex(),
      "verticalScrollbarTrackColor": verticalScrollbarTrackColor?.toHex(),
      "webViewAssetLoader": webViewAssetLoader?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of InAppWebViewSettings.
  InAppWebViewSettings copy() {
    return InAppWebViewSettings.fromMap(toMap()) ?? InAppWebViewSettings();
  }

  @override
  String toString() {
    return 'InAppWebViewSettings{accessibilityIgnoresInvertColors: $accessibilityIgnoresInvertColors, algorithmicDarkeningAllowed: $algorithmicDarkeningAllowed, allowBackgroundAudioPlaying: $allowBackgroundAudioPlaying, allowContentAccess: $allowContentAccess, allowFileAccess: $allowFileAccess, allowFileAccessFromFileURLs: $allowFileAccessFromFileURLs, allowUniversalAccessFromFileURLs: $allowUniversalAccessFromFileURLs, allowingReadAccessTo: $allowingReadAccessTo, allowsAirPlayForMediaPlayback: $allowsAirPlayForMediaPlayback, allowsBackForwardNavigationGestures: $allowsBackForwardNavigationGestures, allowsInlineMediaPlayback: $allowsInlineMediaPlayback, allowsLinkPreview: $allowsLinkPreview, allowsPictureInPictureMediaPlayback: $allowsPictureInPictureMediaPlayback, alpha: $alpha, alwaysBounceHorizontal: $alwaysBounceHorizontal, alwaysBounceVertical: $alwaysBounceVertical, appCachePath: $appCachePath, applePayAPIEnabled: $applePayAPIEnabled, applicationNameForUserAgent: $applicationNameForUserAgent, automaticallyAdjustsScrollIndicatorInsets: $automaticallyAdjustsScrollIndicatorInsets, blockNetworkImage: $blockNetworkImage, blockNetworkLoads: $blockNetworkLoads, browserAcceleratorKeysEnabled: $browserAcceleratorKeysEnabled, builtInZoomControls: $builtInZoomControls, cacheEnabled: $cacheEnabled, cacheMode: $cacheMode, contentBlockers: $contentBlockers, contentInsetAdjustmentBehavior: $contentInsetAdjustmentBehavior, cursiveFontFamily: $cursiveFontFamily, dataDetectorTypes: $dataDetectorTypes, databaseEnabled: $databaseEnabled, decelerationRate: $decelerationRate, defaultFixedFontSize: $defaultFixedFontSize, defaultFontSize: $defaultFontSize, defaultTextEncodingName: $defaultTextEncodingName, defaultVideoPoster: $defaultVideoPoster, disableContextMenu: $disableContextMenu, disableDefaultErrorPage: $disableDefaultErrorPage, disableHorizontalScroll: $disableHorizontalScroll, disableInputAccessoryView: $disableInputAccessoryView, disableLongPressContextMenuOnLinks: $disableLongPressContextMenuOnLinks, disableVerticalScroll: $disableVerticalScroll, disabledActionModeMenuItems: $disabledActionModeMenuItems, disallowOverScroll: $disallowOverScroll, displayZoomControls: $displayZoomControls, domStorageEnabled: $domStorageEnabled, enableViewportScale: $enableViewportScale, enterpriseAuthenticationAppLinkPolicyEnabled: $enterpriseAuthenticationAppLinkPolicyEnabled, fantasyFontFamily: $fantasyFontFamily, fixedFontFamily: $fixedFontFamily, generalAutofillEnabled: $generalAutofillEnabled, geolocationEnabled: $geolocationEnabled, handleAcceleratorKeyPressed: $handleAcceleratorKeyPressed, hardwareAcceleration: $hardwareAcceleration, hiddenPdfToolbarItems: $hiddenPdfToolbarItems, horizontalScrollBarEnabled: $horizontalScrollBarEnabled, horizontalScrollbarThumbColor: $horizontalScrollbarThumbColor, horizontalScrollbarTrackColor: $horizontalScrollbarTrackColor, iframeAllow: $iframeAllow, iframeAllowFullscreen: $iframeAllowFullscreen, iframeAriaHidden: $iframeAriaHidden, iframeCsp: $iframeCsp, iframeName: $iframeName, iframeReferrerPolicy: $iframeReferrerPolicy, iframeRole: $iframeRole, iframeSandbox: $iframeSandbox, ignoresViewportScaleLimits: $ignoresViewportScaleLimits, incognito: $incognito, initialScale: $initialScale, interceptOnlyAsyncAjaxRequests: $interceptOnlyAsyncAjaxRequests, isDirectionalLockEnabled: $isDirectionalLockEnabled, isElementFullscreenEnabled: $isElementFullscreenEnabled, isFindInteractionEnabled: $isFindInteractionEnabled, isFraudulentWebsiteWarningEnabled: $isFraudulentWebsiteWarningEnabled, isInspectable: $isInspectable, isPagingEnabled: $isPagingEnabled, isSiteSpecificQuirksModeEnabled: $isSiteSpecificQuirksModeEnabled, isTextInteractionEnabled: $isTextInteractionEnabled, isUserInteractionEnabled: $isUserInteractionEnabled, javaScriptBridgeEnabled: $javaScriptBridgeEnabled, javaScriptBridgeForMainFrameOnly: $javaScriptBridgeForMainFrameOnly, javaScriptBridgeOriginAllowList: $javaScriptBridgeOriginAllowList, javaScriptCanOpenWindowsAutomatically: $javaScriptCanOpenWindowsAutomatically, javaScriptEnabled: $javaScriptEnabled, javaScriptHandlersForMainFrameOnly: $javaScriptHandlersForMainFrameOnly, javaScriptHandlersOriginAllowList: $javaScriptHandlersOriginAllowList, layoutAlgorithm: $layoutAlgorithm, limitsNavigationsToAppBoundDomains: $limitsNavigationsToAppBoundDomains, loadWithOverviewMode: $loadWithOverviewMode, loadsImagesAutomatically: $loadsImagesAutomatically, maximumViewportInset: $maximumViewportInset, maximumZoomScale: $maximumZoomScale, mediaPlaybackRequiresUserGesture: $mediaPlaybackRequiresUserGesture, mediaType: $mediaType, minimumFontSize: $minimumFontSize, minimumLogicalFontSize: $minimumLogicalFontSize, minimumViewportInset: $minimumViewportInset, minimumZoomScale: $minimumZoomScale, mixedContentMode: $mixedContentMode, needInitialFocus: $needInitialFocus, networkAvailable: $networkAvailable, nonClientRegionSupportEnabled: $nonClientRegionSupportEnabled, offscreenPreRaster: $offscreenPreRaster, overScrollMode: $overScrollMode, pageZoom: $pageZoom, passwordAutosaveEnabled: $passwordAutosaveEnabled, pinchZoomEnabled: $pinchZoomEnabled, pluginScriptsForMainFrameOnly: $pluginScriptsForMainFrameOnly, pluginScriptsOriginAllowList: $pluginScriptsOriginAllowList, preferredContentMode: $preferredContentMode, regexToAllowSyncUrlLoading: $regexToAllowSyncUrlLoading, regexToCancelSubFramesLoading: $regexToCancelSubFramesLoading, rendererPriorityPolicy: $rendererPriorityPolicy, reputationCheckingRequired: $reputationCheckingRequired, requestedWithHeaderOriginAllowList: $requestedWithHeaderOriginAllowList, resourceCustomSchemes: $resourceCustomSchemes, safeBrowsingEnabled: $safeBrowsingEnabled, sansSerifFontFamily: $sansSerifFontFamily, scrollBarDefaultDelayBeforeFade: $scrollBarDefaultDelayBeforeFade, scrollBarFadeDuration: $scrollBarFadeDuration, scrollBarStyle: $scrollBarStyle, scrollMultiplier: $scrollMultiplier, scrollbarFadingEnabled: $scrollbarFadingEnabled, scrollsToTop: $scrollsToTop, selectionGranularity: $selectionGranularity, serifFontFamily: $serifFontFamily, sharedCookiesEnabled: $sharedCookiesEnabled, shouldPrintBackgrounds: $shouldPrintBackgrounds, standardFontFamily: $standardFontFamily, statusBarEnabled: $statusBarEnabled, supportMultipleWindows: $supportMultipleWindows, supportZoom: $supportZoom, suppressesIncrementalRendering: $suppressesIncrementalRendering, textZoom: $textZoom, thirdPartyCookiesEnabled: $thirdPartyCookiesEnabled, transparentBackground: $transparentBackground, underPageBackgroundColor: $underPageBackgroundColor, upgradeKnownHostsToHTTPS: $upgradeKnownHostsToHTTPS, useHybridComposition: $useHybridComposition, useOnAjaxProgress: $useOnAjaxProgress, useOnAjaxReadyStateChange: $useOnAjaxReadyStateChange, useOnDownloadStart: $useOnDownloadStart, useOnLoadResource: $useOnLoadResource, useOnNavigationResponse: $useOnNavigationResponse, useOnRenderProcessGone: $useOnRenderProcessGone, useOnShowFileChooser: $useOnShowFileChooser, useShouldInterceptAjaxRequest: $useShouldInterceptAjaxRequest, useShouldInterceptFetchRequest: $useShouldInterceptFetchRequest, useShouldInterceptRequest: $useShouldInterceptRequest, useShouldOverrideUrlLoading: $useShouldOverrideUrlLoading, useWideViewPort: $useWideViewPort, userAgent: $userAgent, verticalScrollBarEnabled: $verticalScrollBarEnabled, verticalScrollbarPosition: $verticalScrollbarPosition, verticalScrollbarThumbColor: $verticalScrollbarThumbColor, verticalScrollbarTrackColor: $verticalScrollbarTrackColor, webViewAssetLoader: $webViewAssetLoader}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [InAppWebViewSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum InAppWebViewSettingsProperty {
  ///Can be used to check if the [InAppWebViewSettings.accessibilityIgnoresInvertColors] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.accessibilityIgnoresInvertColors.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIView.accessibilityIgnoresInvertColors](https://developer.apple.com/documentation/uikit/uiview/2865843-accessibilityignoresinvertcolors))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  accessibilityIgnoresInvertColors,

  ///Can be used to check if the [InAppWebViewSettings.algorithmicDarkeningAllowed] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.algorithmicDarkeningAllowed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - WebSettingsCompat.setAlgorithmicDarkeningAllowed](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setAlgorithmicDarkeningAllowed(android.webkit.WebSettings,boolean))):
  ///    - available on Android only if [WebViewFeature.ALGORITHMIC_DARKENING] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  algorithmicDarkeningAllowed,

  ///Can be used to check if the [InAppWebViewSettings.allowBackgroundAudioPlaying] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowBackgroundAudioPlaying.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowBackgroundAudioPlaying,

  ///Can be used to check if the [InAppWebViewSettings.allowContentAccess] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowContentAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowContentAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowContentAccess(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowContentAccess,

  ///Can be used to check if the [InAppWebViewSettings.allowFileAccess] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowFileAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccess](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccess(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowFileAccess,

  ///Can be used to check if the [InAppWebViewSettings.allowFileAccessFromFileURLs] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowFileAccessFromFileURLs.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowFileAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowFileAccessFromFileURLs(boolean)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowFileAccessFromFileURLs,

  ///Can be used to check if the [InAppWebViewSettings.allowUniversalAccessFromFileURLs] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowUniversalAccessFromFileURLs.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setAllowUniversalAccessFromFileURLs](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setAllowUniversalAccessFromFileURLs(boolean)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowUniversalAccessFromFileURLs,

  ///Can be used to check if the [InAppWebViewSettings.allowingReadAccessTo] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowingReadAccessTo.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowingReadAccessTo,

  ///Can be used to check if the [InAppWebViewSettings.allowsAirPlayForMediaPlayback] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsAirPlayForMediaPlayback.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsAirPlayForMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback))
  ///- macOS WKWebView ([Official API - WKWebViewConfiguration.allowsAirPlayForMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395673-allowsairplayformediaplayback))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsAirPlayForMediaPlayback,

  ///Can be used to check if the [InAppWebViewSettings.allowsBackForwardNavigationGestures] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsBackForwardNavigationGestures.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsBackForwardNavigationGestures](https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu))
  ///- macOS WKWebView ([Official API - WKWebView.allowsBackForwardNavigationGestures](https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu))
  ///- Windows WebView2 1.0.992.28+ ([Official API - ICoreWebView2Settings6.put_IsSwipeNavigationEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings6?view=webview2-1.0.2849.39#put_isswipenavigationenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsBackForwardNavigationGestures,

  ///Can be used to check if the [InAppWebViewSettings.allowsInlineMediaPlayback] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsInlineMediaPlayback.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsInlineMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614793-allowsinlinemediaplayback))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsInlineMediaPlayback,

  ///Can be used to check if the [InAppWebViewSettings.allowsLinkPreview] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsLinkPreview.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebView.allowsLinkPreview](https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview))
  ///- macOS WKWebView ([Official API - WKWebView.allowsLinkPreview](https://developer.apple.com/documentation/webkit/wkwebview/1415000-allowslinkpreview))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsLinkPreview,

  ///Can be used to check if the [InAppWebViewSettings.allowsPictureInPictureMediaPlayback] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.allowsPictureInPictureMediaPlayback.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.allowsPictureInPictureMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614792-allowspictureinpicturemediaplayb))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowsPictureInPictureMediaPlayback,

  ///Can be used to check if the [InAppWebViewSettings.alpha] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.alpha.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setAlpha](https://developer.android.com/reference/android/view/View#setAlpha(float)))
  ///- iOS WKWebView ([Official API - UIView.alpha](https://developer.apple.com/documentation/uikit/uiview/1622417-alpha))
  ///- macOS WKWebView ([Official API - NSView.alphaValue](https://developer.apple.com/documentation/appkit/nsview/1483560-alphavalue))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  alpha,

  ///Can be used to check if the [InAppWebViewSettings.alwaysBounceHorizontal] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.alwaysBounceHorizontal.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceHorizontal](https://developer.apple.com/documentation/uikit/uiscrollview/1619393-alwaysbouncehorizontal))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  alwaysBounceHorizontal,

  ///Can be used to check if the [InAppWebViewSettings.alwaysBounceVertical] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.alwaysBounceVertical.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.alwaysBounceVertical](https://developer.apple.com/documentation/uikit/uiscrollview/1619383-alwaysbouncevertical))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  alwaysBounceVertical,

  ///Can be used to check if the [InAppWebViewSettings.appCachePath] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.appCachePath.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView (Official API - WebSettings.setAppCachePath)
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  appCachePath,

  ///Can be used to check if the [InAppWebViewSettings.applePayAPIEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.applePayAPIEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+
  ///- macOS WKWebView 10.15+
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  applePayAPIEnabled,

  ///Can be used to check if the [InAppWebViewSettings.applicationNameForUserAgent] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.applicationNameForUserAgent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.applicationNameForUserAgent](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent))
  ///- macOS WKWebView ([Official API - WKWebViewConfiguration.applicationNameForUserAgent](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395665-applicationnameforuseragent))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  applicationNameForUserAgent,

  ///Can be used to check if the [InAppWebViewSettings.automaticallyAdjustsScrollIndicatorInsets] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.automaticallyAdjustsScrollIndicatorInsets.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - UIScrollView.automaticallyAdjustsScrollIndicatorInsets](https://developer.apple.com/documentation/uikit/uiscrollview/3198043-automaticallyadjustsscrollindica))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  automaticallyAdjustsScrollIndicatorInsets,

  ///Can be used to check if the [InAppWebViewSettings.blockNetworkImage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.blockNetworkImage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkImage](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkImage(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  blockNetworkImage,

  ///Can be used to check if the [InAppWebViewSettings.blockNetworkLoads] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.blockNetworkLoads.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBlockNetworkLoads](https://developer.android.com/reference/android/webkit/WebSettings#setBlockNetworkLoads(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  blockNetworkLoads,

  ///Can be used to check if the [InAppWebViewSettings.browserAcceleratorKeysEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.browserAcceleratorKeysEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.864.35+ ([Official API - ICoreWebView2Settings3.put_IsBuiltInErrorPageEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings3?view=webview2-1.0.2849.39#put_arebrowseracceleratorkeysenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  browserAcceleratorKeysEnabled,

  ///Can be used to check if the [InAppWebViewSettings.builtInZoomControls] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.builtInZoomControls.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setBuiltInZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setBuiltInZoomControls(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  builtInZoomControls,

  ///Can be used to check if the [InAppWebViewSettings.cacheEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.cacheEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  cacheEnabled,

  ///Can be used to check if the [InAppWebViewSettings.cacheMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.cacheMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCacheMode](https://developer.android.com/reference/android/webkit/WebSettings#setCacheMode(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  cacheMode,

  ///Can be used to check if the [InAppWebViewSettings.clearCache] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.clearCache.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use InAppWebViewController.clearAllCache instead')
  clearCache,

  ///Can be used to check if the [InAppWebViewSettings.clearSessionCache] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.clearSessionCache.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use CookieManager.removeSessionCookies instead')
  clearSessionCache,

  ///Can be used to check if the [InAppWebViewSettings.contentBlockers] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.contentBlockers.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.13+
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  contentBlockers,

  ///Can be used to check if the [InAppWebViewSettings.contentInsetAdjustmentBehavior] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.contentInsetAdjustmentBehavior.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - UIScrollView.contentInsetAdjustmentBehavior](https://developer.apple.com/documentation/uikit/uiscrollview/2902261-contentinsetadjustmentbehavior))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  contentInsetAdjustmentBehavior,

  ///Can be used to check if the [InAppWebViewSettings.cursiveFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.cursiveFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setCursiveFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setCursiveFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  cursiveFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.dataDetectorTypes] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.dataDetectorTypes.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 10+ ([Official API - WKWebViewConfiguration.dataDetectorTypes](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1641937-datadetectortypes))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  dataDetectorTypes,

  ///Can be used to check if the [InAppWebViewSettings.databaseEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.databaseEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDatabaseEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDatabaseEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  databaseEnabled,

  ///Can be used to check if the [InAppWebViewSettings.decelerationRate] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.decelerationRate.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.decelerationRate](https://developer.apple.com/documentation/uikit/uiscrollview/1619438-decelerationrate))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  decelerationRate,

  ///Can be used to check if the [InAppWebViewSettings.defaultFixedFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultFixedFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFixedFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFixedFontSize(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultFixedFontSize,

  ///Can be used to check if the [InAppWebViewSettings.defaultFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultFontSize](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultFontSize(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultFontSize,

  ///Can be used to check if the [InAppWebViewSettings.defaultTextEncodingName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultTextEncodingName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDefaultTextEncodingName](https://developer.android.com/reference/android/webkit/WebSettings#setDefaultTextEncodingName(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultTextEncodingName,

  ///Can be used to check if the [InAppWebViewSettings.defaultVideoPoster] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.defaultVideoPoster.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  defaultVideoPoster,

  ///Can be used to check if the [InAppWebViewSettings.disableContextMenu] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableContextMenu.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_AreDefaultContextMenusEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_aredefaultcontextmenusenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableContextMenu,

  ///Can be used to check if the [InAppWebViewSettings.disableDefaultErrorPage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableDefaultErrorPage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsBuiltInErrorPageEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2849.39#put_isbuiltinerrorpageenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableDefaultErrorPage,

  ///Can be used to check if the [InAppWebViewSettings.disableHorizontalScroll] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableHorizontalScroll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableHorizontalScroll,

  ///Can be used to check if the [InAppWebViewSettings.disableInputAccessoryView] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableInputAccessoryView.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableInputAccessoryView,

  ///Can be used to check if the [InAppWebViewSettings.disableLongPressContextMenuOnLinks] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableLongPressContextMenuOnLinks.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableLongPressContextMenuOnLinks,

  ///Can be used to check if the [InAppWebViewSettings.disableVerticalScroll] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disableVerticalScroll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disableVerticalScroll,

  ///Can be used to check if the [InAppWebViewSettings.disabledActionModeMenuItems] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disabledActionModeMenuItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 24+ ([Official API - WebSettings.setDisabledActionModeMenuItems](https://developer.android.com/reference/android/webkit/WebSettings#setDisabledActionModeMenuItems(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disabledActionModeMenuItems,

  ///Can be used to check if the [InAppWebViewSettings.disallowOverScroll] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.disallowOverScroll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  disallowOverScroll,

  ///Can be used to check if the [InAppWebViewSettings.displayZoomControls] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.displayZoomControls.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDisplayZoomControls](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDisplayZoomControls(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  displayZoomControls,

  ///Can be used to check if the [InAppWebViewSettings.domStorageEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.domStorageEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setDomStorageEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setDomStorageEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  domStorageEnabled,

  ///Can be used to check if the [InAppWebViewSettings.enableViewportScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.enableViewportScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  enableViewportScale,

  ///Can be used to check if the [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  enterpriseAuthenticationAppLinkPolicyEnabled,

  ///Can be used to check if the [InAppWebViewSettings.fantasyFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.fantasyFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFantasyFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFantasyFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  fantasyFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.fixedFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.fixedFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setFixedFontFamily](https://developer.android.com/reference/android/webkit/WebSettings#setFixedFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  fixedFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.forceDark] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.forceDark.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - WebSettings.setForceDark](https://developer.android.com/reference/android/webkit/WebSettings#setForceDark(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use algorithmicDarkeningAllowed instead')
  forceDark,

  ///Can be used to check if the [InAppWebViewSettings.forceDarkStrategy] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.forceDarkStrategy.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setForceDarkStrategy](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setForceDarkStrategy(android.webkit.WebSettings,int))):
  ///    - it will take effect only if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.FORCE_DARK_STRATEGY].
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use algorithmicDarkeningAllowed instead')
  forceDarkStrategy,

  ///Can be used to check if the [InAppWebViewSettings.generalAutofillEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.generalAutofillEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.902.49+ ([Official API - ICoreWebView2Settings4.put_IsGeneralAutofillEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings4?view=webview2-1.0.2849.39#put_isgeneralautofillenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  generalAutofillEnabled,

  ///Can be used to check if the [InAppWebViewSettings.geolocationEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.geolocationEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setGeolocationEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setGeolocationEnabled(boolean))):
  ///    - Please note that in order for the Geolocation API to be usable by a page in the WebView, the following requirements must be met: - an application must have permission to access the device location, see [Manifest.permission.ACCESS_COARSE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_COARSE_LOCATION), [Manifest.permission.ACCESS_FINE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#ACCESS_FINE_LOCATION); - an application must provide an implementation of the [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt] callback to receive notifications that a page is requesting access to location via the JavaScript Geolocation API.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  geolocationEnabled,

  ///Can be used to check if the [InAppWebViewSettings.handleAcceleratorKeyPressed] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.handleAcceleratorKeyPressed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  handleAcceleratorKeyPressed,

  ///Can be used to check if the [InAppWebViewSettings.hardwareAcceleration] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.hardwareAcceleration.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setLayerType](https://developer.android.com/reference/android/webkit/WebView#setLayerType(int,%20android.graphics.Paint)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hardwareAcceleration,

  ///Can be used to check if the [InAppWebViewSettings.hiddenPdfToolbarItems] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.hiddenPdfToolbarItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1185.39+ ([Official API - ICoreWebView2Settings7.put_HiddenPdfToolbarItems](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings7?view=webview2-1.0.2849.39#put_hiddenpdftoolbaritems))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hiddenPdfToolbarItems,

  ///Can be used to check if the [InAppWebViewSettings.horizontalScrollBarEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.horizontalScrollBarEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setHorizontalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setHorizontalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsHorizontalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619380-showshorizontalscrollindicator))
  ///- Web \<iframe\> but requires same origin:
  ///    - It must have the same value of [verticalScrollBarEnabled] to take effect.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  horizontalScrollBarEnabled,

  ///Can be used to check if the [InAppWebViewSettings.horizontalScrollbarThumbColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.horizontalScrollbarThumbColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  horizontalScrollbarThumbColor,

  ///Can be used to check if the [InAppWebViewSettings.horizontalScrollbarTrackColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.horizontalScrollbarTrackColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setHorizontalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setHorizontalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  horizontalScrollbarTrackColor,

  ///Can be used to check if the [InAppWebViewSettings.iframeAllow] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeAllow.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.allow](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-allow))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeAllow,

  ///Can be used to check if the [InAppWebViewSettings.iframeAllowFullscreen] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeAllowFullscreen.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.allowfullscreen](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-allowfullscreen))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeAllowFullscreen,

  ///Can be used to check if the [InAppWebViewSettings.iframeAriaHidden] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeAriaHidden.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.ariaHidden](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeAriaHidden,

  ///Can be used to check if the [InAppWebViewSettings.iframeCsp] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeCsp.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.csp](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-csp))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeCsp,

  ///Can be used to check if the [InAppWebViewSettings.iframeName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.name](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-name))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeName,

  ///Can be used to check if the [InAppWebViewSettings.iframeReferrerPolicy] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeReferrerPolicy.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.referrerpolicy](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-referrerpolicy))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeReferrerPolicy,

  ///Can be used to check if the [InAppWebViewSettings.iframeRole] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeRole.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.role](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeRole,

  ///Can be used to check if the [InAppWebViewSettings.iframeSandbox] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.iframeSandbox.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Web \<iframe\> ([Official API - iframe.sandbox](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#attr-sandbox))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  iframeSandbox,

  ///Can be used to check if the [InAppWebViewSettings.ignoresViewportScaleLimits] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.ignoresViewportScaleLimits.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.ignoresViewportScaleLimits](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/2274633-ignoresviewportscalelimits))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  ignoresViewportScaleLimits,

  ///Can be used to check if the [InAppWebViewSettings.incognito] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.incognito.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - setting this to `true`, it will clear all the cookies of all WebView instances, because there isn't any way to make the website data store non-persistent for the specific WebView instance such as on iOS.
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2ControllerOptions.put_IsInPrivateModeEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controlleroptions?view=webview2-1.0.2792.45#put_isinprivatemodeenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  incognito,

  ///Can be used to check if the [InAppWebViewSettings.initialScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.initialScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setInitialScale](https://developer.android.com/reference/android/webkit/WebView#setInitialScale(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  initialScale,

  ///Can be used to check if the [InAppWebViewSettings.interceptOnlyAsyncAjaxRequests] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.interceptOnlyAsyncAjaxRequests.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  interceptOnlyAsyncAjaxRequests,

  ///Can be used to check if the [InAppWebViewSettings.isDirectionalLockEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isDirectionalLockEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isDirectionalLockEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619390-isdirectionallockenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isDirectionalLockEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isElementFullscreenEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isElementFullscreenEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isElementFullscreenEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled))
  ///- macOS WKWebView 12.3+ ([Official API - WKPreferences.isElementFullscreenEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3917769-iselementfullscreenenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isElementFullscreenEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isFindInteractionEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isFindInteractionEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.0+ ([Official API - WKWebView.isFindInteractionEnabled](https://developer.apple.com/documentation/webkit/wkwebview/4002044-isfindinteractionenabled/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isFindInteractionEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isFraudulentWebsiteWarningEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isFraudulentWebsiteWarningEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+ ([Official API - WKPreferences.isFraudulentWebsiteWarningEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable))
  ///- macOS WKWebView 10.15+ ([Official API - WKPreferences.isFraudulentWebsiteWarningEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3335219-isfraudulentwebsitewarningenable))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isFraudulentWebsiteWarningEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isInspectable] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isInspectable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.isInspectable](https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable))
  ///- macOS WKWebView 13.3+ ([Official API - WKWebView.isInspectable](https://developer.apple.com/documentation/webkit/wkwebview/4111163-isinspectable))
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_AreDevToolsEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_aredevtoolsenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isInspectable,

  ///Can be used to check if the [InAppWebViewSettings.isPagingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isPagingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.isPagingEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619432-ispagingenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isPagingEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isSiteSpecificQuirksModeEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isSiteSpecificQuirksModeEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.4+ ([Official API - WKPreferences.isSiteSpecificQuirksModeEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled))
  ///- macOS WKWebView 12.3+ ([Official API - WKPreferences.isSiteSpecificQuirksModeEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3916069-issitespecificquirksmodeenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isSiteSpecificQuirksModeEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isTextInteractionEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isTextInteractionEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKPreferences.isTextInteractionEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled))
  ///- macOS WKWebView 11.3+ ([Official API - WKPreferences.isTextInteractionEnabled](https://developer.apple.com/documentation/webkit/wkpreferences/3727362-istextinteractionenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isTextInteractionEnabled,

  ///Can be used to check if the [InAppWebViewSettings.isUserInteractionEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.isUserInteractionEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIView.isUserInteractionEnabled](https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isUserInteractionEnabled,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptBridgeEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptBridgeEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptBridgeEnabled,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptBridgeForMainFrameOnly] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptBridgeForMainFrameOnly.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptBridgeForMainFrameOnly,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptBridgeOriginAllowList] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptBridgeOriginAllowList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptBridgeOriginAllowList,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptCanOpenWindowsAutomatically.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptCanOpenWindowsAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptCanOpenWindowsAutomatically(boolean)))
  ///- iOS WKWebView ([Official API - WKPreferences.javaScriptCanOpenWindowsAutomatically](https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/))
  ///- macOS WKWebView ([Official API - WKPreferences.javaScriptCanOpenWindowsAutomatically](https://developer.apple.com/documentation/webkit/wkpreferences/1536573-javascriptcanopenwindowsautomati/))
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptCanOpenWindowsAutomatically,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setJavaScriptEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setJavaScriptEnabled(boolean)))
  ///- iOS WKWebView ([Official API - WKWebpagePreferences.allowsContentJavaScript](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/))
  ///- macOS WKWebView ([Official API - WKWebpagePreferences.allowsContentJavaScript](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3552422-allowscontentjavascript/))
  ///- Web \<iframe\>
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsScriptEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_isscriptenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptEnabled,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptHandlersForMainFrameOnly] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptHandlersForMainFrameOnly.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptHandlersForMainFrameOnly,

  ///Can be used to check if the [InAppWebViewSettings.javaScriptHandlersOriginAllowList] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.javaScriptHandlersOriginAllowList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Web \<iframe\> but requires same origin
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  javaScriptHandlersOriginAllowList,

  ///Can be used to check if the [InAppWebViewSettings.layoutAlgorithm] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.layoutAlgorithm.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLayoutAlgorithm](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLayoutAlgorithm(android.webkit.WebSettings.LayoutAlgorithm)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  layoutAlgorithm,

  ///Can be used to check if the [InAppWebViewSettings.limitsNavigationsToAppBoundDomains] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.limitsNavigationsToAppBoundDomains.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebViewConfiguration.limitsNavigationsToAppBoundDomains](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebViewConfiguration.limitsNavigationsToAppBoundDomains](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3585117-limitsnavigationstoappbounddomai))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  limitsNavigationsToAppBoundDomains,

  ///Can be used to check if the [InAppWebViewSettings.loadWithOverviewMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.loadWithOverviewMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadWithOverviewMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadWithOverviewMode(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  loadWithOverviewMode,

  ///Can be used to check if the [InAppWebViewSettings.loadsImagesAutomatically] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.loadsImagesAutomatically.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setLoadsImagesAutomatically](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setLoadsImagesAutomatically(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  loadsImagesAutomatically,

  ///Can be used to check if the [InAppWebViewSettings.maximumViewportInset] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.maximumViewportInset.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumViewportInset,

  ///Can be used to check if the [InAppWebViewSettings.maximumZoomScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.maximumZoomScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.maximumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619408-maximumzoomscale))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  maximumZoomScale,

  ///Can be used to check if the [InAppWebViewSettings.mediaPlaybackRequiresUserGesture] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.mediaPlaybackRequiresUserGesture.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMediaPlaybackRequiresUserGesture](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMediaPlaybackRequiresUserGesture(boolean)))
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor))
  ///- macOS WKWebView 10.12+ ([Official API - WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mediaPlaybackRequiresUserGesture,

  ///Can be used to check if the [InAppWebViewSettings.mediaType] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.mediaType.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.mediaType](https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebView.mediaType](https://developer.apple.com/documentation/webkit/wkwebview/3516410-mediatype))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mediaType,

  ///Can be used to check if the [InAppWebViewSettings.minimumFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumFontSize(int)))
  ///- iOS WKWebView ([Official API - WKPreferences.minimumFontSize](https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/))
  ///- macOS WKWebView ([Official API - WKPreferences.minimumFontSize](https://developer.apple.com/documentation/webkit/wkpreferences/1537155-minimumfontsize/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumFontSize,

  ///Can be used to check if the [InAppWebViewSettings.minimumLogicalFontSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumLogicalFontSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setMinimumLogicalFontSize](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMinimumLogicalFontSize(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumLogicalFontSize,

  ///Can be used to check if the [InAppWebViewSettings.minimumViewportInset] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumViewportInset.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.5+ ([Official API - WKWebView.setMinimumViewportInset](https://developer.apple.com/documentation/webkit/wkwebview/3974127-setminimumviewportinset/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumViewportInset,

  ///Can be used to check if the [InAppWebViewSettings.minimumZoomScale] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.minimumZoomScale.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.minimumZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619428-minimumzoomscale))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  minimumZoomScale,

  ///Can be used to check if the [InAppWebViewSettings.mixedContentMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.mixedContentMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - WebSettings.setMixedContentMode](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setMixedContentMode(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  mixedContentMode,

  ///Can be used to check if the [InAppWebViewSettings.needInitialFocus] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.needInitialFocus.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setNeedInitialFocus](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setNeedInitialFocus(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  needInitialFocus,

  ///Can be used to check if the [InAppWebViewSettings.networkAvailable] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.networkAvailable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setNetworkAvailable](https://developer.android.com/reference/android/webkit/WebView#setNetworkAvailable(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  networkAvailable,

  ///Can be used to check if the [InAppWebViewSettings.nonClientRegionSupportEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.nonClientRegionSupportEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2420.47+ ([Official API - ICoreWebView2Settings9.put_IsNonClientRegionSupportEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings9?view=webview2-1.0.2849.39#put_isnonclientregionsupportenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  nonClientRegionSupportEnabled,

  ///Can be used to check if the [InAppWebViewSettings.offscreenPreRaster] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.offscreenPreRaster.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 23+ ([Official API - WebSettings.setOffscreenPreRaster](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setOffscreenPreRaster(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  offscreenPreRaster,

  ///Can be used to check if the [InAppWebViewSettings.overScrollMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.overScrollMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setOverScrollMode](https://developer.android.com/reference/android/view/View#setOverScrollMode(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  overScrollMode,

  ///Can be used to check if the [InAppWebViewSettings.pageZoom] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.pageZoom.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - WKWebView.pageZoom](https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom))
  ///- macOS WKWebView 11.0+ ([Official API - WKWebView.pageZoom](https://developer.apple.com/documentation/webkit/wkwebview/3516411-pagezoom))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pageZoom,

  ///Can be used to check if the [InAppWebViewSettings.passwordAutosaveEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.passwordAutosaveEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.902.49+ ([Official API - ICoreWebView2Settings4.put_IsPasswordAutosaveEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings4?view=webview2-1.0.2849.39#put_ispasswordautosaveenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  passwordAutosaveEnabled,

  ///Can be used to check if the [InAppWebViewSettings.pinchZoomEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.pinchZoomEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.902.49+ ([Official API - ICoreWebView2Settings5.put_IsPinchZoomEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings5?view=webview2-1.0.2849.39#put_ispinchzoomenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pinchZoomEnabled,

  ///Can be used to check if the [InAppWebViewSettings.pluginScriptsForMainFrameOnly] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.pluginScriptsForMainFrameOnly.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pluginScriptsForMainFrameOnly,

  ///Can be used to check if the [InAppWebViewSettings.pluginScriptsOriginAllowList] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.pluginScriptsOriginAllowList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  pluginScriptsOriginAllowList,

  ///Can be used to check if the [InAppWebViewSettings.preferredContentMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.preferredContentMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 13.0+ ([Official API - WKWebpagePreferences.preferredContentMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/))
  ///- macOS WKWebView 10.15+ ([Official API - WKWebpagePreferences.preferredContentMode](https://developer.apple.com/documentation/webkit/wkwebpagepreferences/3194426-preferredcontentmode/))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  preferredContentMode,

  ///Can be used to check if the [InAppWebViewSettings.regexToAllowSyncUrlLoading] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.regexToAllowSyncUrlLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  regexToAllowSyncUrlLoading,

  ///Can be used to check if the [InAppWebViewSettings.regexToCancelSubFramesLoading] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.regexToCancelSubFramesLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  regexToCancelSubFramesLoading,

  ///Can be used to check if the [InAppWebViewSettings.rendererPriorityPolicy] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.rendererPriorityPolicy.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setRendererPriorityPolicy](https://developer.android.com/reference/android/webkit/WebView#setRendererPriorityPolicy(int,%20boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  rendererPriorityPolicy,

  ///Can be used to check if the [InAppWebViewSettings.reputationCheckingRequired] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.reputationCheckingRequired.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1722.45+ ([Official API - ICoreWebView2Settings8.put_IsReputationCheckingRequired](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings8?view=webview2-1.0.2849.39#put_isreputationcheckingrequired))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  reputationCheckingRequired,

  ///Can be used to check if the [InAppWebViewSettings.requestedWithHeaderOriginAllowList] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.requestedWithHeaderOriginAllowList.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettingsCompat.setRequestedWithHeaderOriginAllowList](https://developer.android.com/reference/androidx/webkit/WebSettingsCompat#setRequestedWithHeaderOriginAllowList(android.webkit.WebSettings,java.util.Set%3Cjava.lang.String%3E))):
  ///    - available on Android only if [WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST] feature is supported.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  requestedWithHeaderOriginAllowList,

  ///Can be used to check if the [InAppWebViewSettings.resourceCustomSchemes] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.resourceCustomSchemes.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.13+
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  resourceCustomSchemes,

  ///Can be used to check if the [InAppWebViewSettings.safeBrowsingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.safeBrowsingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 26+ ([Official API - WebSettings.setSafeBrowsingEnabled](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSafeBrowsingEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  safeBrowsingEnabled,

  ///Can be used to check if the [InAppWebViewSettings.sansSerifFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.sansSerifFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSansSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSansSerifFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  sansSerifFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.saveFormData] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.saveFormData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSaveFormData](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSaveFormData(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  @Deprecated('')
  saveFormData,

  ///Can be used to check if the [InAppWebViewSettings.scrollBarDefaultDelayBeforeFade] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollBarDefaultDelayBeforeFade.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarDefaultDelayBeforeFade](https://developer.android.com/reference/android/view/View#setScrollBarDefaultDelayBeforeFade(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollBarDefaultDelayBeforeFade,

  ///Can be used to check if the [InAppWebViewSettings.scrollBarFadeDuration] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollBarFadeDuration.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollBarFadeDuration](https://developer.android.com/reference/android/view/View#setScrollBarFadeDuration(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollBarFadeDuration,

  ///Can be used to check if the [InAppWebViewSettings.scrollBarStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollBarStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.setScrollBarStyle](https://developer.android.com/reference/android/webkit/WebView#setScrollBarStyle(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollBarStyle,

  ///Can be used to check if the [InAppWebViewSettings.scrollMultiplier] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollMultiplier.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollMultiplier,

  ///Can be used to check if the [InAppWebViewSettings.scrollbarFadingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollbarFadingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setScrollbarFadingEnabled](https://developer.android.com/reference/android/view/View#setScrollbarFadingEnabled(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollbarFadingEnabled,

  ///Can be used to check if the [InAppWebViewSettings.scrollsToTop] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.scrollsToTop.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIScrollView.scrollsToTop](https://developer.apple.com/documentation/uikit/uiscrollview/1619421-scrollstotop))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollsToTop,

  ///Can be used to check if the [InAppWebViewSettings.selectionGranularity] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.selectionGranularity.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.selectionGranularity](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614756-selectiongranularity))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  selectionGranularity,

  ///Can be used to check if the [InAppWebViewSettings.serifFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.serifFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSerifFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSerifFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  serifFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.sharedCookiesEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.sharedCookiesEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.13+
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  sharedCookiesEnabled,

  ///Can be used to check if the [InAppWebViewSettings.shouldPrintBackgrounds] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.shouldPrintBackgrounds.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 16.4+ ([Official API - WKWebView.shouldPrintBackgrounds](https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds))
  ///- macOS WKWebView 13.3+ ([Official API - WKWebView.shouldPrintBackgrounds](https://developer.apple.com/documentation/webkit/wkpreferences/4104043-shouldprintbackgrounds))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shouldPrintBackgrounds,

  ///Can be used to check if the [InAppWebViewSettings.standardFontFamily] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.standardFontFamily.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setStandardFontFamily](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setStandardFontFamily(java.lang.String)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  standardFontFamily,

  ///Can be used to check if the [InAppWebViewSettings.statusBarEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.statusBarEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsStatusBarEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2849.39#put_isstatusbarenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  statusBarEnabled,

  ///Can be used to check if the [InAppWebViewSettings.supportMultipleWindows] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.supportMultipleWindows.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportMultipleWindows](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportMultipleWindows(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  supportMultipleWindows,

  ///Can be used to check if the [InAppWebViewSettings.supportZoom] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.supportZoom.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setSupportZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setSupportZoom(boolean)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings.put_IsZoomControlEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings?view=webview2-1.0.2210.55#put_iszoomcontrolenabled))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  supportZoom,

  ///Can be used to check if the [InAppWebViewSettings.suppressesIncrementalRendering] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.suppressesIncrementalRendering.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - WKWebViewConfiguration.suppressesIncrementalRendering](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering))
  ///- macOS WKWebView ([Official API - WKWebViewConfiguration.suppressesIncrementalRendering](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395663-suppressesincrementalrendering))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  suppressesIncrementalRendering,

  ///Can be used to check if the [InAppWebViewSettings.textZoom] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.textZoom.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setTextZoom](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setTextZoom(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  textZoom,

  ///Can be used to check if the [InAppWebViewSettings.thirdPartyCookiesEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.thirdPartyCookiesEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - CookieManager.setAcceptThirdPartyCookies](https://developer.android.com/reference/android/webkit/CookieManager#setAcceptThirdPartyCookies(android.webkit.WebView,%20boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  thirdPartyCookiesEnabled,

  ///Can be used to check if the [InAppWebViewSettings.transparentBackground] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.transparentBackground.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView 12.0+
  ///- Windows WebView2 1.0.774.44+ ([Official API - ICoreWebView2Controller2.put_DefaultBackgroundColor](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2controller2?view=webview2-1.0.2210.55#put_defaultbackgroundcolor))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  transparentBackground,

  ///Can be used to check if the [InAppWebViewSettings.underPageBackgroundColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.underPageBackgroundColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebView.underPageBackgroundColor](https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor))
  ///- macOS WKWebView 12.0+ ([Official API - WKWebView.underPageBackgroundColor](https://developer.apple.com/documentation/webkit/wkwebview/3850574-underpagebackgroundcolor))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  underPageBackgroundColor,

  ///Can be used to check if the [InAppWebViewSettings.upgradeKnownHostsToHTTPS] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.upgradeKnownHostsToHTTPS.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 15.0+ ([Official API - WKWebViewConfiguration.upgradeKnownHostsToHTTPS](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps))
  ///- macOS WKWebView 11.3+ ([Official API - WKWebViewConfiguration.upgradeKnownHostsToHTTPS](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/3752243-upgradeknownhoststohttps))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  upgradeKnownHostsToHTTPS,

  ///Can be used to check if the [InAppWebViewSettings.useHybridComposition] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useHybridComposition.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - It is recommended to use Hybrid Composition only on Android 10+ for a release app, as it can cause framerate drops on animations in Android 9 and lower (see [Hybrid-Composition#performance](https://github.com/flutter/flutter/wiki/Hybrid-Composition#performance)).
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useHybridComposition,

  ///Can be used to check if the [InAppWebViewSettings.useOnAjaxProgress] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnAjaxProgress.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnAjaxProgress,

  ///Can be used to check if the [InAppWebViewSettings.useOnAjaxReadyStateChange] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnAjaxReadyStateChange.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnAjaxReadyStateChange,

  ///Can be used to check if the [InAppWebViewSettings.useOnDownloadStart] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnDownloadStart.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnDownloadStart,

  ///Can be used to check if the [InAppWebViewSettings.useOnLoadResource] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnLoadResource.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnLoadResource,

  ///Can be used to check if the [InAppWebViewSettings.useOnNavigationResponse] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnNavigationResponse.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnNavigationResponse,

  ///Can be used to check if the [InAppWebViewSettings.useOnRenderProcessGone] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnRenderProcessGone.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnRenderProcessGone,

  ///Can be used to check if the [InAppWebViewSettings.useOnShowFileChooser] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useOnShowFileChooser.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useOnShowFileChooser,

  ///Can be used to check if the [InAppWebViewSettings.useShouldInterceptAjaxRequest] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldInterceptAjaxRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldInterceptAjaxRequest,

  ///Can be used to check if the [InAppWebViewSettings.useShouldInterceptFetchRequest] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldInterceptFetchRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldInterceptFetchRequest,

  ///Can be used to check if the [InAppWebViewSettings.useShouldInterceptRequest] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldInterceptRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldInterceptRequest,

  ///Can be used to check if the [InAppWebViewSettings.useShouldOverrideUrlLoading] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useShouldOverrideUrlLoading.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useShouldOverrideUrlLoading,

  ///Can be used to check if the [InAppWebViewSettings.useWideViewPort] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.useWideViewPort.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUseWideViewPort](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUseWideViewPort(boolean)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  useWideViewPort,

  ///Can be used to check if the [InAppWebViewSettings.userAgent] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.userAgent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebSettings.setUserAgentString](https://developer.android.com/reference/android/webkit/WebSettings?hl=en#setUserAgentString(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKWebView.customUserAgent](https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent))
  ///- macOS WKWebView ([Official API - WKWebView.customUserAgent](https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent))
  ///- Windows WebView2 ([Official API - ICoreWebView2Settings2.put_UserAgent](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2settings2?view=webview2-1.0.2210.55#put_useragent))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  userAgent,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollBarEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollBarEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollBarEnabled](https://developer.android.com/reference/android/view/View#setVerticalScrollBarEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.showsVerticalScrollIndicator](https://developer.apple.com/documentation/uikit/uiscrollview/1619405-showsverticalscrollindicator/))
  ///- Web \<iframe\> but requires same origin:
  ///    - It must have the same value of [horizontalScrollBarEnabled] to take effect.
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollBarEnabled,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollbarPosition] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollbarPosition.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.setVerticalScrollbarPosition](https://developer.android.com/reference/android/view/View#setVerticalScrollbarPosition(int)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollbarPosition,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollbarThumbColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollbarThumbColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarThumbDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarThumbDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollbarThumbColor,

  ///Can be used to check if the [InAppWebViewSettings.verticalScrollbarTrackColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.verticalScrollbarTrackColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 29+ ([Official API - View.setVerticalScrollbarTrackDrawable](https://developer.android.com/reference/android/view/View#setVerticalScrollbarTrackDrawable(android.graphics.drawable.Drawable)))
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  verticalScrollbarTrackColor,

  ///Can be used to check if the [InAppWebViewSettings.webViewAssetLoader] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings.webViewAssetLoader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppWebViewSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webViewAssetLoader,
}

extension _InAppWebViewSettingsPropertySupported on InAppWebViewSettings {
  static bool isPropertySupported(InAppWebViewSettingsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case InAppWebViewSettingsProperty.accessibilityIgnoresInvertColors:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.algorithmicDarkeningAllowed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowBackgroundAudioPlaying:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowContentAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowFileAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowFileAccessFromFileURLs:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowUniversalAccessFromFileURLs:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowingReadAccessTo:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsAirPlayForMediaPlayback:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsBackForwardNavigationGestures:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS, TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsInlineMediaPlayback:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsLinkPreview:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.allowsPictureInPictureMediaPlayback:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.alpha:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.alwaysBounceHorizontal:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.alwaysBounceVertical:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.appCachePath:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.applePayAPIEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.applicationNameForUserAgent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty
            .automaticallyAdjustsScrollIndicatorInsets:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.blockNetworkImage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.blockNetworkLoads:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.browserAcceleratorKeysEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.builtInZoomControls:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.cacheEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.cacheMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.clearCache:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.clearSessionCache:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.contentBlockers:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.contentInsetAdjustmentBehavior:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.cursiveFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.dataDetectorTypes:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.databaseEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.decelerationRate:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultFixedFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultTextEncodingName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.defaultVideoPoster:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableContextMenu:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [
                  TargetPlatform.android,
                  TargetPlatform.iOS,
                  TargetPlatform.windows
                ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableDefaultErrorPage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableHorizontalScroll:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [TargetPlatform.android, TargetPlatform.iOS]
                    .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableInputAccessoryView:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableLongPressContextMenuOnLinks:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disableVerticalScroll:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [TargetPlatform.android, TargetPlatform.iOS]
                    .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disabledActionModeMenuItems:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.disallowOverScroll:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.displayZoomControls:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.domStorageEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.enableViewportScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty
            .enterpriseAuthenticationAppLinkPolicyEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.fantasyFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.fixedFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.forceDark:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.forceDarkStrategy:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.generalAutofillEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.geolocationEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.handleAcceleratorKeyPressed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.hardwareAcceleration:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.hiddenPdfToolbarItems:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.horizontalScrollBarEnabled:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [TargetPlatform.android, TargetPlatform.iOS]
                    .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.horizontalScrollbarThumbColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.horizontalScrollbarTrackColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeAllow:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeAllowFullscreen:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeAriaHidden:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeCsp:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeName:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeReferrerPolicy:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeRole:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.iframeSandbox:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.ignoresViewportScaleLimits:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.incognito:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.initialScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.interceptOnlyAsyncAjaxRequests:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isDirectionalLockEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isElementFullscreenEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isFindInteractionEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isFraudulentWebsiteWarningEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isInspectable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS, TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isPagingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isSiteSpecificQuirksModeEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isTextInteractionEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.isUserInteractionEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptBridgeEnabled:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [
                  TargetPlatform.android,
                  TargetPlatform.iOS,
                  TargetPlatform.macOS,
                  TargetPlatform.windows
                ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptBridgeForMainFrameOnly:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptBridgeOriginAllowList:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [
                  TargetPlatform.android,
                  TargetPlatform.iOS,
                  TargetPlatform.macOS,
                  TargetPlatform.windows
                ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptCanOpenWindowsAutomatically:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [
                  TargetPlatform.android,
                  TargetPlatform.iOS,
                  TargetPlatform.macOS
                ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptEnabled:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [
                  TargetPlatform.android,
                  TargetPlatform.iOS,
                  TargetPlatform.macOS,
                  TargetPlatform.windows
                ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptHandlersForMainFrameOnly:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.javaScriptHandlersOriginAllowList:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [
                  TargetPlatform.android,
                  TargetPlatform.iOS,
                  TargetPlatform.macOS,
                  TargetPlatform.windows
                ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.layoutAlgorithm:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.limitsNavigationsToAppBoundDomains:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.loadWithOverviewMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.loadsImagesAutomatically:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.maximumViewportInset:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.maximumZoomScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.mediaPlaybackRequiresUserGesture:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.mediaType:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumLogicalFontSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumViewportInset:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.minimumZoomScale:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.mixedContentMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.needInitialFocus:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.networkAvailable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.nonClientRegionSupportEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.offscreenPreRaster:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.overScrollMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.pageZoom:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.passwordAutosaveEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.pinchZoomEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.pluginScriptsForMainFrameOnly:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.pluginScriptsOriginAllowList:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.preferredContentMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.regexToAllowSyncUrlLoading:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.regexToCancelSubFramesLoading:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.rendererPriorityPolicy:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.reputationCheckingRequired:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.requestedWithHeaderOriginAllowList:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.resourceCustomSchemes:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.safeBrowsingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.sansSerifFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.saveFormData:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollBarDefaultDelayBeforeFade:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollBarFadeDuration:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollBarStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollMultiplier:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollbarFadingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.scrollsToTop:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.selectionGranularity:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.serifFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.sharedCookiesEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.shouldPrintBackgrounds:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.standardFontFamily:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.statusBarEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.supportMultipleWindows:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.supportZoom:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.suppressesIncrementalRendering:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.textZoom:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.thirdPartyCookiesEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.transparentBackground:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.underPageBackgroundColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.upgradeKnownHostsToHTTPS:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useHybridComposition:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnAjaxProgress:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnAjaxReadyStateChange:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnDownloadStart:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnLoadResource:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnNavigationResponse:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnRenderProcessGone:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useOnShowFileChooser:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldInterceptAjaxRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldInterceptFetchRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldInterceptRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useShouldOverrideUrlLoading:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.useWideViewPort:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.userAgent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows
            ].contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollBarEnabled:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                [TargetPlatform.android, TargetPlatform.iOS]
                    .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollbarPosition:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollbarThumbColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.verticalScrollbarTrackColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case InAppWebViewSettingsProperty.webViewAssetLoader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
