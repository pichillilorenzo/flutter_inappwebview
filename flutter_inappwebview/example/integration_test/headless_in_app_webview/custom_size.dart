part of 'main.dart';

void customSize() {
  final shouldSkip = !HeadlessInAppWebView.isMethodSupported(
    PlatformHeadlessInAppWebViewMethod.getSize,
  );

  skippableTest('set and get custom size', () async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();

    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      initialSize: Size(600, 800),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);
      },
    );

    await headlessWebView.run();
    expect(headlessWebView.isRunning(), true);

    final Size? size = await headlessWebView.getSize();
    expect(size, isNotNull);
    expect(size, Size(600, 800));

    await headlessWebView.setSize(Size(1080, 1920));
    final Size? newSize = await headlessWebView.getSize();
    expect(newSize, isNotNull);
    expect(newSize, Size(1080, 1920));

    await headlessWebView.dispose();

    expect(headlessWebView.isRunning(), false);
  }, skip: shouldSkip);
}
