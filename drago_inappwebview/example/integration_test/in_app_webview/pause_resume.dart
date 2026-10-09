part of 'main.dart';

void pauseResume() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.pause,
  );

  skippableTestWidgets('pause/resume', (WidgetTester tester) async {
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
    await expectLater(controller.pause(), completes);
    await Future.delayed(Duration(seconds: 1));
    await expectLater(controller.resume(), completes);
  }, skip: shouldSkip);
}
