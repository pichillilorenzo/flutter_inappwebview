import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'cookie_manager.dart';
import 'find_interaction/find_interaction_controller.dart';
import 'in_app_browser/in_app_browser.dart';
import 'in_app_webview/headless_in_app_webview.dart';
import 'in_app_webview/in_app_webview.dart';
import 'in_app_webview/in_app_webview_controller.dart';
import 'web_message/web_message_channel.dart';
import 'web_message/web_message_listener.dart';
import 'web_message/web_message_port.dart';
import 'web_notification/web_notification_controller.dart';
import 'web_storage/web_storage.dart';
import 'webview_environment/webview_environment.dart';

/// Implementation of [InAppWebViewPlatform] using the WebView2 API.
class WindowsInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [InAppWebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = WindowsInAppWebViewPlatform();
  }

  /// Creates a new [WindowsCookieManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  WindowsCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return WindowsCookieManager(params);
  }

  /// Creates a new empty [WindowsCookieManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  @override
  WindowsCookieManager createPlatformCookieManagerStatic() {
    return WindowsCookieManager.static();
  }

  /// Creates a new [WindowsInAppWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  WindowsInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return WindowsInAppWebViewController(params);
  }

  /// Creates a new empty [WindowsInAppWebViewController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  @override
  WindowsInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return WindowsInAppWebViewController.static();
  }

  /// Creates a new [WindowsInAppWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  WindowsInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return WindowsInAppWebViewWidget(params);
  }

  /// Creates a new empty [WindowsInAppWebViewWidget] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  @override
  WindowsInAppWebViewWidget createPlatformInAppWebViewWidgetStatic() {
    return WindowsInAppWebViewWidget.static();
  }

  /// Creates a new [WindowsInAppBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  @override
  WindowsInAppBrowser createPlatformInAppBrowser(
    PlatformInAppBrowserCreationParams params,
  ) {
    return WindowsInAppBrowser(params);
  }

  /// Creates a new empty [WindowsInAppBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  @override
  WindowsInAppBrowser createPlatformInAppBrowserStatic() {
    return WindowsInAppBrowser.static();
  }

  /// Creates a new [WindowsHeadlessInAppWebView].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  WindowsHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    return WindowsHeadlessInAppWebView(params);
  }

  /// Creates a new empty [WindowsHeadlessInAppWebView] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  @override
  WindowsHeadlessInAppWebView createPlatformHeadlessInAppWebViewStatic() {
    return WindowsHeadlessInAppWebView.static();
  }

  /// Creates a new [WindowsWebViewEnvironment].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewEnvironment] in `flutter_inappwebview` instead.
  @override
  WindowsWebViewEnvironment createPlatformWebViewEnvironment(
    PlatformWebViewEnvironmentCreationParams params,
  ) {
    return WindowsWebViewEnvironment(params);
  }

  /// Creates a new empty [WindowsWebViewEnvironment] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewEnvironment] in `flutter_inappwebview` instead.
  @override
  WindowsWebViewEnvironment createPlatformWebViewEnvironmentStatic() {
    return WindowsWebViewEnvironment.static();
  }

  /// Creates a new [WindowsWebStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  @override
  WindowsWebStorage createPlatformWebStorage(
    PlatformWebStorageCreationParams params,
  ) {
    return WindowsWebStorage(params);
  }

  /// Creates a new empty [WindowsWebStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  @override
  WindowsWebStorage createPlatformWebStorageStatic() {
    return WindowsWebStorage(
      WindowsWebStorageCreationParams(
        localStorage: createPlatformLocalStorageStatic(),
        sessionStorage: createPlatformSessionStorageStatic(),
      ),
    );
  }

  /// Creates a new [WindowsLocalStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  @override
  WindowsLocalStorage createPlatformLocalStorage(
    PlatformLocalStorageCreationParams params,
  ) {
    return WindowsLocalStorage(params);
  }

  /// Creates a new empty [WindowsLocalStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  @override
  WindowsLocalStorage createPlatformLocalStorageStatic() {
    return WindowsLocalStorage.defaultStorage(controller: null);
  }

  /// Creates a new [WindowsSessionStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [SessionStorage] in `flutter_inappwebview` instead.
  @override
  WindowsSessionStorage createPlatformSessionStorage(
    PlatformSessionStorageCreationParams params,
  ) {
    return WindowsSessionStorage(params);
  }

  /// Creates a new empty [WindowsSessionStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [SessionStorage] in `flutter_inappwebview` instead.
  @override
  WindowsSessionStorage createPlatformSessionStorageStatic() {
    return WindowsSessionStorage.defaultStorage(controller: null);
  }

  /// Creates a new [WindowsWebMessageChannel].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  @override
  WindowsWebMessageChannel createPlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    return WindowsWebMessageChannel(params);
  }

  /// Creates a new empty [WindowsWebMessageChannel] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  @override
  WindowsWebMessageChannel createPlatformWebMessageChannelStatic() {
    return WindowsWebMessageChannel.static();
  }

  /// Creates a new [WindowsWebMessagePort].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessagePort] in `flutter_inappwebview` instead.
  @override
  WindowsWebMessagePort createPlatformWebMessagePort(
    PlatformWebMessagePortCreationParams params,
  ) {
    return WindowsWebMessagePort(params);
  }

  /// Creates a new [WindowsWebMessageListener].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  @override
  WindowsWebMessageListener createPlatformWebMessageListener(
    PlatformWebMessageListenerCreationParams params,
  ) {
    return WindowsWebMessageListener(params);
  }

  /// Creates a new [WindowsJavaScriptReplyProxy].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [JavaScriptReplyProxy] in `flutter_inappwebview` instead.
  @override
  WindowsJavaScriptReplyProxy createPlatformJavaScriptReplyProxy(
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    return WindowsJavaScriptReplyProxy(params);
  }

  /// Creates a new empty [WindowsWebMessageListener] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  @override
  WindowsWebMessageListener createPlatformWebMessageListenerStatic() {
    return WindowsWebMessageListener.static();
  }

  /// Creates a new [WindowsFindInteractionController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  @override
  WindowsFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return WindowsFindInteractionController(params);
  }

  /// Creates a new empty [WindowsFindInteractionController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  @override
  WindowsFindInteractionController
  createPlatformFindInteractionControllerStatic() {
    return WindowsFindInteractionController.static();
  }

  /// Creates a new [WindowsWebNotificationController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebNotificationController] in `flutter_inappwebview` instead.
  @override
  WindowsWebNotificationController createPlatformWebNotificationController(
    PlatformWebNotificationControllerCreationParams params,
  ) {
    return WindowsWebNotificationController(params);
  }

  /// Creates a new empty [WindowsWebNotificationController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebNotificationController] in `flutter_inappwebview` instead.
  @override
  WindowsWebNotificationController
  createPlatformWebNotificationControllerStatic() {
    return WindowsWebNotificationController.static();
  }

  // ************************************************************************ //
  // Create static instances of unsupported classes to be able to call        //
  // isClassSupported, isMethodSupported, isPropertySupported, etc.           //
  // static methods without throwing a missing platform implementation        //
  // exception.                                                               //
  // ************************************************************************ //

  /// Creates a new empty [PlatformWebStorageManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  @override
  PlatformWebStorageManager createPlatformWebStorageManagerStatic() {
    return _PlatformWebStorageManager.static();
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

  /// Creates a new empty [PlatformPrintJobController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  @override
  PlatformPrintJobController createPlatformPrintJobControllerStatic() {
    return _PlatformPrintJobController.static();
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

  /// Creates a new empty [PlatformWebAuthenticationSession] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebAuthenticationSession] in `flutter_inappwebview` instead.
  @override
  PlatformWebAuthenticationSession
  createPlatformWebAuthenticationSessionStatic() {
    return _PlatformWebAuthenticationSession.static();
  }

  /// Creates a new empty [PlatformAssetsPathHandler] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [AssetsPathHandler] in `flutter_inappwebview` instead.
  @override
  PlatformAssetsPathHandler createPlatformAssetsPathHandlerStatic() {
    return _PlatformAssetsPathHandler.static();
  }

  /// Creates a new empty [PlatformResourcesPathHandler] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ResourcesPathHandler] in `flutter_inappwebview` instead.
  @override
  PlatformResourcesPathHandler createPlatformResourcesPathHandlerStatic() {
    return _PlatformResourcesPathHandler.static();
  }

  /// Creates a new empty [PlatformInternalStoragePathHandler] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InternalStoragePathHandler] in `flutter_inappwebview` instead.
  @override
  PlatformInternalStoragePathHandler
  createPlatformInternalStoragePathHandlerStatic() {
    return _PlatformInternalStoragePathHandler.static();
  }

  /// Creates a new empty [PlatformCustomPathHandler] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CustomPathHandler] in `flutter_inappwebview` instead.
  @override
  PlatformCustomPathHandler createPlatformCustomPathHandlerStatic() {
    return _PlatformCustomPathHandler.static();
  }

  /// Creates a new [DefaultInAppLocalhostServer].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppLocalhostServer] in `flutter_inappwebview` instead.
  @override
  DefaultInAppLocalhostServer createPlatformInAppLocalhostServer(
    PlatformInAppLocalhostServerCreationParams params,
  ) {
    return DefaultInAppLocalhostServer(params);
  }

  /// Creates a new empty [DefaultInAppLocalhostServer] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppLocalhostServer] in `flutter_inappwebview` instead.
  @override
  DefaultInAppLocalhostServer createPlatformInAppLocalhostServerStatic() {
    return DefaultInAppLocalhostServer.static();
  }

  /// Creates a new empty [PlatformWebViewFeature] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewFeature] in `flutter_inappwebview` instead
  @override
  PlatformWebViewFeature createPlatformWebViewFeatureStatic() {
    return _PlatformWebViewFeature.static();
  }
}

class _PlatformChromeSafariBrowser extends PlatformChromeSafariBrowser {
  _PlatformChromeSafariBrowser(PlatformChromeSafariBrowserCreationParams params)
    : super.implementation(params);
  static final _PlatformChromeSafariBrowser _staticValue =
      _PlatformChromeSafariBrowser(
        const PlatformChromeSafariBrowserCreationParams(),
      );

  factory _PlatformChromeSafariBrowser.static() => _staticValue;
}

class _PlatformHttpAuthCredentialDatabase
    extends PlatformHttpAuthCredentialDatabase {
  _PlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) : super.implementation(params);
  static final _PlatformHttpAuthCredentialDatabase _staticValue =
      _PlatformHttpAuthCredentialDatabase(
        const PlatformHttpAuthCredentialDatabaseCreationParams(),
      );

  factory _PlatformHttpAuthCredentialDatabase.static() => _staticValue;
}

class _PlatformProcessGlobalConfig extends PlatformProcessGlobalConfig {
  _PlatformProcessGlobalConfig(PlatformProcessGlobalConfigCreationParams params)
    : super.implementation(params);
  static final _PlatformProcessGlobalConfig _staticValue =
      _PlatformProcessGlobalConfig(
        const PlatformProcessGlobalConfigCreationParams(),
      );

  factory _PlatformProcessGlobalConfig.static() => _staticValue;
}

class _PlatformProxyController extends PlatformProxyController {
  _PlatformProxyController(PlatformProxyControllerCreationParams params)
    : super.implementation(params);
  static final _PlatformProxyController _staticValue = _PlatformProxyController(
    const PlatformProxyControllerCreationParams(),
  );

  factory _PlatformProxyController.static() => _staticValue;
}

class _PlatformServiceWorkerController extends PlatformServiceWorkerController {
  _PlatformServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) : super.implementation(params);
  static final _PlatformServiceWorkerController _staticValue =
      _PlatformServiceWorkerController(
        const PlatformServiceWorkerControllerCreationParams(),
      );

  factory _PlatformServiceWorkerController.static() => _staticValue;

  @override
  ServiceWorkerClient? get serviceWorkerClient => throw UnimplementedError();
}

class _PlatformTracingController extends PlatformTracingController {
  _PlatformTracingController(PlatformTracingControllerCreationParams params)
    : super.implementation(params);
  static final _PlatformTracingController _staticValue =
      _PlatformTracingController(
        const PlatformTracingControllerCreationParams(),
      );

  factory _PlatformTracingController.static() => _staticValue;
}

class _PlatformPrintJobController extends PlatformPrintJobController {
  _PlatformPrintJobController(PlatformPrintJobControllerCreationParams params)
    : super.implementation(params);

  static final _PlatformPrintJobController _staticValue =
      _PlatformPrintJobController(
        const PlatformPrintJobControllerCreationParams(id: ''),
      );

  factory _PlatformPrintJobController.static() => _staticValue;
}

class _PlatformPullToRefreshController extends PlatformPullToRefreshController {
  _PlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) : super.implementation(params);

  static final _PlatformPullToRefreshController _staticValue =
      _PlatformPullToRefreshController(
        PlatformPullToRefreshControllerCreationParams(),
      );

  factory _PlatformPullToRefreshController.static() => _staticValue;
}

class _PlatformWebAuthenticationSession
    extends PlatformWebAuthenticationSession {
  _PlatformWebAuthenticationSession(
    PlatformWebAuthenticationSessionCreationParams params,
  ) : super.implementation(params);

  static final _PlatformWebAuthenticationSession _staticValue =
      _PlatformWebAuthenticationSession(
        const PlatformWebAuthenticationSessionCreationParams(),
      );

  factory _PlatformWebAuthenticationSession.static() => _staticValue;
}

class _PlatformWebStorageManager extends PlatformWebStorageManager {
  _PlatformWebStorageManager(PlatformWebStorageManagerCreationParams params)
    : super.implementation(params);

  static final _PlatformWebStorageManager _staticValue =
      _PlatformWebStorageManager(
        const PlatformWebStorageManagerCreationParams(),
      );

  factory _PlatformWebStorageManager.static() => _staticValue;
}

class _PlatformWebViewFeature extends PlatformWebViewFeature {
  _PlatformWebViewFeature(PlatformWebViewFeatureCreationParams params)
    : super.implementation(params);

  static final _PlatformWebViewFeature _staticValue = _PlatformWebViewFeature(
    PlatformWebViewFeatureCreationParams(),
  );
  factory _PlatformWebViewFeature.static() => _staticValue;
}

class _PlatformAssetsPathHandler extends PlatformAssetsPathHandler {
  _PlatformAssetsPathHandler(PlatformAssetsPathHandlerCreationParams params)
    : super.implementation(params);

  static final _PlatformAssetsPathHandler _staticValue =
      _PlatformAssetsPathHandler(
        PlatformAssetsPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: ''),
        ),
      );

  factory _PlatformAssetsPathHandler.static() => _staticValue;

  @override
  PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {
    "path": path,
    "type": type,
  };

  @override
  Map<String, dynamic> toJson() => toMap();
}

class _PlatformResourcesPathHandler extends PlatformResourcesPathHandler {
  _PlatformResourcesPathHandler(
    PlatformResourcesPathHandlerCreationParams params,
  ) : super.implementation(params);

  static final _PlatformResourcesPathHandler _staticValue =
      _PlatformResourcesPathHandler(
        PlatformResourcesPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: ''),
        ),
      );

  factory _PlatformResourcesPathHandler.static() => _staticValue;

  @override
  PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {
    "path": path,
    "type": type,
  };

  @override
  Map<String, dynamic> toJson() => toMap();
}

class _PlatformInternalStoragePathHandler
    extends PlatformInternalStoragePathHandler {
  _PlatformInternalStoragePathHandler(
    PlatformInternalStoragePathHandlerCreationParams params,
  ) : super.implementation(params);

  static final _PlatformInternalStoragePathHandler _staticValue =
      _PlatformInternalStoragePathHandler(
        PlatformInternalStoragePathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: ''),
          directory: '',
        ),
      );

  factory _PlatformInternalStoragePathHandler.static() => _staticValue;

  @override
  PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {
    "path": path,
    "type": type,
  };

  @override
  Map<String, dynamic> toJson() => toMap();
}

class _PlatformCustomPathHandler extends PlatformCustomPathHandler {
  _PlatformCustomPathHandler(PlatformCustomPathHandlerCreationParams params)
    : super.implementation(params);

  static final _PlatformCustomPathHandler _staticValue =
      _PlatformCustomPathHandler(
        PlatformCustomPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: ''),
        ),
      );

  factory _PlatformCustomPathHandler.static() => _staticValue;

  @override
  PlatformPathHandlerEvents? eventHandler;

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) => {
    "path": path,
    "type": type,
  };

  @override
  Map<String, dynamic> toJson() => toMap();
}
