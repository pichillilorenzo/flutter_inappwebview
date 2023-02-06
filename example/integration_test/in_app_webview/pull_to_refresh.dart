import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void pullToRefresh() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('launches with pull-to-refresh feature',
      (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
          color: Colors.blue,
          size: PullToRefreshSize.DEFAULT,
          backgroundColor: Colors.grey,
          enabled: true,
          slingshotDistance: 150,
          distanceToTriggerSync: 150,
          attributedTitle: AttributedString(string: "test")),
      onRefresh: () {},
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_1),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final String? currentUrl = (await controller.getUrl())?.toString();
    expect(currentUrl, TEST_URL_1.toString());
  }, skip: shouldSkip);
}
