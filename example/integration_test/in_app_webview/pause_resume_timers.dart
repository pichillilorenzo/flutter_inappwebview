import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void pauseResumeTimers() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('pause/resume timers', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await controller.evaluateJavascript(source: """
      var count = 0;
      setInterval(function() {
        count = count + 10;
      }, 20);
      """);

    await controller.pauseTimers();
    await Future.delayed(Duration(seconds: 2));
    await controller.resumeTimers();
    expect(await controller.evaluateJavascript(source: "count;"), lessThan(50));
    await Future.delayed(Duration(seconds: 4));
    expect(
        await controller.evaluateJavascript(source: "count;"), greaterThan(50));
  }, skip: shouldSkip);
}
