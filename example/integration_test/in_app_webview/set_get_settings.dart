import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void setGetSettings() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  final url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('set/get settings', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          initialSettings: InAppWebViewSettings(javaScriptEnabled: false),
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

    InAppWebViewSettings? settings = await controller.getSettings();
    expect(settings, isNotNull);
    expect(settings!.javaScriptEnabled, false);

    if (kIsWeb) {
      expect(settings.iframeSandbox, isNotNull);
      expect(settings.iframeSandbox!.contains(Sandbox.ALLOW_SCRIPTS), false);
    }

    await controller.setSettings(
        settings: InAppWebViewSettings(javaScriptEnabled: true));

    settings = await controller.getSettings();
    expect(settings, isNotNull);
    expect(settings!.javaScriptEnabled, true);

    if (kIsWeb) {
      expect(settings.iframeSandbox, isNotNull);
      expect(settings.iframeSandbox!.contains(Sandbox.ALLOW_SCRIPTS), true);
    }
  }, skip: shouldSkip);
}
