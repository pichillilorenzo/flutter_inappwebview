part of 'main.dart';

void loadData() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.loadData,
  );

  skippableTestWidgets('loadData', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final StreamController<String> pageLoads =
        StreamController<String>.broadcast();

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
            pageLoads.add(url!.toString());
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    // do not wait for pump to not miss the load event
    tester.pump();
    await pageLoads.stream.first;

    final data = """
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
""";
    final mimeType = 'text/html';

    await controller.loadData(
      data: data,
      encoding: 'utf-8',
      mimeType: mimeType,
      historyUrl: TEST_CROSS_PLATFORM_URL_1,
      baseUrl: TEST_CROSS_PLATFORM_URL_1,
    );
    await pageLoads.stream.first;

    final String? currentUrl = (await controller.getUrl())?.toString();

    if (!kIsWeb) {
      expect(currentUrl, TEST_CROSS_PLATFORM_URL_1.toString());
    } else {
      expect(currentUrl, 'data:$mimeType,' + Uri.encodeComponent(data));
    }

    pageLoads.close();
  }, skip: shouldSkip);
}
