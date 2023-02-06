import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onWindowBlur() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('onWindowBlur', (WidgetTester tester) async {
    final Completer<void> onWindowBlurCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(
                source: 'window.dispatchEvent(new Event("blur"));');
          },
          onWindowBlur: (controller) {
            onWindowBlurCompleter.complete();
          },
        ),
      ),
    );
    await expectLater(onWindowBlurCompleter.future, completes);
  }, skip: shouldSkip);
}
