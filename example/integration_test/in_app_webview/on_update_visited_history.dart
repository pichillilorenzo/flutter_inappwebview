import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onUpdateVisitedHistory() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('onUpdateVisitedHistory', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> firstPushCompleter = Completer<String>();
    final Completer<String> secondPushCompleter = Completer<String>();
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
              secondPushCompleter.complete(url.toString());
            } else if (url.toString().endsWith("first-push")) {
              firstPushCompleter.complete(url.toString());
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

    var firstPushUrl = await firstPushCompleter.future;
    expect(firstPushUrl,
        '${!kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_BASE_URL}first-push');

    var secondPushUrl = await secondPushCompleter.future;
    expect(secondPushUrl,
        '${!kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_BASE_URL}second-push');
  }, skip: shouldSkip);
}
