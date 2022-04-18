import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/src/util.dart';

import '../context_menu.dart';
import '../types.dart';
import 'webview.dart';
import 'in_app_webview_controller.dart';
import 'in_app_webview_options.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import '../pull_to_refresh/pull_to_refresh_options.dart';
import '../util.dart';

///Class that represents a WebView in headless mode.
///It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.
///
///Remember to dispose it when you don't need it anymore.
class HeadlessInAppWebView implements WebView {
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

  HeadlessInAppWebView(
      {this.initialSize = const Size(-1, -1),
      this.windowId,
      this.initialUrlRequest,
      this.initialFile,
      this.initialData,
      this.initialOptions,
      this.contextMenu,
      this.initialUserScripts,
      this.pullToRefreshController,
      this.implementation = WebViewImplementation.NATIVE,
      this.onWebViewCreated,
      this.onLoadStart,
      this.onLoadStop,
      this.onLoadError,
      this.onLoadHttpError,
      this.onProgressChanged,
      this.onConsoleMessage,
      this.shouldOverrideUrlLoading,
      this.onLoadResource,
      this.onScrollChanged,
      @Deprecated('Use `onDownloadStartRequest` instead')
          this.onDownloadStart,
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
      this.androidOnSafeBrowsingHit,
      this.androidOnPermissionRequest,
      this.androidOnGeolocationPermissionsShowPrompt,
      this.androidOnGeolocationPermissionsHidePrompt,
      this.androidShouldInterceptRequest,
      this.androidOnRenderProcessGone,
      this.androidOnRenderProcessResponsive,
      this.androidOnRenderProcessUnresponsive,
      this.androidOnFormResubmission,
      @Deprecated('Use `onZoomScaleChanged` instead')
          this.androidOnScaleChanged,
      this.androidOnReceivedIcon,
      this.androidOnReceivedTouchIconUrl,
      this.androidOnJsBeforeUnload,
      this.androidOnReceivedLoginRequest,
      this.iosOnWebContentProcessDidTerminate,
      this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
      this.iosOnNavigationResponse,
      this.iosShouldAllowDeprecatedTLS}) {
    id = IdGenerator.generate();
    webViewController = new InAppWebViewController(id, this);
    this._channel =
        MethodChannel('com.pichillilorenzo/flutter_headless_inappwebview_$id');
    this._channel.setMethodCallHandler(handleMethod);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onWebViewCreated":
        pullToRefreshController?.initMethodChannel(id);
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
  Future<void> run() async {
    if (_started) {
      return;
    }
    _started = true;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => id);
    args.putIfAbsent(
        'params',
        () => <String, dynamic>{
              'initialUrlRequest': this.initialUrlRequest?.toMap(),
              'initialFile': this.initialFile,
              'initialData': this.initialData?.toMap(),
              'initialOptions': this.initialOptions?.toMap() ?? {},
              'contextMenu': this.contextMenu?.toMap() ?? {},
              'windowId': this.windowId,
              'implementation': this.implementation.toValue(),
              'initialUserScripts':
                  this.initialUserScripts?.map((e) => e.toMap()).toList() ?? [],
              'pullToRefreshOptions':
                  this.pullToRefreshController?.options.toMap() ??
                      PullToRefreshOptions(enabled: false).toMap(),
              'initialSize': this.initialSize.toMap()
            });
    await _sharedChannel.invokeMethod('run', args);
    _running = true;
  }

  ///Disposes the headless WebView.
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
  final InAppWebViewGroupOptions? initialOptions;

  @override
  final ContextMenu? contextMenu;

  @override
  final URLRequest? initialUrlRequest;

  @override
  final UnmodifiableListView<UserScript>? initialUserScripts;

  @override
  final PullToRefreshController? pullToRefreshController;

  @override
  final WebViewImplementation implementation;

  @override
  void Function(InAppWebViewController controller)?
      androidOnGeolocationPermissionsHidePrompt;

  @override
  Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      androidOnGeolocationPermissionsShowPrompt;

  @override
  Future<PermissionRequestResponse?> Function(InAppWebViewController controller,
      String origin, List<String> resources)? androidOnPermissionRequest;

  @override
  Future<SafeBrowsingResponse?> Function(InAppWebViewController controller,
      Uri url, SafeBrowsingThreat? threatType)? androidOnSafeBrowsingHit;

  @override
  void Function(InAppWebViewController controller, Uri? url)?
      onPageCommitVisible;

  @override
  void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;

  @override
  void Function(InAppWebViewController controller)?
      iosOnDidReceiveServerRedirectForProvisionalNavigation;

  @override
  void Function(InAppWebViewController controller)?
      iosOnWebContentProcessDidTerminate;

  @override
  Future<IOSNavigationResponseAction?> Function(
      InAppWebViewController controller,
      IOSWKNavigationResponse navigationResponse)? iosOnNavigationResponse;

  @override
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
  @Deprecated('Use `onDownloadStartRequest` instead')
  @override
  final void Function(InAppWebViewController controller, Uri url)?
      onDownloadStart;

  @override
  final void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

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

  @override
  void Function(InAppWebViewController controller, Uri? url, int code,
      String message)? onLoadError;

  @override
  void Function(InAppWebViewController controller, Uri? url, int statusCode,
      String description)? onLoadHttpError;

  @override
  void Function(InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  @override
  Future<CustomSchemeResponse?> Function(
      InAppWebViewController controller, Uri url)? onLoadResourceCustomScheme;

  @override
  void Function(InAppWebViewController controller, Uri? url)? onLoadStart;

  @override
  void Function(InAppWebViewController controller, Uri? url)? onLoadStop;

  @override
  void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;

  @override
  void Function(InAppWebViewController controller, Uri? url)? onPrint;

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
  void Function(
          InAppWebViewController controller, Uri? url, bool? androidIsReload)?
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

  @override
  Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      androidShouldInterceptRequest;

  @override
  Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessUnresponsive;

  @override
  Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessResponsive;

  @override
  void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      androidOnRenderProcessGone;

  @override
  Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? androidOnFormResubmission;

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use `onZoomScaleChanged` instead')
  @override
  void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      androidOnScaleChanged;

  @override
  void Function(InAppWebViewController controller, Uint8List icon)?
      androidOnReceivedIcon;

  @override
  void Function(InAppWebViewController controller, Uri url, bool precomposed)?
      androidOnReceivedTouchIconUrl;

  @override
  Future<JsBeforeUnloadResponse?> Function(InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? androidOnJsBeforeUnload;

  @override
  void Function(InAppWebViewController controller, LoginRequest loginRequest)?
      androidOnReceivedLoginRequest;
}
