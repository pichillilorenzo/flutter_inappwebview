import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import '../find_interaction/find_interaction_controller.dart';
import 'in_app_webview_controller.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';

///{@template flutter_inappwebview.HeadlessInAppWebView}
///Class that represents a WebView in headless mode.
///It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.
///
///**NOTE**: Remember to dispose it when you don't need it anymore.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- Web
///- MacOS
///{@endtemplate}
class HeadlessInAppWebView {
  /// Constructs a [HeadlessInAppWebView].
  ///
  /// See [HeadlessInAppWebView.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  HeadlessInAppWebView.fromPlatformCreationParams({
    required PlatformHeadlessInAppWebViewCreationParams params,
  }) : this.fromPlatform(platform: PlatformHeadlessInAppWebView(params));

  /// Constructs a [HeadlessInAppWebView] from a specific platform implementation.
  HeadlessInAppWebView.fromPlatform({required this.platform});

  /// Implementation of [PlatformHeadlessInAppWebView] for the current platform.
  final PlatformHeadlessInAppWebView platform;

  ///WebView Controller that can be used to access the [InAppWebViewController] API.
  InAppWebViewController? get webViewController {
    final webViewControllerPlatform = platform.webViewController;
    if (webViewControllerPlatform == null) {
      return null;
    }
    return InAppWebViewController.fromPlatform(
        platform: webViewControllerPlatform);
  }

  HeadlessInAppWebView({
    Size initialSize = const Size(-1, -1),
    int? windowId,
    HeadlessInAppWebView? headlessWebView,
    InAppWebViewKeepAlive? keepAlive,
    bool? preventGestureDelay,
    @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
    void Function(PlatformInAppWebViewController controller)?
        androidOnGeolocationPermissionsHidePrompt,
    @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
    Future<GeolocationPermissionShowPromptResponse?> Function(
            PlatformInAppWebViewController controller, String origin)?
        androidOnGeolocationPermissionsShowPrompt,
    @Deprecated('Use onPermissionRequest instead')
    Future<PermissionRequestResponse?> Function(
            PlatformInAppWebViewController controller,
            String origin,
            List<String> resources)?
        androidOnPermissionRequest,
    @Deprecated('Use onSafeBrowsingHit instead')
    Future<SafeBrowsingResponse?> Function(
            PlatformInAppWebViewController controller,
            Uri url,
            SafeBrowsingThreat? threatType)?
        androidOnSafeBrowsingHit,
    InAppWebViewInitialData? initialData,
    String? initialFile,
    @Deprecated('Use initialSettings instead')
    InAppWebViewGroupOptions? initialOptions,
    InAppWebViewSettings? initialSettings,
    URLRequest? initialUrlRequest,
    UnmodifiableListView<UserScript>? initialUserScripts,
    PullToRefreshController? pullToRefreshController,
    FindInteractionController? findInteractionController,
    ContextMenu? contextMenu,
    void Function(PlatformInAppWebViewController controller, WebUri? url)?
        onPageCommitVisible,
    void Function(PlatformInAppWebViewController controller, String? title)?
        onTitleChanged,
    @Deprecated(
        'Use onDidReceiveServerRedirectForProvisionalNavigation instead')
    void Function(PlatformInAppWebViewController controller)?
        iosOnDidReceiveServerRedirectForProvisionalNavigation,
    @Deprecated('Use onWebContentProcessDidTerminate instead')
    void Function(PlatformInAppWebViewController controller)?
        iosOnWebContentProcessDidTerminate,
    @Deprecated('Use onNavigationResponse instead')
    Future<IOSNavigationResponseAction?> Function(
            PlatformInAppWebViewController controller,
            IOSWKNavigationResponse navigationResponse)?
        iosOnNavigationResponse,
    @Deprecated('Use shouldAllowDeprecatedTLS instead')
    Future<IOSShouldAllowDeprecatedTLSAction?> Function(
            PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        iosShouldAllowDeprecatedTLS,
    Future<AjaxRequestAction> Function(
            PlatformInAppWebViewController controller, AjaxRequest ajaxRequest)?
        onAjaxProgress,
    Future<AjaxRequestAction?> Function(
            PlatformInAppWebViewController controller, AjaxRequest ajaxRequest)?
        onAjaxReadyStateChange,
    void Function(PlatformInAppWebViewController controller,
            ConsoleMessage consoleMessage)?
        onConsoleMessage,
    Future<bool?> Function(PlatformInAppWebViewController controller,
            CreateWindowAction createWindowAction)?
        onCreateWindow,
    void Function(PlatformInAppWebViewController controller)? onCloseWindow,
    void Function(PlatformInAppWebViewController controller)? onWindowFocus,
    void Function(PlatformInAppWebViewController controller)? onWindowBlur,
    @Deprecated('Use onReceivedIcon instead')
    void Function(PlatformInAppWebViewController controller, Uint8List icon)?
        androidOnReceivedIcon,
    @Deprecated('Use onReceivedTouchIconUrl instead')
    void Function(PlatformInAppWebViewController controller, Uri url,
            bool precomposed)?
        androidOnReceivedTouchIconUrl,
    @Deprecated('Use onDownloadStartRequest instead')
    void Function(PlatformInAppWebViewController controller, Uri url)?
        onDownloadStart,
    void Function(PlatformInAppWebViewController controller,
            DownloadStartRequest downloadStartRequest)?
        onDownloadStartRequest,
    @Deprecated('Use FindInteractionController.onFindResultReceived instead')
    void Function(PlatformInAppWebViewController controller,
            int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)?
        onFindResultReceived,
    Future<JsAlertResponse?> Function(PlatformInAppWebViewController controller,
            JsAlertRequest jsAlertRequest)?
        onJsAlert,
    Future<JsConfirmResponse?> Function(
            PlatformInAppWebViewController controller,
            JsConfirmRequest jsConfirmRequest)?
        onJsConfirm,
    Future<JsPromptResponse?> Function(
            PlatformInAppWebViewController controller,
            JsPromptRequest jsPromptRequest)?
        onJsPrompt,
    @Deprecated("Use onReceivedError instead")
    void Function(PlatformInAppWebViewController controller, Uri? url, int code,
            String message)?
        onLoadError,
    void Function(PlatformInAppWebViewController controller,
            WebResourceRequest request, WebResourceError error)?
        onReceivedError,
    @Deprecated("Use onReceivedHttpError instead")
    void Function(PlatformInAppWebViewController controller, Uri? url,
            int statusCode, String description)?
        onLoadHttpError,
    void Function(PlatformInAppWebViewController controller,
            WebResourceRequest request, WebResourceResponse errorResponse)?
        onReceivedHttpError,
    void Function(
            PlatformInAppWebViewController controller, LoadedResource resource)?
        onLoadResource,
    @Deprecated('Use onLoadResourceWithCustomScheme instead')
    Future<CustomSchemeResponse?> Function(
            PlatformInAppWebViewController controller, Uri url)?
        onLoadResourceCustomScheme,
    Future<CustomSchemeResponse?> Function(
            PlatformInAppWebViewController controller,
            WebResourceRequest request)?
        onLoadResourceWithCustomScheme,
    void Function(PlatformInAppWebViewController controller, WebUri? url)?
        onLoadStart,
    void Function(PlatformInAppWebViewController controller, WebUri? url)?
        onLoadStop,
    void Function(PlatformInAppWebViewController controller,
            InAppWebViewHitTestResult hitTestResult)?
        onLongPressHitTestResult,
    @Deprecated("Use onPrintRequest instead")
    void Function(PlatformInAppWebViewController controller, Uri? url)? onPrint,
    Future<bool?> Function(PlatformInAppWebViewController controller,
            WebUri? url, PlatformPrintJobController? printJobController)?
        onPrintRequest,
    void Function(PlatformInAppWebViewController controller, int progress)?
        onProgressChanged,
    Future<ClientCertResponse?> Function(
            PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        onReceivedClientCertRequest,
    Future<HttpAuthResponse?> Function(
            PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        onReceivedHttpAuthRequest,
    Future<ServerTrustAuthResponse?> Function(
            PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        onReceivedServerTrustAuthRequest,
    void Function(PlatformInAppWebViewController controller, int x, int y)?
        onScrollChanged,
    void Function(PlatformInAppWebViewController controller, WebUri? url,
            bool? isReload)?
        onUpdateVisitedHistory,
    void Function(PlatformInAppWebViewController controller)? onWebViewCreated,
    Future<AjaxRequest?> Function(
            PlatformInAppWebViewController controller, AjaxRequest ajaxRequest)?
        shouldInterceptAjaxRequest,
    Future<FetchRequest?> Function(PlatformInAppWebViewController controller,
            FetchRequest fetchRequest)?
        shouldInterceptFetchRequest,
    Future<NavigationActionPolicy?> Function(
            PlatformInAppWebViewController controller,
            NavigationAction navigationAction)?
        shouldOverrideUrlLoading,
    void Function(PlatformInAppWebViewController controller)? onEnterFullscreen,
    void Function(PlatformInAppWebViewController controller)? onExitFullscreen,
    void Function(PlatformInAppWebViewController controller, int x, int y,
            bool clampedX, bool clampedY)?
        onOverScrolled,
    void Function(PlatformInAppWebViewController controller, double oldScale,
            double newScale)?
        onZoomScaleChanged,
    @Deprecated('Use shouldInterceptRequest instead')
    Future<WebResourceResponse?> Function(
            PlatformInAppWebViewController controller,
            WebResourceRequest request)?
        androidShouldInterceptRequest,
    @Deprecated('Use onRenderProcessUnresponsive instead')
    Future<WebViewRenderProcessAction?> Function(
            PlatformInAppWebViewController controller, Uri? url)?
        androidOnRenderProcessUnresponsive,
    @Deprecated('Use onRenderProcessResponsive instead')
    Future<WebViewRenderProcessAction?> Function(
            PlatformInAppWebViewController controller, Uri? url)?
        androidOnRenderProcessResponsive,
    @Deprecated('Use onRenderProcessGone instead')
    void Function(PlatformInAppWebViewController controller,
            RenderProcessGoneDetail detail)?
        androidOnRenderProcessGone,
    @Deprecated('Use onFormResubmission instead')
    Future<FormResubmissionAction?> Function(
            PlatformInAppWebViewController controller, Uri? url)?
        androidOnFormResubmission,
    @Deprecated('Use onZoomScaleChanged instead')
    void Function(PlatformInAppWebViewController controller, double oldScale,
            double newScale)?
        androidOnScaleChanged,
    @Deprecated('Use onJsBeforeUnload instead')
    Future<JsBeforeUnloadResponse?> Function(
            PlatformInAppWebViewController controller,
            JsBeforeUnloadRequest jsBeforeUnloadRequest)?
        androidOnJsBeforeUnload,
    @Deprecated('Use onReceivedLoginRequest instead')
    void Function(PlatformInAppWebViewController controller,
            LoginRequest loginRequest)?
        androidOnReceivedLoginRequest,
    void Function(PlatformInAppWebViewController controller)?
        onDidReceiveServerRedirectForProvisionalNavigation,
    Future<FormResubmissionAction?> Function(
            PlatformInAppWebViewController controller, WebUri? url)?
        onFormResubmission,
    void Function(PlatformInAppWebViewController controller)?
        onGeolocationPermissionsHidePrompt,
    Future<GeolocationPermissionShowPromptResponse?> Function(
            PlatformInAppWebViewController controller, String origin)?
        onGeolocationPermissionsShowPrompt,
    Future<JsBeforeUnloadResponse?> Function(
            PlatformInAppWebViewController controller,
            JsBeforeUnloadRequest jsBeforeUnloadRequest)?
        onJsBeforeUnload,
    Future<NavigationResponseAction?> Function(
            PlatformInAppWebViewController controller,
            NavigationResponse navigationResponse)?
        onNavigationResponse,
    Future<PermissionResponse?> Function(
            PlatformInAppWebViewController controller,
            PermissionRequest permissionRequest)?
        onPermissionRequest,
    void Function(PlatformInAppWebViewController controller, Uint8List icon)?
        onReceivedIcon,
    void Function(PlatformInAppWebViewController controller,
            LoginRequest loginRequest)?
        onReceivedLoginRequest,
    void Function(PlatformInAppWebViewController controller,
            PermissionRequest permissionRequest)?
        onPermissionRequestCanceled,
    void Function(PlatformInAppWebViewController controller)? onRequestFocus,
    void Function(PlatformInAppWebViewController controller, WebUri url,
            bool precomposed)?
        onReceivedTouchIconUrl,
    void Function(PlatformInAppWebViewController controller,
            RenderProcessGoneDetail detail)?
        onRenderProcessGone,
    Future<WebViewRenderProcessAction?> Function(
            PlatformInAppWebViewController controller, WebUri? url)?
        onRenderProcessResponsive,
    Future<WebViewRenderProcessAction?> Function(
            PlatformInAppWebViewController controller, WebUri? url)?
        onRenderProcessUnresponsive,
    Future<SafeBrowsingResponse?> Function(
            PlatformInAppWebViewController controller,
            WebUri url,
            SafeBrowsingThreat? threatType)?
        onSafeBrowsingHit,
    void Function(PlatformInAppWebViewController controller)?
        onWebContentProcessDidTerminate,
    Future<ShouldAllowDeprecatedTLSAction?> Function(
            PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        shouldAllowDeprecatedTLS,
    Future<WebResourceResponse?> Function(
            PlatformInAppWebViewController controller,
            WebResourceRequest request)?
        shouldInterceptRequest,
    Future<void> Function(
      PlatformInAppWebViewController controller,
      MediaCaptureState? oldState,
      MediaCaptureState? newState,
    )? onCameraCaptureStateChanged,
    Future<void> Function(
      PlatformInAppWebViewController controller,
      MediaCaptureState? oldState,
      MediaCaptureState? newState,
    )? onMicrophoneCaptureStateChanged,
    void Function(PlatformInAppWebViewController controller,
            Size oldContentSize, Size newContentSize)?
        onContentSizeChanged,
  }) : this.fromPlatformCreationParams(
            params: PlatformHeadlessInAppWebViewCreationParams(
          initialSize: initialSize,
          windowId: windowId,
          initialUrlRequest: initialUrlRequest,
          initialFile: initialFile,
          initialData: initialData,
          initialOptions: initialOptions,
          initialSettings: initialSettings,
          initialUserScripts: initialUserScripts,
          pullToRefreshController: pullToRefreshController?.platform,
          findInteractionController: findInteractionController?.platform,
          contextMenu: contextMenu,
          onWebViewCreated: onWebViewCreated,
          onLoadStart: onLoadStart,
          onLoadStop: onLoadStop,
          onLoadError: onLoadError,
          onReceivedError: onReceivedError,
          onLoadHttpError: onLoadHttpError,
          onReceivedHttpError: onReceivedHttpError,
          onConsoleMessage: onConsoleMessage,
          onProgressChanged: onProgressChanged,
          shouldOverrideUrlLoading: shouldOverrideUrlLoading,
          onLoadResource: onLoadResource,
          onScrollChanged: onScrollChanged,
          onDownloadStart: onDownloadStart,
          onDownloadStartRequest: onDownloadStartRequest,
          onLoadResourceCustomScheme: onLoadResourceCustomScheme,
          onLoadResourceWithCustomScheme: onLoadResourceWithCustomScheme,
          onCreateWindow: onCreateWindow,
          onCloseWindow: onCloseWindow,
          onJsAlert: onJsAlert,
          onJsConfirm: onJsConfirm,
          onJsPrompt: onJsPrompt,
          onReceivedHttpAuthRequest: onReceivedHttpAuthRequest,
          onReceivedServerTrustAuthRequest: onReceivedServerTrustAuthRequest,
          onReceivedClientCertRequest: onReceivedClientCertRequest,
          onFindResultReceived: onFindResultReceived,
          shouldInterceptAjaxRequest: shouldInterceptAjaxRequest,
          onAjaxReadyStateChange: onAjaxReadyStateChange,
          onAjaxProgress: onAjaxProgress,
          shouldInterceptFetchRequest: shouldInterceptFetchRequest,
          onUpdateVisitedHistory: onUpdateVisitedHistory,
          onPrint: onPrint,
          onPrintRequest: onPrintRequest,
          onLongPressHitTestResult: onLongPressHitTestResult,
          onEnterFullscreen: onEnterFullscreen,
          onExitFullscreen: onExitFullscreen,
          onPageCommitVisible: onPageCommitVisible,
          onTitleChanged: onTitleChanged,
          onWindowFocus: onWindowFocus,
          onWindowBlur: onWindowBlur,
          onOverScrolled: onOverScrolled,
          onZoomScaleChanged: onZoomScaleChanged,
          androidOnSafeBrowsingHit: androidOnSafeBrowsingHit,
          onSafeBrowsingHit: onSafeBrowsingHit,
          androidOnPermissionRequest: androidOnPermissionRequest,
          onPermissionRequest: onPermissionRequest,
          androidOnGeolocationPermissionsShowPrompt:
              androidOnGeolocationPermissionsShowPrompt,
          onGeolocationPermissionsShowPrompt:
              onGeolocationPermissionsShowPrompt,
          androidOnGeolocationPermissionsHidePrompt:
              androidOnGeolocationPermissionsHidePrompt,
          onGeolocationPermissionsHidePrompt:
              onGeolocationPermissionsHidePrompt,
          androidShouldInterceptRequest: androidShouldInterceptRequest,
          shouldInterceptRequest: shouldInterceptRequest,
          androidOnRenderProcessGone: androidOnRenderProcessGone,
          onRenderProcessGone: onRenderProcessGone,
          androidOnRenderProcessResponsive: androidOnRenderProcessResponsive,
          onRenderProcessResponsive: onRenderProcessResponsive,
          androidOnRenderProcessUnresponsive:
              androidOnRenderProcessUnresponsive,
          onRenderProcessUnresponsive: onRenderProcessUnresponsive,
          androidOnFormResubmission: androidOnFormResubmission,
          onFormResubmission: onFormResubmission,
          androidOnScaleChanged: androidOnScaleChanged,
          androidOnReceivedIcon: androidOnReceivedIcon,
          onReceivedIcon: onReceivedIcon,
          androidOnReceivedTouchIconUrl: androidOnReceivedTouchIconUrl,
          onReceivedTouchIconUrl: onReceivedTouchIconUrl,
          androidOnJsBeforeUnload: androidOnJsBeforeUnload,
          onJsBeforeUnload: onJsBeforeUnload,
          androidOnReceivedLoginRequest: androidOnReceivedLoginRequest,
          onReceivedLoginRequest: onReceivedLoginRequest,
          onPermissionRequestCanceled: onPermissionRequestCanceled,
          onRequestFocus: onRequestFocus,
          iosOnWebContentProcessDidTerminate:
              iosOnWebContentProcessDidTerminate,
          onWebContentProcessDidTerminate: onWebContentProcessDidTerminate,
          iosOnDidReceiveServerRedirectForProvisionalNavigation:
              iosOnDidReceiveServerRedirectForProvisionalNavigation,
          onDidReceiveServerRedirectForProvisionalNavigation:
              onDidReceiveServerRedirectForProvisionalNavigation,
          iosOnNavigationResponse: iosOnNavigationResponse,
          onNavigationResponse: onNavigationResponse,
          iosShouldAllowDeprecatedTLS: iosShouldAllowDeprecatedTLS,
          shouldAllowDeprecatedTLS: shouldAllowDeprecatedTLS,
          onCameraCaptureStateChanged: onCameraCaptureStateChanged,
          onMicrophoneCaptureStateChanged: onMicrophoneCaptureStateChanged,
          onContentSizeChanged: onContentSizeChanged,
        ));

  ///Runs the headless WebView.
  ///
  ///**NOTE for Web**: it will append a new `iframe` to the body.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  Future<void> run() => platform.run();

  ///Indicates if the headless WebView is running or not.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  bool isRunning() => platform.isRunning();

  ///Set the size of the WebView in pixels.
  ///
  ///Set `-1` to match the corresponding width or height of the current device screen size.
  ///`Size(-1, -1)` will match both width and height of the current device screen size.
  ///
  ///Note that if the [HeadlessInAppWebView] is not running, this method won't have effect.
  ///
  ///**NOTE for Android**: `Size` width and height values will be converted to `int` values because they cannot have `double` values.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  Future<void> setSize(Size size) => platform.setSize(size);

  ///Gets the current size in pixels of the WebView.
  ///
  ///Note that if the [HeadlessInAppWebView] is not running, this method will return `null`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  Future<Size?> getSize() => platform.getSize();

  ///Disposes the headless WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  Future<void> dispose() => platform.dispose();
}
