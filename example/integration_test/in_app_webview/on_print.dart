import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onPrint() {
  final shouldSkip = !kIsWeb || ![
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('onPrint', (WidgetTester tester) async {
    final Completer<String> onPrintCompleter = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
          URLRequest(url: url),
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: "window.print();");
          },
          onPrint: (controller, url) {
            onPrintCompleter.complete(url?.toString());
          },
        ),
      ),
    );
    await tester.pump();
    final String printUrl = await onPrintCompleter.future;
    expect(printUrl, url.toString());
  }, skip: shouldSkip);
}