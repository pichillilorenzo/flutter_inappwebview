part of 'main.dart';

void containerIsolation() {
  // containerId is honored on Android (System WebView 119+ via the
  // `MULTI_PROFILE` feature), iOS 17+ and macOS 14+. The setting is
  // serialized on every platform but only takes effect on those.
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.containerId,
  );

  // An older System WebView ignores containerId and uses the default profile.
  Future<bool> containersAvailable() async =>
      !PlatformWebViewFeature.static().isClassSupported() ||
      await WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE);

  // Two WebViews bound to the same profile must share storage; two
  // WebViews bound to different profiles must not. We probe this with
  // `localStorage` since it round-trips faster than HTTP cookies and
  // doesn't depend on the test server.
  skippableTestWidgets('containerId isolates storage between profiles', (
    WidgetTester tester,
  ) async {
    if (!await containersAvailable()) {
      markTestSkipped('WebViewFeature.MULTI_PROFILE is not supported');
      return;
    }
    final url = WebUri("http://${environment["NODE_SERVER_IP"]}:8082/");
    final keyA = 'profile-isolation-a-${DateTime.now().millisecondsSinceEpoch}';
    final keyB = 'profile-isolation-b-${DateTime.now().millisecondsSinceEpoch}';

    Future<InAppWebViewController> launch(String? containerId, Key key) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: key,
            initialUrlRequest: URLRequest(url: url),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              containerId: containerId,
            ),
            onWebViewCreated: controllerCompleter.complete,
            onLoadStop: (_, _) => pageLoaded.complete(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final controller = await controllerCompleter.future;
      await pageLoaded.future;
      return controller;
    }

    // Profile A: write a marker to localStorage.
    final a1 = await launch('test-profile-a', GlobalKey());
    await a1.evaluateJavascript(source: "localStorage.setItem('$keyA', 'A');");

    // Profile B: write a different marker.
    final b1 = await launch('test-profile-b', GlobalKey());
    await b1.evaluateJavascript(source: "localStorage.setItem('$keyB', 'B');");

    // Re-open profile A: marker A must still be there, marker B must not.
    final a2 = await launch('test-profile-a', GlobalKey());
    final aReadA = await a2.evaluateJavascript(
      source: "localStorage.getItem('$keyA');",
    );
    final aReadB = await a2.evaluateJavascript(
      source: "localStorage.getItem('$keyB');",
    );
    expect(aReadA, 'A', reason: 'profile A should retain its own marker');
    expect(aReadB, isNull, reason: "profile A must not see profile B's data");
  }, skip: shouldSkip);

  // ContainerController surfaces the registered containerIds and lets the
  // caller delete one. We register a probe profile via a HeadlessInAppWebView,
  // assert listing/has return it, then delete and assert it's gone.
  final controllerSkip = !ContainerController.isClassSupported();
  skippableTestWidgets('ContainerController list/has/delete', (
    WidgetTester tester,
  ) async {
    if (!await containersAvailable()) {
      markTestSkipped('WebViewFeature.MULTI_PROFILE is not supported');
      return;
    }
    final url = WebUri("http://${environment["NODE_SERVER_IP"]}:8082/");
    final probeId =
        'profile-controller-${DateTime.now().millisecondsSinceEpoch}';

    // Materialize the container by loading a page in a HeadlessInAppWebView
    // bound to it, then dispose the WebView (deleteContainer fails while
    // a live WebView is using the container).
    final pageLoaded = Completer<void>();
    final headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: url),
      initialSettings: InAppWebViewSettings(containerId: probeId),
      onLoadStop: (_, _) => pageLoaded.complete(),
    );
    await headless.run();
    await pageLoaded.future;
    // Force a write so the data store actually gets persisted to disk
    // (Apple's `allDataStoreIdentifiers` only lists materialized stores).
    await headless.webViewController?.evaluateJavascript(
      source: "localStorage.setItem('probe', '1');",
    );
    await headless.dispose();

    final controller = ContainerController.instance();
    final names = await controller.getAllContainerNames();
    expect(names, contains(probeId));
    expect(await controller.hasContainer(probeId), isTrue);

    if (defaultTargetPlatform == TargetPlatform.android) {
      // WebView keeps a profile loaded for the rest of the process once it
      // has been used, and refuses to delete a loaded profile.
      expect(await controller.deleteContainer(probeId), isFalse);
      expect(await controller.hasContainer(probeId), isTrue);
      return;
    }
    // WebKit lets go of a disposed WebView's data store asynchronously, so the
    // container can stay in use for a moment after dispose.
    var deleted = false;
    for (var attempt = 0; attempt < 20 && !deleted; attempt++) {
      deleted = await controller.deleteContainer(probeId);
      if (!deleted) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    expect(deleted, isTrue);
    expect(await controller.hasContainer(probeId), isFalse);
  }, skip: controllerSkip);
}
