part of 'main.dart';

// A container's storage session outlives its WebViews, so a proxy change for
// the container lands on a session that may still pool a connection opened
// through the old proxy. Each case loads through proxy A, disposes the
// WebView, rebuilds it on the same container with proxy B and checks that B
// served the second load.
void containerProxyChange() {
  final shouldSkip =
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.proxySettings,
      ) ||
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.containerId,
      );

  // test_node_server: HTTP proxies on 8083/8084, SOCKS5 proxies on 8085/8086,
  // each answering with its own id.
  const ports = {
    'http': [8083, 8084],
    'socks5': [8085, 8086],
  };

  for (final scheme in ports.keys) {
    skippableTestWidgets('container proxy change from A to B over $scheme', (
      WidgetTester tester,
    ) async {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final containerId = 'proxy-change-$scheme-$stamp';

      Future<String?> load(int proxyPort, String step) async {
        final controllerCompleter = Completer<InAppWebViewController>();
        final pageLoaded = Completer<void>();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(
                url: WebUri('http://www.example.com/$step?$stamp'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                containerId: containerId,
                proxySettings: ProxySettings(
                  proxyRules: [
                    ProxyRule(
                      url:
                          '$scheme://${environment["NODE_SERVER_IP"]}:$proxyPort',
                    ),
                  ],
                ),
              ),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStop: (_, _) {
                if (!pageLoaded.isCompleted) pageLoaded.complete();
              },
            ),
          ),
        );
        final controller = await controllerCompleter.future;
        await tester.pump();
        await pageLoaded.future;
        final served = await controller.evaluateJavascript(
          source: "document.getElementById('proxy')?.innerHTML ?? null;",
        );
        // Dispose the WebView so nothing but the container holds its session.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        return served?.toString();
      }

      expect(await load(ports[scheme]![0], 'first'), 'A');
      final second = await load(ports[scheme]![1], 'second');
      expect(
        second,
        'B',
        reason:
            'after the container moved to proxy B its next load still '
            'went out through ${second ?? 'no proxy'}',
      );
    }, skip: shouldSkip);
  }
}
