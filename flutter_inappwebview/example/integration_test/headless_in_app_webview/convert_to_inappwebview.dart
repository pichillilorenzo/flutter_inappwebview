part of 'main.dart';

void convertToInAppWebView() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformInAppWebViewWidgetCreationParamsProperty.headlessWebView,
  );

  skippableTestWidgets('convert to InAppWebView', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
      onLoadStop: (controller, url) async {
        pageLoaded.complete();
      },
    );

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();
    await pageLoaded.future;

    final String? url = (await controller.getUrl())?.toString();
    expect(url, TEST_CROSS_PLATFORM_URL_1.toString());

    final Completer<InAppWebViewController> widgetControllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> loadedUrl = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          headlessWebView: headlessWebView,
          onWebViewCreated: (controller) {
            widgetControllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (url.toString() == TEST_CROSS_PLATFORM_URL_2.toString() &&
                !loadedUrl.isCompleted) {
              loadedUrl.complete(url.toString());
            }
          },
        ),
      ),
    );
    final InAppWebViewController widgetController =
        await widgetControllerCompleter.future;
    await tester.pump();

    expect(headlessWebView.isRunning(), false);

    expect(
      (await widgetController.getUrl())?.toString(),
      TEST_CROSS_PLATFORM_URL_1.toString(),
    );

    await widgetController.loadUrl(
      urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_2),
    );
    expect(await loadedUrl.future, TEST_CROSS_PLATFORM_URL_2.toString());
  }, skip: shouldSkip);
}
