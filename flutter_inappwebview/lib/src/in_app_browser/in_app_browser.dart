import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../find_interaction/find_interaction_controller.dart';
import '../pull_to_refresh/main.dart';

import '../in_app_webview/in_app_webview_controller.dart';
import '../webview_environment/webview_environment.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser}
///
///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.supported_platforms}
class InAppBrowser implements PlatformInAppBrowserEvents {
  ///Constructs a [InAppBrowser].
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.supported_platforms}
  InAppBrowser({
    ContextMenu? contextMenu,
    PullToRefreshController? pullToRefreshController,
    FindInteractionController? findInteractionController,
    UnmodifiableListView<UserScript>? initialUserScripts,
    int? windowId,
    WebViewEnvironment? webViewEnvironment,
  }) : this.fromPlatformCreationParams(
          PlatformInAppBrowserCreationParams(
            contextMenu: contextMenu,
            pullToRefreshController: pullToRefreshController?.platform,
            findInteractionController: findInteractionController?.platform,
            initialUserScripts: initialUserScripts,
            windowId: windowId,
            webViewEnvironment: webViewEnvironment?.platform,
          ),
        );

  /// Constructs a [InAppBrowser] from creation params for a specific
  /// platform.
  InAppBrowser.fromPlatformCreationParams(
    PlatformInAppBrowserCreationParams params,
  ) : this.fromPlatform(PlatformInAppBrowser(params));

  /// Constructs a [InAppBrowser] from a specific platform
  /// implementation.
  InAppBrowser.fromPlatform(this.platform) {
    this.platform.eventHandler = this;
  }

  /// Implementation of [PlatformInAppBrowser] for the current platform.
  final PlatformInAppBrowser platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.id}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.contextMenu}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.contextMenu.supported_platforms}
  ContextMenu? get contextMenu => platform.contextMenu;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.pullToRefreshController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.pullToRefreshController.supported_platforms}
  PullToRefreshController? get pullToRefreshController {
    final pullToRefreshControllerPlatform = platform.pullToRefreshController;
    if (pullToRefreshControllerPlatform == null) {
      return null;
    }
    return PullToRefreshController.fromPlatform(
        platform: pullToRefreshControllerPlatform);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.findInteractionController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.findInteractionController.supported_platforms}
  FindInteractionController? get findInteractionController {
    final findInteractionControllerPlatform =
        platform.findInteractionController;
    if (findInteractionControllerPlatform == null) {
      return null;
    }
    return FindInteractionController.fromPlatform(
        platform: findInteractionControllerPlatform);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.initialUserScripts}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.initialUserScripts.supported_platforms}
  UnmodifiableListView<UserScript>? get initialUserScripts =>
      platform.initialUserScripts;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewCreationParams.windowId}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.windowId.supported_platforms}
  int? get windowId => platform.windowId;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.webViewController}
  InAppWebViewController? get webViewController {
    final webViewControllerPlatform = platform.webViewController;
    if (webViewControllerPlatform == null) {
      return null;
    }
    return InAppWebViewController.fromPlatform(
        platform: webViewControllerPlatform);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openUrlRequest}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openUrlRequest.supported_platforms}
  Future<void> openUrlRequest(
      {required URLRequest urlRequest,
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    this.platform.eventHandler = this;
    return platform.openUrlRequest(
        urlRequest: urlRequest, options: options, settings: settings);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openFile}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openFile.supported_platforms}
  Future<void> openFile(
      {required String assetFilePath,
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    this.platform.eventHandler = this;
    return platform.openFile(
        assetFilePath: assetFilePath, options: options, settings: settings);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openData}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openData.supported_platforms}
  Future<void> openData(
      {required String data,
      String mimeType = "text/html",
      String encoding = "utf8",
      WebUri? baseUrl,
      @Deprecated("Use historyUrl instead") Uri? androidHistoryUrl,
      WebUri? historyUrl,
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    this.platform.eventHandler = this;
    return platform.openData(
        data: data,
        mimeType: mimeType,
        encoding: encoding,
        baseUrl: baseUrl,
        androidHistoryUrl: androidHistoryUrl,
        historyUrl: historyUrl,
        options: options,
        settings: settings);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openWithSystemBrowser}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openWithSystemBrowser.supported_platforms}
  static Future<void> openWithSystemBrowser({required WebUri url}) =>
      PlatformInAppBrowser.static().openWithSystemBrowser(url: url);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItem}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItem.supported_platforms}
  void addMenuItem(InAppBrowserMenuItem menuItem) =>
      platform.addMenuItem(menuItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItems}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItems.supported_platforms}
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) =>
      platform.addMenuItems(menuItems);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItem}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItem.supported_platforms}
  bool removeMenuItem(InAppBrowserMenuItem menuItem) =>
      platform.removeMenuItem(menuItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItems}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItems.supported_platforms}
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) =>
      platform.removeMenuItems(menuItems);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeAllMenuItem}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeAllMenuItem.supported_platforms}
  void removeAllMenuItem() => platform.removeAllMenuItem();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hasMenuItem}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hasMenuItem.supported_platforms}
  bool hasMenuItem(InAppBrowserMenuItem menuItem) =>
      platform.hasMenuItem(menuItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.show}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.show.supported_platforms}
  Future<void> show() => platform.show();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hide}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hide.supported_platforms}
  Future<void> hide() => platform.hide();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.close}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.close.supported_platforms}
  Future<void> close() => platform.close();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isHidden}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isHidden.supported_platforms}
  Future<bool> isHidden() => platform.isHidden();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setOptions}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setOptions.supported_platforms}
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppBrowserClassOptions options}) =>
      platform.setOptions(options: options);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getOptions}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getOptions.supported_platforms}
  @Deprecated('Use getSettings instead')
  Future<InAppBrowserClassOptions?> getOptions() => platform.getOptions();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setSettings}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setSettings.supported_platforms}
  Future<void> setSettings({required InAppBrowserClassSettings settings}) =>
      platform.setSettings(settings: settings);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getSettings}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getSettings.supported_platforms}
  Future<InAppBrowserClassSettings?> getSettings() => platform.getSettings();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isOpened}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isOpened.supported_platforms}
  bool isOpened() => platform.isOpened();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.dispose.supported_platforms}
  @mustCallSuper
  void dispose() => platform.dispose();

  ///Use [onFormResubmission] instead.
  @Deprecated('Use onFormResubmission instead')
  @override
  FutureOr<FormResubmissionAction?>? androidOnFormResubmission(Uri? url) {
    return null;
  }

  ///Use [onGeolocationPermissionsHidePrompt] instead.
  @Deprecated("Use onGeolocationPermissionsHidePrompt instead")
  @override
  void androidOnGeolocationPermissionsHidePrompt() {}

  ///Use [onGeolocationPermissionsShowPrompt] instead.
  @Deprecated("Use onGeolocationPermissionsShowPrompt instead")
  @override
  FutureOr<GeolocationPermissionShowPromptResponse?>?
      androidOnGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  ///Use [onJsBeforeUnload] instead.
  @Deprecated('Use onJsBeforeUnload instead')
  @override
  FutureOr<JsBeforeUnloadResponse?>? androidOnJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

  ///Use [onPermissionRequest] instead.
  @Deprecated("Use onPermissionRequest instead")
  @override
  FutureOr<PermissionRequestResponse?>? androidOnPermissionRequest(
      String origin, List<String> resources) {
    return null;
  }

  ///Use [onReceivedIcon] instead.
  @Deprecated('Use onReceivedIcon instead')
  @override
  void androidOnReceivedIcon(Uint8List icon) {}

  ///Use [onReceivedLoginRequest] instead.
  @Deprecated('Use onReceivedLoginRequest instead')
  @override
  void androidOnReceivedLoginRequest(LoginRequest loginRequest) {}

  ///Use [onReceivedTouchIconUrl] instead.
  @Deprecated('Use onReceivedTouchIconUrl instead')
  @override
  void androidOnReceivedTouchIconUrl(Uri url, bool precomposed) {}

  ///Use [onRenderProcessGone] instead.
  @Deprecated("Use onRenderProcessGone instead")
  @override
  void androidOnRenderProcessGone(RenderProcessGoneDetail detail) {}

  ///Use [onRenderProcessResponsive] instead.
  @Deprecated("Use onRenderProcessResponsive instead")
  @override
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessResponsive(
      Uri? url) {
    return null;
  }

  ///Use [onRenderProcessUnresponsive] instead.
  @Deprecated("Use onRenderProcessUnresponsive instead")
  @override
  FutureOr<WebViewRenderProcessAction?>? androidOnRenderProcessUnresponsive(
      Uri? url) {
    return null;
  }

  ///Use [onSafeBrowsingHit] instead.
  @Deprecated("Use onSafeBrowsingHit instead")
  @override
  FutureOr<SafeBrowsingResponse?>? androidOnSafeBrowsingHit(
      Uri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  ///Use [onZoomScaleChanged] instead.
  @Deprecated('Use onZoomScaleChanged instead')
  @override
  void androidOnScaleChanged(double oldScale, double newScale) {}

  ///Use [shouldInterceptRequest] instead.
  @Deprecated("Use shouldInterceptRequest instead")
  @override
  FutureOr<WebResourceResponse?>? androidShouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  ///Use [onDidReceiveServerRedirectForProvisionalNavigation] instead.
  @Deprecated('Use onDidReceiveServerRedirectForProvisionalNavigation instead')
  @override
  void iosOnDidReceiveServerRedirectForProvisionalNavigation() {}

  ///Use [onNavigationResponse] instead.
  @Deprecated('Use onNavigationResponse instead')
  @override
  FutureOr<IOSNavigationResponseAction?>? iosOnNavigationResponse(
      IOSWKNavigationResponse navigationResponse) {
    return null;
  }

  ///Use [onWebContentProcessDidTerminate] instead.
  @Deprecated('Use onWebContentProcessDidTerminate instead')
  @override
  void iosOnWebContentProcessDidTerminate() {}

  ///Use [shouldAllowDeprecatedTLS] instead.
  @Deprecated('Use shouldAllowDeprecatedTLS instead')
  @override
  FutureOr<IOSShouldAllowDeprecatedTLSAction?>? iosShouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  @override
  FutureOr<AjaxRequestAction?>? onAjaxProgress(AjaxRequest ajaxRequest) {
    return null;
  }

  @override
  FutureOr<AjaxRequestAction?>? onAjaxReadyStateChange(
      AjaxRequest ajaxRequest) {
    return null;
  }

  @override
  void onBrowserCreated() {}

  @override
  void onCameraCaptureStateChanged(
      MediaCaptureState? oldState, MediaCaptureState? newState) {}

  @override
  void onCloseWindow() {}

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {}

  @override
  void onContentSizeChanged(Size oldContentSize, Size newContentSize) {}

  @override
  FutureOr<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {
    return null;
  }

  @override
  void onDidReceiveServerRedirectForProvisionalNavigation() {}

  ///Use [onDownloadStarting] instead
  @Deprecated('Use onDownloadStarting instead')
  @override
  void onDownloadStart(Uri url) {}

  ///Use [onDownloadStarting] instead
  @Deprecated('Use onDownloadStarting instead')
  @override
  void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {}

  @override
  FutureOr<DownloadStartResponse?>? onDownloadStarting(
      DownloadStartRequest downloadStartRequest) {
    return null;
  }

  @override
  void onEnterFullscreen() {}

  @override
  void onExit() {}

  @override
  void onExitFullscreen() {}

  ///Use [FindInteractionController.onFindResultReceived] instead.
  @Deprecated('Use FindInteractionController.onFindResultReceived instead')
  @override
  void onFindResultReceived(
      int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {}

  @override
  FutureOr<FormResubmissionAction?>? onFormResubmission(WebUri? url) {
    return null;
  }

  @override
  void onGeolocationPermissionsHidePrompt() {}

  @override
  FutureOr<GeolocationPermissionShowPromptResponse?>?
      onGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  @override
  FutureOr<JsAlertResponse?>? onJsAlert(JsAlertRequest jsAlertRequest) {
    return null;
  }

  @override
  FutureOr<JsBeforeUnloadResponse?>? onJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

  @override
  FutureOr<JsConfirmResponse?>? onJsConfirm(JsConfirmRequest jsConfirmRequest) {
    return null;
  }

  @override
  FutureOr<JsPromptResponse?>? onJsPrompt(JsPromptRequest jsPromptRequest) {
    return null;
  }

  ///Use [onReceivedError] instead.
  @Deprecated("Use onReceivedError instead")
  @override
  void onLoadError(Uri? url, int code, String message) {}

  ///Use [onReceivedHttpError] instead.
  @Deprecated("Use onReceivedHttpError instead")
  @override
  void onLoadHttpError(Uri? url, int statusCode, String description) {}

  @override
  void onLoadResource(LoadedResource resource) {}

  ///Use [onLoadResourceWithCustomScheme] instead.
  @Deprecated('Use onLoadResourceWithCustomScheme instead')
  @override
  FutureOr<CustomSchemeResponse?>? onLoadResourceCustomScheme(Uri url) {
    return null;
  }

  @override
  FutureOr<CustomSchemeResponse?>? onLoadResourceWithCustomScheme(
      WebResourceRequest request) {
    return null;
  }

  @override
  void onLoadStart(WebUri? url) {}

  @override
  void onLoadStop(WebUri? url) {}

  @override
  void onLongPressHitTestResult(InAppWebViewHitTestResult hitTestResult) {}

  @override
  void onMicrophoneCaptureStateChanged(
      MediaCaptureState? oldState, MediaCaptureState? newState) {}

  @override
  FutureOr<NavigationResponseAction?>? onNavigationResponse(
      NavigationResponse navigationResponse) {
    return null;
  }

  @override
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY) {}

  @override
  void onPageCommitVisible(WebUri? url) {}

  @override
  FutureOr<PermissionResponse?>? onPermissionRequest(
      PermissionRequest permissionRequest) {
    return null;
  }

  @override
  void onPermissionRequestCanceled(PermissionRequest permissionRequest) {}

  ///Use [onPrintRequest] instead
  @Deprecated("Use onPrintRequest instead")
  @override
  void onPrint(Uri? url) {}

  @override
  FutureOr<bool?>? onPrintRequest(
      WebUri? url, PlatformPrintJobController? printJobController) {
    return null;
  }

  @override
  void onProgressChanged(int progress) {}

  @override
  FutureOr<ClientCertResponse?>? onReceivedClientCertRequest(
      ClientCertChallenge challenge) {
    return null;
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {}

  @override
  FutureOr<HttpAuthResponse?>? onReceivedHttpAuthRequest(
      HttpAuthenticationChallenge challenge) {
    return null;
  }

  @override
  void onReceivedHttpError(
      WebResourceRequest request, WebResourceResponse errorResponse) {}

  @override
  void onReceivedIcon(Uint8List icon) {}

  @override
  void onReceivedLoginRequest(LoginRequest loginRequest) {}

  @override
  FutureOr<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(
      ServerTrustChallenge challenge) {
    return null;
  }

  @override
  void onReceivedTouchIconUrl(WebUri url, bool precomposed) {}

  @override
  void onRenderProcessGone(RenderProcessGoneDetail detail) {}

  @override
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessResponsive(
      WebUri? url) {
    return null;
  }

  @override
  FutureOr<WebViewRenderProcessAction?>? onRenderProcessUnresponsive(
      WebUri? url) {
    return null;
  }

  @override
  void onRequestFocus() {}

  @override
  FutureOr<SafeBrowsingResponse?>? onSafeBrowsingHit(
      WebUri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  @override
  void onScrollChanged(int x, int y) {}

  @override
  void onTitleChanged(String? title) {}

  @override
  void onUpdateVisitedHistory(WebUri? url, bool? isReload) {}

  @override
  void onWebContentProcessDidTerminate() {}

  @override
  void onWindowBlur() {}

  @override
  void onWindowFocus() {}

  @override
  void onZoomScaleChanged(double oldScale, double newScale) {}

  @override
  FutureOr<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  @override
  FutureOr<AjaxRequest?>? shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {
    return null;
  }

  @override
  FutureOr<FetchRequest?>? shouldInterceptFetchRequest(
      FetchRequest fetchRequest) {
    return null;
  }

  @override
  FutureOr<WebResourceResponse?>? shouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  @override
  FutureOr<NavigationActionPolicy?>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) {
    return null;
  }

  @override
  void onMainWindowWillClose() {}

  @override
  void onProcessFailed(ProcessFailedDetail detail) {}

  @override
  void onAcceleratorKeyPressed(AcceleratorKeyPressedDetail detail) {}

  @override
  FutureOr<ShowFileChooserResponse?> onShowFileChooser(
      ShowFileChooserRequest request) {
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformInAppBrowser.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isPropertySupported}
  static bool isPropertySupported(PlatformInAppBrowserProperty property,
          {TargetPlatform? platform}) =>
      PlatformInAppBrowser.static()
          .isPropertySupported(property, platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isMethodSupported}
  static bool isMethodSupported(PlatformInAppBrowserMethod property,
          {TargetPlatform? platform}) =>
      PlatformInAppBrowser.static()
          .isMethodSupported(property, platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowserEvents.isMethodSupported}
  static bool isEventMethodSupported(PlatformInAppBrowserEventsMethod method,
          {TargetPlatform? platform}) =>
      PlatformInAppBrowserEvents.isMethodSupported(method, platform: platform);
}
