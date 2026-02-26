part of 'main.dart';

void takeScreenshot() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.takeScreenshot,
  );

  skippableTest('take screenshot', () async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_URL_1),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
      onLoadStop: (controller, url) async {
        if (!pageLoaded.isCompleted) {
          pageLoaded.complete();
        }
      },
    );

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    final String? url = (await controller.getUrl())?.toString();
    expect(url, TEST_URL_1.toString());

    final Size? size = await headlessWebView.getSize();
    expect(size, isNotNull);

    final Uint8List? screenshot = await controller.takeScreenshot();
    expect(screenshot, isNotNull);

    await headlessWebView.dispose();

    expect(headlessWebView.isRunning(), false);
  }, skip: shouldSkip);
}
