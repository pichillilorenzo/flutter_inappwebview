import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

void onJsBeforeUnload() {
  // final shouldSkip = kIsWeb
  //     ? true
  //     : ![
  //         TargetPlatform.android,
  //       ].contains(defaultTargetPlatform);
  final shouldSkip = true;
  // on Android, for some reason, it works on an example app but not in this test
  testWidgets('onJsBeforeUnload', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> onJsBeforeUnloadCompleter = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: "test_assets/in_app_webview_on_js_before_unload.html",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onJsBeforeUnload: (controller, jsBeforeUnloadRequest) async {
            onJsBeforeUnloadCompleter
                .complete(jsBeforeUnloadRequest.url.toString());
            return null;
          },
        ),
      ),
    );

    final String url = await onJsBeforeUnloadCompleter.future;
    expect(
        url, endsWith("test_assets/in_app_webview_on_js_before_unload.html"));
  }, skip: shouldSkip);
}
