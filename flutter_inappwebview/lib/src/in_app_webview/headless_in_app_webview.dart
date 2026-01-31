import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import '../webview_environment/webview_environment.dart';
import 'in_app_webview_controller.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView}
///
///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.supported_platforms}
class HeadlessInAppWebView {
  /// Constructs a [HeadlessInAppWebView].
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView}
  HeadlessInAppWebView.fromPlatformCreationParams({
    required PlatformHeadlessInAppWebViewCreationParams params,
  }) : this.fromPlatform(platform: PlatformHeadlessInAppWebView(params));

  /// Constructs a [HeadlessInAppWebView] from a specific platform implementation.
  HeadlessInAppWebView.fromPlatform({required this.platform});

  /// Implementation of [PlatformHeadlessInAppWebView] for the current platform.
  final PlatformHeadlessInAppWebView platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.id}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.id.supported_platforms}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.webViewController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.webViewController.supported_platforms}
  InAppWebViewController? get webViewController {
    final webViewControllerPlatform = platform.webViewController;
    if (webViewControllerPlatform == null) {
      return null;
    }
    return InAppWebViewController.fromPlatform(
      platform: webViewControllerPlatform,
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.supported_platforms}
  HeadlessInAppWebView({
    Size initialSize = const Size(-1, -1),
    int? windowId,
    HeadlessInAppWebView? headlessWebView,
    InAppWebViewKeepAlive? keepAlive,
    bool? preventGestureDelay,
    WebViewEnvironment? webViewEnvironment,
    @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
    void Function(InAppWebViewController controller)?
    androidOnGeolocationPermissionsHidePrompt,
    @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
    FutureOr<GeolocationPermissionShowPromptResponse?> Function(
      InAppWebViewController controller,
      String origin,
    )?
    androidOnGeolocationPermissionsShowPrompt,
    @Deprecated('Use onPermissionRequest instead')
    FutureOr<PermissionRequestResponse?> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources,
    )?
    androidOnPermissionRequest,
    @Deprecated('Use onSafeBrowsingHit instead')
    FutureOr<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      Uri url,
      SafeBrowsingThreat? threatType,
    )?
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
    void Function(InAppWebViewController controller, WebUri? url)?
    onContentLoading,
    void Function(InAppWebViewController controller, WebUri? url)?
    onDOMContentLoaded,
    void Function(InAppWebViewController controller, WebUri? url)?
    onPageCommitVisible,
    void Function(InAppWebViewController controller, String? title)?
    onTitleChanged,
    @Deprecated(
      'Use onDidReceiveServerRedirectForProvisionalNavigation instead',
    )
    void Function(InAppWebViewController controller)?
    iosOnDidReceiveServerRedirectForProvisionalNavigation,
    @Deprecated('Use onWebContentProcessDidTerminate instead')
    void Function(InAppWebViewController controller)?
    iosOnWebContentProcessDidTerminate,
    @Deprecated('Use onNavigationResponse instead')
    FutureOr<IOSNavigationResponseAction?> Function(
      InAppWebViewController controller,
      IOSWKNavigationResponse navigationResponse,
    )?
    iosOnNavigationResponse,
    @Deprecated('Use shouldAllowDeprecatedTLS instead')
    FutureOr<IOSShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge,
    )?
    iosShouldAllowDeprecatedTLS,
    FutureOr<AjaxRequestAction?> Function(
      InAppWebViewController controller,
      AjaxRequest ajaxRequest,
    )?
    onAjaxProgress,
    FutureOr<AjaxRequestAction?> Function(
      InAppWebViewController controller,
      AjaxRequest ajaxRequest,
    )?
    onAjaxReadyStateChange,
    void Function(
      InAppWebViewController controller,
      ConsoleMessage consoleMessage,
    )?
    onConsoleMessage,
    FutureOr<bool?> Function(
      InAppWebViewController controller,
      CreateWindowAction createWindowAction,
    )?
    onCreateWindow,
    void Function(InAppWebViewController controller)? onCloseWindow,
    void Function(InAppWebViewController controller)? onWindowFocus,
    void Function(InAppWebViewController controller)? onWindowBlur,
    @Deprecated('Use onReceivedIcon instead')
    void Function(InAppWebViewController controller, Uint8List icon)?
    androidOnReceivedIcon,
    @Deprecated('Use onReceivedTouchIconUrl instead')
    void Function(InAppWebViewController controller, Uri url, bool precomposed)?
    androidOnReceivedTouchIconUrl,
    @Deprecated('Use onDownloadStarting instead')
    void Function(InAppWebViewController controller, Uri url)? onDownloadStart,
    @Deprecated('Use onDownloadStarting instead')
    void Function(
      InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest,
    )?
    onDownloadStartRequest,
    FutureOr<DownloadStartResponse?> Function(
      InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest,
    )?
    onDownloadStarting,
    @Deprecated('Use FindInteractionController.onFindResultReceived instead')
    void Function(
      InAppWebViewController controller,
      int activeMatchOrdinal,
      int numberOfMatches,
      bool isDoneCounting,
    )?
    onFindResultReceived,
    FutureOr<JsAlertResponse?> Function(
      InAppWebViewController controller,
      JsAlertRequest jsAlertRequest,
    )?
    onJsAlert,
    FutureOr<JsConfirmResponse?> Function(
      InAppWebViewController controller,
      JsConfirmRequest jsConfirmRequest,
    )?
    onJsConfirm,
    FutureOr<JsPromptResponse?> Function(
      InAppWebViewController controller,
      JsPromptRequest jsPromptRequest,
    )?
    onJsPrompt,
    @Deprecated("Use onReceivedError instead")
    void Function(
      InAppWebViewController controller,
      Uri? url,
      int code,
      String message,
    )?
    onLoadError,
    void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceError error,
    )?
    onReceivedError,
    @Deprecated("Use onReceivedHttpError instead")
    void Function(
      InAppWebViewController controller,
      Uri? url,
      int statusCode,
      String description,
    )?
    onLoadHttpError,
    void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceResponse errorResponse,
    )?
    onReceivedHttpError,
    void Function(InAppWebViewController controller, LoadedResource resource)?
    onLoadResource,
    @Deprecated('Use onLoadResourceWithCustomScheme instead')
    FutureOr<CustomSchemeResponse?> Function(
      InAppWebViewController controller,
      Uri url,
    )?
    onLoadResourceCustomScheme,
    FutureOr<CustomSchemeResponse?> Function(
      InAppWebViewController controller,
      WebResourceRequest request,
    )?
    onLoadResourceWithCustomScheme,
    void Function(InAppWebViewController controller, WebUri? url)? onLoadStart,
    void Function(InAppWebViewController controller, WebUri? url)? onLoadStop,
    void Function(
      InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult,
    )?
    onLongPressHitTestResult,
    @Deprecated("Use onPrintRequest instead")
    void Function(InAppWebViewController controller, Uri? url)? onPrint,
    FutureOr<bool?> Function(
      InAppWebViewController controller,
      WebUri? url,
      PlatformPrintJobController? printJobController,
    )?
    onPrintRequest,
    void Function(InAppWebViewController controller, int progress)?
    onProgressChanged,
    FutureOr<ClientCertResponse?> Function(
      InAppWebViewController controller,
      ClientCertChallenge challenge,
    )?
    onReceivedClientCertRequest,
    FutureOr<HttpAuthResponse?> Function(
      InAppWebViewController controller,
      HttpAuthenticationChallenge challenge,
    )?
    onReceivedHttpAuthRequest,
    FutureOr<ServerTrustAuthResponse?> Function(
      InAppWebViewController controller,
      ServerTrustChallenge challenge,
    )?
    onReceivedServerTrustAuthRequest,
    void Function(InAppWebViewController controller, int x, int y)?
    onScrollChanged,
    void Function(
      InAppWebViewController controller,
      WebUri? url,
      bool? isReload,
    )?
    onUpdateVisitedHistory,
    void Function(InAppWebViewController controller)? onWebViewCreated,
    FutureOr<AjaxRequest?> Function(
      InAppWebViewController controller,
      AjaxRequest ajaxRequest,
    )?
    shouldInterceptAjaxRequest,
    FutureOr<FetchRequest?> Function(
      InAppWebViewController controller,
      FetchRequest fetchRequest,
    )?
    shouldInterceptFetchRequest,
    FutureOr<NavigationActionPolicy?> Function(
      InAppWebViewController controller,
      NavigationAction navigationAction,
    )?
    shouldOverrideUrlLoading,
    void Function(InAppWebViewController controller)? onEnterFullscreen,
    void Function(InAppWebViewController controller)? onExitFullscreen,
    void Function(
      InAppWebViewController controller,
      int x,
      int y,
      bool clampedX,
      bool clampedY,
    )?
    onOverScrolled,
    void Function(
      InAppWebViewController controller,
      double oldScale,
      double newScale,
    )?
    onZoomScaleChanged,
    @Deprecated('Use shouldInterceptRequest instead')
    FutureOr<WebResourceResponse?> Function(
      InAppWebViewController controller,
      WebResourceRequest request,
    )?
    androidShouldInterceptRequest,
    @Deprecated('Use onRenderProcessUnresponsive instead')
    FutureOr<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller,
      Uri? url,
    )?
    androidOnRenderProcessUnresponsive,
    @Deprecated('Use onRenderProcessResponsive instead')
    FutureOr<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller,
      Uri? url,
    )?
    androidOnRenderProcessResponsive,
    @Deprecated('Use onRenderProcessGone instead')
    void Function(
      InAppWebViewController controller,
      RenderProcessGoneDetail detail,
    )?
    androidOnRenderProcessGone,
    @Deprecated('Use onFormResubmission instead')
    FutureOr<FormResubmissionAction?> Function(
      InAppWebViewController controller,
      Uri? url,
    )?
    androidOnFormResubmission,
    @Deprecated('Use onZoomScaleChanged instead')
    void Function(
      InAppWebViewController controller,
      double oldScale,
      double newScale,
    )?
    androidOnScaleChanged,
    @Deprecated('Use onJsBeforeUnload instead')
    FutureOr<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest,
    )?
    androidOnJsBeforeUnload,
    @Deprecated('Use onReceivedLoginRequest instead')
    void Function(InAppWebViewController controller, LoginRequest loginRequest)?
    androidOnReceivedLoginRequest,
    void Function(InAppWebViewController controller)?
    onDidReceiveServerRedirectForProvisionalNavigation,
    FutureOr<FormResubmissionAction?> Function(
      InAppWebViewController controller,
      WebUri? url,
    )?
    onFormResubmission,
    void Function(InAppWebViewController controller)?
    onGeolocationPermissionsHidePrompt,
    FutureOr<GeolocationPermissionShowPromptResponse?> Function(
      InAppWebViewController controller,
      String origin,
    )?
    onGeolocationPermissionsShowPrompt,
    FutureOr<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest,
    )?
    onJsBeforeUnload,
    FutureOr<NavigationResponseAction?> Function(
      InAppWebViewController controller,
      NavigationResponse navigationResponse,
    )?
    onNavigationResponse,
    FutureOr<PermissionResponse?> Function(
      InAppWebViewController controller,
      PermissionRequest permissionRequest,
    )?
    onPermissionRequest,
    @Deprecated('Use onFaviconChanged instead')
    void Function(InAppWebViewController controller, Uint8List icon)?
    onReceivedIcon,
    void Function(
      InAppWebViewController controller,
      FaviconChangedRequest faviconChangedRequest,
    )?
    onFaviconChanged,
    void Function(InAppWebViewController controller, LoginRequest loginRequest)?
    onReceivedLoginRequest,
    void Function(
      InAppWebViewController controller,
      PermissionRequest permissionRequest,
    )?
    onPermissionRequestCanceled,
    void Function(InAppWebViewController controller)? onRequestFocus,
    void Function(
      InAppWebViewController controller,
      WebUri url,
      bool precomposed,
    )?
    onReceivedTouchIconUrl,
    void Function(
      InAppWebViewController controller,
      RenderProcessGoneDetail detail,
    )?
    onRenderProcessGone,
    FutureOr<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller,
      WebUri? url,
    )?
    onRenderProcessResponsive,
    FutureOr<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller,
      WebUri? url,
    )?
    onRenderProcessUnresponsive,
    FutureOr<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      WebUri url,
      SafeBrowsingThreat? threatType,
    )?
    onSafeBrowsingHit,
    void Function(InAppWebViewController controller)?
    onWebContentProcessDidTerminate,
    FutureOr<ShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge,
    )?
    shouldAllowDeprecatedTLS,
    FutureOr<WebResourceResponse?> Function(
      InAppWebViewController controller,
      WebResourceRequest request,
    )?
    shouldInterceptRequest,
    FutureOr<void> Function(
      InAppWebViewController controller,
      MediaCaptureState? oldState,
      MediaCaptureState? newState,
    )?
    onCameraCaptureStateChanged,
    FutureOr<void> Function(
      InAppWebViewController controller,
      MediaCaptureState? oldState,
      MediaCaptureState? newState,
    )?
    onMicrophoneCaptureStateChanged,
    void Function(
      InAppWebViewController controller,
      Size oldContentSize,
      Size newContentSize,
    )?
    onContentSizeChanged,
    void Function(
      InAppWebViewController controller,
      ProcessFailedDetail detail,
    )?
    onProcessFailed,
    FutureOr<NotificationReceivedResponse?> Function(
      InAppWebViewController controller,
      NotificationReceivedRequest request,
    )?
    onNotificationReceived,
    FutureOr<SaveAsUIShowingResponse?> Function(
      InAppWebViewController controller,
      SaveAsUIShowingRequest request,
    )?
    onSaveAsUIShowing,
    FutureOr<SaveFileSecurityCheckStartingResponse?> Function(
      InAppWebViewController controller,
      SaveFileSecurityCheckStartingRequest request,
    )?
    onSaveFileSecurityCheckStarting,
    FutureOr<ScreenCaptureStartingResponse?> Function(
      InAppWebViewController controller,
      ScreenCaptureStartingRequest request,
    )?
    onScreenCaptureStarting,
    void Function(
      InAppWebViewController controller,
      AcceleratorKeyPressedDetail detail,
    )?
    onAcceleratorKeyPressed,
    FutureOr<ShowFileChooserResponse?> Function(
      InAppWebViewController controller,
      ShowFileChooserRequest request,
    )?
    onShowFileChooser,
    FutureOr<LaunchingExternalUriSchemeResponse?> Function(
      InAppWebViewController controller,
      LaunchingExternalUriSchemeRequest request,
    )?
    onLaunchingExternalUriScheme,
  }) : this.fromPlatformCreationParams(
         params: PlatformHeadlessInAppWebViewCreationParams(
           controllerFromPlatform:
               (PlatformInAppWebViewController controller) =>
                   InAppWebViewController.fromPlatform(platform: controller),
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
           webViewEnvironment: webViewEnvironment?.platform,
           onWebViewCreated: onWebViewCreated != null
               ? (controller) => onWebViewCreated.call(controller)
               : null,
           onLoadStart: onLoadStart != null
               ? (controller, url) => onLoadStart.call(controller, url)
               : null,
           onLoadStop: onLoadStop != null
               ? (controller, url) => onLoadStop.call(controller, url)
               : null,
           onLoadError: onLoadError != null
               ? (controller, url, code, message) =>
                     onLoadError.call(controller, url, code, message)
               : null,
           onReceivedError: onReceivedError != null
               ? (controller, request, error) =>
                     onReceivedError.call(controller, request, error)
               : null,
           onLoadHttpError: onLoadHttpError != null
               ? (controller, url, statusCode, description) => onLoadHttpError
                     .call(controller, url, statusCode, description)
               : null,
           onReceivedHttpError: onReceivedHttpError != null
               ? (controller, request, errorResponse) => onReceivedHttpError
                     .call(controller, request, errorResponse)
               : null,
           onConsoleMessage: onConsoleMessage != null
               ? (controller, consoleMessage) =>
                     onConsoleMessage.call(controller, consoleMessage)
               : null,
           onProgressChanged: onProgressChanged != null
               ? (controller, progress) =>
                     onProgressChanged.call(controller, progress)
               : null,
           shouldOverrideUrlLoading: shouldOverrideUrlLoading != null
               ? (controller, navigationAction) =>
                     shouldOverrideUrlLoading(controller, navigationAction)
               : null,
           onLoadResource: onLoadResource != null
               ? (controller, resource) =>
                     onLoadResource.call(controller, resource)
               : null,
           onScrollChanged: onScrollChanged != null
               ? (controller, x, y) => onScrollChanged.call(controller, x, y)
               : null,
           onDownloadStart: onDownloadStart != null
               ? (controller, url) => onDownloadStart.call(controller, url)
               : null,
           onDownloadStartRequest: onDownloadStartRequest != null
               ? (controller, downloadStartRequest) => onDownloadStartRequest
                     .call(controller, downloadStartRequest)
               : null,
           onDownloadStarting: onDownloadStarting != null
               ? (controller, downloadStartRequest) =>
                     onDownloadStarting.call(controller, downloadStartRequest)
               : null,
           onLoadResourceCustomScheme: onLoadResourceCustomScheme != null
               ? (controller, url) =>
                     onLoadResourceCustomScheme.call(controller, url)
               : null,
           onLoadResourceWithCustomScheme:
               onLoadResourceWithCustomScheme != null
               ? (controller, request) =>
                     onLoadResourceWithCustomScheme.call(controller, request)
               : null,
           onCreateWindow: onCreateWindow != null
               ? (controller, createWindowAction) =>
                     onCreateWindow.call(controller, createWindowAction)
               : null,
           onCloseWindow: onCloseWindow != null
               ? (controller) => onCloseWindow.call(controller)
               : null,
           onJsAlert: onJsAlert != null
               ? (controller, jsAlertRequest) =>
                     onJsAlert.call(controller, jsAlertRequest)
               : null,
           onJsConfirm: onJsConfirm != null
               ? (controller, jsConfirmRequest) =>
                     onJsConfirm.call(controller, jsConfirmRequest)
               : null,
           onJsPrompt: onJsPrompt != null
               ? (controller, jsPromptRequest) =>
                     onJsPrompt.call(controller, jsPromptRequest)
               : null,
           onReceivedHttpAuthRequest: onReceivedHttpAuthRequest != null
               ? (controller, challenge) =>
                     onReceivedHttpAuthRequest.call(controller, challenge)
               : null,
           onReceivedServerTrustAuthRequest:
               onReceivedServerTrustAuthRequest != null
               ? (controller, challenge) => onReceivedServerTrustAuthRequest
                     .call(controller, challenge)
               : null,
           onReceivedClientCertRequest: onReceivedClientCertRequest != null
               ? (controller, challenge) =>
                     onReceivedClientCertRequest.call(controller, challenge)
               : null,
           onFindResultReceived: onFindResultReceived != null
               ? (
                   controller,
                   activeMatchOrdinal,
                   numberOfMatches,
                   isDoneCounting,
                 ) => onFindResultReceived.call(
                   controller,
                   activeMatchOrdinal,
                   numberOfMatches,
                   isDoneCounting,
                 )
               : null,
           shouldInterceptAjaxRequest: shouldInterceptAjaxRequest != null
               ? (controller, ajaxRequest) =>
                     shouldInterceptAjaxRequest.call(controller, ajaxRequest)
               : null,
           onAjaxReadyStateChange: onAjaxReadyStateChange != null
               ? (controller, ajaxRequest) =>
                     onAjaxReadyStateChange.call(controller, ajaxRequest)
               : null,
           onAjaxProgress: onAjaxProgress != null
               ? (controller, ajaxRequest) =>
                     onAjaxProgress.call(controller, ajaxRequest)
               : null,
           shouldInterceptFetchRequest: shouldInterceptFetchRequest != null
               ? (controller, fetchRequest) =>
                     shouldInterceptFetchRequest.call(controller, fetchRequest)
               : null,
           onUpdateVisitedHistory: onUpdateVisitedHistory != null
               ? (controller, url, isReload) =>
                     onUpdateVisitedHistory.call(controller, url, isReload)
               : null,
           onPrint: onPrint != null
               ? (controller, url) => onPrint.call(controller, url)
               : null,
           onPrintRequest: onPrintRequest != null
               ? (controller, url, printJobController) =>
                     onPrintRequest.call(controller, url, printJobController)
               : null,
           onLongPressHitTestResult: onLongPressHitTestResult != null
               ? (controller, hitTestResult) =>
                     onLongPressHitTestResult.call(controller, hitTestResult)
               : null,
           onEnterFullscreen: onEnterFullscreen != null
               ? (controller) => onEnterFullscreen.call(controller)
               : null,
           onExitFullscreen: onExitFullscreen != null
               ? (controller) => onExitFullscreen.call(controller)
               : null,
           onContentLoading: onContentLoading != null
               ? (controller, url) => onContentLoading.call(controller, url)
               : null,
           onDOMContentLoaded: onDOMContentLoaded != null
               ? (controller, url) => onDOMContentLoaded.call(controller, url)
               : null,
           onPageCommitVisible: onPageCommitVisible != null
               ? (controller, url) => onPageCommitVisible.call(controller, url)
               : null,
           onTitleChanged: onTitleChanged != null
               ? (controller, title) => onTitleChanged.call(controller, title)
               : null,
           onWindowFocus: onWindowFocus != null
               ? (controller) => onWindowFocus.call(controller)
               : null,
           onWindowBlur: onWindowBlur != null
               ? (controller) => onWindowBlur.call(controller)
               : null,
           onOverScrolled: onOverScrolled != null
               ? (controller, x, y, clampedX, clampedY) =>
                     onOverScrolled.call(controller, x, y, clampedX, clampedY)
               : null,
           onZoomScaleChanged: onZoomScaleChanged != null
               ? (controller, oldScale, newScale) =>
                     onZoomScaleChanged.call(controller, oldScale, newScale)
               : null,
           androidOnSafeBrowsingHit: androidOnSafeBrowsingHit != null
               ? (controller, url, threatType) =>
                     androidOnSafeBrowsingHit.call(controller, url, threatType)
               : null,
           onSafeBrowsingHit: onSafeBrowsingHit != null
               ? (controller, url, threatType) =>
                     onSafeBrowsingHit.call(controller, url, threatType)
               : null,
           androidOnPermissionRequest: androidOnPermissionRequest != null
               ? (controller, origin, resources) => androidOnPermissionRequest
                     .call(controller, origin, resources)
               : null,
           onPermissionRequest: onPermissionRequest != null
               ? (controller, permissionRequest) =>
                     onPermissionRequest.call(controller, permissionRequest)
               : null,
           androidOnGeolocationPermissionsShowPrompt:
               androidOnGeolocationPermissionsShowPrompt != null
               ? (controller, origin) =>
                     androidOnGeolocationPermissionsShowPrompt.call(
                       controller,
                       origin,
                     )
               : null,
           onGeolocationPermissionsShowPrompt:
               onGeolocationPermissionsShowPrompt != null
               ? (controller, origin) =>
                     onGeolocationPermissionsShowPrompt.call(controller, origin)
               : null,
           androidOnGeolocationPermissionsHidePrompt:
               androidOnGeolocationPermissionsHidePrompt != null
               ? (controller) =>
                     androidOnGeolocationPermissionsHidePrompt.call(controller)
               : null,
           onGeolocationPermissionsHidePrompt:
               onGeolocationPermissionsHidePrompt != null
               ? (controller) =>
                     onGeolocationPermissionsHidePrompt.call(controller)
               : null,
           androidShouldInterceptRequest: androidShouldInterceptRequest != null
               ? (controller, request) =>
                     androidShouldInterceptRequest.call(controller, request)
               : null,
           shouldInterceptRequest: shouldInterceptRequest != null
               ? (controller, request) =>
                     shouldInterceptRequest.call(controller, request)
               : null,
           androidOnRenderProcessGone: androidOnRenderProcessGone != null
               ? (controller, detail) =>
                     androidOnRenderProcessGone.call(controller, detail)
               : null,
           onRenderProcessGone: onRenderProcessGone != null
               ? (controller, detail) =>
                     onRenderProcessGone.call(controller, detail)
               : null,
           androidOnRenderProcessResponsive:
               androidOnRenderProcessResponsive != null
               ? (controller, url) =>
                     androidOnRenderProcessResponsive.call(controller, url)
               : null,
           onRenderProcessResponsive: onRenderProcessResponsive != null
               ? (controller, url) =>
                     onRenderProcessResponsive.call(controller, url)
               : null,
           androidOnRenderProcessUnresponsive:
               androidOnRenderProcessUnresponsive != null
               ? (controller, url) =>
                     androidOnRenderProcessUnresponsive.call(controller, url)
               : null,
           onRenderProcessUnresponsive: onRenderProcessUnresponsive != null
               ? (controller, url) =>
                     onRenderProcessUnresponsive.call(controller, url)
               : null,
           androidOnFormResubmission: androidOnFormResubmission != null
               ? (controller, url) =>
                     androidOnFormResubmission.call(controller, url)
               : null,
           onFormResubmission: onFormResubmission != null
               ? (controller, url) => onFormResubmission.call(controller, url)
               : null,
           androidOnScaleChanged: androidOnScaleChanged != null
               ? (controller, oldScale, newScale) =>
                     androidOnScaleChanged.call(controller, oldScale, newScale)
               : null,
           androidOnReceivedIcon: androidOnReceivedIcon != null
               ? (controller, icon) =>
                     androidOnReceivedIcon.call(controller, icon)
               : null,
           onReceivedIcon: onReceivedIcon != null
               ? (controller, icon) => onReceivedIcon.call(controller, icon)
               : null,
           onFaviconChanged: onFaviconChanged != null
               ? (controller, request) =>
                     onFaviconChanged.call(controller, request)
               : null,
           androidOnReceivedTouchIconUrl: androidOnReceivedTouchIconUrl != null
               ? (controller, url, precomposed) => androidOnReceivedTouchIconUrl
                     .call(controller, url, precomposed)
               : null,
           onReceivedTouchIconUrl: onReceivedTouchIconUrl != null
               ? (controller, url, precomposed) =>
                     onReceivedTouchIconUrl.call(controller, url, precomposed)
               : null,
           androidOnJsBeforeUnload: androidOnJsBeforeUnload != null
               ? (controller, jsBeforeUnloadRequest) => androidOnJsBeforeUnload
                     .call(controller, jsBeforeUnloadRequest)
               : null,
           onJsBeforeUnload: onJsBeforeUnload != null
               ? (controller, jsBeforeUnloadRequest) =>
                     onJsBeforeUnload.call(controller, jsBeforeUnloadRequest)
               : null,
           androidOnReceivedLoginRequest: androidOnReceivedLoginRequest != null
               ? (controller, loginRequest) => androidOnReceivedLoginRequest
                     .call(controller, loginRequest)
               : null,
           onReceivedLoginRequest: onReceivedLoginRequest != null
               ? (controller, loginRequest) =>
                     onReceivedLoginRequest.call(controller, loginRequest)
               : null,
           onPermissionRequestCanceled: onPermissionRequestCanceled != null
               ? (controller, permissionRequest) => onPermissionRequestCanceled
                     .call(controller, permissionRequest)
               : null,
           onRequestFocus: onRequestFocus != null
               ? (controller) => onRequestFocus.call(controller)
               : null,
           iosOnWebContentProcessDidTerminate:
               iosOnWebContentProcessDidTerminate != null
               ? (controller) =>
                     iosOnWebContentProcessDidTerminate.call(controller)
               : null,
           onWebContentProcessDidTerminate:
               onWebContentProcessDidTerminate != null
               ? (controller) =>
                     onWebContentProcessDidTerminate.call(controller)
               : null,
           iosOnDidReceiveServerRedirectForProvisionalNavigation:
               iosOnDidReceiveServerRedirectForProvisionalNavigation != null
               ? (controller) =>
                     iosOnDidReceiveServerRedirectForProvisionalNavigation.call(
                       controller,
                     )
               : null,
           onDidReceiveServerRedirectForProvisionalNavigation:
               onDidReceiveServerRedirectForProvisionalNavigation != null
               ? (controller) =>
                     onDidReceiveServerRedirectForProvisionalNavigation.call(
                       controller,
                     )
               : null,
           iosOnNavigationResponse: iosOnNavigationResponse != null
               ? (controller, navigationResponse) => iosOnNavigationResponse
                     .call(controller, navigationResponse)
               : null,
           onNavigationResponse: onNavigationResponse != null
               ? (controller, navigationResponse) =>
                     onNavigationResponse.call(controller, navigationResponse)
               : null,
           iosShouldAllowDeprecatedTLS: iosShouldAllowDeprecatedTLS != null
               ? (controller, challenge) =>
                     iosShouldAllowDeprecatedTLS.call(controller, challenge)
               : null,
           shouldAllowDeprecatedTLS: shouldAllowDeprecatedTLS != null
               ? (controller, challenge) =>
                     shouldAllowDeprecatedTLS.call(controller, challenge)
               : null,
           onCameraCaptureStateChanged: onCameraCaptureStateChanged != null
               ? (controller, oldState, newState) => onCameraCaptureStateChanged
                     .call(controller, oldState, newState)
               : null,
           onMicrophoneCaptureStateChanged:
               onMicrophoneCaptureStateChanged != null
               ? (controller, oldState, newState) =>
                     onMicrophoneCaptureStateChanged.call(
                       controller,
                       oldState,
                       newState,
                     )
               : null,
           onContentSizeChanged: onContentSizeChanged != null
               ? (controller, oldContentSize, newContentSize) =>
                     onContentSizeChanged.call(
                       controller,
                       oldContentSize,
                       newContentSize,
                     )
               : null,
           onProcessFailed: onProcessFailed != null
               ? (controller, detail) =>
                     onProcessFailed.call(controller, detail)
               : null,
           onNotificationReceived: onNotificationReceived != null
               ? (controller, request) =>
                     onNotificationReceived.call(controller, request)
               : null,
           onSaveAsUIShowing: onSaveAsUIShowing != null
               ? (controller, request) =>
                     onSaveAsUIShowing.call(controller, request)
               : null,
           onSaveFileSecurityCheckStarting:
               onSaveFileSecurityCheckStarting != null
               ? (controller, request) =>
                     onSaveFileSecurityCheckStarting.call(controller, request)
               : null,
           onScreenCaptureStarting: onScreenCaptureStarting != null
               ? (controller, request) =>
                     onScreenCaptureStarting.call(controller, request)
               : null,
           onAcceleratorKeyPressed: onAcceleratorKeyPressed != null
               ? (controller, detail) =>
                     onAcceleratorKeyPressed.call(controller, detail)
               : null,
           onShowFileChooser: onShowFileChooser != null
               ? (controller, request) =>
                     onShowFileChooser.call(controller, request)
               : null,
           onLaunchingExternalUriScheme: onLaunchingExternalUriScheme != null
               ? (controller, request) =>
                     onLaunchingExternalUriScheme.call(controller, request)
               : null,
         ),
       );

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.run}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.run.supported_platforms}
  Future<void> run() => platform.run();

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.isRunning}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.isRunning.supported_platforms}
  bool isRunning() => platform.isRunning();

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.setSize}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.setSize.supported_platforms}
  Future<void> setSize(Size size) => platform.setSize(size);

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.getSize}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.getSize.supported_platforms}
  Future<Size?> getSize() => platform.getSize();

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.dispose.supported_platforms}
  Future<void> dispose() => platform.dispose();

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebViewCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformHeadlessInAppWebView.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebViewCreationParams.isPropertySupported}
  static bool isPropertySupported(
    PlatformHeadlessInAppWebViewCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformHeadlessInAppWebView.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebViewCreationParams.isMethodSupported}
  static bool isMethodSupported(
    PlatformHeadlessInAppWebViewMethod method, {
    TargetPlatform? platform,
  }) => PlatformHeadlessInAppWebView.static().isMethodSupported(
    method,
    platform: platform,
  );
}
