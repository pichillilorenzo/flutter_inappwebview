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
}
