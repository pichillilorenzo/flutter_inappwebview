import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void loadUrl() {
  final shouldSkip = kIsWeb ? false :
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  var initialUrl = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('loadUrl', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final StreamController<String> pageLoads =
    StreamController<String>.broadcast();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
          URLRequest(url: initialUrl),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoads.add(url!.toString());
          },
        ),
      ),
    );
    final InAppWebViewController controller =
    await controllerCompleter.future;
    var url = await pageLoads.stream.first;
    expect(url, initialUrl.toString());

    await controller.loadUrl(
        urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1));
    url = await pageLoads.stream.first;
    expect(url, TEST_CROSS_PLATFORM_URL_1.toString());

    pageLoads.close();
  }, skip: shouldSkip);
}
