import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void takeScreenshot() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('takeScreenshot', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
    );
    headlessWebView.onLoadStop = (controller, url) async {
      pageLoaded.complete();
    };

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await Future.delayed(Duration(seconds: 1));

    var screenshotConfiguration = ScreenshotConfiguration(
        compressFormat: CompressFormat.JPEG,
        quality: 20,
        rect: InAppWebViewRect(width: 100, height: 100, x: 50, y: 50));
    var screenshot = await controller.takeScreenshot(
        screenshotConfiguration: screenshotConfiguration);
    expect(screenshot, isNotNull);
  }, skip: shouldSkip);
}
