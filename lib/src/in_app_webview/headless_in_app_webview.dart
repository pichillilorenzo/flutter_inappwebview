import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:talkjs_flutter_inappwebview/src/util.dart';

import '../context_menu.dart';
import '../find_interaction/find_interaction_controller.dart';
import '../types/main.dart';
import '../print_job/main.dart';
import '../web_uri.dart';
import 'webview.dart';
import 'in_app_webview_controller.dart';
import 'in_app_webview_settings.dart';
import '../pull_to_refresh/pull_to_refresh_controller.dart';
import '../pull_to_refresh/pull_to_refresh_settings.dart';
import '../types/disposable.dart';

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

  ///{@macro flutter_inappwebview.WebView.windowId}
  final int? windowId;

  ///The WebView initial size in pixels.
  ///
  ///Set `-1` to match the corresponding width or height of the current device screen size.
  ///`Size(-1, -1)` will match both width and height of the current device screen size.
  ///
  ///**NOTE for Android**: `Size` width and height values will be converted to `int` values because they cannot have `double` values.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  ///- MacOS
  final Size initialSize;

  ///{@macro flutter_inappwebview.HeadlessInAppWebView}
  HeadlessInAppWebView(
      {this.initialSize = const Size(-1, -1),
      this.windowId,
      this.initialUrlRequest,
      this.initialFile,
      this.initialData,
      @Deprecated('Use initialSettings instead')
          this.initialOptions,
      this.initialSettings,
      this.contextMenu,
      this.initialUserScripts,
      this.pullToRefreshController,
      this.findInteractionController,
      this.implementation = WebViewImplementation.NATIVE,
      this.onWebViewCreated,
      this.onLoadStart,
      this.onLoadStop,
      @Deprecated("Use onReceivedError instead")
          this.onLoadError,
      this.onReceivedError,
      @Deprecated("Use onReceivedHttpError instead")
          this.onLoadHttpError,
      this.onReceivedHttpError,
      this.onProgressChanged,
      this.onConsoleMessage,
      this.shouldOverrideUrlLoading,
      this.onLoadResource,
      this.onScrollChanged,
      @Deprecated('Use onDownloadStartRequest instead')
          this.onDownloadStart,
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
      @Deprecated("Use onPrintRequest instead")
          this.onPrint,
      this.onPrintRequest,
      this.onLongPressHitTestResult,
      this.onEnterFullscreen,
      this.onExitFullscreen,
      this.onPageCommitVisible,
      this.onTitleChanged,
      this.onWindowFocus,
      this.onWindowBlur,
      this.onOverScrolled,
      @Deprecated('Use onSafeBrowsingHit instead')
          this.androidOnSafeBrowsingHit,
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
      @Deprecated('Use onZoomScaleChanged instead')
          this.androidOnScaleChanged,
      @Deprecated('Use onReceivedIcon instead')
          this.androidOnReceivedIcon,
      this.onReceivedIcon,
      @Deprecated('Use onReceivedTouchIconUrl instead')
          this.androidOnReceivedTouchIconUrl,
      this.onReceivedTouchIconUrl,
      @Deprecated('Use onJsBeforeUnload instead')
          this.androidOnJsBeforeUnload,
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
      this.onContentSizeChanged}) {
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

    final initialSettings = this.initialSettings ?? InAppWebViewSettings();
    _inferInitialSettings(initialSettings);

    Map<String, dynamic> settingsMap =
        (this.initialSettings != null ? initialSettings.toMap() : null) ??
            // ignore: deprecated_member_use_from_same_package
            this.initialOptions?.toMap() ??
            initialSettings.toMap();

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
              'initialSettings': settingsMap,
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

  void _inferInitialSettings(InAppWebViewSettings settings) {
    if (this.shouldOverrideUrlLoading != null &&
        settings.useShouldOverrideUrlLoading == null) {
      settings.useShouldOverrideUrlLoading = true;
    }
    if (this.onLoadResource != null && settings.useOnLoadResource == null) {
      settings.useOnLoadResource = true;
    }
    if (this.onDownloadStartRequest != null &&
        settings.useOnDownloadStart == null) {
      settings.useOnDownloadStart = true;
    }
    if (this.shouldInterceptAjaxRequest != null &&
        settings.useShouldInterceptAjaxRequest == null) {
      settings.useShouldInterceptAjaxRequest = true;
    }
    if (this.shouldInterceptFetchRequest != null &&
        settings.useShouldInterceptFetchRequest == null) {
      settings.useShouldInterceptFetchRequest = true;
    }
    if (this.shouldInterceptRequest != null &&
        settings.useShouldInterceptRequest == null) {
      settings.useShouldInterceptRequest = true;
    }
    if (this.onRenderProcessGone != null &&
        settings.useOnRenderProcessGone == null) {
      settings.useOnRenderProcessGone = true;
    }
    if (this.onNavigationResponse != null &&
        settings.useOnNavigationResponse == null) {
      settings.useOnNavigationResponse = true;
    }
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

  ///{@macro flutter_inappwebview.WebView.contextMenu}
  @override
  final ContextMenu? contextMenu;

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

  ///{@macro flutter_inappwebview.WebView.implementation}
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

  ///{@macro flutter_inappwebview.WebView.onPageCommitVisible}
  @override
  void Function(InAppWebViewController controller, WebUri? url)?
      onPageCommitVisible;

  ///{@macro flutter_inappwebview.WebView.onTitleChanged}
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

  ///{@macro flutter_inappwebview.WebView.onAjaxProgress}
  @override
  Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxProgress;

  ///{@macro flutter_inappwebview.WebView.onAjaxReadyStateChange}
  @override
  Future<AjaxRequestAction?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxReadyStateChange;

  ///{@macro flutter_inappwebview.WebView.onConsoleMessage}
  @override
  void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;

  ///{@macro flutter_inappwebview.WebView.onCreateWindow}
  @override
  Future<bool?> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction)? onCreateWindow;

  ///{@macro flutter_inappwebview.WebView.onCloseWindow}
  @override
  void Function(InAppWebViewController controller)? onCloseWindow;

  ///{@macro flutter_inappwebview.WebView.onWindowFocus}
  @override
  void Function(InAppWebViewController controller)? onWindowFocus;

  ///{@macro flutter_inappwebview.WebView.onWindowBlur}
  @override
  void Function(InAppWebViewController controller)? onWindowBlur;

  ///Use [onDownloadStartRequest] instead
  @Deprecated('Use onDownloadStartRequest instead')
  @override
  void Function(InAppWebViewController controller, Uri url)? onDownloadStart;

  ///{@macro flutter_inappwebview.WebView.onDownloadStartRequest}
  @override
  void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  @override
  void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting)? onFindResultReceived;

  ///{@macro flutter_inappwebview.WebView.onJsAlert}
  @override
  Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;

  ///{@macro flutter_inappwebview.WebView.onJsConfirm}
  @override
  Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;

  ///{@macro flutter_inappwebview.WebView.onJsPrompt}
  @override
  Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  @override
  void Function(InAppWebViewController controller, Uri? url, int code,
      String message)? onLoadError;

  ///{@macro flutter_inappwebview.WebView.onReceivedError}
  @override
  void Function(InAppWebViewController controller, WebResourceRequest request,
      WebResourceError error)? onReceivedError;

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  @override
  void Function(InAppWebViewController controller, Uri? url, int statusCode,
      String description)? onLoadHttpError;

  ///{@macro flutter_inappwebview.WebView.onReceivedHttpError}
  @override
  void Function(InAppWebViewController controller, WebResourceRequest request,
      WebResourceResponse errorResponse)? onReceivedHttpError;

  ///{@macro flutter_inappwebview.WebView.onLoadResource}
  @override
  void Function(InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  @override
  Future<CustomSchemeResponse?> Function(
      InAppWebViewController controller, Uri url)? onLoadResourceCustomScheme;

  ///{@macro flutter_inappwebview.WebView.onLoadResourceWithCustomScheme}
  @override
  Future<CustomSchemeResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      onLoadResourceWithCustomScheme;

  ///{@macro flutter_inappwebview.WebView.onLoadStart}
  @override
  void Function(InAppWebViewController controller, WebUri? url)? onLoadStart;

  ///{@macro flutter_inappwebview.WebView.onLoadStop}
  @override
  void Function(InAppWebViewController controller, WebUri? url)? onLoadStop;

  ///{@macro flutter_inappwebview.WebView.onLongPressHitTestResult}
  @override
  void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  @override
  void Function(InAppWebViewController controller, Uri? url)? onPrint;

  ///{@macro flutter_inappwebview.WebView.onPrintRequest}
  @override
  Future<bool?> Function(InAppWebViewController controller, WebUri? url,
      PrintJobController? printJobController)? onPrintRequest;

  ///{@macro flutter_inappwebview.WebView.onProgressChanged}
  @override
  void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;

  ///{@macro flutter_inappwebview.WebView.onReceivedClientCertRequest}
  @override
  Future<ClientCertResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedClientCertRequest;

  ///{@macro flutter_inappwebview.WebView.onReceivedHttpAuthRequest}
  @override
  Future<HttpAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedHttpAuthRequest;

  ///{@macro flutter_inappwebview.WebView.onReceivedServerTrustAuthRequest}
  @override
  Future<ServerTrustAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedServerTrustAuthRequest;

  ///{@macro flutter_inappwebview.WebView.onScrollChanged}
  @override
  void Function(InAppWebViewController controller, int x, int y)?
      onScrollChanged;

  ///{@macro flutter_inappwebview.WebView.onUpdateVisitedHistory}
  @override
  void Function(InAppWebViewController controller, WebUri? url, bool? isReload)?
      onUpdateVisitedHistory;

  ///{@macro flutter_inappwebview.WebView.onWebViewCreated}
  @override
  void Function(InAppWebViewController controller)? onWebViewCreated;

  ///{@macro flutter_inappwebview.WebView.shouldInterceptAjaxRequest}
  @override
  Future<AjaxRequest?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;

  ///{@macro flutter_inappwebview.WebView.shouldInterceptFetchRequest}
  @override
  Future<FetchRequest?> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)?
      shouldInterceptFetchRequest;

  ///{@macro flutter_inappwebview.WebView.shouldOverrideUrlLoading}
  @override
  Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;

  ///{@macro flutter_inappwebview.WebView.onEnterFullscreen}
  @override
  void Function(InAppWebViewController controller)? onEnterFullscreen;

  ///{@macro flutter_inappwebview.WebView.onExitFullscreen}
  @override
  void Function(InAppWebViewController controller)? onExitFullscreen;

  ///{@macro flutter_inappwebview.WebView.onOverScrolled}
  @override
  void Function(InAppWebViewController controller, int x, int y, bool clampedX,
      bool clampedY)? onOverScrolled;

  ///{@macro flutter_inappwebview.WebView.onZoomScaleChanged}
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

  ///{@macro flutter_inappwebview.WebView.onDidReceiveServerRedirectForProvisionalNavigation}
  @override
  void Function(InAppWebViewController controller)?
      onDidReceiveServerRedirectForProvisionalNavigation;

  ///{@macro flutter_inappwebview.WebView.onFormResubmission}
  @override
  Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, WebUri? url)? onFormResubmission;

  ///{@macro flutter_inappwebview.WebView.onGeolocationPermissionsHidePrompt}
  @override
  void Function(InAppWebViewController controller)?
      onGeolocationPermissionsHidePrompt;

  ///{@macro flutter_inappwebview.WebView.onGeolocationPermissionsShowPrompt}
  @override
  Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      onGeolocationPermissionsShowPrompt;

  ///{@macro flutter_inappwebview.WebView.onJsBeforeUnload}
  @override
  Future<JsBeforeUnloadResponse?> Function(InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? onJsBeforeUnload;

  ///{@macro flutter_inappwebview.WebView.onNavigationResponse}
  @override
  Future<NavigationResponseAction?> Function(InAppWebViewController controller,
      NavigationResponse navigationResponse)? onNavigationResponse;

  ///{@macro flutter_inappwebview.WebView.onPermissionRequest}
  @override
  Future<PermissionResponse?> Function(InAppWebViewController controller,
      PermissionRequest permissionRequest)? onPermissionRequest;

  ///{@macro flutter_inappwebview.WebView.onReceivedIcon}
  @override
  void Function(InAppWebViewController controller, Uint8List icon)?
      onReceivedIcon;

  ///{@macro flutter_inappwebview.WebView.onReceivedLoginRequest}
  @override
  void Function(InAppWebViewController controller, LoginRequest loginRequest)?
      onReceivedLoginRequest;

  ///{@macro flutter_inappwebview.WebView.onPermissionRequestCanceled}
  @override
  void Function(InAppWebViewController controller,
      PermissionRequest permissionRequest)? onPermissionRequestCanceled;

  ///{@macro flutter_inappwebview.WebView.onRequestFocus}
  @override
  void Function(InAppWebViewController controller)? onRequestFocus;

  ///{@macro flutter_inappwebview.WebView.onReceivedTouchIconUrl}
  @override
  void Function(
          InAppWebViewController controller, WebUri url, bool precomposed)?
      onReceivedTouchIconUrl;

  ///{@macro flutter_inappwebview.WebView.onRenderProcessGone}
  @override
  void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      onRenderProcessGone;

  ///{@macro flutter_inappwebview.WebView.onRenderProcessResponsive}
  @override
  Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, WebUri? url)?
      onRenderProcessResponsive;

  ///{@macro flutter_inappwebview.WebView.onRenderProcessUnresponsive}
  @override
  Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, WebUri? url)?
      onRenderProcessUnresponsive;

  ///{@macro flutter_inappwebview.WebView.onSafeBrowsingHit}
  @override
  Future<SafeBrowsingResponse?> Function(InAppWebViewController controller,
      WebUri url, SafeBrowsingThreat? threatType)? onSafeBrowsingHit;

  ///{@macro flutter_inappwebview.WebView.onWebContentProcessDidTerminate}
  @override
  void Function(InAppWebViewController controller)?
      onWebContentProcessDidTerminate;

  ///{@macro flutter_inappwebview.WebView.shouldAllowDeprecatedTLS}
  @override
  Future<ShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? shouldAllowDeprecatedTLS;

  ///{@macro flutter_inappwebview.WebView.shouldInterceptRequest}
  @override
  Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      shouldInterceptRequest;

  ///{@macro flutter_inappwebview.WebView.onCameraCaptureStateChanged}
  @override
  Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onCameraCaptureStateChanged;

  ///{@macro flutter_inappwebview.WebView.onMicrophoneCaptureStateChanged}
  @override
  Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onMicrophoneCaptureStateChanged;

  ///{@macro flutter_inappwebview.WebView.onContentSizeChanged}
  @override
  void Function(InAppWebViewController controller, Size oldContentSize,
      Size newContentSize)? onContentSizeChanged;
}

extension InternalHeadlessInAppWebView on HeadlessInAppWebView {
  Future<void> internalDispose() async {
    _started = false;
    _running = false;
  }
}
