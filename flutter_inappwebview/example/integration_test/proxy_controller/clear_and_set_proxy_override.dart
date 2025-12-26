part of 'main.dart';

void clearAndSetProxyOverride() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableTestWidgets('clear and set proxy override',
      (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();

    var proxyAvailable = defaultTargetPlatform != TargetPlatform.android ||
        await WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE);

    if (proxyAvailable) {
      ProxyController proxyController = ProxyController.instance();

      await proxyController.clearProxyOverride();
      await proxyController.setProxyOverride(
          settings: ProxySettings(
        proxyRules: [ProxyRule(url: "${environment["NODE_SERVER_IP"]}:8083")],
      ));
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

    final String url = await pageLoaded.future;
    expect(url, TEST_URL_HTTP_EXAMPLE.toString());

    expect(
        await controller.evaluateJavascript(
            source: "document.getElementById('url').innerHTML;"),
        TEST_URL_HTTP_EXAMPLE.toString());
    expect(
        await controller.evaluateJavascript(
            source: "document.getElementById('method').innerHTML;"),
        "GET");
    expect(
        await controller.evaluateJavascript(
            source: "document.getElementById('headers').innerHTML;"),
        isNotNull);
  }, skip: shouldSkip);
}
