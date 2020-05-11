import 'package:flutter/services.dart';

import 'types.dart';
import 'webview.dart';
import 'in_app_webview_controller.dart';

///Class that represents a WebView in headless mode.
///It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.
///
///Remember to dispose it when you don't need it anymore.
class HeadlessInAppWebView implements WebView {
  String uuid;
  bool _isDisposed = true;
  static const MethodChannel _sharedChannel = const MethodChannel('com.pichillilorenzo/flutter_headless_inappwebview');

  ///WebView Controller that can be used to access the [InAppWebViewController] API.
  InAppWebViewController webViewController;

  HeadlessInAppWebView(
      {this.onWebViewCreated,
        this.onLoadStart,
        this.onLoadStop,
        this.onLoadError,
        this.onLoadHttpError,
        this.onProgressChanged,
        this.onConsoleMessage,
        this.shouldOverrideUrlLoading,
        this.onLoadResource,
        this.onScrollChanged,
        this.onDownloadStart,
        this.onLoadResourceCustomScheme,
        this.onCreateWindow,
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
        this.androidOnSafeBrowsingHit,
        this.androidOnPermissionRequest,
        this.androidOnGeolocationPermissionsShowPrompt,
        this.androidOnGeolocationPermissionsHidePrompt,
        this.iosOnWebContentProcessDidTerminate,
        this.iosOnDidCommit,
        this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
        this.initialUrl,
        this.initialFile,
        this.initialData,
        this.initialHeaders,
        this.initialOptions}) {
    uuid = uuidGenerator.v4();
    webViewController = new InAppWebViewController(uuid, this);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onHeadlessWebViewCreated":
        onWebViewCreated(webViewController);
        break;
      default:
        return webViewController.handleMethod(call);
    }
  }

  ///Runs the headless WebView.
  Future<void> run() async {
    if (!_isDisposed) {
      return;
    }
    _isDisposed = false;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent('params', () => <String, dynamic>{
      'initialUrl': '${Uri.parse(this.initialUrl)}',
      'initialFile': this.initialFile,
      'initialData': this.initialData?.toMap(),
      'initialHeaders': this.initialHeaders,
      'initialOptions': this.initialOptions?.toMap()
    });
    await _sharedChannel.invokeMethod('createHeadlessWebView', args);
  }

  ///Disposes the headless WebView.
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _sharedChannel.invokeMethod('disposeHeadlessWebView', args);
    _isDisposed = true;
  }

  @override
  final Future<void> Function(InAppWebViewController controller)
  androidOnGeolocationPermissionsHidePrompt;

  @override
  final Future<GeolocationPermissionShowPromptResponse> Function(
      InAppWebViewController controller, String origin)
  androidOnGeolocationPermissionsShowPrompt;

  @override
  final Future<PermissionRequestResponse> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources) androidOnPermissionRequest;

  @override
  final Future<SafeBrowsingResponse> Function(InAppWebViewController controller,
      String url, SafeBrowsingThreat threatType) androidOnSafeBrowsingHit;

  @override
  final InAppWebViewInitialData initialData;

  @override
  final String initialFile;

  @override
  final Map<String, String> initialHeaders;

  @override
  final InAppWebViewGroupOptions initialOptions;

  @override
  final String initialUrl;

  @override
  final Future<void> Function(InAppWebViewController controller) iosOnDidCommit;

  @override
  final Future<void> Function(InAppWebViewController controller)
  iosOnDidReceiveServerRedirectForProvisionalNavigation;

  @override
  final Future<void> Function(InAppWebViewController controller)
  iosOnWebContentProcessDidTerminate;

  @override
  final Future<AjaxRequestAction> Function(
      InAppWebViewController controller, AjaxRequest ajaxRequest)
  onAjaxProgress;

  @override
  final Future<AjaxRequestAction> Function(
      InAppWebViewController controller, AjaxRequest ajaxRequest)
  onAjaxReadyStateChange;

  @override
  final void Function(
      InAppWebViewController controller, ConsoleMessage consoleMessage)
  onConsoleMessage;

  @override
  final void Function(InAppWebViewController controller,
      OnCreateWindowRequest onCreateWindowRequest) onCreateWindow;

  @override
  final void Function(InAppWebViewController controller, String url)
  onDownloadStart;

  @override
  final void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting) onFindResultReceived;

  @override
  final Future<JsAlertResponse> Function(
      InAppWebViewController controller, String message) onJsAlert;

  @override
  final Future<JsConfirmResponse> Function(
      InAppWebViewController controller, String message) onJsConfirm;

  @override
  final Future<JsPromptResponse> Function(InAppWebViewController controller,
      String message, String defaultValue) onJsPrompt;

  @override
  final void Function(InAppWebViewController controller, String url, int code,
      String message) onLoadError;

  @override
  final void Function(InAppWebViewController controller, String url,
      int statusCode, String description) onLoadHttpError;

  @override
  final void Function(
      InAppWebViewController controller, LoadedResource resource)
  onLoadResource;

  @override
  final Future<CustomSchemeResponse> Function(
      InAppWebViewController controller, String scheme, String url)
  onLoadResourceCustomScheme;

  @override
  final void Function(InAppWebViewController controller, String url)
  onLoadStart;

  @override
  final void Function(InAppWebViewController controller, String url) onLoadStop;

  @override
  final void Function(InAppWebViewController controller,
      LongPressHitTestResult hitTestResult) onLongPressHitTestResult;

  @override
  final void Function(InAppWebViewController controller, String url) onPrint;

  @override
  final void Function(InAppWebViewController controller, int progress)
  onProgressChanged;

  @override
  final Future<ClientCertResponse> Function(
      InAppWebViewController controller, ClientCertChallenge challenge)
  onReceivedClientCertRequest;

  @override
  final Future<HttpAuthResponse> Function(
      InAppWebViewController controller, HttpAuthChallenge challenge)
  onReceivedHttpAuthRequest;

  @override
  final Future<ServerTrustAuthResponse> Function(
      InAppWebViewController controller, ServerTrustChallenge challenge)
  onReceivedServerTrustAuthRequest;

  @override
  final void Function(InAppWebViewController controller, int x, int y)
  onScrollChanged;

  @override
  final void Function(
      InAppWebViewController controller, String url, bool androidIsReload)
  onUpdateVisitedHistory;

  @override
  final void Function(InAppWebViewController controller) onWebViewCreated;

  @override
  final Future<AjaxRequest> Function(
      InAppWebViewController controller, AjaxRequest ajaxRequest)
  shouldInterceptAjaxRequest;

  @override
  final Future<FetchRequest> Function(
      InAppWebViewController controller, FetchRequest fetchRequest)
  shouldInterceptFetchRequest;

  @override
  final Future<ShouldOverrideUrlLoadingAction> Function(
      InAppWebViewController controller,
      ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest)
  shouldOverrideUrlLoading;
}