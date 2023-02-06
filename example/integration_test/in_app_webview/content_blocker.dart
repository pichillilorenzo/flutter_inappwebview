import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void contentBlocker() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('Content Blocker', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialSettings:
              InAppWebViewSettings(clearCache: true, contentBlockers: [
            ContentBlocker(
                trigger: ContentBlockerTrigger(urlFilter: ".*", resourceType: [
                  ContentBlockerTriggerResourceType.IMAGE,
                  ContentBlockerTriggerResourceType.STYLE_SHEET
                ], ifTopUrl: [
                  TEST_CROSS_PLATFORM_URL_1.toString()
                ]),
                action:
                    ContentBlockerAction(type: ContentBlockerActionType.BLOCK))
          ]),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );
    await expectLater(pageLoaded.future, completes);
  }, skip: shouldSkip);
}
