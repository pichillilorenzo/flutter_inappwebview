import 'package:flutter_inappwebview_android/src/print_job/main.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'chrome_safari_browser/chrome_safari_browser.dart';
import 'cookie_manager.dart';
import 'http_auth_credentials_database.dart';
import 'find_interaction/main.dart';
import 'in_app_browser/in_app_browser.dart';
import 'in_app_webview/main.dart';
import 'pull_to_refresh/main.dart';
import 'web_message/main.dart';
import 'web_storage/main.dart';
import 'process_global_config.dart';
import 'proxy_controller.dart';
import 'service_worker_controller.dart';
import 'tracing_controller.dart';
import 'webview_asset_loader.dart';
import 'webview_feature.dart' as wv;

/// Implementation of [WebViewPlatform] using the WebKit API.
class AndroidInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [WebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = AndroidInAppWebViewPlatform();
  }

  /// Creates a new [AndroidCookieManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [CookieManager] in `flutter_inappwebview` instead.
  AndroidCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return AndroidCookieManager(params);
  }

  /// Creates a new [AndroidInAppWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  AndroidInAppWebViewController createPlatformInAppWebViewController(
    PlatformInAppWebViewControllerCreationParams params,
  ) {
    return AndroidInAppWebViewController(params);
  }

  /// Creates a new empty [AndroidInAppWebViewController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebViewController] in `flutter_inappwebview` instead.
  AndroidInAppWebViewController createPlatformInAppWebViewControllerStatic() {
    return AndroidInAppWebViewController.static();
  }

  /// Creates a new [AndroidInAppWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppWebView] in `flutter_inappwebview` instead.
  AndroidInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return AndroidInAppWebViewWidget(params);
  }

  /// Creates a new [AndroidFindInteractionController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [FindInteractionController] in `flutter_inappwebview` instead.
  AndroidFindInteractionController createPlatformFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) {
    return AndroidFindInteractionController(params);
  }

  /// Creates a new [AndroidPrintJobController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PrintJobController] in `flutter_inappwebview` instead.
  AndroidPrintJobController createPlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) {
    return AndroidPrintJobController(params);
  }

  /// Creates a new [AndroidPullToRefreshController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PullToRefreshController] in `flutter_inappwebview` instead.
  AndroidPullToRefreshController createPlatformPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) {
    return AndroidPullToRefreshController(params);
  }

  /// Creates a new [AndroidWebMessageChannel].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  AndroidWebMessageChannel createPlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    return AndroidWebMessageChannel(params);
  }

  /// Creates a new empty [AndroidWebMessageChannel] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageChannel] in `flutter_inappwebview` instead.
  AndroidWebMessageChannel createPlatformWebMessageChannelStatic() {
    return AndroidWebMessageChannel.static();
  }

  /// Creates a new [AndroidWebMessageListener].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessageListener] in `flutter_inappwebview` instead.
  AndroidWebMessageListener createPlatformWebMessageListener(
    PlatformWebMessageListenerCreationParams params,
  ) {
    return AndroidWebMessageListener(params);
  }

  /// Creates a new [AndroidJavaScriptReplyProxy].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [JavaScriptReplyProxy] in `flutter_inappwebview` instead.
  AndroidJavaScriptReplyProxy createPlatformJavaScriptReplyProxy(
    PlatformJavaScriptReplyProxyCreationParams params,
  ) {
    return AndroidJavaScriptReplyProxy(params);
  }

  /// Creates a new [AndroidWebMessagePort].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebMessagePort] in `flutter_inappwebview` instead.
  AndroidWebMessagePort createPlatformWebMessagePort(
    PlatformWebMessagePortCreationParams params,
  ) {
    return AndroidWebMessagePort(params);
  }

  /// Creates a new [AndroidWebStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [AndroidWebStorage] in `flutter_inappwebview` instead.
  AndroidWebStorage createPlatformWebStorage(
    PlatformWebStorageCreationParams params,
  ) {
    return AndroidWebStorage(params);
  }

  /// Creates a new [AndroidLocalStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [AndroidLocalStorage] in `flutter_inappwebview` instead.
  AndroidLocalStorage createPlatformLocalStorage(
    PlatformLocalStorageCreationParams params,
  ) {
    return AndroidLocalStorage(params);
  }

  /// Creates a new [AndroidSessionStorage].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [PlatformSessionStorage] in `flutter_inappwebview` instead.
  AndroidSessionStorage createPlatformSessionStorage(
    PlatformSessionStorageCreationParams params,
  ) {
    return AndroidSessionStorage(params);
  }

  /// Creates a new [AndroidHeadlessInAppWebView].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessInAppWebView] in `flutter_inappwebview` instead.
  AndroidHeadlessInAppWebView createPlatformHeadlessInAppWebView(
    PlatformHeadlessInAppWebViewCreationParams params,
  ) {
    return AndroidHeadlessInAppWebView(params);
  }

  /// Creates a new [AndroidHttpAuthCredentialDatabase].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HttpAuthCredentialDatabase] in `flutter_inappwebview` instead.
  AndroidHttpAuthCredentialDatabase createPlatformHttpAuthCredentialDatabase(
    PlatformHttpAuthCredentialDatabaseCreationParams params,
  ) {
    return AndroidHttpAuthCredentialDatabase(params);
  }

  /// Creates a new [AndroidInAppBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  AndroidInAppBrowser createPlatformInAppBrowser(
    PlatformInAppBrowserCreationParams params,
  ) {
    return AndroidInAppBrowser(params);
  }

  /// Creates a new empty [AndroidInAppBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InAppBrowser] in `flutter_inappwebview` instead.
  AndroidInAppBrowser createPlatformInAppBrowserStatic() {
    return AndroidInAppBrowser.static();
  }

  /// Creates a new [AndroidProcessGlobalConfig].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProcessGlobalConfig] in `flutter_inappwebview` instead.
  AndroidProcessGlobalConfig createPlatformProcessGlobalConfig(
    PlatformProcessGlobalConfigCreationParams params,
  ) {
    return AndroidProcessGlobalConfig(params);
  }

  /// Creates a new [AndroidProxyController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ProxyController] in `flutter_inappwebview` instead.
  AndroidProxyController createPlatformProxyController(
    PlatformProxyControllerCreationParams params,
  ) {
    return AndroidProxyController(params);
  }

  /// Creates a new [AndroidServiceWorkerController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ServiceWorkerController] in `flutter_inappwebview` instead.
  AndroidServiceWorkerController createPlatformServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) {
    return AndroidServiceWorkerController(params);
  }

  /// Creates a new empty [AndroidServiceWorkerController] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ServiceWorkerController] in `flutter_inappwebview` instead.
  AndroidServiceWorkerController createPlatformServiceWorkerControllerStatic() {
    return AndroidServiceWorkerController.static();
  }

  /// Creates a new [AndroidTracingController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [TracingController] in `flutter_inappwebview` instead.
  AndroidTracingController createPlatformTracingController(
    PlatformTracingControllerCreationParams params,
  ) {
    return AndroidTracingController(params);
  }

  /// Creates a new [AndroidAssetsPathHandler].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [AssetsPathHandler] in `flutter_inappwebview` instead.
  AndroidAssetsPathHandler createPlatformAssetsPathHandler(
    PlatformAssetsPathHandlerCreationParams params,
  ) {
    return AndroidAssetsPathHandler(params);
  }

  /// Creates a new [AndroidResourcesPathHandler].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ResourcesPathHandler] in `flutter_inappwebview` instead.
  AndroidResourcesPathHandler createPlatformResourcesPathHandler(
    PlatformResourcesPathHandlerCreationParams params,
  ) {
    return AndroidResourcesPathHandler(params);
  }

  /// Creates a new [AndroidInternalStoragePathHandler].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [InternalStoragePathHandler] in `flutter_inappwebview` instead.
  AndroidInternalStoragePathHandler createPlatformInternalStoragePathHandler(
    PlatformInternalStoragePathHandlerCreationParams params,
  ) {
    return AndroidInternalStoragePathHandler(params);
  }

  /// Creates a new [wv.AndroidWebViewFeature].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewFeature] in `flutter_inappwebview` instead.
  wv.AndroidWebViewFeature createPlatformWebViewFeature(
    PlatformWebViewFeatureCreationParams params,
  ) {
    return wv.AndroidWebViewFeature(params);
  }

  /// Creates a new empty [wv.AndroidWebViewFeature] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewFeature] in `flutter_inappwebview` instead.
  wv.AndroidWebViewFeature createPlatformWebViewFeatureStatic() {
    return wv.AndroidWebViewFeature.static();
  }

  /// Creates a new [AndroidChromeSafariBrowser].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  AndroidChromeSafariBrowser createPlatformChromeSafariBrowser(
    PlatformChromeSafariBrowserCreationParams params,
  ) {
    return AndroidChromeSafariBrowser(params);
  }

  /// Creates a new empty [AndroidChromeSafariBrowser] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [ChromeSafariBrowser] in `flutter_inappwebview` instead.
  AndroidChromeSafariBrowser createPlatformChromeSafariBrowserStatic() {
    return AndroidChromeSafariBrowser.static();
  }

  /// Creates a new empty [AndroidWebStorageManager] to access static methods.
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebStorageManager] in `flutter_inappwebview` instead.
  AndroidWebStorageManager createPlatformWebStorageManager(
      PlatformWebStorageManagerCreationParams params) {
    return AndroidWebStorageManager(params);
  }
}
