part of 'main.dart';

void onPrint() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onPrintRequest,
  );

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('onPrint', (WidgetTester tester) async {
    final Completer<String> onPrintCompleter = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: "window.print();");
          },
          onPrintRequest: (controller, url, printJob) async {
            onPrintCompleter.complete(url?.toString());
            return false;
          },
        ),
      ),
    );
    await tester.pump();
    final String printUrl = await onPrintCompleter.future;
    expect(printUrl, url.toString());
  }, skip: shouldSkip);
}
