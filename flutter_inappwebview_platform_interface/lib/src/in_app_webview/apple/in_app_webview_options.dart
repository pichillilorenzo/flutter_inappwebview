import '../../types/main.dart';

import '../../in_app_browser/in_app_browser_settings.dart';

import '../in_app_webview_settings.dart';
import '../platform_inappwebview_controller.dart';

class IosOptions {}

///Use [InAppWebViewSettings] instead.
@Deprecated('Use InAppWebViewSettings instead')
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
  ///If this property is set to `true` and [IOSInAppWebViewOptions.disallowOverScroll] is `false`,
  ///vertical dragging is allowed even if the content is smaller than the bounds of the scroll view.
  ///The default value is `false`.
  bool alwaysBounceVertical;

  ///A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
  ///If this property is set to `true` and [IOSInAppWebViewOptions.disallowOverScroll] is `false`,
  ///horizontal dragging is allowed even if the content is smaller than the bounds of the scroll view.
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

  ///A Boolean value that determines whether scrolling is disabled in a particular direction.
  ///If this property is `false`, scrolling is permitted in both horizontal and vertical directions.
  ///If this property is `true` and the user begins dragging in one general direction (horizontally or vertically),
  ///the scroll view disables scrolling in the other direction.
  ///If the drag direction is diagonal, then scrolling will not be locked and the user can drag in any direction until the drag completes.
  ///The default value is `false`.
  bool isDirectionalLockEnabled;

  ///The media type for the contents of the web view.
  ///When the value of this property is `null`, the web view derives the current media type from the CSS media property of its content.
  ///If you assign a value other than `null` to this property, the web view uses the value you provide instead.
  ///The default value of this property is `null`.
  ///
  ///**NOTE**: available on iOS 14.0+.
  String? mediaType;

  ///The scale factor by which the web view scales content relative to its bounds.
  ///The default value of this property is `1.0`, which displays the content without any scaling.
  ///Changing the value of this property is equivalent to setting the CSS `zoom` property on all page content.
  ///
  ///**NOTE**: available on iOS 14.0+.
  double pageZoom;

  ///A Boolean value that indicates whether the web view limits navigation to pages within the app’s domain.
  ///Check [App-Bound Domains](https://webkit.org/blog/10882/app-bound-domains/) for more details.
  ///The default value is `false`.
  ///
  ///**NOTE**: available on iOS 14.0+.
  bool limitsNavigationsToAppBoundDomains;

  ///Set to `true` to be able to listen to the [PlatformWebViewCreationParams.iosOnNavigationResponse] event. The default value is `false`.
  bool useOnNavigationResponse;

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
  ///Options affected:
  ///- [PlatformWebViewCreationParams.initialUserScripts]
  ///- [InAppWebViewOptions.supportZoom]
  ///- [InAppWebViewOptions.useOnLoadResource]
  ///- [InAppWebViewOptions.useShouldInterceptAjaxRequest]
  ///- [InAppWebViewOptions.useShouldInterceptFetchRequest]
  ///- [IOSInAppWebViewOptions.enableViewportScale]
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
  ///- [PlatformWebViewCreationParams.onPrint]
  ///- [PlatformWebViewCreationParams.onWindowFocus]
  ///- [PlatformWebViewCreationParams.onWindowBlur]
  ///- [PlatformWebViewCreationParams.onFindResultReceived]
  ///
  ///**NOTE**: available on iOS 13.0+.
  bool applePayAPIEnabled;

  ///Used in combination with [PlatformWebViewCreationParams.initialUrlRequest] or [PlatformWebViewCreationParams.initialData] (using the `file://` scheme), it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [URLRequest.url] if you are using it with the [PlatformWebViewCreationParams.initialUrlRequest] parameter or
  ///the [InAppWebViewInitialData.baseUrl] if you are using it with the [PlatformWebViewCreationParams.initialData] parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  Uri? allowingReadAccessTo;

  ///Set to `true` to disable the context menu (copy, select, etc.) that is shown when the user emits a long press event on a HTML link.
  ///This is implemented using also JavaScript, so it must be enabled or it won't work.
  ///The default value is `false`.
  bool disableLongPressContextMenuOnLinks;

  ///Set to `true` to disable the [inputAccessoryView](https://developer.apple.com/documentation/uikit/uiresponder/1621119-inputaccessoryview) above system keyboard.
  ///The default value is `false`.
  bool disableInputAccessoryView;

  IOSInAppWebViewOptions({
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
    this.disableInputAccessoryView = false,
  }) {
    assert(
      allowingReadAccessTo == null || allowingReadAccessTo!.isScheme("file"),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    List<String> dataDetectorTypesList = [];
    dataDetectorTypes.forEach((dataDetectorType) {
      if (dataDetectorType.isSupported()) {
        dataDetectorTypesList.add(dataDetectorType.toNativeValue()!);
      }
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
      "selectionGranularity": selectionGranularity.toNativeValue(),
      "dataDetectorTypes": dataDetectorTypesList,
      "sharedCookiesEnabled": sharedCookiesEnabled,
      "automaticallyAdjustsScrollIndicatorInsets":
          automaticallyAdjustsScrollIndicatorInsets,
      "accessibilityIgnoresInvertColors": accessibilityIgnoresInvertColors,
      "decelerationRate": decelerationRate.toNativeValue(),
      "alwaysBounceVertical": alwaysBounceVertical,
      "alwaysBounceHorizontal": alwaysBounceHorizontal,
      "scrollsToTop": scrollsToTop,
      "isPagingEnabled": isPagingEnabled,
      "maximumZoomScale": maximumZoomScale,
      "minimumZoomScale": minimumZoomScale,
      "contentInsetAdjustmentBehavior": contentInsetAdjustmentBehavior
          .toNativeValue(),
      "isDirectionalLockEnabled": isDirectionalLockEnabled,
      "mediaType": mediaType,
      "pageZoom": pageZoom,
      "limitsNavigationsToAppBoundDomains": limitsNavigationsToAppBoundDomains,
      "useOnNavigationResponse": useOnNavigationResponse,
      "applePayAPIEnabled": applePayAPIEnabled,
      "allowingReadAccessTo": allowingReadAccessTo.toString(),
      "disableLongPressContextMenuOnLinks": disableLongPressContextMenuOnLinks,
      "disableInputAccessoryView": disableInputAccessoryView,
    };
  }

  static IOSInAppWebViewOptions fromMap(Map<String, dynamic> map) {
    List<IOSWKDataDetectorTypes> dataDetectorTypes = [];
    List<String> dataDetectorTypesList = List<String>.from(
      map["dataDetectorTypes"] ?? [],
    );
    dataDetectorTypesList.forEach((dataDetectorTypeValue) {
      var dataDetectorType = IOSWKDataDetectorTypes.fromNativeValue(
        dataDetectorTypeValue,
      );
      if (dataDetectorType != null) {
        dataDetectorTypes.add(dataDetectorType);
      }
    });

    var instance = IOSInAppWebViewOptions();
    instance.disallowOverScroll = map["disallowOverScroll"];
    instance.enableViewportScale = map["enableViewportScale"];
    instance.suppressesIncrementalRendering =
        map["suppressesIncrementalRendering"];
    instance.allowsAirPlayForMediaPlayback =
        map["allowsAirPlayForMediaPlayback"];
    instance.allowsBackForwardNavigationGestures =
        map["allowsBackForwardNavigationGestures"];
    instance.allowsLinkPreview = map["allowsLinkPreview"];
    instance.ignoresViewportScaleLimits = map["ignoresViewportScaleLimits"];
    instance.allowsInlineMediaPlayback = map["allowsInlineMediaPlayback"];
    instance.allowsPictureInPictureMediaPlayback =
        map["allowsPictureInPictureMediaPlayback"];
    instance.isFraudulentWebsiteWarningEnabled =
        map["isFraudulentWebsiteWarningEnabled"];
    instance.selectionGranularity = IOSWKSelectionGranularity.fromNativeValue(
      map["selectionGranularity"],
    )!;
    instance.dataDetectorTypes = dataDetectorTypes;
    instance.sharedCookiesEnabled = map["sharedCookiesEnabled"];
    instance.automaticallyAdjustsScrollIndicatorInsets =
        map["automaticallyAdjustsScrollIndicatorInsets"];
    instance.accessibilityIgnoresInvertColors =
        map["accessibilityIgnoresInvertColors"];
    instance.decelerationRate = IOSUIScrollViewDecelerationRate.fromNativeValue(
      map["decelerationRate"],
    )!;
    instance.alwaysBounceVertical = map["alwaysBounceVertical"];
    instance.alwaysBounceHorizontal = map["alwaysBounceHorizontal"];
    instance.scrollsToTop = map["scrollsToTop"];
    instance.isPagingEnabled = map["isPagingEnabled"];
    instance.maximumZoomScale = map["maximumZoomScale"];
    instance.minimumZoomScale = map["minimumZoomScale"];
    instance.contentInsetAdjustmentBehavior =
        IOSUIScrollViewContentInsetAdjustmentBehavior.fromNativeValue(
          map["contentInsetAdjustmentBehavior"],
        )!;
    instance.isDirectionalLockEnabled = map["isDirectionalLockEnabled"];
    instance.mediaType = map["mediaType"];
    instance.pageZoom = map["pageZoom"];
    instance.limitsNavigationsToAppBoundDomains =
        map["limitsNavigationsToAppBoundDomains"];
    instance.useOnNavigationResponse = map["useOnNavigationResponse"];
    instance.applePayAPIEnabled = map["applePayAPIEnabled"];
    instance.allowingReadAccessTo = map["allowingReadAccessTo"] != null
        ? Uri.tryParse(map["allowingReadAccessTo"])
        : null;
    instance.disableLongPressContextMenuOnLinks =
        map["disableLongPressContextMenuOnLinks"];
    instance.disableInputAccessoryView = map["disableInputAccessoryView"];
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
  IOSInAppWebViewOptions copy() {
    return IOSInAppWebViewOptions.fromMap(this.toMap());
  }
}
