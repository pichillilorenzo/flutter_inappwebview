part of 'main.dart';

void onReceivedHttpError() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onReceivedHttpError,
  );

  skippableTestWidgets('onReceivedHttpError', (WidgetTester tester) async {
    final Completer<String> errorUrlCompleter = Completer<String>();
    final Completer<int> statusCodeCompleter = Completer<int>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_404),
          onReceivedHttpError: (controller, request, errorResponse) async {
            errorUrlCompleter.complete(request.url.toString());
            statusCodeCompleter.complete(errorResponse.statusCode);
          },
        ),
      ),
    );

    final String url = await errorUrlCompleter.future;
    final int code = await statusCodeCompleter.future;

    expect(url, TEST_URL_404.toString());
    expect(code, 404);
  }, skip: shouldSkip);
}
