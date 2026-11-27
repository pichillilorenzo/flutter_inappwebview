part of 'main.dart';

void loadUrl() {
  final shouldSkip1 = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.loadUrl,
  );

  var initialUrl = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('loadUrl', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> firstUrlLoad = Completer<String>();
    final Completer<String> loadedUrl = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: initialUrl),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (url.toString() == initialUrl.toString() &&
                !firstUrlLoad.isCompleted) {
              firstUrlLoad.complete(url.toString());
            } else if (url.toString() == TEST_CROSS_PLATFORM_URL_1.toString() &&
                !loadedUrl.isCompleted) {
              loadedUrl.complete(url.toString());
            }
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    await tester.pump();
    expect(await firstUrlLoad.future, initialUrl.toString());

    await controller.loadUrl(
      urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
    );
    expect(await loadedUrl.future, TEST_CROSS_PLATFORM_URL_1.toString());
  }, skip: shouldSkip1);

  final shouldSkip2 = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.loadSimulatedRequest,
  );

  skippableTestWidgets('loadSimulatedRequest', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> firstUrlLoad = Completer<String>();
    final Completer<String> loadedUrl = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: initialUrl),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (url.toString() == initialUrl.toString() &&
                !firstUrlLoad.isCompleted) {
              firstUrlLoad.complete(url.toString());
            } else if (url.toString() == TEST_CROSS_PLATFORM_URL_1.toString() &&
                !loadedUrl.isCompleted) {
              loadedUrl.complete(url.toString());
            }
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    expect(await firstUrlLoad.future, initialUrl.toString());

    final htmlCode = "<h1>Hello</h1>";
    await controller.loadSimulatedRequest(
      urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      data: Uint8List.fromList(utf8.encode(htmlCode)),
    );
    expect(await loadedUrl.future, TEST_CROSS_PLATFORM_URL_1.toString());
    expect(
      (await controller.evaluateJavascript(
        source: "document.body.innerHTML",
      )).toString().trim(),
      htmlCode,
    );
  }, skip: shouldSkip2);
}
