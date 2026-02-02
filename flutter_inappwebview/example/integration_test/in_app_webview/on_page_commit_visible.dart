part of 'main.dart';

void onPageCommitVisible() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onPageCommitVisible,
  );

  skippableTestWidgets('onPageCommitVisible', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> onPageCommitVisibleCompleter = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onPageCommitVisible: (controller, url) {
            onPageCommitVisibleCompleter.complete(url?.toString());
          },
        ),
      ),
    );

    final String? url = await onPageCommitVisibleCompleter.future;
    expect(url, TEST_URL_1.toString());
  }, skip: shouldSkip);
}
