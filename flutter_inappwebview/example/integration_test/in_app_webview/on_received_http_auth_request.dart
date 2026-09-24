part of 'main.dart';

void onReceivedHttpAuthRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onReceivedHttpAuthRequest,
  );

  skippableTestWidgets('onReceivedHttpAuthRequest', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final List<HttpAuthenticationChallenge> challenges = [];
    final url = WebUri("http://${environment["NODE_SERVER_IP"]}:8081/");

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialSettings: InAppWebViewSettings(clearCache: true),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, loadedUrl) {
            if (loadedUrl?.port == url.port && !pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onReceivedHttpAuthRequest: (controller, challenge) async {
            challenges.add(challenge);
            // A wrong password first, so that the server challenges again.
            return new HttpAuthResponse(
              username: "USERNAME",
              password: challenges.length == 1 ? "WRONG_PASSWORD" : "PASSWORD",
              action: HttpAuthResponseAction.PROCEED,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    // Loaded once the controller exists rather than with initialUrlRequest, so
    // that the first challenge cannot race the WebView's creation.
    await controller.loadUrl(urlRequest: URLRequest(url: url));
    await pageLoaded.future;

    expect(challenges.length, 2);
    expect(challenges[0].protectionSpace.host, environment["NODE_SERVER_IP"]);
    expect(challenges[0].protectionSpace.realm, "Node");
    // Platforms count differently (Windows resets the count on every
    // navigation), but a retry always reports a previous failure.
    expect(challenges[1].previousFailureCount, greaterThan(0));

    final String h1Content = await controller.evaluateJavascript(
      source: "document.body.querySelector('h1').textContent",
    );
    expect(h1Content, "Authorized");
  }, skip: shouldSkip);
}
