import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'chrome_safari_browser/chrome_safari_browser.dart';
import 'cookie_manager.dart';
import 'find_interaction/main.dart';
import 'http_auth_credentials_database.dart';
import 'in_app_browser/in_app_browser.dart';
import 'in_app_webview/main.dart';
import 'print_job/main.dart';
import 'proxy_controller.dart';
import 'pull_to_refresh/main.dart';
import 'web_authentication_session/main.dart';
import 'web_message/main.dart';
import 'web_storage/main.dart';

/// Implementation of [InAppWebViewPlatform] using the WebKit API.
class IOSInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [InAppWebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = IOSInAppWebViewPlatform();
  }

  /// Creates a new [IOSCookieManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  IOSCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return IOSCookieManager(params);
  }

  /// Creates a new empty [IOSCookieManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  IOSCookieManager createPlatformCookieManagerStatic() {
    return IOSCookieManager.static();
  }

  /// Creates a new [IOSInAppWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  IOSInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return IOSInAppWebViewController(params);
  }

  /// Creates a new empty [IOSInAppWebViewController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  IOSInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return IOSInAppWebViewController.static();
  }

  /// Creates a new [IOSInAppWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  IOSInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return IOSInAppWebViewWidget(params);
  }

  /// Creates a new empty [IOSInAppWebViewWidget] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  IOSInAppWebViewWidget createPlatformInAppWebViewWidgetStatic() {
    return IOSInAppWebViewWidget.static();
  }

  /// Creates a new [IOSFindInteractionController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  @override
  IOSFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return IOSFindInteractionController(params);
  }

  /// Creates a new empty [IOSFindInteractionController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  @override
  IOSFindInteractionController createPlatformFindInteractionControllerStatic() {
    return IOSFindInteractionController.static();
  }

  /// Creates a new [IOSPrintJobController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  @override
  IOSPrintJobController createPlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) {
    return IOSPrintJobController(params);
  }

  /// Creates a new empty [PlatformPrintJobController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  @override
  IOSPrintJobController createPlatformPrintJobControllerStatic() {
    return IOSPrintJobController.static();
  }

  /// Creates a new [IOSPullToRefreshController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PullToRefreshController] in `flutter_inappwebview` instead.
  @override
  IOSPullToRefreshController createPlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) {
    return IOSPullToRefreshController(params);
  }

  /// Creates a new empty [IOSPullToRefreshController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PullToRefreshController] in `flutter_inappwebview` instead.
  @override
  IOSPullToRefreshController createPlatformPullToRefreshControllerStatic() {
    return IOSPullToRefreshController.static();
  }

  /// Creates a new [IOSWebMessageChannel].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  @override
  IOSWebMessageChannel createPlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    return IOSWebMessageChannel(params);
  }

  /// Creates a new empty [IOSWebMessageChannel] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  @override
  IOSWebMessageChannel createPlatformWebMessageChannelStatic() {
    return IOSWebMessageChannel.static();
  }

  /// Creates a new [IOSWebMessageListener].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  @override
  IOSWebMessageListener createPlatformWebMessageListener(
    PlatformWebMessageListenerCreationParams params,
  ) {
    return IOSWebMessageListener(params);
  }

  /// Creates a new empty [IOSWebMessageListener] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  @override
  IOSWebMessageListener createPlatformWebMessageListenerStatic() {
    return IOSWebMessageListener.static();
  }

  /// Creates a new [IOSJavaScriptReplyProxy].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [JavaScriptReplyProxy] in `flutter_inappwebview` instead.
  @override
  IOSJavaScriptReplyProxy createPlatformJavaScriptReplyProxy(
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    return IOSJavaScriptReplyProxy(params);
  }

  /// Creates a new [IOSWebMessagePort].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessagePort] in `flutter_inappwebview` instead.
  @override
  IOSWebMessagePort createPlatformWebMessagePort(
    PlatformWebMessagePortCreationParams params,
  ) {
    return IOSWebMessagePort(params);
  }

  /// Creates a new [IOSWebStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  @override
  IOSWebStorage createPlatformWebStorage(
    PlatformWebStorageCreationParams params,
  ) {
    return IOSWebStorage(params);
  }

  /// Creates a new empty [IOSWebStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  @override
  IOSWebStorage createPlatformWebStorageStatic() {
    return IOSWebStorage(IOSWebStorageCreationParams(
        localStorage: createPlatformLocalStorageStatic(),
        sessionStorage: createPlatformSessionStorageStatic()));
  }

  /// Creates a new [IOSLocalStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  @override
  IOSLocalStorage createPlatformLocalStorage(
    PlatformLocalStorageCreationParams params,
  ) {
    return IOSLocalStorage(params);
  }

  /// Creates a new empty [IOSLocalStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  @override
  IOSLocalStorage createPlatformLocalStorageStatic() {
    return IOSLocalStorage.defaultStorage(controller: null);
  }

  /// Creates a new [IOSSessionStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [SessionStorage] in `flutter_inappwebview` instead.
  @override
  IOSSessionStorage createPlatformSessionStorage(
    PlatformSessionStorageCreationParams params,
  ) {
    return IOSSessionStorage(params);
  }

  /// Creates a new empty [IOSSessionStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [SessionStorage] in `flutter_inappwebview` instead.
  @override
  IOSSessionStorage createPlatformSessionStorageStatic() {
    return IOSSessionStorage.defaultStorage(controller: null);
  }

  /// Creates a new [IOSHeadlessInAppWebView].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  IOSHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    return IOSHeadlessInAppWebView(params);
  }

  /// Creates a new empty [IOSHeadlessInAppWebView] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  IOSHeadlessInAppWebView createPlatformHeadlessInAppWebViewStatic() {
    return IOSHeadlessInAppWebView.static();
  }

  /// Creates a new [IOSHttpAuthCredentialDatabase].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  @override
  IOSHttpAuthCredentialDatabase createPlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    return IOSHttpAuthCredentialDatabase(params);
  }

  /// Creates a new empty [IOSHttpAuthCredentialDatabase] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  @override
  IOSHttpAuthCredentialDatabase
      createPlatformHttpAuthCredentialDatabaseStatic() {
    return IOSHttpAuthCredentialDatabase.static();
  }

  /// Creates a new [IOSInAppBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  @override
  IOSInAppBrowser createPlatformInAppBrowser(
    PlatformInAppBrowserCreationParams params,
  ) {
    return IOSInAppBrowser(params);
  }

  /// Creates a new empty [IOSInAppBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  @override
  IOSInAppBrowser createPlatformInAppBrowserStatic() {
    return IOSInAppBrowser.static();
  }

  /// Creates a new [IOSChromeSafariBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  @override
  IOSChromeSafariBrowser createPlatformChromeSafariBrowser(
    PlatformChromeSafariBrowserCreationParams params,
  ) {
    return IOSChromeSafariBrowser(params);
  }

  /// Creates a new empty [IOSChromeSafariBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  @override
  IOSChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    return IOSChromeSafariBrowser.static();
  }

  /// Creates a new empty [IOSWebStorageManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  @override
  IOSWebStorageManager createPlatformWebStorageManager(
      PlatformWebStorageManagerCreationParams params) {
    return IOSWebStorageManager(params);
  }

  /// Creates a new empty [IOSWebStorageManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  @override
  IOSWebStorageManager createPlatformWebStorageManagerStatic() {
    return IOSWebStorageManager.static();
  }

  /// Creates a new [IOSWebAuthenticationSession].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebAuthenticationSession] in `flutter_inappwebview` instead.
  @override
  IOSWebAuthenticationSession createPlatformWebAuthenticationSession(
      PlatformWebAuthenticationSessionCreationParams params) {
    return IOSWebAuthenticationSession(params);
  }

  /// Creates a new empty [IOSWebAuthenticationSession] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebAuthenticationSession] in `flutter_inappwebview` instead.
  @override
  IOSWebAuthenticationSession createPlatformWebAuthenticationSessionStatic() {
    return IOSWebAuthenticationSession.static();
  }

  /// Creates a new [IOSProxyController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  @override
  PlatformProxyController createPlatformProxyController(
      PlatformProxyControllerCreationParams params) {
    return IOSProxyController(params);
  }

  /// Creates a new empty [IOSProxyController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  @override
  IOSProxyController createPlatformProxyControllerStatic() {
    return IOSProxyController.static();
  }

  // ************************************************************************ //
  // Create static instances of unsupported classes to be able to call        //
  // isClassSupported, isMethodSupported, isPropertySupported, etc.           //
  // static methods without throwing a missing platform implementation        //
  // exception.                                                               //
  // ************************************************************************ //

  /// Creates a new empty [PlatformWebViewEnvironment] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewEnvironment] in `flutter_inappwebview` instead.
  @override
  PlatformWebViewEnvironment createPlatformWebViewEnvironmentStatic() {
    return _PlatformWebViewEnvironment.static();
  }

  /// Creates a new empty [PlatformProcessGlobalConfig] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProcessGlobalConfig] in `flutter_inappwebview` instead.
  @override
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfigStatic() {
    return _PlatformProcessGlobalConfig.static();
  }

  /// Creates a new empty [PlatformServiceWorkerController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ServiceWorkerController] in `flutter_inappwebview` instead.
  @override
  PlatformServiceWorkerController
      createPlatformServiceWorkerControllerStatic() {
    return _PlatformServiceWorkerController.static();
  }

  /// Creates a new empty [PlatformTracingController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [TracingController] in `flutter_inappwebview` instead.
  @override
  PlatformTracingController createPlatformTracingControllerStatic() {
    return _PlatformTracingController.static();
  }
}

class _PlatformProcessGlobalConfig extends PlatformProcessGlobalConfig {
  _PlatformProcessGlobalConfig(PlatformProcessGlobalConfigCreationParams params)
      : super.implementation(params);
  static final _PlatformProcessGlobalConfig _staticValue =
      _PlatformProcessGlobalConfig(
          const PlatformProcessGlobalConfigCreationParams());

  factory _PlatformProcessGlobalConfig.static() => _staticValue;
}

class _PlatformServiceWorkerController extends PlatformServiceWorkerController {
  _PlatformServiceWorkerController(
      PlatformServiceWorkerControllerCreationParams params)
      : super.implementation(params);
  static final _PlatformServiceWorkerController _staticValue =
      _PlatformServiceWorkerController(
          const PlatformServiceWorkerControllerCreationParams());

  factory _PlatformServiceWorkerController.static() => _staticValue;

  @override
  ServiceWorkerClient? get serviceWorkerClient => throw UnimplementedError();
}

class _PlatformTracingController extends PlatformTracingController {
  _PlatformTracingController(PlatformTracingControllerCreationParams params)
      : super.implementation(params);
  static final _PlatformTracingController _staticValue =
      _PlatformTracingController(
          const PlatformTracingControllerCreationParams());

  factory _PlatformTracingController.static() => _staticValue;
}

class _PlatformWebViewEnvironment extends PlatformWebViewEnvironment {
  _PlatformWebViewEnvironment(PlatformWebViewEnvironmentCreationParams params)
      : super.implementation(params);
  static final _PlatformWebViewEnvironment _staticValue =
      _PlatformWebViewEnvironment(
          const PlatformWebViewEnvironmentCreationParams());

  factory _PlatformWebViewEnvironment.static() => _staticValue;
}
