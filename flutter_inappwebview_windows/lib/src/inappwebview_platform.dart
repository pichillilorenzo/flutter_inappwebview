import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'in_app_browser/in_app_browser.dart';

/// Implementation of [InAppWebViewPlatform] using the WebKit API.
class WindowsInAppWebViewPlatform extends InAppWebViewPlatform {
  /// Registers this class as the default instance of [InAppWebViewPlatform].
  static void registerWith() {
    InAppWebViewPlatform.instance = WindowsInAppWebViewPlatform();
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
