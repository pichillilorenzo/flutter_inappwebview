part of 'main.dart';

void onConsoleMessage() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onConsoleMessage,
  );

  skippableTestWidgets('onConsoleMessage', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<ConsoleMessage> onConsoleMessageCompleter =
        Completer<ConsoleMessage>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: !kIsWeb
              ? "test_assets/in_app_webview_on_console_message_test.html"
              : null,
          initialUrlRequest: kIsWeb
              ? URLRequest(url: TEST_WEB_PLATFORM_URL_1)
              : null,
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onConsoleMessage: (controller, consoleMessage) {
            onConsoleMessageCompleter.complete(consoleMessage);
          },
        ),
      ),
    );
    await tester.pump();
    final ConsoleMessage consoleMessage =
        await onConsoleMessageCompleter.future;
    expect(consoleMessage.message, 'message');
    expect(consoleMessage.messageLevel, ConsoleMessageLevel.LOG);
  }, skip: shouldSkip);
}
