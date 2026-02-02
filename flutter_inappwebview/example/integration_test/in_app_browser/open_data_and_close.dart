part of 'main.dart';

void openDataAndClose() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('open data and close', () async {
    var inAppBrowser = new MyInAppBrowser();
    expect(inAppBrowser.isOpened(), false);
    expect(() async {
      await inAppBrowser.show();
    }, throwsAssertionError);

    await inAppBrowser.openData(
      data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="stylesheet" href="https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css">
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    </head>
    <body>
      <img src="https://via.placeholder.com/100x50" alt="placeholder 100x50">
    </body>
</html>
""",
      encoding: 'utf-8',
      mimeType: 'text/html',
      historyUrl: TEST_CROSS_PLATFORM_URL_1,
      baseUrl: TEST_CROSS_PLATFORM_URL_1,
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
    expect(url, TEST_CROSS_PLATFORM_URL_1.toString());

    await inAppBrowser.close();
    await inAppBrowser.browserClosed.future;
    expect(inAppBrowser.isOpened(), false);
    expect(inAppBrowser.webViewController, isNull);
  }, skip: shouldSkip);
}
