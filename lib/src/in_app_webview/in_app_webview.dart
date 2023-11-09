import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'headless_in_app_webview.dart';
import '../util.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../web/web_platform_manager.dart';

import '../context_menu/context_menu.dart';
import '../types/main.dart';
import '../print_job/main.dart';

import '../web_uri.dart';
import 'webview.dart';
import 'in_app_webview_controller.dart';
import 'in_app_webview_settings.dart';
import '../pull_to_refresh/main.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import 'in_app_webview_keep_alive.dart';

///{@template flutter_inappwebview.InAppWebView}
///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- Web
///{@endtemplate}
class InAppWebView extends StatefulWidget implements WebView {
  /// `gestureRecognizers` specifies which gestures should be consumed by the WebView.
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  /// When `gestureRecognizers` is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  ///{@macro flutter_inappwebview.WebView.windowId}
  @override
  final int? windowId;

  ///The [HeadlessInAppWebView] to use to initialize this widget.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  final HeadlessInAppWebView? headlessWebView;

  ///Used to keep alive this WebView.
  ///Remember to dispose the [InAppWebViewKeepAlive] instance
  ///using [InAppWebViewController.disposeKeepAlive].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  final InAppWebViewKeepAlive? keepAlive;

  final bool? preventGestureDelay;

  ///{@macro flutter_inappwebview.InAppWebView}
  const InAppWebView({
    Key? key,
    this.windowId,
    this.keepAlive,
    this.initialUrlRequest,
    this.initialFile,
    this.initialData,
    @Deprecated('Use initialSettings instead') this.initialOptions,
    this.initialSettings,
    this.initialUserScripts,
    this.pullToRefreshController,
    this.findInteractionController,
    this.contextMenu,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    @Deprecated("Use onReceivedError instead") this.onLoadError,
    this.onReceivedError,
    @Deprecated("Use onReceivedHttpError instead") this.onLoadHttpError,
    this.onReceivedHttpError,
    this.onConsoleMessage,
    this.onProgressChanged,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    @Deprecated('Use onDownloadStartRequest instead') this.onDownloadStart,
    this.onDownloadStartRequest,
    @Deprecated('Use onLoadResourceWithCustomScheme instead')
        this.onLoadResourceCustomScheme,
    this.onLoadResourceWithCustomScheme,
    this.onCreateWindow,
    this.onCloseWindow,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.onReceivedHttpAuthRequest,
    this.onReceivedServerTrustAuthRequest,
    this.onReceivedClientCertRequest,
    @Deprecated('Use FindInteractionController.onFindResultReceived instead')
        this.onFindResultReceived,
    this.shouldInterceptAjaxRequest,
    this.onAjaxReadyStateChange,
    this.onAjaxProgress,
    this.shouldInterceptFetchRequest,
    this.onUpdateVisitedHistory,
    @Deprecated("Use onPrintRequest instead") this.onPrint,
    this.onPrintRequest,
    this.onLongPressHitTestResult,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onPageCommitVisible,
    this.onTitleChanged,
    this.onWindowFocus,
    this.onWindowBlur,
    this.onOverScrolled,
    this.onZoomScaleChanged,
    @Deprecated('Use onSafeBrowsingHit instead') this.androidOnSafeBrowsingHit,
    this.onSafeBrowsingHit,
    @Deprecated('Use onPermissionRequest instead')
        this.androidOnPermissionRequest,
    this.onPermissionRequest,
    @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
        this.androidOnGeolocationPermissionsShowPrompt,
    this.onGeolocationPermissionsShowPrompt,
    @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
        this.androidOnGeolocationPermissionsHidePrompt,
    this.onGeolocationPermissionsHidePrompt,
    @Deprecated('Use shouldInterceptRequest instead')
        this.androidShouldInterceptRequest,
    this.shouldInterceptRequest,
    @Deprecated('Use onRenderProcessGone instead')
        this.androidOnRenderProcessGone,
    this.onRenderProcessGone,
    @Deprecated('Use onRenderProcessResponsive instead')
        this.androidOnRenderProcessResponsive,
    this.onRenderProcessResponsive,
    @Deprecated('Use onRenderProcessUnresponsive instead')
        this.androidOnRenderProcessUnresponsive,
    this.onRenderProcessUnresponsive,
    @Deprecated('Use onFormResubmission instead')
        this.androidOnFormResubmission,
    this.onFormResubmission,
    @Deprecated('Use onZoomScaleChanged instead') this.androidOnScaleChanged,
    @Deprecated('Use onReceivedIcon instead') this.androidOnReceivedIcon,
    this.onReceivedIcon,
    @Deprecated('Use onReceivedTouchIconUrl instead')
        this.androidOnReceivedTouchIconUrl,
    this.onReceivedTouchIconUrl,
    @Deprecated('Use onJsBeforeUnload instead') this.androidOnJsBeforeUnload,
    this.onJsBeforeUnload,
    @Deprecated('Use onReceivedLoginRequest instead')
        this.androidOnReceivedLoginRequest,
    this.onReceivedLoginRequest,
    this.onPermissionRequestCanceled,
    this.onRequestFocus,
    @Deprecated('Use onWebContentProcessDidTerminate instead')
        this.iosOnWebContentProcessDidTerminate,
    this.onWebContentProcessDidTerminate,
    @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
        this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
    this.onDidReceiveServerRedirectForProvisionalNavigation,
    @Deprecated('Use onNavigationResponse instead')
        this.iosOnNavigationResponse,
    this.onNavigationResponse,
    @Deprecated('Use shouldAllowDeprecatedTLS instead')
        this.iosShouldAllowDeprecatedTLS,
    this.shouldAllowDeprecatedTLS,
    this.onCameraCaptureStateChanged,
    this.onMicrophoneCaptureStateChanged,
    this.onContentSizeChanged,
    this.gestureRecognizers,
    this.headlessWebView,
    this.preventGestureDelay,
  }) : super(key: key);

  @override
  _InAppWebViewState createState() => _InAppWebViewState();

  ///Use [onGeolocationPermissionsHidePrompt] instead.
  @override
  @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
  final void Function(InAppWebViewController controller)?
      androidOnGeolocationPermissionsHidePrompt;

  ///Use [onGeolocationPermissionsShowPrompt] instead.
  @override
  @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
  final Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      androidOnGeolocationPermissionsShowPrompt;

  ///Use [onPermissionRequest] instead.
  @override
  @Deprecated('Use onPermissionRequest instead')
  final Future<PermissionRequestResponse?> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources)? androidOnPermissionRequest;

  ///Use [onSafeBrowsingHit] instead.
  @override
  @Deprecated('Use onSafeBrowsingHit instead')
  final Future<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      Uri url,
      SafeBrowsingThreat? threatType)? androidOnSafeBrowsingHit;

  ///{@macro flutter_inappwebview.WebView.initialData}
  @override
  final InAppWebViewInitialData? initialData;

  ///{@macro flutter_inappwebview.WebView.initialFile}
  @override
  final String? initialFile;

  ///Use [initialSettings] instead.
  @override
  @Deprecated('Use initialSettings instead')
  final InAppWebViewGroupOptions? initialOptions;

  ///{@macro flutter_inappwebview.WebView.initialSettings}
  @override
  final InAppWebViewSettings? initialSettings;

  ///{@macro flutter_inappwebview.WebView.initialUrlRequest}
  @override
  final URLRequest? initialUrlRequest;

  ///{@macro flutter_inappwebview.WebView.initialUserScripts}
  @override
  final UnmodifiableListView<UserScript>? initialUserScripts;

  ///{@macro flutter_inappwebview.WebView.pullToRefreshController}
  @override
  final PullToRefreshController? pullToRefreshController;

  ///{@macro flutter_inappwebview.WebView.findInteractionController}
  @override
  final FindInteractionController? findInteractionController;

  ///{@macro flutter_inappwebview.WebView.contextMenu}
  @override
  final ContextMenu? contextMenu;

  ///{@macro flutter_inappwebview.WebView.onPageCommitVisible}
  @override
  final void Function(InAppWebViewController controller, WebUri? url)?
      onPageCommitVisible;

  ///{@macro flutter_inappwebview.WebView.onTitleChanged}
  @override
  final void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;

  ///Use [onDidReceiveServerRedirectForProvisionalNavigation] instead.
  @override
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  final void Function(InAppWebViewController controller)?
      iosOnDidReceiveServerRedirectForProvisionalNavigation;

  ///Use [onWebContentProcessDidTerminate] instead.
  @override
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  final void Function(InAppWebViewController controller)?
      iosOnWebContentProcessDidTerminate;

  ///Use [onNavigationResponse] instead.
  @override
  @Deprecated('Use onNavigationResponse instead')
  final Future<IOSNavigationResponseAction?> Function(
      InAppWebViewController controller,
      IOSWKNavigationResponse navigationResponse)? iosOnNavigationResponse;

  ///Use [shouldAllowDeprecatedTLS] instead.
  @override
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  final Future<IOSShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? iosShouldAllowDeprecatedTLS;

  ///{@macro flutter_inappwebview.WebView.onAjaxProgress}
  @override
  final Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxProgress;

  ///{@macro flutter_inappwebview.WebView.onAjaxReadyStateChange}
  @override
  final Future<AjaxRequestAction?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxReadyStateChange;

  ///{@macro flutter_inappwebview.WebView.onConsoleMessage}
  @override
  final void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;

  ///{@macro flutter_inappwebview.WebView.onCreateWindow}
  @override
  final Future<bool?> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction)? onCreateWindow;

  ///{@macro flutter_inappwebview.WebView.onCloseWindow}
  @override
  final void Function(InAppWebViewController controller)? onCloseWindow;

  ///{@macro flutter_inappwebview.WebView.onWindowFocus}
  @override
  final void Function(InAppWebViewController controller)? onWindowFocus;

  ///{@macro flutter_inappwebview.WebView.onWindowBlur}
  @override
  final void Function(InAppWebViewController controller)? onWindowBlur;

  ///Use [onReceivedIcon] instead
  @override
  @Deprecated('Use onReceivedIcon instead')
  final void Function(InAppWebViewController controller, Uint8List icon)?
      androidOnReceivedIcon;

  ///Use [onReceivedTouchIconUrl] instead
  @override
  @Deprecated('Use onReceivedTouchIconUrl instead')
  final void Function(
          InAppWebViewController controller, Uri url, bool precomposed)?
      androidOnReceivedTouchIconUrl;

  ///Use [onDownloadStartRequest] instead
  @Deprecated('Use onDownloadStartRequest instead')
  @override
  final void Function(InAppWebViewController controller, Uri url)?
      onDownloadStart;

  ///{@macro flutter_inappwebview.WebView.onDownloadStartRequest}
  @override
  final void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  @override
  final void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting)? onFindResultReceived;

  ///{@macro flutter_inappwebview.WebView.onJsAlert}
  @override
  final Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;

  ///{@macro flutter_inappwebview.WebView.onJsConfirm}
  @override
  final Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;

  ///{@macro flutter_inappwebview.WebView.onJsPrompt}
  @override
  final Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  @override
  final void Function(InAppWebViewController controller, Uri? url, int code,
      String message)? onLoadError;

  ///{@macro flutter_inappwebview.WebView.onReceivedError}
  @override
  final void Function(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error)? onReceivedError;

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  @override
  final void Function(InAppWebViewController controller, Uri? url,
      int statusCode, String description)? onLoadHttpError;

  ///{@macro flutter_inappwebview.WebView.onReceivedHttpError}
  @override
  final void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceResponse errorResponse)? onReceivedHttpError;

  ///{@macro flutter_inappwebview.WebView.onLoadResource}
  @override
  final void Function(
          InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  @override
  final Future<CustomSchemeResponse?> Function(
      InAppWebViewController controller, Uri url)? onLoadResourceCustomScheme;

  ///{@macro flutter_inappwebview.WebView.onLoadResourceWithCustomScheme}
  @override
  final Future<CustomSchemeResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      onLoadResourceWithCustomScheme;

  ///{@macro flutter_inappwebview.WebView.onLoadStart}
  @override
  final void Function(InAppWebViewController controller, WebUri? url)?
      onLoadStart;

  ///{@macro flutter_inappwebview.WebView.onLoadStop}
  @override
  final void Function(InAppWebViewController controller, WebUri? url)?
      onLoadStop;

  ///{@macro flutter_inappwebview.WebView.onLongPressHitTestResult}
  @override
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  @override
  final void Function(InAppWebViewController controller, Uri? url)? onPrint;

  ///{@macro flutter_inappwebview.WebView.onPrintRequest}
  @override
  final Future<bool?> Function(InAppWebViewController controller, WebUri? url,
      PrintJobController? printJobController)? onPrintRequest;

  ///{@macro flutter_inappwebview.WebView.onProgressChanged}
  @override
  final void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;

  ///{@macro flutter_inappwebview.WebView.onReceivedClientCertRequest}
  @override
  final Future<ClientCertResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedClientCertRequest;

  ///{@macro flutter_inappwebview.WebView.onReceivedHttpAuthRequest}
  @override
  final Future<HttpAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedHttpAuthRequest;

  ///{@macro flutter_inappwebview.WebView.onReceivedServerTrustAuthRequest}
  @override
  final Future<ServerTrustAuthResponse?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedServerTrustAuthRequest;

  ///{@macro flutter_inappwebview.WebView.onScrollChanged}
  @override
  final void Function(InAppWebViewController controller, int x, int y)?
      onScrollChanged;

  ///{@macro flutter_inappwebview.WebView.onUpdateVisitedHistory}
  @override
  final void Function(
          InAppWebViewController controller, WebUri? url, bool? isReload)?
      onUpdateVisitedHistory;

  ///{@macro flutter_inappwebview.WebView.onWebViewCreated}
  @override
  final void Function(InAppWebViewController controller)? onWebViewCreated;

  ///{@macro flutter_inappwebview.WebView.shouldInterceptAjaxRequest}
  @override
  final Future<AjaxRequest?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;

  ///{@macro flutter_inappwebview.WebView.shouldInterceptFetchRequest}
  @override
  final Future<FetchRequest?> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)?
      shouldInterceptFetchRequest;

  ///{@macro flutter_inappwebview.WebView.shouldOverrideUrlLoading}
  @override
  final Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;

  ///{@macro flutter_inappwebview.WebView.onEnterFullscreen}
  @override
  final void Function(InAppWebViewController controller)? onEnterFullscreen;

  ///{@macro flutter_inappwebview.WebView.onExitFullscreen}
  @override
  final void Function(InAppWebViewController controller)? onExitFullscreen;

  ///{@macro flutter_inappwebview.WebView.onOverScrolled}
  @override
  final void Function(InAppWebViewController controller, int x, int y,
      bool clampedX, bool clampedY)? onOverScrolled;

  ///{@macro flutter_inappwebview.WebView.onZoomScaleChanged}
  @override
  final void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      onZoomScaleChanged;

  ///Use [shouldInterceptRequest] instead.
  @override
  @Deprecated('Use shouldInterceptRequest instead')
  final Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      androidShouldInterceptRequest;

  ///Use [onRenderProcessUnresponsive] instead.
  @override
  @Deprecated('Use onRenderProcessUnresponsive instead')
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessUnresponsive;

  ///Use [onRenderProcessResponsive] instead.
  @override
  @Deprecated('Use onRenderProcessResponsive instead')
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessResponsive;

  ///Use [onRenderProcessGone] instead.
  @override
  @Deprecated('Use onRenderProcessGone instead')
  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      androidOnRenderProcessGone;

  ///Use [onFormResubmission] instead.
  @override
  @Deprecated('Use onFormResubmission instead')
  final Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? androidOnFormResubmission;

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use onZoomScaleChanged instead')
  @override
  final void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      androidOnScaleChanged;

  ///Use [onJsBeforeUnload] instead.
  @override
  @Deprecated('Use onJsBeforeUnload instead')
  final Future<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? androidOnJsBeforeUnload;

  ///Use [onReceivedLoginRequest] instead.
  @override
  @Deprecated('Use onReceivedLoginRequest instead')
  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)?
      androidOnReceivedLoginRequest;

  ///{@macro flutter_inappwebview.WebView.onDidReceiveServerRedirectForProvisionalNavigation}
  @override
  final void Function(InAppWebViewController controller)?
      onDidReceiveServerRedirectForProvisionalNavigation;

  ///{@macro flutter_inappwebview.WebView.onFormResubmission}
  @override
  final Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, WebUri? url)? onFormResubmission;

  ///{@macro flutter_inappwebview.WebView.onGeolocationPermissionsHidePrompt}
  @override
  final void Function(InAppWebViewController controller)?
      onGeolocationPermissionsHidePrompt;

  ///{@macro flutter_inappwebview.WebView.onGeolocationPermissionsShowPrompt}
  @override
  final Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      onGeolocationPermissionsShowPrompt;

  ///{@macro flutter_inappwebview.WebView.onJsBeforeUnload}
  @override
  final Future<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? onJsBeforeUnload;

  ///{@macro flutter_inappwebview.WebView.onNavigationResponse}
  @override
  final Future<NavigationResponseAction?> Function(
      InAppWebViewController controller,
      NavigationResponse navigationResponse)? onNavigationResponse;

  ///{@macro flutter_inappwebview.WebView.onPermissionRequest}
  @override
  final Future<PermissionResponse?> Function(InAppWebViewController controller,
      PermissionRequest permissionRequest)? onPermissionRequest;

  ///{@macro flutter_inappwebview.WebView.onReceivedIcon}
  @override
  final void Function(InAppWebViewController controller, Uint8List icon)?
      onReceivedIcon;

  ///{@macro flutter_inappwebview.WebView.onReceivedLoginRequest}
  @override
  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)?
      onReceivedLoginRequest;

  ///{@macro flutter_inappwebview.WebView.onPermissionRequestCanceled}
  @override
  final void Function(InAppWebViewController controller,
      PermissionRequest permissionRequest)? onPermissionRequestCanceled;

  ///{@macro flutter_inappwebview.WebView.onRequestFocus}
  @override
  final void Function(InAppWebViewController controller)? onRequestFocus;

  ///{@macro flutter_inappwebview.WebView.onReceivedTouchIconUrl}
  @override
  final void Function(
          InAppWebViewController controller, WebUri url, bool precomposed)?
      onReceivedTouchIconUrl;

  ///{@macro flutter_inappwebview.WebView.onRenderProcessGone}
  @override
  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      onRenderProcessGone;

  ///{@macro flutter_inappwebview.WebView.onRenderProcessResponsive}
  @override
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, WebUri? url)?
      onRenderProcessResponsive;

  ///{@macro flutter_inappwebview.WebView.onRenderProcessUnresponsive}
  @override
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, WebUri? url)?
      onRenderProcessUnresponsive;

  ///{@macro flutter_inappwebview.WebView.onSafeBrowsingHit}
  @override
  final Future<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      WebUri url,
      SafeBrowsingThreat? threatType)? onSafeBrowsingHit;

  ///{@macro flutter_inappwebview.WebView.onWebContentProcessDidTerminate}
  @override
  final void Function(InAppWebViewController controller)?
      onWebContentProcessDidTerminate;

  ///{@macro flutter_inappwebview.WebView.shouldAllowDeprecatedTLS}
  @override
  final Future<ShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? shouldAllowDeprecatedTLS;

  ///{@macro flutter_inappwebview.WebView.shouldInterceptRequest}
  @override
  final Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      shouldInterceptRequest;

  ///{@macro flutter_inappwebview.WebView.onCameraCaptureStateChanged}
  @override
  final Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onCameraCaptureStateChanged;

  ///{@macro flutter_inappwebview.WebView.onMicrophoneCaptureStateChanged}
  @override
  final Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onMicrophoneCaptureStateChanged;

  ///{@macro flutter_inappwebview.WebView.onContentSizeChanged}
  @override
  final void Function(InAppWebViewController controller, Size oldContentSize,
      Size newContentSize)? onContentSizeChanged;
}

class _InAppWebViewState extends State<InAppWebView> {
  InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    final initialSettings = widget.initialSettings ?? InAppWebViewSettings();
    _inferInitialSettings(initialSettings);

    Map<String, dynamic> settingsMap =
        (widget.initialSettings != null ? initialSettings.toMap() : null) ??
            // ignore: deprecated_member_use_from_same_package
            widget.initialOptions?.toMap() ??
            initialSettings.toMap();

    Map<String, dynamic> pullToRefreshSettings =
        widget.pullToRefreshController?.settings.toMap() ??
            // ignore: deprecated_member_use_from_same_package
            widget.pullToRefreshController?.options.toMap() ??
            PullToRefreshSettings(enabled: false).toMap();

    if ((widget.headlessWebView?.isRunning() ?? false) &&
        widget.keepAlive != null) {
      final headlessId = widget.headlessWebView?.id;
      if (headlessId != null) {
        // force keep alive id to match headless webview id
        widget.keepAlive?.id = headlessId;
      }
    }

    if (Util.isWeb) {
      return HtmlElementView(
        viewType: 'com.pichillilorenzo/flutter_inappwebview',
        onPlatformViewCreated: (int viewId) {
          var webViewHtmlElement = WebPlatformManager.webViews[viewId]!;
          webViewHtmlElement.initialSettings = initialSettings;
          webViewHtmlElement.initialUrlRequest = widget.initialUrlRequest;
          webViewHtmlElement.initialFile = widget.initialFile;
          webViewHtmlElement.initialData = widget.initialData;
          webViewHtmlElement.headlessWebViewId =
              widget.headlessWebView?.isRunning() ?? false
                  ? widget.headlessWebView?.id
                  : null;
          webViewHtmlElement.prepare();
          if (webViewHtmlElement.headlessWebViewId == null) {
            webViewHtmlElement.makeInitialLoad();
          }
          _onPlatformViewCreated(viewId);
        },
      );
    } else if (Util.isAndroid) {
      var useHybridComposition = (widget.initialSettings != null
              ? initialSettings.useHybridComposition
              : widget.initialOptions?.android.useHybridComposition) ??
          true;

      return PlatformViewLink(
        viewType: 'com.pichillilorenzo/flutter_inappwebview',
        surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
        ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: widget.gestureRecognizers ??
                const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return _createAndroidViewController(
            hybridComposition: useHybridComposition,
            id: params.id,
            viewType: 'com.pichillilorenzo/flutter_inappwebview',
            layoutDirection:
                Directionality.maybeOf(context) ?? TextDirection.rtl,
            creationParams: <String, dynamic>{
              'initialUrlRequest': widget.initialUrlRequest?.toMap(),
              'initialFile': widget.initialFile,
              'initialData': widget.initialData?.toMap(),
              'initialSettings': settingsMap,
              'contextMenu': widget.contextMenu?.toMap() ?? {},
              'windowId': widget.windowId,
              'headlessWebViewId': widget.headlessWebView?.isRunning() ?? false
                  ? widget.headlessWebView?.id
                  : null,
              'initialUserScripts':
                  widget.initialUserScripts?.map((e) => e.toMap()).toList() ??
                      [],
              'pullToRefreshSettings': pullToRefreshSettings,
              'keepAliveId': widget.keepAlive?.id
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(
                (id) => _onPlatformViewCreated(id))
            ..create();
        },
      );
    } else if (Util.isIOS /* || Util.isMacOS*/) {
      final viewType = widget.preventGestureDelay == true
          ? 'com.pichillilorenzo/flutter_inappwebview_nonblocking'
          : 'com.pichillilorenzo/flutter_inappwebview';
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: <String, dynamic>{
          'initialUrlRequest': widget.initialUrlRequest?.toMap(),
          'initialFile': widget.initialFile,
          'initialData': widget.initialData?.toMap(),
          'initialSettings': settingsMap,
          'contextMenu': widget.contextMenu?.toMap() ?? {},
          'windowId': widget.windowId,
          'headlessWebViewId': widget.headlessWebView?.isRunning() ?? false
              ? widget.headlessWebView?.id
              : null,
          'initialUserScripts':
              widget.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
          'pullToRefreshSettings': pullToRefreshSettings,
          'keepAliveId': widget.keepAlive?.id
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the flutter_inappwebview plugin');
  }

  @override
  void didUpdateWidget(InAppWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    dynamic viewId = _controller?.getViewId();
    debugLog(
        className: "InAppWebView",
        name: "WebView",
        id: viewId?.toString(),
        debugLoggingSettings: WebView.debugLoggingSettings,
        method: "dispose",
        args: []);
    if (viewId != null &&
        kIsWeb &&
        WebPlatformManager.webViews.containsKey(viewId)) {
      WebPlatformManager.webViews.remove(viewId);
    }
    final isKeepAlive = widget.keepAlive != null;
    _controller?.dispose(isKeepAlive: isKeepAlive);
    _controller = null;
    widget.pullToRefreshController?.dispose(isKeepAlive: isKeepAlive);
    widget.findInteractionController?.dispose(isKeepAlive: isKeepAlive);
    super.dispose();
  }

  AndroidViewController _createAndroidViewController({
    required bool hybridComposition,
    required int id,
    required String viewType,
    required TextDirection layoutDirection,
    required Map<String, dynamic> creationParams,
  }) {
    if (hybridComposition) {
      return PlatformViewsService.initExpensiveAndroidView(
        id: id,
        viewType: viewType,
        layoutDirection: layoutDirection,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return PlatformViewsService.initSurfaceAndroidView(
      id: id,
      viewType: viewType,
      layoutDirection: layoutDirection,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    dynamic viewId = id;
    if (!kIsWeb) {
      if (widget.headlessWebView?.isRunning() ?? false) {
        viewId = widget.headlessWebView?.id;
      }
      viewId = widget.keepAlive?.id ?? viewId ?? id;
    }
    widget.headlessWebView?.internalDispose();
    _controller = InAppWebViewController(viewId, widget);
    widget.pullToRefreshController?.init(viewId);
    widget.findInteractionController?.init(viewId);
    debugLog(
        className: "InAppWebView",
        name: "WebView",
        id: viewId?.toString(),
        debugLoggingSettings: WebView.debugLoggingSettings,
        method: "onWebViewCreated",
        args: []);
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated!(_controller!);
    }
  }

  void _inferInitialSettings(InAppWebViewSettings settings) {
    if (widget.shouldOverrideUrlLoading != null &&
        settings.useShouldOverrideUrlLoading == null) {
      settings.useShouldOverrideUrlLoading = true;
    }
    if (widget.onLoadResource != null && settings.useOnLoadResource == null) {
      settings.useOnLoadResource = true;
    }
    if (widget.onDownloadStartRequest != null &&
        settings.useOnDownloadStart == null) {
      settings.useOnDownloadStart = true;
    }
    if (widget.shouldInterceptAjaxRequest != null &&
        settings.useShouldInterceptAjaxRequest == null) {
      settings.useShouldInterceptAjaxRequest = true;
    }
    if (widget.shouldInterceptFetchRequest != null &&
        settings.useShouldInterceptFetchRequest == null) {
      settings.useShouldInterceptFetchRequest = true;
    }
    if (widget.shouldInterceptRequest != null &&
        settings.useShouldInterceptRequest == null) {
      settings.useShouldInterceptRequest = true;
    }
    if (widget.onRenderProcessGone != null &&
        settings.useOnRenderProcessGone == null) {
      settings.useOnRenderProcessGone = true;
    }
    if (widget.onNavigationResponse != null &&
        settings.useOnNavigationResponse == null) {
      settings.useOnNavigationResponse = true;
    }
  }
}
