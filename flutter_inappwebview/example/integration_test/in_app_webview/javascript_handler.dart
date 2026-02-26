part of 'main.dart';

void javascriptHandler() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
  );

  skippableTestWidgets('JavaScript Handler', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageStarted = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> handlerFoo = Completer<void>();
    final Completer<void> handlerFooWithArgs = Completer<void>();
    final List<dynamic> messagesReceived = <dynamic>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile:
              "test_assets/in_app_webview_javascript_handler_test.html",
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(
              handlerName: 'handlerFoo',
              callback: (args) {
                handlerFoo.complete();
                return Foo(bar: 'bar_value', baz: 'baz_value');
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'handlerFooWithArgs',
              callback: (args) {
                messagesReceived.add(args[0] as int);
                messagesReceived.add(args[1] as bool);
                messagesReceived.add(args[2] as List<dynamic>?);
                messagesReceived.add(
                  args[3]?.cast<String, String>() as Map<String, String>?,
                );
                messagesReceived.add(
                  args[4]?.cast<String, String>() as Map<String, String>?,
                );
                handlerFooWithArgs.complete();
              },
            );
          },
          initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
          onLoadStart: (controller, url) {
            pageStarted.complete();
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    await pageStarted.future;
    await pageLoaded.future;
    await handlerFoo.future;
    await handlerFooWithArgs.future;

    expect(messagesReceived[0], 1);
    expect(messagesReceived[1], true);
    expect(listEquals(messagesReceived[2] as List<dynamic>?, ["bar", 5]), true);
    expect(mapEquals(messagesReceived[3], {"foo": "baz"}), true);
    expect(
      mapEquals(messagesReceived[4], {"bar": "bar_value", "baz": "baz_value"}),
      true,
    );
  }, skip: shouldSkip);
}
