part of 'main.dart';

void stopLoading() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.stopLoading,
  );

  skippableTestWidgets('stopLoading', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          initialSettings: InAppWebViewSettings(clearCache: true),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStart: (controller, url) {
            controller.stopLoading();
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;

    if (defaultTargetPlatform == TargetPlatform.android) {
      await pageLoaded.future;
      expect(
        await controller.evaluateJavascript(source: "document.body"),
        isNullOrEmpty,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      expect(pageLoaded.future, doesNotComplete);
    }
  }, skip: shouldSkip);
}
