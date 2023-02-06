import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void isSecureContext() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('isSecureContext', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final StreamController<String> pageLoads =
        StreamController<String>.broadcast();

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
            pageLoads.add(url!.toString());
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoads.stream.first;
    expect(await controller.isSecureContext(), true);

    if (!kIsWeb) {
      await controller.loadUrl(
          urlRequest: URLRequest(url: WebUri('http://example.com/')));
      await pageLoads.stream.first;
      expect(await controller.isSecureContext(), false);
    }

    pageLoads.close();
  }, skip: shouldSkip);
}
