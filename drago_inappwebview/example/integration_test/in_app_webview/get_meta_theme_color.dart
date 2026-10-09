part of 'main.dart';

void getMetaThemeColor() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getMetaThemeColor,
  );

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('getMetaThemeColor', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
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
    await tester.pump();
    await pageLoaded.future;

    expect(await controller.getMetaThemeColor(), isNotNull);
  }, skip: shouldSkip);
}
