part of 'main.dart';

void loadAssetFile(InAppLocalhostServer localhostServer) {
  final shouldSkip = kIsWeb || !InAppWebView.isClassSupported();

  skippableTestWidgets('load asset file', (WidgetTester tester) async {
    expect(localhostServer.isRunning(), true);

    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(
            url: WebUri('http://localhost:8080/test_assets/index.html'),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final String? currentUrl = (await controller.getUrl())?.toString();
    expect(currentUrl, 'http://localhost:8080/test_assets/index.html');
  }, skip: shouldSkip);
}
