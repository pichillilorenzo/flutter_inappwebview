import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void initialUserScripts() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  testWidgets('initialUserScripts', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          initialUserScripts: UnmodifiableListView<UserScript>([
            UserScript(
                source: "var foo = 49;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START),
            UserScript(
                source: "var foo2 = 19;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                contentWorld: ContentWorld.PAGE),
            UserScript(
                source: "var bar = 2;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                contentWorld: ContentWorld.DEFAULT_CLIENT),
            UserScript(
                source: "var bar2 = 12;",
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                contentWorld: ContentWorld.world(name: "test")),
          ]),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) async {
            pageLoaded.complete();
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    expect(await controller.evaluateJavascript(source: "foo;"), 49);
    expect(await controller.evaluateJavascript(source: "foo2;"), 19);
    expect(
        await controller.evaluateJavascript(
            source: "foo2;", contentWorld: ContentWorld.PAGE),
        19);
    expect(await controller.evaluateJavascript(source: "bar;"), isNull);
    expect(await controller.evaluateJavascript(source: "bar2;"), isNull);
    expect(
        await controller.evaluateJavascript(
            source: "bar;", contentWorld: ContentWorld.DEFAULT_CLIENT),
        2);
    expect(
        await controller.evaluateJavascript(
            source: "bar2;", contentWorld: ContentWorld.world(name: "test")),
        12);
  }, skip: shouldSkip);
}
