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

  skippableTestWidgets('JavaScript handler JSON results are parsed as data', (
    WidgetTester tester,
  ) async {
    final controllerReady = Completer<InAppWebViewController>();
    final pageLoaded = Completer<void>();
    final report = Completer<Map<String, dynamic>>();
    const rawValues = [
      '{"__proto__":1,"__proto__":2}',
      '{"__proto__":{"inherited":true},"ok":1}',
      '{"nested":[{"__proto__":null,"__proto__":{"x":1}}]}',
      r'"עברית 😃\n"',
      'null',
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          initialData: InAppWebViewInitialData(
            data: '<html><body></body></html>',
          ),
          onWebViewCreated: (controller) {
            controllerReady.complete(controller);
            controller.addJavaScriptHandler(
              handlerName: 'rawJson',
              callback: (JavaScriptHandlerFunctionData data) =>
                  JavaScriptHandlerJsonResult(rawValues[data.args[0] as int]),
            );
            controller.addJavaScriptHandler(
              handlerName: 'invalidJson',
              callback: (JavaScriptHandlerFunctionData data) =>
                  const JavaScriptHandlerJsonResult('{"broken":'),
            );
            controller.addJavaScriptHandler(
              handlerName: 'jsonReport',
              callback: (JavaScriptHandlerFunctionData data) {
                report.complete(Map<String, dynamic>.from(data.args[0] as Map));
              },
            );
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) pageLoaded.complete();
          },
        ),
      ),
    );
    final controller = await controllerReady.future;
    await tester.pump();
    await pageLoaded.future;
    await controller.evaluateJavascript(
      source:
          '''
      (async function() {
        var bridge = window.flutter_inappwebview;
        try {
          var values = [];
          for (var i = 0; i < ${rawValues.length}; i++) {
            values.push(await bridge.callHandler('rawJson', i));
          }
          var rejected = false;
          try { await bridge.callHandler('invalidJson'); }
          catch (error) { rejected = true; }
          await bridge.callHandler('jsonReport', {
            values: values,
            ownProto: Object.prototype.hasOwnProperty.call(values[1], '__proto__'),
            inherited: values[1].inherited === true,
            rejected: rejected
          });
        } catch (error) {
          await bridge.callHandler('jsonReport', {error: String(error)});
        }
      })();
    ''',
    );
    final result = await report.future.timeout(const Duration(seconds: 10));
    expect(result['error'], isNull);
    expect(result['values'], rawValues.map(jsonDecode).toList());
    expect(result['ownProto'], isTrue);
    expect(result['inherited'], isFalse);
    expect(result['rejected'], isTrue);
  }, skip: shouldSkip);
}
