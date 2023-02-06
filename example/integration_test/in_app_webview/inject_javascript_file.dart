import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void injectJavascriptFile() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_URL_ABOUT_BLANK : TEST_WEB_PLATFORM_URL_1;

  group('inject javascript file', () {
    testWidgets('from url', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> jQueryLoaded = Completer<void>();
      final Completer<void> jQueryLoadError = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: url),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.injectJavascriptFileFromUrl(
          urlFile: WebUri('https://www.notawebsite..com/jquery-3.3.1.min.js'),
          scriptHtmlTagAttributes: ScriptHtmlTagAttributes(
            id: 'jquery-error',
            onError: () {
              jQueryLoadError.complete();
            },
          ));
      await jQueryLoadError.future;
      expect(
          await controller.evaluateJavascript(
              source: "document.body.querySelector('#jquery-error') == null;"),
          false);
      expect(
          await controller.evaluateJavascript(source: "window.jQuery == null;"),
          true);

      await controller.injectJavascriptFileFromUrl(
          urlFile: WebUri('https://code.jquery.com/jquery-3.3.1.min.js'),
          scriptHtmlTagAttributes: ScriptHtmlTagAttributes(
            id: 'jquery',
            onLoad: () {
              jQueryLoaded.complete();
            },
          ));
      await jQueryLoaded.future;
      expect(
          await controller.evaluateJavascript(
              source: "document.body.querySelector('#jquery') == null;"),
          false);
      expect(
          await controller.evaluateJavascript(source: "window.jQuery == null;"),
          false);
    });

    testWidgets('from asset', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: url),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      await controller.injectJavascriptFileFromAsset(
          assetFilePath: 'test_assets/js/jquery-3.3.1.min.js');
      expect(
          await controller.evaluateJavascript(source: "window.jQuery == null;"),
          false);
    });
  }, skip: shouldSkip);
}
