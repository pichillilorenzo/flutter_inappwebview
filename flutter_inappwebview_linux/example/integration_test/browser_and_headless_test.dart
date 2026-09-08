// End-to-end tests for the two other WebView hosts on Linux:
//  - InAppBrowser: a standalone GTK window with an embedded WebView
//  - HeadlessInAppWebView: a WebView without any Flutter widget
//
// Run with:
//   flutter test integration_test/browser_and_headless_test.dart -d linux

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

const String _kHtml = '''
<!DOCTYPE html>
<html><head><title>Backend Test Page</title></head>
<body style="background:#123456">
  <h1 id="h">Hello from WebKit</h1>
  <script>window.answer = 6 * 7;</script>
</body></html>
''';

class _BrowserEvents extends PlatformInAppBrowserEvents {
  final created = Completer<void>();
  final loaded = Completer<void>();
  final exited = Completer<void>();

  @override
  void onBrowserCreated() {
    if (!created.isCompleted) created.complete();
  }

  @override
  void onLoadStop(WebUri? url) {
    if (!loaded.isCompleted) loaded.complete();
  }

  @override
  void onExit() {
    if (!exited.isCompleted) exited.complete();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HeadlessInAppWebView loads content and runs JavaScript',
      (WidgetTester tester) async {
    LinuxInAppWebViewPlatform.registerWith();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));

    final loaded = Completer<void>();
    final headless = LinuxHeadlessInAppWebView(
      LinuxHeadlessInAppWebViewCreationParams(
        initialSize: const Size(640, 480),
        initialData: InAppWebViewInitialData(data: _kHtml),
        onLoadStop: (controller, url) {
          if (!loaded.isCompleted) loaded.complete();
        },
      ),
    );
    await headless.run();
    expect(headless.isRunning(), isTrue);

    for (int i = 0; i < 150 && !loaded.isCompleted; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(loaded.isCompleted, isTrue, reason: 'headless onLoadStop should fire');

    final controller = headless.webViewController!;
    expect(await controller.evaluateJavascript(source: 'window.answer'), 42);
    expect(await controller.getTitle(), 'Backend Test Page');

    // Headless views also render offscreen: a screenshot must be producible.
    final png = await controller.takeScreenshot();
    expect(png, isNotNull);
    expect(png!.length, greaterThan(100));

    await headless.dispose();
    expect(headless.isRunning(), isFalse);
  });

  testWidgets('InAppBrowser opens a native window, loads content and closes',
      (WidgetTester tester) async {
    LinuxInAppWebViewPlatform.registerWith();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));

    final events = _BrowserEvents();
    final browser = LinuxInAppBrowser(LinuxInAppBrowserCreationParams());
    browser.eventHandler = events;

    await browser.openData(
      data: _kHtml,
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(hidden: false),
        webViewSettings: InAppWebViewSettings(javaScriptEnabled: true),
      ),
    );

    for (int i = 0; i < 150 && !(events.created.isCompleted && events.loaded.isCompleted); i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(events.created.isCompleted, isTrue, reason: 'onBrowserCreated should fire');
    expect(events.loaded.isCompleted, isTrue, reason: 'onLoadStop should fire');

    final controller = browser.webViewController!;
    expect(await controller.evaluateJavascript(source: 'document.getElementById("h").textContent'),
        'Hello from WebKit');
    debugPrint('[TEST] browser exited before isHidden? ${events.exited.isCompleted}');
    expect(events.exited.isCompleted, isFalse,
        reason: 'browser window must stay open until close() is called');
    expect(await browser.isHidden(), isFalse);

    await browser.hide();
    await tester.pump(const Duration(milliseconds: 300));
    expect(await browser.isHidden(), isTrue);
    await browser.show();
    await tester.pump(const Duration(milliseconds: 300));
    expect(await browser.isHidden(), isFalse);

    await browser.close();
    for (int i = 0; i < 50 && !events.exited.isCompleted; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(events.exited.isCompleted, isTrue, reason: 'onExit should fire after close');
  });
}
