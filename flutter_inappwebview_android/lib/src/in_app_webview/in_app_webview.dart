import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'headless_in_app_webview.dart';

import '../find_interaction/find_interaction_controller.dart';
import 'in_app_webview_controller.dart';
import '../pull_to_refresh/main.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';

/// Object specifying creation parameters for creating a [PlatformInAppWebViewWidget].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
class AndroidInAppWebViewWidgetCreationParams
    extends PlatformInAppWebViewWidgetCreationParams {
  AndroidInAppWebViewWidgetCreationParams(
      {super.key,
      super.layoutDirection,
      super.gestureRecognizers,
      super.headlessWebView,
      super.keepAlive,
      super.preventGestureDelay,
      super.windowId,
      super.onWebViewCreated,
      super.onLoadStart,
      super.onLoadStop,
      @Deprecated('Use onReceivedError instead') super.onLoadError,
      super.onReceivedError,
      @Deprecated("Use onReceivedHttpError instead") super.onLoadHttpError,
      super.onReceivedHttpError,
      super.onProgressChanged,
      super.onConsoleMessage,
      super.shouldOverrideUrlLoading,
      super.onLoadResource,
      super.onScrollChanged,
      @Deprecated('Use onDownloadStartRequest instead') super.onDownloadStart,
      super.onDownloadStartRequest,
      @Deprecated('Use onLoadResourceWithCustomScheme instead')
      super.onLoadResourceCustomScheme,
      super.onLoadResourceWithCustomScheme,
      super.onCreateWindow,
      super.onCloseWindow,
      super.onJsAlert,
      super.onJsConfirm,
      super.onJsPrompt,
      super.onReceivedHttpAuthRequest,
      super.onReceivedServerTrustAuthRequest,
      super.onReceivedClientCertRequest,
      @Deprecated('Use FindInteractionController.onFindResultReceived instead')
      super.onFindResultReceived,
      super.shouldInterceptAjaxRequest,
      super.onAjaxReadyStateChange,
      super.onAjaxProgress,
      super.shouldInterceptFetchRequest,
      super.onUpdateVisitedHistory,
      @Deprecated("Use onPrintRequest instead") super.onPrint,
      super.onPrintRequest,
      super.onLongPressHitTestResult,
      super.onEnterFullscreen,
      super.onExitFullscreen,
      super.onPageCommitVisible,
      super.onTitleChanged,
      super.onWindowFocus,
      super.onWindowBlur,
      super.onOverScrolled,
      super.onZoomScaleChanged,
      @Deprecated('Use onSafeBrowsingHit instead')
      super.androidOnSafeBrowsingHit,
      super.onSafeBrowsingHit,
      @Deprecated('Use onPermissionRequest instead')
      super.androidOnPermissionRequest,
      super.onPermissionRequest,
      @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
      super.androidOnGeolocationPermissionsShowPrompt,
      super.onGeolocationPermissionsShowPrompt,
      @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
      super.androidOnGeolocationPermissionsHidePrompt,
      super.onGeolocationPermissionsHidePrompt,
      @Deprecated('Use shouldInterceptRequest instead')
      super.androidShouldInterceptRequest,
      super.shouldInterceptRequest,
      @Deprecated('Use onRenderProcessGone instead')
      super.androidOnRenderProcessGone,
      super.onRenderProcessGone,
      @Deprecated('Use onRenderProcessResponsive instead')
      super.androidOnRenderProcessResponsive,
      super.onRenderProcessResponsive,
      @Deprecated('Use onRenderProcessUnresponsive instead')
      super.androidOnRenderProcessUnresponsive,
      super.onRenderProcessUnresponsive,
      @Deprecated('Use onFormResubmission instead')
      super.androidOnFormResubmission,
      super.onFormResubmission,
      @Deprecated('Use onZoomScaleChanged instead') super.androidOnScaleChanged,
      @Deprecated('Use onReceivedIcon instead') super.androidOnReceivedIcon,
      super.onReceivedIcon,
      @Deprecated('Use onReceivedTouchIconUrl instead')
      super.androidOnReceivedTouchIconUrl,
      super.onReceivedTouchIconUrl,
      @Deprecated('Use onJsBeforeUnload instead') super.androidOnJsBeforeUnload,
      super.onJsBeforeUnload,
      @Deprecated('Use onReceivedLoginRequest instead')
      super.androidOnReceivedLoginRequest,
      super.onReceivedLoginRequest,
      super.onPermissionRequestCanceled,
      super.onRequestFocus,
      @Deprecated('Use onWebContentProcessDidTerminate instead')
      super.iosOnWebContentProcessDidTerminate,
      super.onWebContentProcessDidTerminate,
      @Deprecated(
          'Use onDidReceiveServerRedirectForProvisionalNavigation instead')
      super.iosOnDidReceiveServerRedirectForProvisionalNavigation,
      super.onDidReceiveServerRedirectForProvisionalNavigation,
      @Deprecated('Use onNavigationResponse instead')
      super.iosOnNavigationResponse,
      super.onNavigationResponse,
      @Deprecated('Use shouldAllowDeprecatedTLS instead')
      super.iosShouldAllowDeprecatedTLS,
      super.shouldAllowDeprecatedTLS,
      super.onCameraCaptureStateChanged,
      super.onMicrophoneCaptureStateChanged,
      super.onContentSizeChanged,
      super.initialUrlRequest,
      super.initialFile,
      super.initialData,
      @Deprecated('Use initialSettings instead') super.initialOptions,
      super.initialSettings,
      super.contextMenu,
      super.initialUserScripts,
      this.pullToRefreshController,
      this.findInteractionController});

  /// Constructs a [AndroidInAppWebViewWidgetCreationParams] using a
  /// [PlatformInAppWebViewWidgetCreationParams].
  AndroidInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
      PlatformInAppWebViewWidgetCreationParams params)
      : this(
            key: params.key,
            layoutDirection: params.layoutDirection,
            gestureRecognizers: params.gestureRecognizers,
            headlessWebView: params.headlessWebView,
            keepAlive: params.keepAlive,
            preventGestureDelay: params.preventGestureDelay,
            windowId: params.windowId,
            onWebViewCreated: params.onWebViewCreated,
            onLoadStart: params.onLoadStart,
            onLoadStop: params.onLoadStop,
            onLoadError: params.onLoadError,
            onReceivedError: params.onReceivedError,
            onLoadHttpError: params.onLoadHttpError,
            onReceivedHttpError: params.onReceivedHttpError,
            onProgressChanged: params.onProgressChanged,
            onConsoleMessage: params.onConsoleMessage,
            shouldOverrideUrlLoading: params.shouldOverrideUrlLoading,
            onLoadResource: params.onLoadResource,
            onScrollChanged: params.onScrollChanged,
            onDownloadStart: params.onDownloadStart,
            onDownloadStartRequest: params.onDownloadStartRequest,
            onLoadResourceCustomScheme: params.onLoadResourceCustomScheme,
            onLoadResourceWithCustomScheme:
                params.onLoadResourceWithCustomScheme,
            onCreateWindow: params.onCreateWindow,
            onCloseWindow: params.onCloseWindow,
            onJsAlert: params.onJsAlert,
            onJsConfirm: params.onJsConfirm,
            onJsPrompt: params.onJsPrompt,
            onReceivedHttpAuthRequest: params.onReceivedHttpAuthRequest,
            onReceivedServerTrustAuthRequest:
                params.onReceivedServerTrustAuthRequest,
            onReceivedClientCertRequest: params.onReceivedClientCertRequest,
            onFindResultReceived: params.onFindResultReceived,
            shouldInterceptAjaxRequest: params.shouldInterceptAjaxRequest,
            onAjaxReadyStateChange: params.onAjaxReadyStateChange,
            onAjaxProgress: params.onAjaxProgress,
            shouldInterceptFetchRequest: params.shouldInterceptFetchRequest,
            onUpdateVisitedHistory: params.onUpdateVisitedHistory,
            onPrint: params.onPrint,
            onPrintRequest: params.onPrintRequest,
            onLongPressHitTestResult: params.onLongPressHitTestResult,
            onEnterFullscreen: params.onEnterFullscreen,
            onExitFullscreen: params.onExitFullscreen,
            onPageCommitVisible: params.onPageCommitVisible,
            onTitleChanged: params.onTitleChanged,
            onWindowFocus: params.onWindowFocus,
            onWindowBlur: params.onWindowBlur,
            onOverScrolled: params.onOverScrolled,
            onZoomScaleChanged: params.onZoomScaleChanged,
            androidOnSafeBrowsingHit: params.androidOnSafeBrowsingHit,
            onSafeBrowsingHit: params.onSafeBrowsingHit,
            androidOnPermissionRequest: params.androidOnPermissionRequest,
            onPermissionRequest: params.onPermissionRequest,
            androidOnGeolocationPermissionsShowPrompt:
                params.androidOnGeolocationPermissionsShowPrompt,
            onGeolocationPermissionsShowPrompt:
                params.onGeolocationPermissionsShowPrompt,
            androidOnGeolocationPermissionsHidePrompt:
                params.androidOnGeolocationPermissionsHidePrompt,
            onGeolocationPermissionsHidePrompt:
                params.onGeolocationPermissionsHidePrompt,
            androidShouldInterceptRequest: params.androidShouldInterceptRequest,
            shouldInterceptRequest: params.shouldInterceptRequest,
            androidOnRenderProcessGone: params.androidOnRenderProcessGone,
            onRenderProcessGone: params.onRenderProcessGone,
            androidOnRenderProcessResponsive:
                params.androidOnRenderProcessResponsive,
            onRenderProcessResponsive: params.onRenderProcessResponsive,
            androidOnRenderProcessUnresponsive:
                params.androidOnRenderProcessUnresponsive,
            onRenderProcessUnresponsive: params.onRenderProcessUnresponsive,
            androidOnFormResubmission: params.androidOnFormResubmission,
            onFormResubmission: params.onFormResubmission,
            androidOnScaleChanged: params.androidOnScaleChanged,
            androidOnReceivedIcon: params.androidOnReceivedIcon,
            onReceivedIcon: params.onReceivedIcon,
            androidOnReceivedTouchIconUrl: params.androidOnReceivedTouchIconUrl,
            onReceivedTouchIconUrl: params.onReceivedTouchIconUrl,
            androidOnJsBeforeUnload: params.androidOnJsBeforeUnload,
            onJsBeforeUnload: params.onJsBeforeUnload,
            androidOnReceivedLoginRequest: params.androidOnReceivedLoginRequest,
            onReceivedLoginRequest: params.onReceivedLoginRequest,
            onPermissionRequestCanceled: params.onPermissionRequestCanceled,
            onRequestFocus: params.onRequestFocus,
            iosOnWebContentProcessDidTerminate:
                params.iosOnWebContentProcessDidTerminate,
            onWebContentProcessDidTerminate:
                params.onWebContentProcessDidTerminate,
            iosOnDidReceiveServerRedirectForProvisionalNavigation:
                params.iosOnDidReceiveServerRedirectForProvisionalNavigation,
            onDidReceiveServerRedirectForProvisionalNavigation:
                params.onDidReceiveServerRedirectForProvisionalNavigation,
            iosOnNavigationResponse: params.iosOnNavigationResponse,
            onNavigationResponse: params.onNavigationResponse,
            iosShouldAllowDeprecatedTLS: params.iosShouldAllowDeprecatedTLS,
            shouldAllowDeprecatedTLS: params.shouldAllowDeprecatedTLS,
            onCameraCaptureStateChanged: params.onCameraCaptureStateChanged,
            onMicrophoneCaptureStateChanged:
                params.onMicrophoneCaptureStateChanged,
            onContentSizeChanged: params.onContentSizeChanged,
            initialUrlRequest: params.initialUrlRequest,
            initialFile: params.initialFile,
            initialData: params.initialData,
            initialOptions: params.initialOptions,
            initialSettings: params.initialSettings,
            contextMenu: params.contextMenu,
            initialUserScripts: params.initialUserScripts,
            pullToRefreshController: params.pullToRefreshController
                as AndroidPullToRefreshController?,
            findInteractionController: params.findInteractionController
                as AndroidFindInteractionController?);

  @override
  final AndroidFindInteractionController? findInteractionController;

  @override
  final AndroidPullToRefreshController? pullToRefreshController;
}

///{@template flutter_inappwebview.InAppWebView}
///Flutter Widget for adding an **inline native WebView** integrated in the flutter widget tree.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- Web
///{@endtemplate}
class AndroidInAppWebViewWidget extends PlatformInAppWebViewWidget {
  /// Constructs a [AndroidInAppWebViewWidget].
  AndroidInAppWebViewWidget(PlatformInAppWebViewWidgetCreationParams params)
      : super.implementation(
          params is AndroidInAppWebViewWidgetCreationParams
              ? params
              : AndroidInAppWebViewWidgetCreationParams
                  .fromPlatformInAppWebViewWidgetCreationParams(params),
        );

  AndroidInAppWebViewWidgetCreationParams get _androidParams =>
      params as AndroidInAppWebViewWidgetCreationParams;

  AndroidInAppWebViewController? _controller;

  AndroidHeadlessInAppWebView? get _androidHeadlessInAppWebView =>
      _androidParams.headlessWebView as AndroidHeadlessInAppWebView?;

  @override
  Widget build(BuildContext context) {
    final initialSettings =
        _androidParams.initialSettings ?? InAppWebViewSettings();
    _inferInitialSettings(initialSettings);

    Map<String, dynamic> settingsMap = (_androidParams.initialSettings != null
            ? initialSettings.toMap()
            : null) ??
        // ignore: deprecated_member_use_from_same_package
        _androidParams.initialOptions?.toMap() ??
        initialSettings.toMap();

    Map<String, dynamic> pullToRefreshSettings =
        _androidParams.pullToRefreshController?.params.settings.toMap() ??
            // ignore: deprecated_member_use_from_same_package
            _androidParams.pullToRefreshController?.params.options.toMap() ??
            PullToRefreshSettings(enabled: false).toMap();

    if ((_androidParams.headlessWebView?.isRunning() ?? false) &&
        _androidParams.keepAlive != null) {
      final headlessId = _androidParams.headlessWebView?.id;
      if (headlessId != null) {
        // force keep alive id to match headless webview id
        _androidParams.keepAlive?.id = headlessId;
      }
    }

    var useHybridComposition = (_androidParams.initialSettings != null
            ? initialSettings.useHybridComposition
            : _androidParams.initialOptions?.android.useHybridComposition) ??
        true;

    return PlatformViewLink(
      // Setting a default key using `params` ensures the `PlatformViewLink`
      // recreates the PlatformView when changes are made.
      key: _androidParams.key,
      viewType: 'com.pichillilorenzo/flutter_inappwebview',
      surfaceFactory: (
        BuildContext context,
        PlatformViewController controller,
      ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: _androidParams.gestureRecognizers ??
              const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return _createAndroidViewController(
          hybridComposition: useHybridComposition,
          id: params.id,
          viewType: 'com.pichillilorenzo/flutter_inappwebview',
          layoutDirection: _androidParams.layoutDirection ??
              Directionality.maybeOf(context) ??
              TextDirection.rtl,
          creationParams: <String, dynamic>{
            'initialUrlRequest': _androidParams.initialUrlRequest?.toMap(),
            'initialFile': _androidParams.initialFile,
            'initialData': _androidParams.initialData?.toMap(),
            'initialSettings': settingsMap,
            'contextMenu': _androidParams.contextMenu?.toMap() ?? {},
            'windowId': _androidParams.windowId,
            'headlessWebViewId':
                _androidParams.headlessWebView?.isRunning() ?? false
                    ? _androidParams.headlessWebView?.id
                    : null,
            'initialUserScripts': _androidParams.initialUserScripts
                    ?.map((e) => e.toMap())
                    .toList() ??
                [],
            'pullToRefreshSettings': pullToRefreshSettings,
            'keepAliveId': _androidParams.keepAlive?.id
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener((id) => _onPlatformViewCreated(id))
          ..create();
      },
    );
  }

  @override
  void dispose() {
    dynamic viewId = _controller?.getViewId();
    debugLog(
        className: runtimeType.toString(),
        id: viewId?.toString(),
        debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
        method: "dispose",
        args: []);
    final isKeepAlive = _androidParams.keepAlive != null;
    _controller?.dispose(isKeepAlive: isKeepAlive);
    _controller = null;
    _androidParams.pullToRefreshController?.dispose(isKeepAlive: isKeepAlive);
    _androidParams.findInteractionController?.dispose(isKeepAlive: isKeepAlive);
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
      if (_androidParams.headlessWebView?.isRunning() ?? false) {
        viewId = _androidParams.headlessWebView?.id;
      }
      viewId = _androidParams.keepAlive?.id ?? viewId ?? id;
    }
    _androidHeadlessInAppWebView?.internalDispose();
    _controller = AndroidInAppWebViewController(
        PlatformInAppWebViewControllerCreationParams(
            id: viewId, webviewParams: params));
    _androidParams.pullToRefreshController?.init(viewId);
    _androidParams.findInteractionController?.init(viewId);
    debugLog(
        className: runtimeType.toString(),
        id: viewId?.toString(),
        debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
        method: "onWebViewCreated",
        args: []);
    if (_androidParams.onWebViewCreated != null) {
      _androidParams.onWebViewCreated!(_controller!);
    }
  }

  void _inferInitialSettings(InAppWebViewSettings settings) {
    if (_androidParams.shouldOverrideUrlLoading != null &&
        settings.useShouldOverrideUrlLoading == null) {
      settings.useShouldOverrideUrlLoading = true;
    }
    if (_androidParams.onLoadResource != null &&
        settings.useOnLoadResource == null) {
      settings.useOnLoadResource = true;
    }
    if (_androidParams.onDownloadStartRequest != null &&
        settings.useOnDownloadStart == null) {
      settings.useOnDownloadStart = true;
    }
    if (_androidParams.shouldInterceptAjaxRequest != null &&
        settings.useShouldInterceptAjaxRequest == null) {
      settings.useShouldInterceptAjaxRequest = true;
    }
    if (_androidParams.shouldInterceptFetchRequest != null &&
        settings.useShouldInterceptFetchRequest == null) {
      settings.useShouldInterceptFetchRequest = true;
    }
    if (_androidParams.shouldInterceptRequest != null &&
        settings.useShouldInterceptRequest == null) {
      settings.useShouldInterceptRequest = true;
    }
    if (_androidParams.onRenderProcessGone != null &&
        settings.useOnRenderProcessGone == null) {
      settings.useOnRenderProcessGone = true;
    }
    if (_androidParams.onNavigationResponse != null &&
        settings.useOnNavigationResponse == null) {
      settings.useOnNavigationResponse = true;
    }
  }
}
