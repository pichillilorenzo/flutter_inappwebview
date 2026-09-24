part of 'main.dart';

void sslRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onReceivedServerTrustAuthRequest,
  );

  skippableTestWidgets('SSL request', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(
            url: WebUri("https://${environment["NODE_SERVER_IP"]}:4433/"),
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            // On Linux, onLoadStop also fires for the load that failed the
            // server trust check, before it is retried.
            if (url?.scheme == "https" && !pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return new ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
          onReceivedClientCertRequest: (controller, challenge) async {
            return new ClientCertResponse(
              certificatePath: "test_assets/certificate.pfx",
              certificatePassword: "password",
              keyStoreType: "PKCS12",
              action: ClientCertResponseAction.PROCEED,
            );
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final String h1Content = await controller.evaluateJavascript(
      source: "document.body.querySelector('h1').textContent",
    );
    expect(h1Content, "Authorized");
  }, skip: shouldSkip);
}
