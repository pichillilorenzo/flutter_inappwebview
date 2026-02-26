part of 'main.dart';

void getCertificate() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getCertificate,
  );

  skippableTestWidgets('getCertificate', (WidgetTester tester) async {
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

    var sslCertificate = await controller.getCertificate();
    expect(sslCertificate, isNotNull);
    expect(sslCertificate!.x509Certificate, isNotNull);
    expect(sslCertificate.issuedBy, isNotNull);
    expect(sslCertificate.issuedTo, isNotNull);
    expect(sslCertificate.validNotAfterDate, isNotNull);
    expect(sslCertificate.validNotBeforeDate, isNotNull);
  }, skip: shouldSkip);
}
