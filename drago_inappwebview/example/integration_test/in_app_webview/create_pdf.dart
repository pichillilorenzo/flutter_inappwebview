part of 'main.dart';

void createPdf() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.createPdf,
  );

  skippableTestWidgets('createPdf', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    var pdfConfiguration = PDFConfiguration(
      rect: InAppWebViewRect(width: 100, height: 100, x: 50, y: 50),
    );
    var pdf = await controller.createPdf(pdfConfiguration: pdfConfiguration);
    expect(pdf, isNotNull);
  }, skip: shouldSkip);
}
