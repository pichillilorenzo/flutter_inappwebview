import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onNavigationResponse() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  group("onNavigationResponse", () {
    testWidgets('allow navigation', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<String> onNavigationResponseCompleter =
          Completer<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onNavigationResponse: (controller, navigationResponse) async {
              onNavigationResponseCompleter
                  .complete(navigationResponse.response!.url.toString());
              return NavigationResponseAction.ALLOW;
            },
          ),
        ),
      );

      await pageLoaded.future;
      final String url = await onNavigationResponseCompleter.future;
      expect(url, TEST_URL_1.toString());
    });

    testWidgets('cancel navigation', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<String> onNavigationResponseCompleter =
          Completer<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onNavigationResponse: (controller, navigationResponse) async {
              onNavigationResponseCompleter
                  .complete(navigationResponse.response!.url.toString());
              return NavigationResponseAction.CANCEL;
            },
          ),
        ),
      );

      final String url = await onNavigationResponseCompleter.future;
      expect(url, TEST_URL_1.toString());
      expect(pageLoaded.future, doesNotComplete);
    });
  }, skip: shouldSkip);
}
