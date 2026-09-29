part of 'main.dart';

void emptyProxyOverrideIsRefused() {
  final shouldSkip = !ProxyController.isMethodSupported(
    PlatformProxyControllerMethod.setProxyOverride,
  );

  // A ProxySettings with no proxy rule names no proxy. Applying it would send
  // every request direct, so it is refused and the override already in place
  // stays; clearProxyOverride is how a caller asks for no proxy.
  skippableTestWidgets('proxy override with no proxy rule is refused', (
    WidgetTester tester,
  ) async {
    final proxyAvailable =
        !PlatformWebViewFeature.static().isClassSupported() ||
        await WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE);
    if (!proxyAvailable) {
      markTestSkipped('WebViewFeature.PROXY_OVERRIDE is not supported');
      return;
    }

    final proxyController = ProxyController.instance();
    await proxyController.clearProxyOverride();
    await proxyController.setProxyOverride(
      settings: ProxySettings(
        proxyRules: [ProxyRule(url: "${environment["NODE_SERVER_IP"]}:8083")],
      ),
    );

    try {
      await proxyController.setProxyOverride(settings: ProxySettings());

      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            // A fresh URL, so the page cannot come from the HTTP cache.
            initialUrlRequest: URLRequest(
              url: WebUri(
                '${TEST_URL_HTTP_EXAMPLE}?empty-override=${DateTime.now().millisecondsSinceEpoch}',
              ),
            ),
            onWebViewCreated: controllerCompleter.complete,
            onLoadStop: (_, _) => pageLoaded.complete(),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await tester.pump();
      await pageLoaded.future;

      expect(
        await controller.evaluateJavascript(
          source: "document.getElementById('proxy').innerHTML;",
        ),
        'A',
        reason: 'an override with no proxy rule must leave the current one in place',
      );
    } finally {
      await proxyController.clearProxyOverride();
    }
  }, skip: shouldSkip);
}
