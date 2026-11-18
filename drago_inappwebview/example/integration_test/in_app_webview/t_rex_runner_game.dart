part of 'main.dart';

void tRexRunnerGame() {
  final shouldSkip = !InAppWebViewController.isPropertySupported(
    PlatformInAppWebViewControllerProperty.tRexRunnerHtml,
  );

  skippableTestWidgets('T-Rex Runner game', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    await controllerCompleter.future;
    await pageLoaded.future;

    var html = await InAppWebViewController.tRexRunnerHtml;
    var css = await InAppWebViewController.tRexRunnerCss;

    expect(html, isNotNull);
    expect(css, isNotNull);
  }, skip: shouldSkip);
}
