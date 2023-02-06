import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void setServiceWorkerClient() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  testWidgets('setServiceWorkerClient to null', (WidgetTester tester) async {
    final Completer<String> pageLoaded = Completer<String>();

    var swAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      ServiceWorkerController serviceWorkerController =
          ServiceWorkerController.instance();

      await serviceWorkerController.setServiceWorkerClient(null);
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_SERVICE_WORKER_URL),
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final String url = await pageLoaded.future;
    expect(url, TEST_SERVICE_WORKER_URL.toString());
  }, skip: shouldSkip);
}
