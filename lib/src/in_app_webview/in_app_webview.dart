import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../web/web_platform_manager.dart';

import '../context_menu.dart';
import '../types/main.dart';
import '../print_job/main.dart';

import 'webview.dart';
import 'in_app_webview_controller.dart';
import 'in_app_webview_settings.dart';
import '../pull_to_refresh/main.dart';

///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- Web
class InAppWebView extends StatefulWidget implements WebView {
  /// `gestureRecognizers` specifies which gestures should be consumed by the WebView.
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  /// When `gestureRecognizers` is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  ///The window id of a [CreateWindowAction.windowId].
  @override
  final int? windowId;

  const InAppWebView({
    Key? key,
    this.windowId,
    this.initialUrlRequest,
    this.initialFile,
    this.initialData,
    @Deprecated('Use initialSettings instead') this.initialOptions,
    this.initialSettings,
    this.initialUserScripts,
    this.pullToRefreshController,
    this.findInteractionController,
    this.implementation = WebViewImplementation.NATIVE,
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
    this.gestureRecognizers,
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

  @override
  final InAppWebViewInitialData? initialData;

  @override
  final String? initialFile;

  ///Use [initialSettings] instead.
  @override
  @Deprecated('Use initialSettings instead')
  final InAppWebViewGroupOptions? initialOptions;

  @override
  final InAppWebViewSettings? initialSettings;

  @override
  final URLRequest? initialUrlRequest;

  @override
  final WebViewImplementation implementation;

  @override
  final UnmodifiableListView<UserScript>? initialUserScripts;

  @override
  final PullToRefreshController? pullToRefreshController;

  @override
  final FindInteractionController? findInteractionController;

  @override
  final ContextMenu? contextMenu;

  @override
  final void Function(InAppWebViewController controller, Uri? url)?
      onPageCommitVisible;

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

  @override
  final Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxProgress;

  @override
  final Future<AjaxRequestAction?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxReadyStateChange;

  @override
  final void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;

  @override
  final Future<bool?> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction)? onCreateWindow;

  @override
  final void Function(InAppWebViewController controller)? onCloseWindow;

  @override
  final void Function(InAppWebViewController controller)? onWindowFocus;

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

  @override
  final void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  @override
  final void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting)? onFindResultReceived;

  @override
  final Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;

  @override
  final Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;

  @override
  final Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  @override
  final void Function(InAppWebViewController controller, Uri? url, int code,
      String message)? onLoadError;

  @override
  final void Function(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error)? onReceivedError;

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  @override
  final void Function(InAppWebViewController controller, Uri? url,
      int statusCode, String description)? onLoadHttpError;

  @override
  final void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceResponse errorResponse)? onReceivedHttpError;

  @override
  final void Function(
          InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  @override
  final Future<CustomSchemeResponse?> Function(
      InAppWebViewController controller, Uri url)? onLoadResourceCustomScheme;

  @override
  final Future<CustomSchemeResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      onLoadResourceWithCustomScheme;

  @override
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStart;

  @override
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStop;

  @override
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  @override
  final void Function(InAppWebViewController controller, Uri? url)? onPrint;

  @override
  final Future<bool?> Function(InAppWebViewController controller, Uri? url,
      PrintJobController? printJobController)? onPrintRequest;

  @override
  final void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;

  @override
  final Future<ClientCertResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedClientCertRequest;

  @override
  final Future<HttpAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedHttpAuthRequest;

  @override
  final Future<ServerTrustAuthResponse?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedServerTrustAuthRequest;

  @override
  final void Function(InAppWebViewController controller, int x, int y)?
      onScrollChanged;

  @override
  final void Function(
          InAppWebViewController controller, Uri? url, bool? isReload)?
      onUpdateVisitedHistory;

  @override
  final void Function(InAppWebViewController controller)? onWebViewCreated;

  @override
  final Future<AjaxRequest?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;

  @override
  final Future<FetchRequest?> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)?
      shouldInterceptFetchRequest;

  @override
  final Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;

  @override
  final void Function(InAppWebViewController controller)? onEnterFullscreen;

  @override
  final void Function(InAppWebViewController controller)? onExitFullscreen;

  @override
  final void Function(InAppWebViewController controller, int x, int y,
      bool clampedX, bool clampedY)? onOverScrolled;

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

  @override
  final void Function(InAppWebViewController controller)?
      onDidReceiveServerRedirectForProvisionalNavigation;

  @override
  final Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? onFormResubmission;

  @override
  final void Function(InAppWebViewController controller)?
      onGeolocationPermissionsHidePrompt;

  @override
  final Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      onGeolocationPermissionsShowPrompt;

  @override
  final Future<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? onJsBeforeUnload;

  @override
  final Future<NavigationResponseAction?> Function(
      InAppWebViewController controller,
      NavigationResponse navigationResponse)? onNavigationResponse;

  @override
  final Future<PermissionResponse?> Function(InAppWebViewController controller,
      PermissionRequest permissionRequest)? onPermissionRequest;

  @override
  final void Function(InAppWebViewController controller, Uint8List icon)?
      onReceivedIcon;

  @override
  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)?
      onReceivedLoginRequest;

  @override
  final void Function(
          InAppWebViewController controller, Uri url, bool precomposed)?
      onReceivedTouchIconUrl;

  @override
  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      onRenderProcessGone;

  @override
  final Future<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller, Uri? url)? onRenderProcessResponsive;

  @override
  final Future<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller, Uri? url)? onRenderProcessUnresponsive;

  @override
  final Future<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      Uri url,
      SafeBrowsingThreat? threatType)? onSafeBrowsingHit;

  @override
  final void Function(InAppWebViewController controller)?
      onWebContentProcessDidTerminate;

  @override
  final Future<ShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? shouldAllowDeprecatedTLS;

  @override
  final Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      shouldInterceptRequest;

  @override
  final Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onCameraCaptureStateChanged;

  @override
  final Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onMicrophoneCaptureStateChanged;
}

class _InAppWebViewState extends State<InAppWebView> {
  InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> initialSettings = widget.initialSettings?.toMap() ??
        // ignore: deprecated_member_use_from_same_package
        widget.initialOptions?.toMap() ??
        {};

    Map<String, dynamic> pullToRefreshSettings =
        widget.pullToRefreshController?.settings.toMap() ??
            // ignore: deprecated_member_use_from_same_package
            widget.pullToRefreshController?.options.toMap() ??
            PullToRefreshSettings(enabled: false).toMap();

    if (kIsWeb) {
      return HtmlElementView(
        viewType: 'com.pichillilorenzo/flutter_inappwebview',
        onPlatformViewCreated: (int viewId) {
          var webViewHtmlElement = WebPlatformManager.webViews[viewId]!;
          webViewHtmlElement.initialSettings = widget.initialSettings;
          webViewHtmlElement.initialUrlRequest = widget.initialUrlRequest;
          webViewHtmlElement.initialFile = widget.initialFile;
          webViewHtmlElement.initialData = widget.initialData;
          webViewHtmlElement.prepare();
          webViewHtmlElement.makeInitialLoad();
          _onPlatformViewCreated(viewId);
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      var useHybridComposition = (widget.initialSettings != null
              ? widget.initialSettings?.useHybridComposition
              :
              // ignore: deprecated_member_use_from_same_package
              widget.initialOptions?.android.useHybridComposition) ??
          true;

      if (!useHybridComposition && widget.pullToRefreshController != null) {
        throw new Exception(
            "To use the pull-to-refresh feature, useHybridComposition Android-specific option MUST be true!");
      }

      if (useHybridComposition) {
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
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'com.pichillilorenzo/flutter_inappwebview',
              layoutDirection: TextDirection.rtl,
              creationParams: <String, dynamic>{
                'initialUrlRequest': widget.initialUrlRequest?.toMap(),
                'initialFile': widget.initialFile,
                'initialData': widget.initialData?.toMap(),
                'initialSettings': initialSettings,
                'contextMenu': widget.contextMenu?.toMap() ?? {},
                'windowId': widget.windowId,
                'implementation': widget.implementation.toNativeValue(),
                'initialUserScripts':
                    widget.initialUserScripts?.map((e) => e.toMap()).toList() ??
                        [],
                'pullToRefreshSettings': pullToRefreshSettings
              },
              creationParamsCodec: const StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(
                  (id) => _onPlatformViewCreated(id))
              ..create();
          },
        );
      } else {
        return AndroidView(
          viewType: 'com.pichillilorenzo/flutter_inappwebview',
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          layoutDirection: Directionality.maybeOf(context) ?? TextDirection.rtl,
          creationParams: <String, dynamic>{
            'initialUrlRequest': widget.initialUrlRequest?.toMap(),
            'initialFile': widget.initialFile,
            'initialData': widget.initialData?.toMap(),
            'initialSettings': initialSettings,
            'contextMenu': widget.contextMenu?.toMap() ?? {},
            'windowId': widget.windowId,
            'implementation': widget.implementation.toNativeValue(),
            'initialUserScripts':
                widget.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
            'pullToRefreshSettings': pullToRefreshSettings
          },
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
    } else if (defaultTargetPlatform ==
        TargetPlatform
            .iOS /* || defaultTargetPlatform == TargetPlatform.macOS*/) {
      return UiKitView(
        viewType: 'com.pichillilorenzo/flutter_inappwebview',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: <String, dynamic>{
          'initialUrlRequest': widget.initialUrlRequest?.toMap(),
          'initialFile': widget.initialFile,
          'initialData': widget.initialData?.toMap(),
          'initialSettings': initialSettings,
          'contextMenu': widget.contextMenu?.toMap() ?? {},
          'windowId': widget.windowId,
          'implementation': widget.implementation.toNativeValue(),
          'initialUserScripts':
              widget.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
          'pullToRefreshSettings': pullToRefreshSettings
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
    if (viewId != null &&
        kIsWeb &&
        WebPlatformManager.webViews.containsKey(viewId)) {
      WebPlatformManager.webViews.remove(viewId);
    }
    super.dispose();
    _controller = null;
  }

  void _onPlatformViewCreated(int id) {
    _controller = InAppWebViewController(id, widget);
    widget.pullToRefreshController?.initMethodChannel(id);
    widget.findInteractionController?.initMethodChannel(id);
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated!(_controller!);
    }
  }
}
