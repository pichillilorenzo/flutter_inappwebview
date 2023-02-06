import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void setCustomUserAgent() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('set custom userAgent', (WidgetTester tester) async {
    final Completer controllerCompleter1 = Completer<InAppWebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            userAgent: 'Custom_User_Agent1',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter1.complete(controller);
          },
        ),
      ),
    );
    InAppWebViewController controller1 = await controllerCompleter1.future;
    final String customUserAgent1 =
        await controller1.evaluateJavascript(source: 'navigator.userAgent;');
    expect(customUserAgent1, 'Custom_User_Agent1');

    await controller1.setSettings(
        settings: InAppWebViewSettings(
      userAgent: 'Custom_User_Agent2',
    ));

    final String customUserAgent2 =
        await controller1.evaluateJavascript(source: 'navigator.userAgent;');
    expect(customUserAgent2, 'Custom_User_Agent2');
  }, skip: shouldSkip);
}
