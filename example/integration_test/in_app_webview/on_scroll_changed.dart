import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onScrollChanged() {
  final shouldSkip = !kIsWeb || ![
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('onScrollChanged', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> onScrollChangedCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
          URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onScrollChanged: (controller, x, y) {
            if (x == 0 && y == 500) {
              onScrollChangedCompleter.complete();
            }
          },
        ),
      ),
    );

    final InAppWebViewController controller =
    await controllerCompleter.future;
    await pageLoaded.future;

    controller.scrollTo(x: 0, y: 500);
    await tester.pumpAndSettle(Duration(seconds: 1));

    await expectLater(onScrollChangedCompleter.future, completes);
  }, skip: shouldSkip);
}