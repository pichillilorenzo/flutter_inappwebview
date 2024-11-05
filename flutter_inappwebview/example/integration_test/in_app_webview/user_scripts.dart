part of 'main.dart';

void userScripts() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableGroup('user scripts', () {
    skippableTestWidgets('initialUserScripts', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
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
                  forMainFrameOnly:
                      defaultTargetPlatform != TargetPlatform.android,
                  contentWorld: ContentWorld.DEFAULT_CLIENT),
              UserScript(
                  source: "var bar2 = 12;",
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                  forMainFrameOnly:
                      defaultTargetPlatform != TargetPlatform.android,
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
      final InAppWebViewController controller =
          await controllerCompleter.future;
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
    });

    skippableTestWidgets('add/remove user scripts',
        (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;

      var userScript1 = UserScript(
          source: "window.foo = 49;",
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START);
      var userScript2 = UserScript(
          source: "window.bar = 19;",
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END);
      await controller.addUserScripts(userScripts: [userScript1, userScript2]);
      await controller.reload();
      await pageLoads.stream.first;
      var value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, 49);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, 19);

      await controller.removeUserScript(userScript: userScript1);
      await controller.reload();
      await pageLoads.stream.first;
      value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, isNull);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, 19);

      await controller.removeAllUserScripts();
      await controller.reload();
      await pageLoads.stream.first;
      value = await controller.evaluateJavascript(source: "window.foo;");
      expect(value, isNull);
      value = await controller.evaluateJavascript(source: "window.bar;");
      expect(value, isNull);

      pageLoads.close();
    });
  }, skip: shouldSkip);
}
