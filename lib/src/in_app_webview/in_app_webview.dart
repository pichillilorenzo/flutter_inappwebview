import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import '../context_menu.dart';
import '../types.dart';

import 'webview.dart';
import 'in_app_webview_controller.dart';
import 'in_app_webview_options.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import '../pull_to_refresh/pull_to_refresh_options.dart';

///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
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
  final int? windowId;

  const InAppWebView({
    Key? key,
    this.windowId,
    this.initialUrlRequest,
    this.initialFile,
    this.initialData,
    this.initialOptions,
    this.initialUserScripts,
    this.pullToRefreshController,
    this.implementation = WebViewImplementation.NATIVE,
    this.contextMenu,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onLoadError,
    this.onLoadHttpError,
    this.onConsoleMessage,
    this.onProgressChanged,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    @Deprecated('Use `onDownloadStartRequest` instead') this.onDownloadStart,
    this.onDownloadStartRequest,
    this.onLoadResourceCustomScheme,
    this.onCreateWindow,
    this.onCloseWindow,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.onReceivedHttpAuthRequest,
    this.onReceivedServerTrustAuthRequest,
    this.onReceivedClientCertRequest,
    this.onFindResultReceived,
    this.shouldInterceptAjaxRequest,
    this.onAjaxReadyStateChange,
    this.onAjaxProgress,
    this.shouldInterceptFetchRequest,
    this.onUpdateVisitedHistory,
    this.onPrint,
    this.onLongPressHitTestResult,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onPageCommitVisible,
    this.onTitleChanged,
    this.onWindowFocus,
    this.onWindowBlur,
    this.onOverScrolled,
    this.onZoomScaleChanged,
    this.androidOnSafeBrowsingHit,
    this.androidOnPermissionRequest,
    this.androidOnGeolocationPermissionsShowPrompt,
    this.androidOnGeolocationPermissionsHidePrompt,
    this.androidShouldInterceptRequest,
    this.androidOnRenderProcessGone,
    this.androidOnRenderProcessResponsive,
    this.androidOnRenderProcessUnresponsive,
    this.androidOnFormResubmission,
    @Deprecated('Use `onZoomScaleChanged` instead') this.androidOnScaleChanged,
    this.androidOnReceivedIcon,
    this.androidOnReceivedTouchIconUrl,
    this.androidOnJsBeforeUnload,
    this.androidOnReceivedLoginRequest,
    this.iosOnWebContentProcessDidTerminate,
    this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
    this.iosOnNavigationResponse,
    this.iosShouldAllowDeprecatedTLS,
    this.gestureRecognizers,
  }) : super(key: key);

  @override
  _InAppWebViewState createState() => _InAppWebViewState();

  @override
  final void Function(InAppWebViewController controller)?
      androidOnGeolocationPermissionsHidePrompt;

  @override
  final Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      androidOnGeolocationPermissionsShowPrompt;

  @override
  final Future<PermissionRequestResponse?> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources)? androidOnPermissionRequest;

  @override
  final Future<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      Uri url,
      SafeBrowsingThreat? threatType)? androidOnSafeBrowsingHit;

  @override
  final InAppWebViewInitialData? initialData;

  @override
  final String? initialFile;

  @override
  final InAppWebViewGroupOptions? initialOptions;

  @override
  final URLRequest? initialUrlRequest;

  @override
  final WebViewImplementation implementation;

  @override
  final UnmodifiableListView<UserScript>? initialUserScripts;

  @override
  final PullToRefreshController? pullToRefreshController;

  @override
  final ContextMenu? contextMenu;

  @override
  final void Function(InAppWebViewController controller, Uri? url)?
      onPageCommitVisible;

  @override
  final void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;

  @override
  final void Function(InAppWebViewController controller)?
      iosOnDidReceiveServerRedirectForProvisionalNavigation;

  @override
  final void Function(InAppWebViewController controller)?
      iosOnWebContentProcessDidTerminate;

  @override
  final Future<IOSNavigationResponseAction?> Function(
      InAppWebViewController controller,
      IOSWKNavigationResponse navigationResponse)? iosOnNavigationResponse;

  @override
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

  @override
  final void Function(InAppWebViewController controller, Uint8List icon)?
      androidOnReceivedIcon;

  @override
  final void Function(
          InAppWebViewController controller, Uri url, bool precomposed)?
      androidOnReceivedTouchIconUrl;

  ///Use [onDownloadStartRequest] instead
  @Deprecated('Use `onDownloadStartRequest` instead')
  @override
  final void Function(InAppWebViewController controller, Uri url)?
      onDownloadStart;

  @override
  final void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

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

  @override
  final void Function(InAppWebViewController controller, Uri? url, int code,
      String message)? onLoadError;

  @override
  final void Function(InAppWebViewController controller, Uri? url,
      int statusCode, String description)? onLoadHttpError;

  @override
  final void Function(
          InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  @override
  final Future<CustomSchemeResponse?> Function(
      InAppWebViewController controller, Uri url)? onLoadResourceCustomScheme;

  @override
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStart;

  @override
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStop;

  @override
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;

  @override
  final void Function(InAppWebViewController controller, Uri? url)? onPrint;

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
          InAppWebViewController controller, Uri? url, bool? androidIsReload)?
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

  @override
  final Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      androidShouldInterceptRequest;

  @override
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessUnresponsive;

  @override
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessResponsive;

  @override
  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      androidOnRenderProcessGone;

  @override
  final Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? androidOnFormResubmission;

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use `onZoomScaleChanged` instead')
  @override
  final void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      androidOnScaleChanged;

  @override
  final Future<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? androidOnJsBeforeUnload;

  @override
  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)?
      androidOnReceivedLoginRequest;
}

class _InAppWebViewState extends State<InAppWebView> {
  late InAppWebViewController _controller;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      var useHybridComposition =
          widget.initialOptions?.android.useHybridComposition ?? false;

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
                'initialOptions': widget.initialOptions?.toMap() ?? {},
                'contextMenu': widget.contextMenu?.toMap() ?? {},
                'windowId': widget.windowId,
                'implementation': widget.implementation.toValue(),
                'initialUserScripts':
                    widget.initialUserScripts?.map((e) => e.toMap()).toList() ??
                        [],
                'pullToRefreshOptions':
                    widget.pullToRefreshController?.options.toMap() ??
                        PullToRefreshOptions(enabled: false).toMap()
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
            'initialOptions': widget.initialOptions?.toMap() ?? {},
            'contextMenu': widget.contextMenu?.toMap() ?? {},
            'windowId': widget.windowId,
            'implementation': widget.implementation.toValue(),
            'initialUserScripts':
                widget.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
            'pullToRefreshOptions':
                widget.pullToRefreshController?.options.toMap() ??
                    PullToRefreshOptions(enabled: false).toMap()
          },
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.pichillilorenzo/flutter_inappwebview',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: <String, dynamic>{
          'initialUrlRequest': widget.initialUrlRequest?.toMap(),
          'initialFile': widget.initialFile,
          'initialData': widget.initialData?.toMap(),
          'initialOptions': widget.initialOptions?.toMap() ?? {},
          'contextMenu': widget.contextMenu?.toMap() ?? {},
          'windowId': widget.windowId,
          'implementation': widget.implementation.toValue(),
          'initialUserScripts':
              widget.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
          'pullToRefreshOptions':
              widget.pullToRefreshController?.options.toMap() ??
                  PullToRefreshOptions(enabled: false).toMap()
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
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _controller = InAppWebViewController(id, widget);
    widget.pullToRefreshController?.initMethodChannel(id);
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated!(_controller);
    }
  }
}
