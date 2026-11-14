part of 'main.dart';

void containerIsolation() {
  // containerId is honored on Android (System WebView 110+ via the
  // `MULTI_PROFILE` feature), iOS 17+ and macOS 14+. The setting is
  // serialized on every platform but only takes effect on those.
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.containerId,
  );

  // Two WebViews bound to the same profile must share storage; two
  // WebViews bound to different profiles must not. We probe this with
  // `localStorage` since it round-trips faster than HTTP cookies and
  // doesn't depend on the test server.
  skippableTestWidgets('containerId isolates storage between profiles', (
    WidgetTester tester,
  ) async {
    final url = TEST_CROSS_PLATFORM_URL_1;
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

  // ProfileController surfaces the registered containerIds and lets the
  // caller delete one. We register a probe profile via a HeadlessInAppWebView,
  // assert listing/has return it, then delete and assert it's gone.
  final controllerSkip = !ProfileController.isClassSupported();
  skippableTestWidgets('ProfileController list/has/delete', (
    WidgetTester tester,
  ) async {
    final url = TEST_CROSS_PLATFORM_URL_1;
    final probeId =
        'profile-controller-${DateTime.now().millisecondsSinceEpoch}';

    // Materialize the profile by loading a page in a HeadlessInAppWebView
    // bound to it, then dispose the WebView (deleteProfile fails while
    // a live WebView is using the profile on every supported platform).
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

    final controller = ProfileController.instance();
    final names = await controller.getAllContainerNames();
    expect(names, contains(probeId));
    expect(await controller.hasContainer(probeId), isTrue);

    expect(await controller.deleteContainer(probeId), isTrue);
    expect(await controller.hasContainer(probeId), isFalse);
  }, skip: controllerSkip);
}
