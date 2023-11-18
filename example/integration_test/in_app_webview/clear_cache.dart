part of 'main.dart';

void clearCache() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableTestWidgets('clearCache', (WidgetTester tester) async {
    final Completer<PlatformInAppWebViewController> controllerCompleter =
        Completer<PlatformInAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final PlatformInAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await expectLater(controller.clearCache(), completes);
  }, skip: shouldSkip);
}
