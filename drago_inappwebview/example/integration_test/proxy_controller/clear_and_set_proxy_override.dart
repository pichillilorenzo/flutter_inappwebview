part of 'main.dart';

void clearAndSetProxyOverride() {
  final shouldSkip = !ProxyController.isMethodSupported(
    PlatformProxyControllerMethod.setProxyOverride,
  );

  skippableTestWidgets('clear and set proxy override', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();

    var proxyAvailable =
        !PlatformWebViewFeature.static().isClassSupported() ||
        await WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE);

    if (proxyAvailable) {
      ProxyController proxyController = ProxyController.instance();

      await proxyController.clearProxyOverride();
      await proxyController.setProxyOverride(
        settings: ProxySettings(
          proxyRules: [ProxyRule(url: "${environment["NODE_SERVER_IP"]}:8083")],
        ),
      );
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_HTTP_EXAMPLE),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;

    await tester.pump();

    final String url = await pageLoaded.future;
    expect(url, TEST_URL_HTTP_EXAMPLE.toString());

    // The proxy server's req.url returns different values by platform:
    // - Android: full URL (http://www.example.com/)
    // - macOS/iOS: just the path (/)
    final proxyUrl = await controller.evaluateJavascript(
      source: "document.getElementById('url').innerHTML;",
    );
    expect(proxyUrl, anyOf("/", TEST_URL_HTTP_EXAMPLE.toString()));
    expect(
      await controller.evaluateJavascript(
        source: "document.getElementById('method').innerHTML;",
      ),
      "GET",
    );
    expect(
      await controller.evaluateJavascript(
        source: "document.getElementById('headers').innerHTML;",
      ),
      isNotNull,
    );
  }, skip: shouldSkip);
}
