part of 'main.dart';

void setGetSettings() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getSettings,
  );

  final url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('set/get settings', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          initialSettings: InAppWebViewSettings(javaScriptEnabled: false),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );
    // Platform view creation happens asynchronously.
    await tester.pumpAndSettle();
    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    InAppWebViewSettings? settings = await controller.getSettings();
    expect(settings, isNotNull);
    expect(settings!.javaScriptEnabled, false);

    if (kIsWeb) {
      expect(settings.iframeSandbox, isNotNull);
      expect(settings.iframeSandbox!.contains(Sandbox.ALLOW_SCRIPTS), false);
    }

    await controller.setSettings(
      settings: InAppWebViewSettings(javaScriptEnabled: true),
    );

    settings = await controller.getSettings();
    expect(settings, isNotNull);
    expect(settings!.javaScriptEnabled, true);

    if (kIsWeb) {
      expect(settings.iframeSandbox, isNotNull);
      expect(settings.iframeSandbox!.contains(Sandbox.ALLOW_SCRIPTS), true);
    }
  }, skip: shouldSkip);
}
