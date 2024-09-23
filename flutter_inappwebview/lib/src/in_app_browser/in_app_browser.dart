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
class InAppBrowser implements PlatformInAppBrowserEvents {
  /// Constructs a [InAppBrowser].
  ///
  /// {@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser}
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.contextMenu}
  ContextMenu? get contextMenu => platform.contextMenu;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.pullToRefreshController}
  PullToRefreshController? get pullToRefreshController {
    final pullToRefreshControllerPlatform = platform.pullToRefreshController;
    if (pullToRefreshControllerPlatform == null) {
      return null;
    }
    return PullToRefreshController.fromPlatform(
        platform: pullToRefreshControllerPlatform);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.findInteractionController}
  FindInteractionController? get findInteractionController {
    final findInteractionControllerPlatform =
        platform.findInteractionController;
    if (findInteractionControllerPlatform == null) {
      return null;
    }
    return FindInteractionController.fromPlatform(
        platform: findInteractionControllerPlatform);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.initialUserScripts}
  UnmodifiableListView<UserScript>? get initialUserScripts =>
      platform.initialUserScripts;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.windowId}
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
  Future<void> openUrlRequest(
      {required URLRequest urlRequest,
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    this.platform.eventHandler = this;
    return platform.openUrlRequest(
        urlRequest: urlRequest, options: options, settings: settings);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openFile}
  Future<void> openFile(
      {required String assetFilePath,
      @Deprecated('Use settings instead') InAppBrowserClassOptions? options,
      InAppBrowserClassSettings? settings}) {
    this.platform.eventHandler = this;
    return platform.openFile(
        assetFilePath: assetFilePath, options: options, settings: settings);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.openData}
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
  static Future<void> openWithSystemBrowser({required WebUri url}) =>
      PlatformInAppBrowser.static().openWithSystemBrowser(url: url);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItem}
  void addMenuItem(InAppBrowserMenuItem menuItem) =>
      platform.addMenuItem(menuItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.addMenuItems}
  void addMenuItems(List<InAppBrowserMenuItem> menuItems) =>
      platform.addMenuItems(menuItems);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItem}
  bool removeMenuItem(InAppBrowserMenuItem menuItem) =>
      platform.removeMenuItem(menuItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeMenuItems}
  void removeMenuItems(List<InAppBrowserMenuItem> menuItems) =>
      platform.removeMenuItems(menuItems);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.removeAllMenuItem}
  void removeAllMenuItem() => platform.removeAllMenuItem();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hasMenuItem}
  bool hasMenuItem(InAppBrowserMenuItem menuItem) =>
      platform.hasMenuItem(menuItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.show}
  Future<void> show() => platform.show();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.hide}
  Future<void> hide() => platform.hide();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.close}
  Future<void> close() => platform.close();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isHidden}
  Future<bool> isHidden() => platform.isHidden();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setOptions}
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppBrowserClassOptions options}) =>
      platform.setOptions(options: options);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getOptions}
  @Deprecated('Use getSettings instead')
  Future<InAppBrowserClassOptions?> getOptions() => platform.getOptions();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.setSettings}
  Future<void> setSettings({required InAppBrowserClassSettings settings}) =>
      platform.setSettings(settings: settings);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.getSettings}
  Future<InAppBrowserClassSettings?> getSettings() => platform.getSettings();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.isOpened}
  bool isOpened() => platform.isOpened();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppBrowser.dispose}
  @mustCallSuper
  void dispose() => platform.dispose();

  @override
  Future<FormResubmissionAction?>? androidOnFormResubmission(Uri? url) {
    return null;
  }

  @override
  void androidOnGeolocationPermissionsHidePrompt() {}

  @override
  Future<GeolocationPermissionShowPromptResponse?>?
      androidOnGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  @override
  Future<JsBeforeUnloadResponse?>? androidOnJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

  @override
  Future<PermissionRequestResponse?>? androidOnPermissionRequest(
      String origin, List<String> resources) {
    return null;
  }

  @override
  void androidOnReceivedIcon(Uint8List icon) {}

  @override
  void androidOnReceivedLoginRequest(LoginRequest loginRequest) {}

  @override
  void androidOnReceivedTouchIconUrl(Uri url, bool precomposed) {}

  @override
  void androidOnRenderProcessGone(RenderProcessGoneDetail detail) {}

  @override
  Future<WebViewRenderProcessAction?>? androidOnRenderProcessResponsive(
      Uri? url) {
    return null;
  }

  @override
  Future<WebViewRenderProcessAction?>? androidOnRenderProcessUnresponsive(
      Uri? url) {
    return null;
  }

  @override
  Future<SafeBrowsingResponse?>? androidOnSafeBrowsingHit(
      Uri url, SafeBrowsingThreat? threatType) {
    return null;
  }

  @override
  void androidOnScaleChanged(double oldScale, double newScale) {}

  @override
  Future<WebResourceResponse?>? androidShouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  @override
  void iosOnDidReceiveServerRedirectForProvisionalNavigation() {}

  @override
  Future<IOSNavigationResponseAction?>? iosOnNavigationResponse(
      IOSWKNavigationResponse navigationResponse) {
    return null;
  }

  @override
  void iosOnWebContentProcessDidTerminate() {}

  @override
  Future<IOSShouldAllowDeprecatedTLSAction?>? iosShouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  @override
  Future<AjaxRequestAction?>? onAjaxProgress(AjaxRequest ajaxRequest) {
    return null;
  }

  @override
  Future<AjaxRequestAction?>? onAjaxReadyStateChange(AjaxRequest ajaxRequest) {
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
  Future<bool?>? onCreateWindow(CreateWindowAction createWindowAction) {
    return null;
  }

  @override
  void onDidReceiveServerRedirectForProvisionalNavigation() {}

  @override
  void onDownloadStart(Uri url) {}

  @override
  void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {}

  @override
  void onEnterFullscreen() {}

  @override
  void onExit() {}

  @override
  void onExitFullscreen() {}

  @override
  void onFindResultReceived(
      int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {}

  @override
  Future<FormResubmissionAction?>? onFormResubmission(WebUri? url) {
    return null;
  }

  @override
  void onGeolocationPermissionsHidePrompt() {}

  @override
  Future<GeolocationPermissionShowPromptResponse?>?
      onGeolocationPermissionsShowPrompt(String origin) {
    return null;
  }

  @override
  Future<JsAlertResponse?>? onJsAlert(JsAlertRequest jsAlertRequest) {
    return null;
  }

  @override
  Future<JsBeforeUnloadResponse?>? onJsBeforeUnload(
      JsBeforeUnloadRequest jsBeforeUnloadRequest) {
    return null;
  }

  @override
  Future<JsConfirmResponse?>? onJsConfirm(JsConfirmRequest jsConfirmRequest) {
    return null;
  }

  @override
  Future<JsPromptResponse?>? onJsPrompt(JsPromptRequest jsPromptRequest) {
    return null;
  }

  @override
  void onLoadError(Uri? url, int code, String message) {}

  @override
  void onLoadHttpError(Uri? url, int statusCode, String description) {}

  @override
  void onLoadResource(LoadedResource resource) {}

  @override
  Future<CustomSchemeResponse?>? onLoadResourceCustomScheme(Uri url) {
    return null;
  }

  @override
  Future<CustomSchemeResponse?>? onLoadResourceWithCustomScheme(
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
  Future<NavigationResponseAction?>? onNavigationResponse(
      NavigationResponse navigationResponse) {
    return null;
  }

  @override
  void onOverScrolled(int x, int y, bool clampedX, bool clampedY) {}

  @override
  void onPageCommitVisible(WebUri? url) {}

  @override
  Future<PermissionResponse?>? onPermissionRequest(
      PermissionRequest permissionRequest) {
    return null;
  }

  @override
  void onPermissionRequestCanceled(PermissionRequest permissionRequest) {}

  @override
  void onPrint(Uri? url) {}

  @override
  Future<bool?>? onPrintRequest(
      WebUri? url, PlatformPrintJobController? printJobController) {
    return null;
  }

  @override
  void onProgressChanged(int progress) {}

  @override
  Future<ClientCertResponse?>? onReceivedClientCertRequest(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {}

  @override
  Future<HttpAuthResponse?>? onReceivedHttpAuthRequest(
      URLAuthenticationChallenge challenge) {
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
  Future<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  @override
  void onReceivedTouchIconUrl(WebUri url, bool precomposed) {}

  @override
  void onRenderProcessGone(RenderProcessGoneDetail detail) {}

  @override
  Future<WebViewRenderProcessAction?>? onRenderProcessResponsive(WebUri? url) {
    return null;
  }

  @override
  Future<WebViewRenderProcessAction?>? onRenderProcessUnresponsive(
      WebUri? url) {
    return null;
  }

  @override
  void onRequestFocus() {}

  @override
  Future<SafeBrowsingResponse?>? onSafeBrowsingHit(
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
  Future<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(
      URLAuthenticationChallenge challenge) {
    return null;
  }

  @override
  Future<AjaxRequest?>? shouldInterceptAjaxRequest(AjaxRequest ajaxRequest) {
    return null;
  }

  @override
  Future<FetchRequest?>? shouldInterceptFetchRequest(
      FetchRequest fetchRequest) {
    return null;
  }

  @override
  Future<WebResourceResponse?>? shouldInterceptRequest(
      WebResourceRequest request) {
    return null;
  }

  @override
  Future<NavigationActionPolicy?>? shouldOverrideUrlLoading(
      NavigationAction navigationAction) {
    return null;
  }

  @override
  void onMainWindowWillClose() {}
}
