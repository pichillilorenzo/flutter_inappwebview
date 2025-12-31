import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'cookie_manager/cookie_manager.dart';
import 'in_app_webview/in_app_webview.dart';
import 'in_app_webview/in_app_webview_controller.dart';

/// Implementation of [InAppWebViewPlatform] using WPE WebKit.
class LinuxInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [InAppWebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = LinuxInAppWebViewPlatform();
  }

  /// Creates a new [LinuxInAppWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  LinuxInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return LinuxInAppWebViewController(params);
  }

  /// Creates a new empty [LinuxInAppWebViewController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  LinuxInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return LinuxInAppWebViewController.static();
  }

  /// Creates a new [LinuxInAppWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  LinuxInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return LinuxInAppWebViewWidget(params);
  }

  /// Creates a new empty [LinuxInAppWebViewWidget] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  LinuxInAppWebViewWidget createPlatformInAppWebViewWidgetStatic() {
    return LinuxInAppWebViewWidget.static();
  }

  /// Creates a new empty [PlatformCookieManager] to access static methods.
  @override
  PlatformCookieManager createPlatformCookieManagerStatic() {
    return LinuxCookieManager.static();
  }

  /// Creates a new [LinuxCookieManager].
  @override
  LinuxCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return LinuxCookieManager(params);
  }

  // ************************************************************************ //
  // Create static instances of unsupported classes to be able to call        //
  // isClassSupported, isMethodSupported, isPropertySupported, etc.           //
  // static methods without throwing a missing platform implementation        //
  // exception.                                                               //
  // ************************************************************************ //

  /// Creates a new empty [PlatformChromeSafariBrowser] to access static methods.
  @override
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    return _PlatformChromeSafariBrowser.static();
  }

  /// Creates a new empty [PlatformHttpAuthCredentialDatabase] to access static methods.
  @override
  PlatformHttpAuthCredentialDatabase
      createPlatformHttpAuthCredentialDatabaseStatic() {
    return _PlatformHttpAuthCredentialDatabase.static();
  }

  /// Creates a new empty [PlatformInAppBrowser] to access static methods.
  @override
  PlatformInAppBrowser createPlatformInAppBrowserStatic() {
    return _PlatformInAppBrowser.static();
  }

  /// Creates a new empty [PlatformHeadlessInAppWebView] to access static methods.
  @override
  PlatformHeadlessInAppWebView createPlatformHeadlessInAppWebViewStatic() {
    return _PlatformHeadlessInAppWebView.static();
  }

  /// Creates a new empty [PlatformProcessGlobalConfig] to access static methods.
  @override
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfigStatic() {
    return _PlatformProcessGlobalConfig.static();
  }

  /// Creates a new empty [PlatformProxyController] to access static methods.
  @override
  PlatformProxyController createPlatformProxyControllerStatic() {
    return _PlatformProxyController.static();
  }

  /// Creates a new empty [PlatformServiceWorkerController] to access static methods.
  @override
  PlatformServiceWorkerController
      createPlatformServiceWorkerControllerStatic() {
    return _PlatformServiceWorkerController.static();
  }

  /// Creates a new empty [PlatformTracingController] to access static methods.
  @override
  PlatformTracingController createPlatformTracingControllerStatic() {
    return _PlatformTracingController.static();
  }

  /// Creates a new empty [PlatformFindInteractionController] to access static methods.
  @override
  PlatformFindInteractionController
      createPlatformFindInteractionControllerStatic() {
    return _PlatformFindInteractionController.static();
  }

  /// Creates a new empty [PlatformPrintJobController] to access static methods.
  @override
  PlatformPrintJobController createPlatformPrintJobControllerStatic() {
    return _PlatformPrintJobController.static();
  }

  /// Creates a new empty [PlatformPullToRefreshController] to access static methods.
  @override
  PlatformPullToRefreshController
      createPlatformPullToRefreshControllerStatic() {
    return _PlatformPullToRefreshController.static();
  }

  /// Creates a new empty [PlatformWebAuthenticationSession] to access static methods.
  @override
  PlatformWebAuthenticationSession
      createPlatformWebAuthenticationSessionStatic() {
    return _PlatformWebAuthenticationSession.static();
  }

  /// Creates a new empty [PlatformWebMessageChannel] to access static methods.
  @override
  PlatformWebMessageChannel createPlatformWebMessageChannelStatic() {
    return _PlatformWebMessageChannel.static();
  }

  /// Creates a new empty [PlatformWebMessageListener] to access static methods.
  @override
  PlatformWebMessageListener createPlatformWebMessageListenerStatic() {
    return _PlatformWebMessageListener.static();
  }

  /// Creates a new empty [PlatformWebStorageManager] to access static methods.
  @override
  PlatformWebStorageManager createPlatformWebStorageManagerStatic() {
    return _PlatformWebStorageManager.static();
  }
}

// Stub implementations for unsupported classes

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

class _PlatformInAppBrowser extends PlatformInAppBrowser {
  _PlatformInAppBrowser(PlatformInAppBrowserCreationParams params)
      : super.implementation(params);
  static final _PlatformInAppBrowser _staticValue =
      _PlatformInAppBrowser(const PlatformInAppBrowserCreationParams());

  factory _PlatformInAppBrowser.static() => _staticValue;
}

class _PlatformHeadlessInAppWebView extends PlatformHeadlessInAppWebView {
  _PlatformHeadlessInAppWebView(
      PlatformHeadlessInAppWebViewCreationParams params)
      : super.implementation(params);
  static final _PlatformHeadlessInAppWebView _staticValue =
      _PlatformHeadlessInAppWebView(
          const PlatformHeadlessInAppWebViewCreationParams());

  factory _PlatformHeadlessInAppWebView.static() => _staticValue;
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

class _PlatformFindInteractionController
    extends PlatformFindInteractionController {
  _PlatformFindInteractionController(
      PlatformFindInteractionControllerCreationParams params)
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

class _PlatformPullToRefreshController extends PlatformPullToRefreshController {
  _PlatformPullToRefreshController(
      PlatformPullToRefreshControllerCreationParams params)
      : super.implementation(params);

  static final _PlatformPullToRefreshController _staticValue =
      _PlatformPullToRefreshController(
          PlatformPullToRefreshControllerCreationParams());

  factory _PlatformPullToRefreshController.static() => _staticValue;
}

class _PlatformWebAuthenticationSession
    extends PlatformWebAuthenticationSession {
  _PlatformWebAuthenticationSession(
      PlatformWebAuthenticationSessionCreationParams params)
      : super.implementation(params);

  static final _PlatformWebAuthenticationSession _staticValue =
      _PlatformWebAuthenticationSession(
          const PlatformWebAuthenticationSessionCreationParams());

  factory _PlatformWebAuthenticationSession.static() => _staticValue;
}

class _PlatformWebMessageChannel extends PlatformWebMessageChannel {
  _PlatformWebMessageChannel(PlatformWebMessageChannelCreationParams params)
      : super.implementation(params);

  static final _PlatformWebMessageChannel _staticValue =
      _PlatformWebMessageChannel(PlatformWebMessageChannelCreationParams(
          id: '',
          port1: _PlatformWebMessagePort(
              const PlatformWebMessagePortCreationParams(index: 0)),
          port2: _PlatformWebMessagePort(
              const PlatformWebMessagePortCreationParams(index: 1))));

  factory _PlatformWebMessageChannel.static() => _staticValue;
}

class _PlatformWebMessageListener extends PlatformWebMessageListener {
  _PlatformWebMessageListener(PlatformWebMessageListenerCreationParams params)
      : super.implementation(params);

  static final _PlatformWebMessageListener _staticValue =
      _PlatformWebMessageListener(
          const PlatformWebMessageListenerCreationParams(jsObjectName: ''));

  factory _PlatformWebMessageListener.static() => _staticValue;
}

class _PlatformWebMessagePort extends PlatformWebMessagePort {
  _PlatformWebMessagePort(PlatformWebMessagePortCreationParams params)
      : super.implementation(params);

  static final _PlatformWebMessagePort _staticValue = _PlatformWebMessagePort(
      const PlatformWebMessagePortCreationParams(index: 0));

  factory _PlatformWebMessagePort.static() => _staticValue;

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> postMessage(WebMessage message) {
    throw UnimplementedError();
  }

  @override
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    throw UnimplementedError();
  }
}

class _PlatformWebStorageManager extends PlatformWebStorageManager {
  _PlatformWebStorageManager(PlatformWebStorageManagerCreationParams params)
      : super.implementation(params);

  static final _PlatformWebStorageManager _staticValue =
      _PlatformWebStorageManager(
          const PlatformWebStorageManagerCreationParams());

  factory _PlatformWebStorageManager.static() => _staticValue;
}
