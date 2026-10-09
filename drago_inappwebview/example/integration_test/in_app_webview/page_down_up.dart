part of 'main.dart';

void pageDownUp() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.pageDown,
  );

  skippableTestWidgets('pageDown/pageUp', (WidgetTester tester) async {
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
    await tester.pump();
    await Future.delayed(Duration(seconds: 1));
    expect(await controller.pageDown(bottom: false), true);
    await Future.delayed(Duration(seconds: 1));
    expect(await controller.pageUp(top: false), true);
  }, skip: shouldSkip);
}
