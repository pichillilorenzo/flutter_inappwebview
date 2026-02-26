part of 'main.dart';

void openUrlAndClose() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('open url and close', () async {
    var inAppBrowser = new MyInAppBrowser();
    expect(inAppBrowser.isOpened(), false);
    expect(() async {
      await inAppBrowser.show();
    }, throwsAssertionError);

    await inAppBrowser.openUrlRequest(urlRequest: URLRequest(url: TEST_URL_1));
    await inAppBrowser.browserCreated.future;
    expect(inAppBrowser.isOpened(), true);
    expect(() async {
      await inAppBrowser.openUrlRequest(
        urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
      );
    }, throwsAssertionError);

    await inAppBrowser.firstPageLoaded.future;
    var controller = inAppBrowser.webViewController;

    expect(controller, isNotNull);
    final String? url = (await controller!.getUrl())?.toString();
    expect(url, TEST_URL_1.toString());

    await inAppBrowser.close();
    await inAppBrowser.browserClosed.future;
    expect(inAppBrowser.isOpened(), false);
    expect(inAppBrowser.webViewController, isNull);
  }, skip: shouldSkip);
}
