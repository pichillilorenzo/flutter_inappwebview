import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'cookie_manager.dart';
import 'find_interaction/main.dart';
import 'http_auth_credentials_database.dart';
import 'in_app_browser/in_app_browser.dart';
import 'in_app_webview/main.dart';
import 'print_job/main.dart';
import 'proxy_controller.dart';
import 'web_authentication_session/main.dart';
import 'web_message/main.dart';
import 'web_storage/main.dart';

/// Implementation of [InAppWebViewPlatform] using the WebKit API.
class MacOSInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [InAppWebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = MacOSInAppWebViewPlatform();
  }

  /// Creates a new [MacOSCookieManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  MacOSCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return MacOSCookieManager(params);
  }

  /// Creates a new empty [MacOSCookieManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  MacOSCookieManager createPlatformCookieManagerStatic() {
    return MacOSCookieManager.static();
  }

  /// Creates a new [MacOSInAppWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  MacOSInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return MacOSInAppWebViewController(params);
  }

  /// Creates a new empty [MacOSInAppWebViewController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  MacOSInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return MacOSInAppWebViewController.static();
  }

  /// Creates a new [MacOSInAppWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  MacOSInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return MacOSInAppWebViewWidget(params);
  }

  /// Creates a new empty [MacOSInAppWebViewWidget] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  MacOSInAppWebViewWidget createPlatformInAppWebViewWidgetStatic() {
    return MacOSInAppWebViewWidget.static();
  }

  /// Creates a new [MacOSFindInteractionController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  @override
  MacOSFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return MacOSFindInteractionController(params);
  }

  /// Creates a new empty [MacOSFindInteractionController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  @override
  MacOSFindInteractionController
      createPlatformFindInteractionControllerStatic() {
    return MacOSFindInteractionController.static();
  }

  /// Creates a new [MacOSPrintJobController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  @override
  MacOSPrintJobController createPlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) {
    return MacOSPrintJobController(params);
  }

  /// Creates a new empty [PlatformPrintJobController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  @override
  MacOSPrintJobController createPlatformPrintJobControllerStatic() {
    return MacOSPrintJobController.static();
  }

  /// Creates a new empty [PlatformPullToRefreshController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PullToRefreshController] in `flutter_inappwebview` instead.
  @override
  PlatformPullToRefreshController
      createPlatformPullToRefreshControllerStatic() {
    return _PlatformPullToRefreshController.static();
  }

  /// Creates a new [MacOSWebMessageChannel].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  @override
  MacOSWebMessageChannel createPlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    return MacOSWebMessageChannel(params);
  }

  /// Creates a new empty [MacOSWebMessageChannel] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  @override
  MacOSWebMessageChannel createPlatformWebMessageChannelStatic() {
    return MacOSWebMessageChannel.static();
  }

  /// Creates a new [MacOSWebMessageListener].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  @override
  MacOSWebMessageListener createPlatformWebMessageListener(
    PlatformWebMessageListenerCreationParams params,
  ) {
    return MacOSWebMessageListener(params);
  }

  /// Creates a new empty [MacOSWebMessageListener] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  @override
  MacOSWebMessageListener createPlatformWebMessageListenerStatic() {
    return MacOSWebMessageListener.static();
  }

  /// Creates a new [MacOSJavaScriptReplyProxy].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [JavaScriptReplyProxy] in `flutter_inappwebview` instead.
  @override
  MacOSJavaScriptReplyProxy createPlatformJavaScriptReplyProxy(
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    return MacOSJavaScriptReplyProxy(params);
  }

  /// Creates a new [MacOSWebMessagePort].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessagePort] in `flutter_inappwebview` instead.
  @override
  MacOSWebMessagePort createPlatformWebMessagePort(
    PlatformWebMessagePortCreationParams params,
  ) {
    return MacOSWebMessagePort(params);
  }

  /// Creates a new [MacOSWebStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  @override
  MacOSWebStorage createPlatformWebStorage(
    PlatformWebStorageCreationParams params,
  ) {
    return MacOSWebStorage(params);
  }

  /// Creates a new empty [MacOSWebStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  @override
  MacOSWebStorage createPlatformWebStorageStatic() {
    return MacOSWebStorage(MacOSWebStorageCreationParams(
        localStorage: createPlatformLocalStorageStatic(),
        sessionStorage: createPlatformSessionStorageStatic()));
  }

  /// Creates a new [MacOSLocalStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  @override
  MacOSLocalStorage createPlatformLocalStorage(
    PlatformLocalStorageCreationParams params,
  ) {
    return MacOSLocalStorage(params);
  }

  /// Creates a new empty [MacOSLocalStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  @override
  MacOSLocalStorage createPlatformLocalStorageStatic() {
    return MacOSLocalStorage.defaultStorage(controller: null);
  }

  /// Creates a new [MacOSSessionStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [SessionStorage] in `flutter_inappwebview` instead.
  @override
  MacOSSessionStorage createPlatformSessionStorage(
    PlatformSessionStorageCreationParams params,
  ) {
    return MacOSSessionStorage(params);
  }

  /// Creates a new empty [MacOSSessionStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [SessionStorage] in `flutter_inappwebview` instead.
  @override
  MacOSSessionStorage createPlatformSessionStorageStatic() {
    return MacOSSessionStorage.defaultStorage(controller: null);
  }

  /// Creates a new [MacOSHeadlessInAppWebView].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  MacOSHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    return MacOSHeadlessInAppWebView(params);
  }

  /// Creates a new empty [MacOSHeadlessInAppWebView] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  MacOSHeadlessInAppWebView createPlatformHeadlessInAppWebViewStatic() {
    return MacOSHeadlessInAppWebView.static();
  }

  /// Creates a new [MacOSHttpAuthCredentialDatabase].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  @override
  MacOSHttpAuthCredentialDatabase createPlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    return MacOSHttpAuthCredentialDatabase(params);
  }

  /// Creates a new empty [MacOSHttpAuthCredentialDatabase] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  @override
  MacOSHttpAuthCredentialDatabase
      createPlatformHttpAuthCredentialDatabaseStatic() {
    return MacOSHttpAuthCredentialDatabase.static();
  }

  /// Creates a new [MacOSInAppBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  @override
  MacOSInAppBrowser createPlatformInAppBrowser(
    PlatformInAppBrowserCreationParams params,
  ) {
    return MacOSInAppBrowser(params);
  }

  /// Creates a new empty [MacOSInAppBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  @override
  MacOSInAppBrowser createPlatformInAppBrowserStatic() {
    return MacOSInAppBrowser.static();
  }

  /// Creates a new empty [MacOSWebStorageManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  @override
  MacOSWebStorageManager createPlatformWebStorageManager(
      PlatformWebStorageManagerCreationParams params) {
    return MacOSWebStorageManager(params);
  }

  /// Creates a new empty [MacOSWebStorageManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  @override
  MacOSWebStorageManager createPlatformWebStorageManagerStatic() {
    return MacOSWebStorageManager.static();
  }

  /// Creates a new [MacOSWebAuthenticationSession].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebAuthenticationSession] in `flutter_inappwebview` instead.
  @override
  MacOSWebAuthenticationSession createPlatformWebAuthenticationSession(
      PlatformWebAuthenticationSessionCreationParams params) {
    return MacOSWebAuthenticationSession(params);
  }

  /// Creates a new empty [MacOSWebAuthenticationSession] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebAuthenticationSession] in `flutter_inappwebview` instead.
  @override
  MacOSWebAuthenticationSession createPlatformWebAuthenticationSessionStatic() {
    return MacOSWebAuthenticationSession.static();
  }

  /// Creates a new [MacOSProxyController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  @override
  PlatformProxyController createPlatformProxyController(
      PlatformProxyControllerCreationParams params) {
    return MacOSProxyController(params);
  }

  /// Creates a new empty [MacOSProxyController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  @override
  MacOSProxyController createPlatformProxyControllerStatic() {
    return MacOSProxyController.static();
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

  /// Creates a new empty [PlatformChromeSafariBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    return _PlatformChromeSafariBrowser.static();
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

class _PlatformChromeSafariBrowser extends PlatformChromeSafariBrowser {
  _PlatformChromeSafariBrowser(PlatformChromeSafariBrowserCreationParams params)
      : super.implementation(params);
  static final _PlatformChromeSafariBrowser _staticValue =
      _PlatformChromeSafariBrowser(
          const PlatformChromeSafariBrowserCreationParams());

  factory _PlatformChromeSafariBrowser.static() => _staticValue;
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

class _PlatformPullToRefreshController extends PlatformPullToRefreshController {
  _PlatformPullToRefreshController(
      PlatformPullToRefreshControllerCreationParams params)
      : super.implementation(params);

  static final _PlatformPullToRefreshController _staticValue =
      _PlatformPullToRefreshController(
          PlatformPullToRefreshControllerCreationParams());

  factory _PlatformPullToRefreshController.static() => _staticValue;
}

class _PlatformWebViewEnvironment extends PlatformWebViewEnvironment {
  _PlatformWebViewEnvironment(PlatformWebViewEnvironmentCreationParams params)
      : super.implementation(params);
  static final _PlatformWebViewEnvironment _staticValue =
      _PlatformWebViewEnvironment(
          const PlatformWebViewEnvironmentCreationParams());

  factory _PlatformWebViewEnvironment.static() => _staticValue;
}
