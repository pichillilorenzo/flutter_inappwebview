import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onUpdateVisitedHistory() {
  final shouldSkip = !kIsWeb ||
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('onUpdateVisitedHistory', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> firstPushCompleter = Completer<void>();
    final Completer<void> secondPushCompleter = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          initialSettings: InAppWebViewSettings(clearCache: true),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) async {
            if (url!.toString().endsWith("second-push")) {
              secondPushCompleter.complete();
            } else if (url.toString().endsWith("first-push")) {
              firstPushCompleter.complete();
            }
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await controller.evaluateJavascript(source: """
var state = {}
var title = ''
var url = 'first-push';
history.pushState(state, title, url);

setTimeout(function() {
    var url = 'second-push';
    history.pushState(state, title, url);
}, 500);
""");

    await firstPushCompleter.future;
    expect((await controller.getUrl())?.toString(),
        '${!kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_BASE_URL}/first-push');

    await secondPushCompleter.future;
    expect((await controller.getUrl())?.toString(),
        '${!kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_BASE_URL}/second-push');
  }, skip: shouldSkip);
}
