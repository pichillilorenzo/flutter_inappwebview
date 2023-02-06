import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onPrint() {
  final shouldSkip = kIsWeb
      ? false
      : ![
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
          initialUrlRequest: URLRequest(url: url),
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: "window.print();");
          },
          onPrintRequest: (controller, url, printJob) async {
            onPrintCompleter.complete(url?.toString());
            return false;
          },
        ),
      ),
    );
    await tester.pump();
    final String printUrl = await onPrintCompleter.future;
    expect(printUrl, url.toString());
  }, skip: shouldSkip);
}
