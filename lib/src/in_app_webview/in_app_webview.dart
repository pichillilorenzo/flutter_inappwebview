import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'headless_in_app_webview.dart';
import '../find_interaction/find_interaction_controller.dart';
import '../pull_to_refresh/main.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';

///{@template flutter_inappwebview.InAppWebView}
///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- Web
///{@endtemplate}
class InAppWebView extends StatefulWidget {
  /// Constructs a [InAppWebView].
  ///
  /// See [InAppWebView.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  InAppWebView.fromPlatformCreationParams({
    Key? key,
    required PlatformInAppWebViewWidgetCreationParams params,
  }) : this.fromPlatform(
            key: key, platform: PlatformInAppWebViewWidget(params));

  /// Constructs a [InAppWebView] from a specific platform implementation.
  InAppWebView.fromPlatform({super.key, required this.platform});

  /// Implementation of [PlatformInAppWebView] for the current platform.
  final PlatformInAppWebViewWidget platform;

  ///{@macro flutter_inappwebview.InAppWebView}
  InAppWebView({
    Key? key,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
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
    Future<SafeBrowsingResponse?> Function(PlatformInAppWebViewController controller,
            Uri url, SafeBrowsingThreat? threatType)?
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
    void Function(
            PlatformInAppWebViewController controller, ConsoleMessage consoleMessage)?
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
    void Function(PlatformInAppWebViewController controller, Uri url, bool precomposed)?
        androidOnReceivedTouchIconUrl,
    @Deprecated('Use onDownloadStartRequest instead')
    void Function(PlatformInAppWebViewController controller, Uri url)? onDownloadStart,
    void Function(PlatformInAppWebViewController controller,
            DownloadStartRequest downloadStartRequest)?
        onDownloadStartRequest,
    @Deprecated('Use FindInteractionController.onFindResultReceived instead')
    void Function(PlatformInAppWebViewController controller, int activeMatchOrdinal,
            int numberOfMatches, bool isDoneCounting)?
        onFindResultReceived,
    Future<JsAlertResponse?> Function(
            PlatformInAppWebViewController controller, JsAlertRequest jsAlertRequest)?
        onJsAlert,
    Future<JsConfirmResponse?> Function(PlatformInAppWebViewController controller,
            JsConfirmRequest jsConfirmRequest)?
        onJsConfirm,
    Future<JsPromptResponse?> Function(
            PlatformInAppWebViewController controller, JsPromptRequest jsPromptRequest)?
        onJsPrompt,
    @Deprecated("Use onReceivedError instead")
    void Function(PlatformInAppWebViewController controller, Uri? url, int code,
            String message)?
        onLoadError,
    void Function(PlatformInAppWebViewController controller, WebResourceRequest request,
            WebResourceError error)?
        onReceivedError,
    @Deprecated("Use onReceivedHttpError instead")
    void Function(PlatformInAppWebViewController controller, Uri? url, int statusCode,
            String description)?
        onLoadHttpError,
    void Function(PlatformInAppWebViewController controller, WebResourceRequest request,
            WebResourceResponse errorResponse)?
        onReceivedHttpError,
    void Function(PlatformInAppWebViewController controller, LoadedResource resource)?
        onLoadResource,
    @Deprecated('Use onLoadResourceWithCustomScheme instead')
    Future<CustomSchemeResponse?> Function(
            PlatformInAppWebViewController controller, Uri url)?
        onLoadResourceCustomScheme,
    Future<CustomSchemeResponse?> Function(
            PlatformInAppWebViewController controller, WebResourceRequest request)?
        onLoadResourceWithCustomScheme,
    void Function(PlatformInAppWebViewController controller, WebUri? url)? onLoadStart,
    void Function(PlatformInAppWebViewController controller, WebUri? url)? onLoadStop,
    void Function(PlatformInAppWebViewController controller,
            InAppWebViewHitTestResult hitTestResult)?
        onLongPressHitTestResult,
    @Deprecated("Use onPrintRequest instead")
    void Function(PlatformInAppWebViewController controller, Uri? url)? onPrint,
    Future<bool?> Function(PlatformInAppWebViewController controller, WebUri? url,
        PlatformPrintJobController? printJobController)?
        onPrintRequest,
    void Function(PlatformInAppWebViewController controller, int progress)?
        onProgressChanged,
    Future<ClientCertResponse?> Function(PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        onReceivedClientCertRequest,
    Future<HttpAuthResponse?> Function(PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        onReceivedHttpAuthRequest,
    Future<ServerTrustAuthResponse?> Function(PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        onReceivedServerTrustAuthRequest,
    void Function(PlatformInAppWebViewController controller, int x, int y)?
        onScrollChanged,
    void Function(
            PlatformInAppWebViewController controller, WebUri? url, bool? isReload)?
        onUpdateVisitedHistory,
    void Function(PlatformInAppWebViewController controller)? onWebViewCreated,
    Future<AjaxRequest?> Function(
            PlatformInAppWebViewController controller, AjaxRequest ajaxRequest)?
        shouldInterceptAjaxRequest,
    Future<FetchRequest?> Function(
            PlatformInAppWebViewController controller, FetchRequest fetchRequest)?
        shouldInterceptFetchRequest,
    Future<NavigationActionPolicy?> Function(PlatformInAppWebViewController controller,
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
            PlatformInAppWebViewController controller, WebResourceRequest request)?
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
    void Function(
            PlatformInAppWebViewController controller, RenderProcessGoneDetail detail)?
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
    Future<JsBeforeUnloadResponse?> Function(PlatformInAppWebViewController controller,
            JsBeforeUnloadRequest jsBeforeUnloadRequest)?
        androidOnJsBeforeUnload,
    @Deprecated('Use onReceivedLoginRequest instead')
    void Function(PlatformInAppWebViewController controller, LoginRequest loginRequest)?
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
    Future<JsBeforeUnloadResponse?> Function(PlatformInAppWebViewController controller,
            JsBeforeUnloadRequest jsBeforeUnloadRequest)?
        onJsBeforeUnload,
    Future<NavigationResponseAction?> Function(
            PlatformInAppWebViewController controller,
            NavigationResponse navigationResponse)?
        onNavigationResponse,
    Future<PermissionResponse?> Function(PlatformInAppWebViewController controller,
            PermissionRequest permissionRequest)?
        onPermissionRequest,
    void Function(PlatformInAppWebViewController controller, Uint8List icon)?
        onReceivedIcon,
    void Function(PlatformInAppWebViewController controller, LoginRequest loginRequest)?
        onReceivedLoginRequest,
    void Function(PlatformInAppWebViewController controller,
            PermissionRequest permissionRequest)?
        onPermissionRequestCanceled,
    void Function(PlatformInAppWebViewController controller)? onRequestFocus,
    void Function(
            PlatformInAppWebViewController controller, WebUri url, bool precomposed)?
        onReceivedTouchIconUrl,
    void Function(
            PlatformInAppWebViewController controller, RenderProcessGoneDetail detail)?
        onRenderProcessGone,
    Future<WebViewRenderProcessAction?> Function(
            PlatformInAppWebViewController controller, WebUri? url)?
        onRenderProcessResponsive,
    Future<WebViewRenderProcessAction?> Function(
            PlatformInAppWebViewController controller, WebUri? url)?
        onRenderProcessUnresponsive,
    Future<SafeBrowsingResponse?> Function(PlatformInAppWebViewController controller,
            WebUri url, SafeBrowsingThreat? threatType)?
        onSafeBrowsingHit,
    void Function(PlatformInAppWebViewController controller)?
        onWebContentProcessDidTerminate,
    Future<ShouldAllowDeprecatedTLSAction?> Function(
            PlatformInAppWebViewController controller,
            URLAuthenticationChallenge challenge)?
        shouldAllowDeprecatedTLS,
    Future<WebResourceResponse?> Function(
            PlatformInAppWebViewController controller, WebResourceRequest request)?
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
    void Function(PlatformInAppWebViewController controller, Size oldContentSize,
            Size newContentSize)?
        onContentSizeChanged,
  }) : this.fromPlatformCreationParams(
            key: key,
            params: PlatformInAppWebViewWidgetCreationParams(
              windowId: windowId,
              keepAlive: keepAlive,
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
              onReceivedServerTrustAuthRequest:
                  onReceivedServerTrustAuthRequest,
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
              androidOnRenderProcessResponsive:
                  androidOnRenderProcessResponsive,
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
              gestureRecognizers: gestureRecognizers,
              headlessWebView: headlessWebView?.platform,
              preventGestureDelay: preventGestureDelay,
            ));

  @override
  _InAppWebViewState createState() => _InAppWebViewState();
}

class _InAppWebViewState extends State<InAppWebView> {
  @override
  Widget build(BuildContext context) {
    return widget.platform.build(context);
  }

  @override
  void dispose() {
    widget.platform.dispose();
    super.dispose();
  }
}
