import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void initialUrlRequest() {
  final shouldSkip = !kIsWeb || ![
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);

  testWidgets('initialUrlRequest', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
          URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    final InAppWebViewController controller =
    await controllerCompleter.future;
    final String? currentUrl = (await controller.getUrl())?.toString();

    expect(currentUrl, TEST_CROSS_PLATFORM_URL_1.toString());
  }, skip: shouldSkip);
}