part of 'main.dart';

void perWebViewProxy() {
  // A WebView's own proxy: an incognito WebView gets a private data store
  // (WKWebsiteDataStore.nonPersistent() on Apple, an ephemeral
  // WebKitNetworkSession on Linux), so its proxySettings reaches it alone.
  // A WebView that is neither incognito nor in a container shares the
  // default store, and its proxySettings is ignored.
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.proxySettings,
  );

  // The test server's proxy (port 8083) answers *any* request with its own
  // "Proxy Works" page instead of forwarding, so the page that comes back is
  // itself the evidence: if the proxy is bound we get the marker document, and
  // if it is ignored we get whatever www.example.com serves, or nothing
  // offline. The destination must be a host this machine does not own: macOS
  // routes traffic for any of its own addresses over lo0 and never proxies it.
  skippableTestWidgets('proxySettings routes an incognito WebView through the proxy', (
    WidgetTester tester,
  ) async {
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
            incognito: true,
            proxySettings: ProxySettings(
              proxyRules: [
                ProxyRule(url: "${environment["NODE_SERVER_IP"]}:8083"),
              ],
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

    // Served by the proxy, not by www.example.com. `#url` is the request line
    // the proxy saw, which is the full URL on some platforms and just the path
    // on others — same split the ProxyController test documents.
    expect(
      await controller.evaluateJavascript(
        source: "document.getElementById('method').innerHTML;",
      ),
      "GET",
      reason: 'the page must come from the proxy, not from the origin',
    );
    expect(
      await controller.evaluateJavascript(
        source: "document.getElementById('url').innerHTML;",
      ),
      anyOf("/", TEST_URL_HTTP_EXAMPLE.toString()),
    );
  }, skip: shouldSkip);
}

void perWebViewProxyIsolation() {
  final shouldSkip =
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.proxySettings,
      ) ||
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.containerId,
      );

  // `proxyConfigurations` is a property of the storage session, so a
  // per-WebView proxy is only per-WebView when each WebView owns its session,
  // hence a containerId per side. Two proxies on different ports, each
  // answering with its own id, make the binding observable per WebView: A
  // must report A and B must report B. A WebView that reached the wrong proxy,
  // or none at all, has the wrong marker or none, so it cannot pass.
  skippableTestWidgets('each container WebView binds its own proxy', (
    WidgetTester tester,
  ) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;

    Future<String?> launch(String containerId, int proxyPort) async {
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
              proxySettings: ProxySettings(
                proxyRules: [
                  ProxyRule(
                    url: "${environment["NODE_SERVER_IP"]}:$proxyPort",
                  ),
                ],
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
      return await controller.evaluateJavascript(
        source: "document.getElementById('proxy')?.innerHTML;",
      );
    }

    final first = await launch('proxy-iso-a-$stamp', 8083);
    expect(
      first,
      'A',
      reason: 'the first container WebView must load through proxy A',
    );

    // The one that regresses: a second store, created after the first store's
    // proxy is already bound in the network process.
    final second = await launch('proxy-iso-b-$stamp', 8084);
    expect(
      second,
      'B',
      reason:
          'the second container WebView must load through its own proxy B, '
          'not through A and not unproxied',
    );
  }, skip: shouldSkip);
}
