import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chrome_safari_browser/platform_chrome_safari_browser.dart';
import 'find_interaction/platform_find_interaction_controller.dart';
import 'in_app_browser/platform_in_app_browser.dart';
import 'in_app_localhost_server.dart';
import 'in_app_webview/platform_headless_in_app_webview.dart';
import 'in_app_webview/platform_inappwebview_controller.dart';
import 'in_app_webview/platform_inappwebview_widget.dart';
import 'platform_cookie_manager.dart';
import 'platform_http_auth_credentials_database.dart';
import 'platform_in_app_localhost_server.dart';
import 'platform_process_global_config.dart';
import 'platform_proxy_controller.dart';
import 'platform_service_worker_controller.dart';
import 'platform_tracing_controller.dart';
import 'platform_webview_asset_loader.dart';
import 'platform_webview_feature.dart';
import 'print_job/platform_print_job_controller.dart';
import 'pull_to_refresh/platform_pull_to_refresh_controller.dart';
import 'web_authentication_session/platform_web_authenticate_session.dart';
import 'web_message/platform_web_message_channel.dart';
import 'web_message/platform_web_message_listener.dart';
import 'web_message/platform_web_message_port.dart';
import 'web_storage/platform_web_storage.dart';
import 'web_storage/platform_web_storage_manager.dart';
import 'webview_environment/platform_webview_environment.dart';

/// Interface for a platform implementation of a WebView.
abstract class InAppWebViewPlatform extends PlatformInterface {
  /// Creates a new [InAppWebViewPlatform].
  InAppWebViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static InAppWebViewPlatform? _instance;

  /// The instance of [InAppWebViewPlatform] to use.
  static InAppWebViewPlatform? get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [InAppWebViewPlatform] when they register themselves.
  static set instance(InAppWebViewPlatform? instance) {
    if (instance == null) {
      throw AssertionError(
          'Platform interfaces can only be set to a non-null instance');
    }

    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Creates a new [PlatformCookieManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  PlatformCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformCookieManager is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformCookieManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  PlatformCookieManager createPlatformCookieManagerStatic() {
    throw UnimplementedError(
        'createPlatformCookieManagerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformInAppWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  PlatformInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformInAppWebViewController is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformInAppWebViewController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  PlatformInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    throw UnimplementedError(
        'createPlatformInAppWebViewControllerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformInAppWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformInAppWebViewWidget is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformInAppWebViewWidget] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidgetStatic() {
    throw UnimplementedError(
        'createPlatformInAppWebViewWidgetStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformFindInteractionController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  PlatformFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformFindInteractionController is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformFindInteractionController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  PlatformFindInteractionController
      createPlatformFindInteractionControllerStatic() {
    throw UnimplementedError(
        'createPlatformFindInteractionControllerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformPrintJobController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  PlatformPrintJobController createPlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformPrintJobController is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformPrintJobController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  PlatformPrintJobController createPlatformPrintJobControllerStatic() {
    throw UnimplementedError(
        'createPlatformPrintJobControllerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformPullToRefreshController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PullToRefreshController] in `flutter_inappwebview` instead.
  PlatformPullToRefreshController createPlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformPullToRefreshController is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformPullToRefreshController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PullToRefreshController] in `flutter_inappwebview` instead.
  PlatformPullToRefreshController
      createPlatformPullToRefreshControllerStatic() {
    throw UnimplementedError(
        'createPlatformPullToRefreshControllerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebAuthenticationSession].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebAuthenticationSession] in `flutter_inappwebview` instead.
  PlatformWebAuthenticationSession createPlatformWebAuthenticationSession(
    PlatformWebAuthenticationSessionCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebAuthenticationSession is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformWebAuthenticationSession] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebAuthenticationSession] in `flutter_inappwebview` instead.
  PlatformWebAuthenticationSession
      createPlatformWebAuthenticationSessionStatic() {
    throw UnimplementedError(
        'createPlatformWebAuthenticationSessionStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebMessageChannel].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  PlatformWebMessageChannel createPlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebMessageChannel is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformWebMessageChannel] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  PlatformWebMessageChannel createPlatformWebMessageChannelStatic() {
    throw UnimplementedError(
        'createPlatformWebMessageChannelStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebMessageListener].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  PlatformWebMessageListener createPlatformWebMessageListener(
    PlatformWebMessageListenerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebMessageListener is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformWebMessageListener] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  PlatformWebMessageListener createPlatformWebMessageListenerStatic() {
    throw UnimplementedError(
        'createPlatformWebMessageListenerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformJavaScriptReplyProxy].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [JavaScriptReplyProxy] in `flutter_inappwebview` instead.
  PlatformJavaScriptReplyProxy createPlatformJavaScriptReplyProxy(
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformJavaScriptReplyProxy is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebMessagePort].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessagePort] in `flutter_inappwebview` instead.
  PlatformWebMessagePort createPlatformWebMessagePort(
    PlatformWebMessagePortCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebMessagePort is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  PlatformWebStorage createPlatformWebStorage(
    PlatformWebStorageCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebStorage is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformWebStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorage] in `flutter_inappwebview` instead.
  PlatformWebStorage createPlatformWebStorageStatic() {
    throw UnimplementedError(
        'createPlatformWebStorageStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformLocalStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  PlatformLocalStorage createPlatformLocalStorage(
    PlatformLocalStorageCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformLocalStorage is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformLocalStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [LocalStorage] in `flutter_inappwebview` instead.
  PlatformLocalStorage createPlatformLocalStorageStatic() {
    throw UnimplementedError(
        'createPlatformLocalStorageStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformSessionStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PlatformSessionStorage] in `flutter_inappwebview` instead.
  PlatformSessionStorage createPlatformSessionStorage(
    PlatformSessionStorageCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformSessionStorage is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformSessionStorage] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PlatformSessionStorage] in `flutter_inappwebview` instead.
  PlatformSessionStorage createPlatformSessionStorageStatic() {
    throw UnimplementedError(
        'createPlatformSessionStorageStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformHeadlessInAppWebView].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  PlatformHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformHeadlessInAppWebView is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformHeadlessInAppWebView] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  PlatformHeadlessInAppWebView createPlatformHeadlessInAppWebViewStatic() {
    throw UnimplementedError(
        'createPlatformHeadlessInAppWebViewStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebStorageManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  PlatformWebStorageManager createPlatformWebStorageManager(
    PlatformWebStorageManagerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebStorageManager is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformWebStorageManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  PlatformWebStorageManager createPlatformWebStorageManagerStatic() {
    throw UnimplementedError(
        'createPlatformWebStorageManagerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformHttpAuthCredentialDatabase].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  PlatformHttpAuthCredentialDatabase createPlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformHttpAuthCredentialDatabase is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformHttpAuthCredentialDatabase] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  PlatformHttpAuthCredentialDatabase
      createPlatformHttpAuthCredentialDatabaseStatic() {
    throw UnimplementedError(
        'createPlatformHttpAuthCredentialDatabaseStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformInAppBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  PlatformInAppBrowser createPlatformInAppBrowser(
    PlatformInAppBrowserCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformInAppBrowser is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformInAppBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  PlatformInAppBrowser createPlatformInAppBrowserStatic() {
    throw UnimplementedError(
        'createPlatformInAppBrowserStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformProcessGlobalConfig].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProcessGlobalConfig] in `flutter_inappwebview` instead.
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfig(
    PlatformProcessGlobalConfigCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformProcessGlobalConfig is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformProcessGlobalConfig] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProcessGlobalConfig] in `flutter_inappwebview` instead.
  PlatformProcessGlobalConfig createPlatformProcessGlobalConfigStatic() {
    throw UnimplementedError(
        'createPlatformProcessGlobalConfigStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformProxyController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  PlatformProxyController createPlatformProxyController(
    PlatformProxyControllerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformProxyController is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformProxyController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  PlatformProxyController createPlatformProxyControllerStatic() {
    throw UnimplementedError(
        'createPlatformProxyControllerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformServiceWorkerController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ServiceWorkerController] in `flutter_inappwebview` instead.
  PlatformServiceWorkerController createPlatformServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformServiceWorkerController is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformServiceWorkerController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ServiceWorkerController] in `flutter_inappwebview` instead.
  PlatformServiceWorkerController
      createPlatformServiceWorkerControllerStatic() {
    throw UnimplementedError(
        'createPlatformServiceWorkerControllerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformTracingController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [TracingController] in `flutter_inappwebview` instead.
  PlatformTracingController createPlatformTracingController(
    PlatformTracingControllerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformTracingController is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformTracingController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [TracingController] in `flutter_inappwebview` instead.
  PlatformTracingController createPlatformTracingControllerStatic() {
    throw UnimplementedError(
        'createPlatformTracingControllerStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformAssetsPathHandler].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [AssetsPathHandler] in `flutter_inappwebview` instead.
  PlatformAssetsPathHandler createPlatformAssetsPathHandler(
    PlatformAssetsPathHandlerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformAssetsPathHandler is not implemented on the current platform.');
  }

  /// Creates a new [PlatformResourcesPathHandler].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ResourcesPathHandler] in `flutter_inappwebview` instead.
  PlatformResourcesPathHandler createPlatformResourcesPathHandler(
    PlatformResourcesPathHandlerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformResourcesPathHandler is not implemented on the current platform.');
  }

  /// Creates a new [PlatformInternalStoragePathHandler].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InternalStoragePathHandler] in `flutter_inappwebview` instead.
  PlatformInternalStoragePathHandler createPlatformInternalStoragePathHandler(
    PlatformInternalStoragePathHandlerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformInternalStoragePathHandler is not implemented on the current platform.');
  }

  /// Creates a new [PlatformCustomPathHandler].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CustomPathHandler] in `flutter_inappwebview` instead.
  PlatformCustomPathHandler createPlatformCustomPathHandler(
    PlatformCustomPathHandlerCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformCustomPathHandler is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebViewFeature].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewFeature] in `flutter_inappwebview` instead.
  PlatformWebViewFeature createPlatformWebViewFeature(
    PlatformWebViewFeatureCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebViewFeature is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformWebViewFeature] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewFeature] in `flutter_inappwebview` instead.
  PlatformWebViewFeature createPlatformWebViewFeatureStatic() {
    throw UnimplementedError(
        'createPlatformWebViewFeatureStatic is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformInAppLocalhostServer] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [DefaultInAppLocalhostServer] in `flutter_inappwebview` instead.
  PlatformInAppLocalhostServer createPlatformInAppLocalhostServer(
      PlatformInAppLocalhostServerCreationParams params) {
    return DefaultInAppLocalhostServer(params);
  }

  /// Creates a new [PlatformChromeSafariBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowser(
    PlatformChromeSafariBrowserCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformChromeSafariBrowser is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformChromeSafariBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  PlatformChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    throw UnimplementedError(
        'createPlatformChromeSafariBrowserStatic is not implemented on the current platform.');
  }

  /// Creates a new [PlatformWebViewEnvironment].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewEnvironment] in `flutter_inappwebview` instead.
  PlatformWebViewEnvironment createPlatformWebViewEnvironment(
    PlatformWebViewEnvironmentCreationParams params,
  ) {
    throw UnimplementedError(
        'createPlatformWebViewEnvironment is not implemented on the current platform.');
  }

  /// Creates a new empty [PlatformWebViewEnvironment] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewEnvironment] in `flutter_inappwebview` instead.
  PlatformWebViewEnvironment createPlatformWebViewEnvironmentStatic() {
    throw UnimplementedError(
        'createPlatformWebViewEnvironmentStatic is not implemented on the current platform.');
  }
}
