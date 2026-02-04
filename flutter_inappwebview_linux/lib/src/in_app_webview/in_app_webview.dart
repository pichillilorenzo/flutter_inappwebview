import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../webview_environment/webview_environment.dart';
import 'in_app_webview_controller.dart';
import 'custom_platform_view.dart';

/// Object specifying creation parameters for creating a [PlatformInAppWebViewWidget].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
class LinuxInAppWebViewWidgetCreationParams
    extends PlatformInAppWebViewWidgetCreationParams {
  LinuxInAppWebViewWidgetCreationParams({
    super.controllerFromPlatform,
    super.key,
    super.layoutDirection,
    super.gestureRecognizers,
    super.headlessWebView,
    super.keepAlive,
    super.preventGestureDelay,
    super.windowId,
    this.webViewEnvironment,
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
    @Deprecated('Use onDownloadStarting instead') super.onDownloadStart,
    @Deprecated('Use onDownloadStarting instead') super.onDownloadStartRequest,
    super.onDownloadStarting,
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
    super.onSafeBrowsingHit,
    super.onPermissionRequest,
    super.onGeolocationPermissionsShowPrompt,
    super.onGeolocationPermissionsHidePrompt,
    super.shouldInterceptRequest,
    super.onRenderProcessGone,
    super.onRenderProcessResponsive,
    super.onRenderProcessUnresponsive,
    super.onFormResubmission,
    super.onReceivedIcon,
    super.onReceivedTouchIconUrl,
    super.onJsBeforeUnload,
    super.onReceivedLoginRequest,
    super.onPermissionRequestCanceled,
    super.onRequestFocus,
    super.onWebContentProcessDidTerminate,
    super.onDidReceiveServerRedirectForProvisionalNavigation,
    super.onNavigationResponse,
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
    super.pullToRefreshController,
    super.findInteractionController,
  });

  /// Constructs a [LinuxInAppWebViewWidgetCreationParams] using a
  /// [PlatformInAppWebViewWidgetCreationParams].
  LinuxInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
    PlatformInAppWebViewWidgetCreationParams params,
  ) : this(
        controllerFromPlatform: params.controllerFromPlatform,
        key: params.key,
        layoutDirection: params.layoutDirection,
        gestureRecognizers: params.gestureRecognizers,
        headlessWebView: params.headlessWebView,
        keepAlive: params.keepAlive,
        preventGestureDelay: params.preventGestureDelay,
        windowId: params.windowId,
        webViewEnvironment:
            params.webViewEnvironment as LinuxWebViewEnvironment?,
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
        onDownloadStarting: params.onDownloadStarting,
        onLoadResourceCustomScheme: params.onLoadResourceCustomScheme,
        onLoadResourceWithCustomScheme: params.onLoadResourceWithCustomScheme,
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
        onSafeBrowsingHit: params.onSafeBrowsingHit,
        onPermissionRequest: params.onPermissionRequest,
        onGeolocationPermissionsShowPrompt:
            params.onGeolocationPermissionsShowPrompt,
        onGeolocationPermissionsHidePrompt:
            params.onGeolocationPermissionsHidePrompt,
        shouldInterceptRequest: params.shouldInterceptRequest,
        onRenderProcessGone: params.onRenderProcessGone,
        onRenderProcessResponsive: params.onRenderProcessResponsive,
        onRenderProcessUnresponsive: params.onRenderProcessUnresponsive,
        onFormResubmission: params.onFormResubmission,
        onReceivedIcon: params.onReceivedIcon,
        onReceivedTouchIconUrl: params.onReceivedTouchIconUrl,
        onJsBeforeUnload: params.onJsBeforeUnload,
        onReceivedLoginRequest: params.onReceivedLoginRequest,
        onPermissionRequestCanceled: params.onPermissionRequestCanceled,
        onRequestFocus: params.onRequestFocus,
        onWebContentProcessDidTerminate: params.onWebContentProcessDidTerminate,
        onDidReceiveServerRedirectForProvisionalNavigation:
            params.onDidReceiveServerRedirectForProvisionalNavigation,
        onNavigationResponse: params.onNavigationResponse,
        shouldAllowDeprecatedTLS: params.shouldAllowDeprecatedTLS,
        onCameraCaptureStateChanged: params.onCameraCaptureStateChanged,
        onMicrophoneCaptureStateChanged: params.onMicrophoneCaptureStateChanged,
        onContentSizeChanged: params.onContentSizeChanged,
        initialUrlRequest: params.initialUrlRequest,
        initialFile: params.initialFile,
        initialData: params.initialData,
        initialOptions: params.initialOptions,
        initialSettings: params.initialSettings,
        contextMenu: params.contextMenu,
        initialUserScripts: params.initialUserScripts,
        pullToRefreshController: params.pullToRefreshController,
        findInteractionController: params.findInteractionController,
      );

  @override
  final LinuxWebViewEnvironment? webViewEnvironment;
}

///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
class LinuxInAppWebViewWidget extends PlatformInAppWebViewWidget {
  /// Constructs a [LinuxInAppWebViewWidget].
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewWidget}
  LinuxInAppWebViewWidget(PlatformInAppWebViewWidgetCreationParams params)
    : super.implementation(
        params is LinuxInAppWebViewWidgetCreationParams
            ? params
            : LinuxInAppWebViewWidgetCreationParams.fromPlatformInAppWebViewWidgetCreationParams(
                params,
              ),
      );

  LinuxInAppWebViewWidgetCreationParams get _linuxParams =>
      params as LinuxInAppWebViewWidgetCreationParams;

  LinuxInAppWebViewController? _controller;

  static final LinuxInAppWebViewWidget _staticValue = LinuxInAppWebViewWidget(
    LinuxInAppWebViewWidgetCreationParams(),
  );

  factory LinuxInAppWebViewWidget.static() {
    return _staticValue;
  }

  @override
  Widget build(BuildContext context) {
    final initialSettings = params.initialSettings ?? InAppWebViewSettings();
    _inferInitialSettings(initialSettings);

    Map<String, dynamic> settingsMap =
        (params.initialSettings != null ? initialSettings.toMap() : null) ??
        // ignore: deprecated_member_use_from_same_package
        params.initialOptions?.toMap() ??
        initialSettings.toMap();

    if ((params.headlessWebView?.isRunning() ?? false) &&
        params.keepAlive != null) {
      final headlessId = params.headlessWebView?.id;
      if (headlessId != null) {
        // force keep alive id to match headless webview id
        params.keepAlive?.id = headlessId;
      }
    }

    return CustomPlatformView(
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: <String, dynamic>{
        'initialUrlRequest': params.initialUrlRequest?.toMap(),
        'initialFile': params.initialFile,
        'initialData': params.initialData?.toMap(),
        'initialSettings': settingsMap,
        'contextMenu': params.contextMenu?.toMap() ?? {},
        'windowId': params.windowId,
        'headlessWebViewId': params.headlessWebView?.isRunning() ?? false
            ? params.headlessWebView?.id
            : null,
        'initialUserScripts':
            params.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
        'keepAliveId': params.keepAlive?.id,
        'webViewEnvironmentId': params.webViewEnvironment?.id,
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    dynamic viewId = id;
    if (params.headlessWebView?.isRunning() ?? false) {
      viewId = params.headlessWebView?.id;
    }
    viewId = params.keepAlive?.id ?? viewId ?? id;

    _controller = LinuxInAppWebViewController(
      PlatformInAppWebViewControllerCreationParams(
        id: viewId,
        webviewParams: params,
      ),
    );

    // Initialize the find interaction controller with the same view ID
    if (_linuxParams.findInteractionController != null) {
      var findInteractionController =
          _linuxParams.findInteractionController
              as LinuxFindInteractionController;
      findInteractionController.init(viewId);
    }

    debugLog(
      className: runtimeType.toString(),
      id: viewId?.toString(),
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: "onWebViewCreated",
      args: [],
    );
    if (params.onWebViewCreated != null) {
      params.onWebViewCreated!(
        params.controllerFromPlatform?.call(_controller!) ?? _controller!,
      );
    }
  }

  void _inferInitialSettings(InAppWebViewSettings settings) {
    if (params.shouldOverrideUrlLoading != null &&
        settings.useShouldOverrideUrlLoading == null) {
      settings.useShouldOverrideUrlLoading = true;
    }
    if (params.onLoadResource != null && settings.useOnLoadResource == null) {
      settings.useOnLoadResource = true;
    }
    if ((params.onDownloadStartRequest != null ||
            params.onDownloadStarting != null) &&
        settings.useOnDownloadStart == null) {
      settings.useOnDownloadStart = true;
    }
    if ((params.shouldInterceptAjaxRequest != null ||
        params.onAjaxProgress != null ||
        params.onAjaxReadyStateChange != null)) {
      if (settings.useShouldInterceptAjaxRequest == null) {
        settings.useShouldInterceptAjaxRequest = true;
      }
      if (params.onAjaxReadyStateChange != null &&
          settings.useOnAjaxReadyStateChange == null) {
        settings.useOnAjaxReadyStateChange = true;
      }
      if (params.onAjaxProgress != null && settings.useOnAjaxProgress == null) {
        settings.useOnAjaxProgress = true;
      }
    }
    if (params.shouldInterceptFetchRequest != null &&
        settings.useShouldInterceptFetchRequest == null) {
      settings.useShouldInterceptFetchRequest = true;
    }
    if (params.shouldInterceptRequest != null &&
        settings.useShouldInterceptRequest == null) {
      settings.useShouldInterceptRequest = true;
    }
    if (params.onRenderProcessGone != null &&
        settings.useOnRenderProcessGone == null) {
      settings.useOnRenderProcessGone = true;
    }
    if (params.onNavigationResponse != null &&
        settings.useOnNavigationResponse == null) {
      settings.useOnNavigationResponse = true;
    }
  }

  @override
  void dispose() {
    dynamic viewId = _controller?.id;
    debugLog(
      className: runtimeType.toString(),
      id: viewId?.toString(),
      debugLoggingSettings: PlatformInAppWebViewController.debugLoggingSettings,
      method: "dispose",
      args: [],
    );
    final isKeepAlive = params.keepAlive != null;
    _controller?.dispose(isKeepAlive: isKeepAlive);
    _controller = null;
    params.findInteractionController?.dispose(isKeepAlive: isKeepAlive);
  }

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    // unused
    throw UnimplementedError();
  }
}
