import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void initialUrlRequest() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  group('initial url request', () {
    final shouldSkipTest2 = kIsWeb
        ? true
        : ![
            TargetPlatform.iOS,
            TargetPlatform.macOS,
          ].contains(defaultTargetPlatform);

    testWidgets('launches with allowsBackForwardNavigationGestures true',
        (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 300,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: TEST_URL_1),
              initialSettings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: true),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        ),
      );
      await pageLoaded.future;
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, TEST_URL_1.toString());
    }, skip: shouldSkipTest2);

    final shouldSkipTest1 = kIsWeb
        ? false
        : ![
            TargetPlatform.android,
            TargetPlatform.iOS,
            TargetPlatform.macOS,
          ].contains(defaultTargetPlatform);

    testWidgets('basic', (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      await pageLoaded.future;
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();

      expect(currentUrl, TEST_CROSS_PLATFORM_URL_1.toString());
    }, skip: shouldSkipTest1);
  }, skip: shouldSkip);
}
