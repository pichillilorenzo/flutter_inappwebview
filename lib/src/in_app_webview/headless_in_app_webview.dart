import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/src/util.dart';

import '../context_menu.dart';
import '../find_interaction/find_interaction_controller.dart';
import '../types/main.dart';
import '../print_job/main.dart';
import 'webview.dart';
import 'in_app_webview_controller.dart';
import 'in_app_webview_settings.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import '../pull_to_refresh/pull_to_refresh_settings.dart';
import '../types/disposable.dart';

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
class HeadlessInAppWebView implements WebView, Disposable {
  ///View ID.
  late final String id;

  bool _started = false;
  bool _running = false;

  static const MethodChannel _sharedChannel =
      const MethodChannel('com.pichillilorenzo/flutter_headless_inappwebview');
  late MethodChannel _channel;

  ///WebView Controller that can be used to access the [InAppWebViewController] API.
  late final InAppWebViewController webViewController;

  ///The window id of a [CreateWindowAction.windowId].
  final int? windowId;

  ///The WebView initial size in pixels.
  ///
  ///Set `-1` to match the corresponding width or height of the current device screen size.
  ///`Size(-1, -1)` will match both width and height of the current device screen size.
  ///
  ///**NOTE for Android**: `Size` width and height values will be converted to `int` values because they cannot have `double` values.
  final Size initialSize;

  HeadlessInAppWebView({
    this.initialSize = const Size(-1, -1),
    this.windowId,
    this.initialUrlRequest,
    this.initialFile,
    this.initialData,
    @Deprecated('Use initialSettings instead') this.initialOptions,
    this.initialSettings,
    this.contextMenu,
    this.initialUserScripts,
    this.pullToRefreshController,
    this.findInteractionController,
    this.implementation = WebViewImplementation.NATIVE,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    @Deprecated("Use onReceivedError instead") this.onLoadError,
    this.onReceivedError,
    @Deprecated("Use onReceivedHttpError instead") this.onLoadHttpError,
    this.onReceivedHttpError,
    this.onProgressChanged,
    this.onConsoleMessage,
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
  }) {
    id = IdGenerator.generate();
    webViewController = new InAppWebViewController(id, this);
    this._channel =
        MethodChannel('com.pichillilorenzo/flutter_headless_inappwebview_$id');
    this._channel.setMethodCallHandler((call) async {
      try {
        return await handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onWebViewCreated":
        pullToRefreshController?.initMethodChannel(id);
        findInteractionController?.initMethodChannel(id);
        if (onWebViewCreated != null) {
          onWebViewCreated!(webViewController);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  ///Runs the headless WebView.
  ///
  ///**NOTE for Web**: it will append a new `iframe` to the body.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  Future<void> run() async {
    if (_started) {
      return;
    }
    _started = true;

    Map<String, dynamic> initialSettings = this.initialSettings?.toMap() ??
        // ignore: deprecated_member_use_from_same_package
        this.initialOptions?.toMap() ??
        {};

    Map<String, dynamic> pullToRefreshSettings =
        this.pullToRefreshController?.settings.toMap() ??
            // ignore: deprecated_member_use_from_same_package
            this.pullToRefreshController?.options.toMap() ??
            PullToRefreshSettings(enabled: false).toMap();

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent(
        'params',
        () => <String, dynamic>{
              'initialUrlRequest': this.initialUrlRequest?.toMap(),
              'initialFile': this.initialFile,
              'initialData': this.initialData?.toMap(),
              'initialSettings': initialSettings,
              'contextMenu': this.contextMenu?.toMap() ?? {},
              'windowId': this.windowId,
              'implementation': this.implementation.toNativeValue(),
              'initialUserScripts':
                  this.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
              'pullToRefreshSettings': pullToRefreshSettings,
              'initialSize': this.initialSize.toMap()
            });
    await _sharedChannel.invokeMethod('run', args);
    _running = true;
  }

  ///Disposes the headless WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  @override
  Future<void> dispose() async {
    if (!_running) {
      return;
    }
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('dispose', args);
    _started = false;
    _running = false;
  }

  ///Indicates if the headless WebView is running or not.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  bool isRunning() {
    return _running;
  }

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
  Future<void> setSize(Size size) async {
    if (!_running) {
      return;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toMap());
    await _channel.invokeMethod('setSize', args);
  }

  ///Gets the current size in pixels of the WebView.
  ///
  ///Note that if the [HeadlessInAppWebView] is not running, this method will return `null`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  Future<Size?> getSize() async {
    if (!_running) {
      return null;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic> sizeMap =
        (await _channel.invokeMethod('getSize', args))?.cast<String, dynamic>();
    return MapSize.fromMap(sizeMap);
  }

  @override
  final InAppWebViewInitialData? initialData;

  @override
  final String? initialFile;

  @override
  @Deprecated('Use initialSettings instead')
  final InAppWebViewGroupOptions? initialOptions;

  @override
  final InAppWebViewSettings? initialSettings;

  @override
  final ContextMenu? contextMenu;

  @override
  final URLRequest? initialUrlRequest;

  @override
  final UnmodifiableListView<UserScript>? initialUserScripts;

  @override
  final PullToRefreshController? pullToRefreshController;

  @override
  final FindInteractionController? findInteractionController;

  @override
  final WebViewImplementation implementation;

  ///Use [onGeolocationPermissionsHidePrompt] instead.
  @override
  @Deprecated('Use onGeolocationPermissionsHidePrompt instead')
  void Function(InAppWebViewController controller)?
      androidOnGeolocationPermissionsHidePrompt;

  ///Use [onGeolocationPermissionsShowPrompt] instead.
  @override
  @Deprecated('Use onGeolocationPermissionsShowPrompt instead')
  Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      androidOnGeolocationPermissionsShowPrompt;

  ///Use [onPermissionRequest] instead.
  @override
  @Deprecated('Use onPermissionRequest instead')
  Future<PermissionRequestResponse?> Function(InAppWebViewController controller,
      String origin, List<String> resources)? androidOnPermissionRequest;

  ///Use [onSafeBrowsingHit] instead.
  @override
  @Deprecated('Use onSafeBrowsingHit instead')
  Future<SafeBrowsingResponse?> Function(InAppWebViewController controller,
      Uri url, SafeBrowsingThreat? threatType)? androidOnSafeBrowsingHit;

  @override
  void Function(InAppWebViewController controller, Uri? url)?
      onPageCommitVisible;

  @override
  void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;

  ///Use [onDidReceiveServerRedirectForProvisionalNavigation] instead.
  @override
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  void Function(InAppWebViewController controller)?
      iosOnDidReceiveServerRedirectForProvisionalNavigation;

  ///Use [onWebContentProcessDidTerminate] instead.
  @override
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  void Function(InAppWebViewController controller)?
      iosOnWebContentProcessDidTerminate;

  ///Use [onNavigationResponse] instead.
  @override
  @Deprecated('Use onNavigationResponse instead')
  Future<IOSNavigationResponseAction?> Function(
      InAppWebViewController controller,
      IOSWKNavigationResponse navigationResponse)? iosOnNavigationResponse;

  ///Use [shouldAllowDeprecatedTLS] instead.
  @override
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  Future<IOSShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? iosShouldAllowDeprecatedTLS;

  @override
  Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxProgress;

  @override
  Future<AjaxRequestAction?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxReadyStateChange;

  @override
  void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;

  @override
  Future<bool?> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction)? onCreateWindow;

  @override
  void Function(InAppWebViewController controller)? onCloseWindow;

  @override
  void Function(InAppWebViewController controller)? onWindowFocus;

  @override
  void Function(InAppWebViewController controller)? onWindowBlur;

  ///Use [onDownloadStartRequest] instead
  @Deprecated('Use onDownloadStartRequest instead')
  @override
  void Function(InAppWebViewController controller, Uri url)? onDownloadStart;

  @override
  void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  @override
  void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting)? onFindResultReceived;

  @override
  Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;

  @override
  Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;

  @override
  Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  @override
  void Function(InAppWebViewController controller, Uri? url, int code,
      String message)? onLoadError;

  @override
  void Function(InAppWebViewController controller, WebResourceRequest request,
      WebResourceError error)? onReceivedError;

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  @override
  void Function(InAppWebViewController controller, Uri? url, int statusCode,
      String description)? onLoadHttpError;

  void Function(InAppWebViewController controller, WebResourceRequest request,
      WebResourceResponse errorResponse)? onReceivedHttpError;

  @override
  void Function(InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  @override
  Future<CustomSchemeResponse?> Function(
      InAppWebViewController controller, Uri url)? onLoadResourceCustomScheme;

  @override
  Future<CustomSchemeResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      onLoadResourceWithCustomScheme;

  @override
  void Function(InAppWebViewController controller, Uri? url)? onLoadStart;

  @override
  void Function(InAppWebViewController controller, Uri? url)? onLoadStop;

  @override
  void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  @override
  void Function(InAppWebViewController controller, Uri? url)? onPrint;

  @override
  Future<bool?> Function(InAppWebViewController controller, Uri? url,
      PrintJobController? printJobController)? onPrintRequest;

  @override
  void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;

  @override
  Future<ClientCertResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedClientCertRequest;

  @override
  Future<HttpAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedHttpAuthRequest;

  @override
  Future<ServerTrustAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedServerTrustAuthRequest;

  @override
  void Function(InAppWebViewController controller, int x, int y)?
      onScrollChanged;

  @override
  void Function(InAppWebViewController controller, Uri? url, bool? isReload)?
      onUpdateVisitedHistory;

  @override
  void Function(InAppWebViewController controller)? onWebViewCreated;

  @override
  Future<AjaxRequest?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;

  @override
  Future<FetchRequest?> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)?
      shouldInterceptFetchRequest;

  @override
  Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;

  @override
  void Function(InAppWebViewController controller)? onEnterFullscreen;

  @override
  void Function(InAppWebViewController controller)? onExitFullscreen;

  @override
  void Function(InAppWebViewController controller, int x, int y, bool clampedX,
      bool clampedY)? onOverScrolled;

  @override
  void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      onZoomScaleChanged;

  ///Use [shouldInterceptRequest] instead.
  @override
  @Deprecated('Use shouldInterceptRequest instead')
  Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      androidShouldInterceptRequest;

  ///Use [onRenderProcessUnresponsive] instead.
  @override
  @Deprecated('Use onRenderProcessUnresponsive instead')
  Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessUnresponsive;

  ///Use [onRenderProcessResponsive] instead.
  @override
  @Deprecated('Use onRenderProcessResponsive instead')
  Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessResponsive;

  ///Use [onRenderProcessGone] instead.
  @override
  @Deprecated('Use onRenderProcessGone instead')
  void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      androidOnRenderProcessGone;

  ///Use [onFormResubmission] instead.
  @override
  @Deprecated('Use onFormResubmission instead')
  Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? androidOnFormResubmission;

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use onZoomScaleChanged instead')
  @override
  void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      androidOnScaleChanged;

  ///Use [onReceivedIcon] instead
  @override
  @Deprecated('Use onReceivedIcon instead')
  void Function(InAppWebViewController controller, Uint8List icon)?
      androidOnReceivedIcon;

  ///Use [onReceivedTouchIconUrl] instead
  @override
  @Deprecated('Use onReceivedTouchIconUrl instead')
  void Function(InAppWebViewController controller, Uri url, bool precomposed)?
      androidOnReceivedTouchIconUrl;

  ///Use [onJsBeforeUnload] instead.
  @override
  @Deprecated('Use onJsBeforeUnload instead')
  Future<JsBeforeUnloadResponse?> Function(InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? androidOnJsBeforeUnload;

  ///Use [onReceivedLoginRequest] instead.
  @override
  @Deprecated('Use onReceivedLoginRequest instead')
  void Function(InAppWebViewController controller, LoginRequest loginRequest)?
      androidOnReceivedLoginRequest;

  @override
  void Function(InAppWebViewController controller)?
      onDidReceiveServerRedirectForProvisionalNavigation;

  @override
  Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? onFormResubmission;

  @override
  void Function(InAppWebViewController controller)?
      onGeolocationPermissionsHidePrompt;

  @override
  Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      onGeolocationPermissionsShowPrompt;

  @override
  Future<JsBeforeUnloadResponse?> Function(InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? onJsBeforeUnload;

  @override
  Future<NavigationResponseAction?> Function(InAppWebViewController controller,
      NavigationResponse navigationResponse)? onNavigationResponse;

  @override
  Future<PermissionResponse?> Function(InAppWebViewController controller,
      PermissionRequest permissionRequest)? onPermissionRequest;

  @override
  void Function(InAppWebViewController controller, Uint8List icon)?
      onReceivedIcon;

  @override
  void Function(InAppWebViewController controller, LoginRequest loginRequest)?
      onReceivedLoginRequest;

  @override
  void Function(InAppWebViewController controller, Uri url, bool precomposed)?
      onReceivedTouchIconUrl;

  @override
  void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      onRenderProcessGone;

  @override
  Future<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller, Uri? url)? onRenderProcessResponsive;

  @override
  Future<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller, Uri? url)? onRenderProcessUnresponsive;

  @override
  Future<SafeBrowsingResponse?> Function(InAppWebViewController controller,
      Uri url, SafeBrowsingThreat? threatType)? onSafeBrowsingHit;

  @override
  void Function(InAppWebViewController controller)?
      onWebContentProcessDidTerminate;

  @override
  Future<ShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? shouldAllowDeprecatedTLS;

  @override
  Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      shouldInterceptRequest;

  @override
  Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onCameraCaptureStateChanged;

  @override
  Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onMicrophoneCaptureStateChanged;
}
