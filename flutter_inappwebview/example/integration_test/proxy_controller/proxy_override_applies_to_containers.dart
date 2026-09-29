part of 'main.dart';

void proxyOverrideAppliesToContainers() {
  final shouldSkip =
      !ProxyController.isMethodSupported(
        PlatformProxyControllerMethod.setProxyOverride,
      ) ||
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.containerId,
      );

  // A container's storage backend — WKWebsiteDataStore(forIdentifier:) on
  // Apple, WebKitNetworkSession on Linux — is created lazily, the first time a
  // WebView joins that container, and setProxyOverride can only reach the
  // backends that exist when it runs. So the ordering below, override first
  // and container joined afterwards, checks that a backend created later picks
  // the override up. The containerId is unique per run so the backend really
  // is created after the override.
  skippableTestWidgets('proxy override reaches a container joined afterwards', (
    WidgetTester tester,
  ) async {
    final proxyController = ProxyController.instance();
    final containerId =
        'proxy-container-${DateTime.now().millisecondsSinceEpoch}';

    await proxyController.clearProxyOverride();
    await proxyController.setProxyOverride(
      settings: ProxySettings(
        proxyRules: [ProxyRule(url: "${environment["NODE_SERVER_IP"]}:8083")],
      ),
    );

    try {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_HTTP_EXAMPLE),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              containerId: containerId,
            ),
            onWebViewCreated: controllerCompleter.complete,
            onLoadStop: (_, _) => pageLoaded.complete(),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await tester.pump();
      await pageLoaded.future;

      // The test server's proxy answers every request with its own page, so
      // receiving it proves the contained WebView went through the proxy.
      expect(
        await controller.evaluateJavascript(
          source: "document.getElementById('method').innerHTML;",
        ),
        "GET",
        reason: 'a container joined after setProxyOverride must still be proxied',
      );
    } finally {
      await proxyController.clearProxyOverride();
    }
  }, skip: shouldSkip);
}
