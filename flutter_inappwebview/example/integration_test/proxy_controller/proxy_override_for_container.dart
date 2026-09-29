part of 'main.dart';

// A container's proxy has one entry, which ProxyController.setProxyOverride
// with a containerId and a WebView's InAppWebViewSettings.proxySettings both
// write. These check that the two agree in both directions, and that the
// app-wide override and a container's own leave each other alone. The test
// server's proxies on 8083 and 8084 answer every request with a page naming
// them, A and B, so each load reports which proxy served it.
void proxyOverrideForContainer() {
  final containersSkip =
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.proxySettings,
      ) ||
      !InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.containerId,
      );
  final appWideSkip = !ProxyController.isClassSupported();
  final ownIncognitoSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.proxySettings,
  );

  ProxySettings proxy(int port) => ProxySettings(
    proxyRules: [
      ProxyRule(url: 'http://${environment["NODE_SERVER_IP"]}:$port'),
    ],
  );
  final a = proxy(8083);
  final b = proxy(8084);
  final proxyController = ProxyController.instance();
  String fresh(String name) =>
      'proxy-$name-${DateTime.now().microsecondsSinceEpoch}';

  // Opens a WebView and returns a function that loads a fresh URL in it and
  // reports which proxy served that load.
  Future<Future<String?> Function()> open(
    WidgetTester tester,
    InAppWebViewSettings settings,
  ) async {
    final created = Completer<InAppWebViewController>();
    var loaded = Completer<void>();
    var step = 0;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    settings.javaScriptEnabled = true;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialSettings: settings,
          onWebViewCreated: created.complete,
          onLoadStop: (_, url) {
            if (url?.host == 'www.example.com' && !loaded.isCompleted) {
              loaded.complete();
            }
          },
        ),
      ),
    );
    final controller = await created.future;
    await tester.pump();
    return () async {
      loaded = Completer<void>();
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri('http://www.example.com/load-${step++}?$stamp'),
        ),
      );
      await loaded.future;
      final served = await controller.evaluateJavascript(
        source: "document.getElementById('proxy')?.innerHTML ?? null;",
      );
      return served?.toString();
    };
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  skippableTestWidgets(
    'setProxyOverride with a containerId proxies that container',
    (WidgetTester tester) async {
      final container = fresh('set');
      await proxyController.setProxyOverride(
        settings: b,
        containerId: container,
      );
      try {
        final load = await open(
          tester,
          InAppWebViewSettings(containerId: container),
        );
        expect(await load(), 'B');
      } finally {
        await close(tester);
        await proxyController.clearProxyOverride(containerId: container);
      }
    },
    skip: containersSkip,
  );

  skippableTestWidgets(
    'a WebView without proxySettings leaves its container proxy alone',
    (WidgetTester tester) async {
      final container = fresh('unset');
      try {
        final first = await open(
          tester,
          InAppWebViewSettings(containerId: container, proxySettings: b),
        );
        expect(await first(), 'B');
        final second = await open(
          tester,
          InAppWebViewSettings(containerId: container),
        );
        expect(
          await second(),
          'B',
          reason:
              'opening a WebView that names no proxy must not change the '
              "container's",
        );
      } finally {
        await close(tester);
        await proxyController.clearProxyOverride(containerId: container);
      }
    },
    skip: containersSkip,
  );

  skippableTestWidgets(
    'setProxyOverride moves an open WebView that proxySettings bound',
    (WidgetTester tester) async {
      final container = fresh('move');
      try {
        final load = await open(
          tester,
          InAppWebViewSettings(containerId: container, proxySettings: a),
        );
        expect(await load(), 'A');
        await proxyController.setProxyOverride(
          settings: b,
          containerId: container,
        );
        expect(
          await load(),
          'B',
          reason:
              'ProxyController and proxySettings write the same entry, so '
              'the open WebView moves to B',
        );
      } finally {
        await close(tester);
        await proxyController.clearProxyOverride(containerId: container);
      }
    },
    skip: containersSkip,
  );

  skippableTestWidgets(
    'clearProxyOverride with a containerId hands it back to the app-wide override',
    (WidgetTester tester) async {
      final container = fresh('clear');
      await proxyController.setProxyOverride(settings: a);
      await proxyController.setProxyOverride(
        settings: b,
        containerId: container,
      );
      try {
        final load = await open(
          tester,
          InAppWebViewSettings(containerId: container),
        );
        expect(await load(), 'B');
        await proxyController.clearProxyOverride(containerId: container);
        expect(await load(), 'A');
      } finally {
        await close(tester);
        await proxyController.clearProxyOverride(containerId: container);
        await proxyController.clearProxyOverride();
      }
    },
    skip: containersSkip,
  );

  skippableTestWidgets(
    'the app-wide override leaves a container with its own alone',
    (WidgetTester tester) async {
      final container = fresh('own');
      await proxyController.setProxyOverride(
        settings: b,
        containerId: container,
      );
      await proxyController.setProxyOverride(settings: a);
      try {
        final load = await open(
          tester,
          InAppWebViewSettings(containerId: container),
        );
        expect(await load(), 'B');
        await proxyController.clearProxyOverride();
        expect(await load(), 'B');
      } finally {
        await close(tester);
        await proxyController.clearProxyOverride(containerId: container);
        await proxyController.clearProxyOverride();
      }
    },
    skip: containersSkip,
  );

  skippableTestWidgets('deleting a container drops its proxy', (
    WidgetTester tester,
  ) async {
    final container = fresh('delete');
    final containerController = ContainerController.instance();
    await proxyController.setProxyOverride(settings: a);
    await proxyController.setProxyOverride(settings: b, containerId: container);
    try {
      final load = await open(
        tester,
        InAppWebViewSettings(containerId: container),
      );
      expect(await load(), 'B');
      await close(tester);
      // WebKit releases a disposed WebView's store asynchronously, and
      // deleteContainer refuses a store still in use.
      var deleted = false;
      for (var i = 0; i < 20 && !deleted; i++) {
        deleted = await containerController.deleteContainer(container);
        if (!deleted) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      expect(deleted, isTrue);
      final again = await open(
        tester,
        InAppWebViewSettings(containerId: container),
      );
      expect(
        await again(),
        'A',
        reason:
            'a container created again under the same id starts from the '
            'app-wide proxy',
      );
    } finally {
      await close(tester);
      await proxyController.clearProxyOverride(containerId: container);
      await proxyController.clearProxyOverride();
    }
  }, skip: containersSkip || !ContainerController.isClassSupported());

  skippableTestWidgets('an incognito WebView follows the app-wide override', (
    WidgetTester tester,
  ) async {
    await proxyController.setProxyOverride(settings: a);
    try {
      final load = await open(tester, InAppWebViewSettings(incognito: true));
      expect(await load(), 'A');
    } finally {
      await close(tester);
      await proxyController.clearProxyOverride();
    }
  }, skip: appWideSkip);

  skippableTestWidgets('an incognito WebView keeps its own proxySettings', (
    WidgetTester tester,
  ) async {
    await proxyController.setProxyOverride(settings: a);
    try {
      final load = await open(
        tester,
        InAppWebViewSettings(incognito: true, proxySettings: b),
      );
      expect(await load(), 'B');
    } finally {
      await close(tester);
      await proxyController.clearProxyOverride();
    }
  }, skip: ownIncognitoSkip);
}
