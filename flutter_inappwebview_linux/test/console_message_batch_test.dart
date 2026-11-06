import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_linux/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../../tool/console_message_controller_test.dart';

void main() {
  testConsoleMessageController(
    (callback) => LinuxInAppWebViewController(
      PlatformInAppWebViewControllerCreationParams(
        id: 'console-batch',
        webviewParams: PlatformInAppWebViewWidgetCreationParams(
          onConsoleMessage: callback,
        ),
      ),
    ),
    (controller, callback) => (controller as LinuxInAppWebViewController)
        .updateConsoleMessageCallback(callback),
    (events) {
      final browser = LinuxInAppBrowser(
        const PlatformInAppBrowserCreationParams(),
      )..eventHandler = events;
      final controller = LinuxInAppWebViewController.fromInAppBrowser(
        const PlatformInAppWebViewControllerCreationParams(id: 'console-batch'),
        const MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_console-batch',
        ),
        browser,
        null,
      );
      controller.handler = controller.handleMethod;
      controller.initMethodCallHandler();
      return controller;
    },
  );
}
