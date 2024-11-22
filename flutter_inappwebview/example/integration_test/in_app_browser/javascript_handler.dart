part of 'main.dart';

void javascriptHandler() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableTest('JavaScript Handler', () async {
    final Completer<void> handlerFoo = Completer<void>();
    final Completer<void> handlerFooWithArgs = Completer<void>();
    final List<dynamic> messagesReceived = <dynamic>[];

    MyInAppBrowser inAppBrowser = MyInAppBrowser();
    inAppBrowser.browserCreated.future.then((_) {
      inAppBrowser.webViewController!.addJavaScriptHandler(
          handlerName: 'handlerFoo',
          callback: (args) {
            handlerFoo.complete();
            return Foo(bar: 'bar_value', baz: 'baz_value');
          });
      inAppBrowser.webViewController!.addJavaScriptHandler(
          handlerName: 'handlerFooWithArgs',
          callback: (args) {
            messagesReceived.add(args[0] as int);
            messagesReceived.add(args[1] as bool);
            messagesReceived.add(args[2] as List<dynamic>?);
            messagesReceived
                .add(args[3]?.cast<String, String>() as Map<String, String>?);
            messagesReceived
                .add(args[4]?.cast<String, String>() as Map<String, String>?);
            handlerFooWithArgs.complete();
          });
    });
    await inAppBrowser.openFile(
        assetFilePath:
            'test_assets/in_app_webview_javascript_handler_test.html');

    await handlerFoo.future;
    await handlerFooWithArgs.future;

    expect(messagesReceived[0], 1);
    expect(messagesReceived[1], true);
    expect(listEquals(messagesReceived[2] as List<dynamic>?, ["bar", 5]), true);
    expect(mapEquals(messagesReceived[3], {"foo": "baz"}), true);
    expect(
        mapEquals(
            messagesReceived[4], {"bar": "bar_value", "baz": "baz_value"}),
        true);
  }, skip: shouldSkip);
}
