part of 'main.dart';

void setCustomUserAgent() {
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.userAgent,
  );

  skippableTestWidgets('set custom userAgent', (WidgetTester tester) async {
    final Completer controllerCompleter1 = Completer<InAppWebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            userAgent: 'Custom_User_Agent1',
          ),
          onWebViewCreated: (controller) {
            controllerCompleter1.complete(controller);
          },
        ),
      ),
    );
    InAppWebViewController controller1 = await controllerCompleter1.future;
    final String customUserAgent1 = await controller1.evaluateJavascript(
      source: 'navigator.userAgent;',
    );
    expect(customUserAgent1, 'Custom_User_Agent1');

    await controller1.setSettings(
      settings: InAppWebViewSettings(userAgent: 'Custom_User_Agent2'),
    );

    final String customUserAgent2 = await controller1.evaluateJavascript(
      source: 'navigator.userAgent;',
    );
    expect(customUserAgent2, 'Custom_User_Agent2');
  }, skip: shouldSkip);
}
