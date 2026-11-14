part of 'main.dart';

void onWindowFocus() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onWindowFocus,
  );

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('onWindowFocus', (WidgetTester tester) async {
    final Completer<void> onWindowFocusCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(
              source: 'window.dispatchEvent(new Event("focus"));',
            );
          },
          onWindowFocus: (controller) {
            onWindowFocusCompleter.complete();
          },
        ),
      ),
    );
    await tester.pump();
    await expectLater(onWindowFocusCompleter.future, completes);
  }, skip: shouldSkip);
}
