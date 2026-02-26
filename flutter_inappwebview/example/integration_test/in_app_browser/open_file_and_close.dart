part of 'main.dart';

void openFileAndClose() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('open file and close', () async {
    var inAppBrowser = new MyInAppBrowser();
    expect(inAppBrowser.isOpened(), false);
    expect(() async {
      await inAppBrowser.show();
    }, throwsAssertionError);

    await inAppBrowser.openFile(
      assetFilePath: "test_assets/in_app_webview_initial_file_test.html",
    );
    await inAppBrowser.browserCreated.future;
    expect(inAppBrowser.isOpened(), true);
    expect(() async {
      await inAppBrowser.openUrlRequest(
        urlRequest: URLRequest(url: TEST_URL_1),
      );
    }, throwsAssertionError);

    await inAppBrowser.firstPageLoaded.future;
    var controller = inAppBrowser.webViewController;

    expect(controller, isNotNull);
    final String? url = (await controller!.getUrl())?.toString();
    expect(url, endsWith("in_app_webview_initial_file_test.html"));

    await inAppBrowser.close();
    await inAppBrowser.browserClosed.future;
    expect(inAppBrowser.isOpened(), false);
    expect(inAppBrowser.webViewController, isNull);
  }, skip: shouldSkip);
}
