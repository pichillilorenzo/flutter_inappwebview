import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onJsBeforeUnload() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
      ].contains(defaultTargetPlatform);

  testWidgets('onJsBeforeUnload', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<String> onJsBeforeUnloadCompleter = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
          URLRequest(url: TEST_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: """
            window.addEventListener('beforeunload', function (e) {
              e.preventDefault();
              e.returnValue = '';
            });
            """);
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onJsBeforeUnload: (controller, jsBeforeUnloadRequest) async {
            onJsBeforeUnloadCompleter
                .complete(jsBeforeUnloadRequest.url.toString());
            return null;
          },
        ),
      ),
    );

    final InAppWebViewController controller =
    await controllerCompleter.future;
    await pageLoaded.future;
    await controller.evaluateJavascript(
        source: "window.location.href = '$TEST_URL_1';");
    final String url = await onJsBeforeUnloadCompleter.future;
    expect(url, TEST_URL_1.toString());
  }, skip: shouldSkip);
}
