import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'cookie_manager.dart';
import 'in_app_webview/main.dart';

/// Implementation of [InAppWebViewPlatform] using the Web API.
class WebPlatformInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [InAppWebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = WebPlatformInAppWebViewPlatform();
  }

  /// Creates a new [WebPlatformCookieManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  WebPlatformCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return WebPlatformCookieManager(params);
  }

  /// Creates a new empty [WebPlatformCookieManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  WebPlatformCookieManager createPlatformCookieManagerStatic() {
    return WebPlatformCookieManager.static();
  }

  /// Creates a new [WebPlatformInAppWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  WebPlatformInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return WebPlatformInAppWebViewController(params);
  }

  /// Creates a new empty [WebPlatformInAppWebViewController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  WebPlatformInAppWebViewController
      createPlatformInAppWebViewControllerStatic() {
    return WebPlatformInAppWebViewController.static();
  }

  /// Creates a new [WebPlatformInAppWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  WebPlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return WebPlatformInAppWebViewWidget(params);
  }

  /// Creates a new empty [WebPlatformInAppWebViewWidget] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  WebPlatformInAppWebViewWidget createPlatformInAppWebViewWidgetStatic() {
    return WebPlatformInAppWebViewWidget.static();
  }

  /// Creates a new [WebPlatformHeadlessInAppWebView].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  WebPlatformHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    return WebPlatformHeadlessInAppWebView(params);
  }

  /// Creates a new empty [WebPlatformHeadlessInAppWebView] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  WebPlatformHeadlessInAppWebView createPlatformHeadlessInAppWebViewStatic() {
    return WebPlatformHeadlessInAppWebView.static();
  }

  // ************************************************************************ //
  // Create static instances of unsupported classes to be able to call        //
  // isClassSupported, isMethodSupported, isPropertySupported, etc.           //
  // static methods without throwing a missing platform implementation        //
  // exception.                                                               //
  // ************************************************************************ //

  /// Creates a new empty [PlatformInAppBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  @override
  PlatformInAppBrowser createPlatformInAppBrowserStatic() {
    return _PlatformInAppBrowser.static();
  }

  /// Creates a new empty [PlatformChromeSafariBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    return _PlatformChromeSafariBrowser.static();
  }

  /// Creates a new empty [PlatformHttpAuthCredentialDatabase] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  @override
  PlatformHttpAuthCredentialDatabase
      createPlatformHttpAuthCredentialDatabaseStatic() {
    return _PlatformHttpAuthCredentialDatabase.static();
  }

  /// Creates a new empty [PlatformProcessGlobalConfig] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProcessGlobalConfig] in `flutter_inappwebview` instead.
  @override
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfigStatic() {
    return _PlatformProcessGlobalConfig.static();
  }

  /// Creates a new empty [PlatformProxyController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  @override
  PlatformProxyController createPlatformProxyControllerStatic() {
    return _PlatformProxyController.static();
  }

  /// Creates a new empty [PlatformServiceWorkerController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ServiceWorkerController] in `flutter_inappwebview` instead.
  @override
  PlatformServiceWorkerController createPlatformServiceWorkerControllerStatic() {
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

  /// Creates a new empty [PlatformFindInteractionController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  @override
  PlatformFindInteractionController createPlatformFindInteractionControllerStatic() {
    return _PlatformFindInteractionController.static();
  }

  /// Creates a new empty [PlatformPrintJobController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  @override
  PlatformPrintJobController createPlatformPrintJobControllerStatic() {
    return _PlatformPrintJobController.static();
  }
}

class _PlatformInAppBrowser extends PlatformInAppBrowser {
  _PlatformInAppBrowser(PlatformInAppBrowserCreationParams params)
      : super.implementation(params);
  static final _PlatformInAppBrowser _staticValue =
      _PlatformInAppBrowser(const PlatformInAppBrowserCreationParams());

  factory _PlatformInAppBrowser.static() => _staticValue;
}

class _PlatformChromeSafariBrowser extends PlatformChromeSafariBrowser {
  _PlatformChromeSafariBrowser(PlatformChromeSafariBrowserCreationParams params)
      : super.implementation(params);
  static final _PlatformChromeSafariBrowser _staticValue =
      _PlatformChromeSafariBrowser(
          const PlatformChromeSafariBrowserCreationParams());

  factory _PlatformChromeSafariBrowser.static() => _staticValue;
}

class _PlatformHttpAuthCredentialDatabase
    extends PlatformHttpAuthCredentialDatabase {
  _PlatformHttpAuthCredentialDatabase(
      PlatformHttpAuthCredentialDatabaseCreationParams params)
      : super.implementation(params);
  static final _PlatformHttpAuthCredentialDatabase _staticValue =
      _PlatformHttpAuthCredentialDatabase(
          const PlatformHttpAuthCredentialDatabaseCreationParams());

  factory _PlatformHttpAuthCredentialDatabase.static() => _staticValue;
}

class _PlatformProcessGlobalConfig extends PlatformProcessGlobalConfig {
  _PlatformProcessGlobalConfig(PlatformProcessGlobalConfigCreationParams params)
      : super.implementation(params);
  static final _PlatformProcessGlobalConfig _staticValue =
      _PlatformProcessGlobalConfig(
          const PlatformProcessGlobalConfigCreationParams());

  factory _PlatformProcessGlobalConfig.static() => _staticValue;
}

class _PlatformProxyController extends PlatformProxyController {
  _PlatformProxyController(PlatformProxyControllerCreationParams params)
      : super.implementation(params);
  static final _PlatformProxyController _staticValue =
      _PlatformProxyController(const PlatformProxyControllerCreationParams());

  factory _PlatformProxyController.static() => _staticValue;
}

class _PlatformServiceWorkerController extends PlatformServiceWorkerController {
  _PlatformServiceWorkerController(PlatformServiceWorkerControllerCreationParams params)
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

class _PlatformFindInteractionController extends PlatformFindInteractionController {
  _PlatformFindInteractionController(PlatformFindInteractionControllerCreationParams params)
      : super.implementation(params);
  static final _PlatformFindInteractionController _staticValue =
  _PlatformFindInteractionController(
      const PlatformFindInteractionControllerCreationParams());

  factory _PlatformFindInteractionController.static() => _staticValue;
}

class _PlatformPrintJobController extends PlatformPrintJobController {
  _PlatformPrintJobController(PlatformPrintJobControllerCreationParams params)
      : super.implementation(params);

  static final _PlatformPrintJobController _staticValue =
      _PlatformPrintJobController(
          const PlatformPrintJobControllerCreationParams(id: ''));

  factory _PlatformPrintJobController.static() => _staticValue;
}
