part of 'main.dart';

void takeScreenshot() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.takeScreenshot,
  );

  skippableTestWidgets('takeScreenshot', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
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

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await Future.delayed(Duration(seconds: 1));
    await tester.pump();

    var screenshotConfiguration = ScreenshotConfiguration(
      compressFormat: CompressFormat.JPEG,
      quality: 20,
      rect: InAppWebViewRect(width: 100, height: 100, x: 50, y: 50),
    );
    var screenshot = await controller.takeScreenshot(
      screenshotConfiguration: screenshotConfiguration,
    );
    expect(screenshot, isNotNull);
  }, skip: shouldSkip);
}
