import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void shouldInterceptRequest() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  testWidgets('shouldInterceptRequest', (WidgetTester tester) async {
    final Completer completer = Completer();

    var swAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      ServiceWorkerController serviceWorkerController =
          ServiceWorkerController.instance();

      await serviceWorkerController.setServiceWorkerClient(ServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          if (!completer.isCompleted) {
            completer.complete();
          }
          return null;
        },
      ));
    } else {
      completer.complete();
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_SERVICE_WORKER_URL),
        ),
      ),
    );

    await expectLater(completer.future, completes);
  }, skip: shouldSkip);
}
