import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'in_app_browser/in_app_browser.dart';
import 'in_app_webview/in_app_webview.dart';
import 'in_app_webview/in_app_webview_controller.dart';

/// Implementation of [InAppWebViewPlatform] using the WebKit API.
class WindowsInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [InAppWebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = WindowsInAppWebViewPlatform();
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
}
