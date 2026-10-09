part of 'main.dart';

void shouldInterceptRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.shouldInterceptRequest,
  );

  skippableTestWidgets('shouldInterceptRequest', (WidgetTester tester) async {
    List<String> resourceList = [
      "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
      "https://code.jquery.com/jquery-3.3.1.min.js",
      "https://via.placeholder.com/100x50",
    ];
    List<String> resourceLoaded = [];

    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> loadedResourceCompleter = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
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
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          shouldInterceptRequest: (controller, request) async {
            resourceLoaded.add(request.url.toString());
            if (resourceLoaded.length == resourceList.length) {
              loadedResourceCompleter.complete();
            }
            return null;
          },
        ),
      ),
    );

    await pageLoaded.future;
    await loadedResourceCompleter.future;
    expect(resourceLoaded, containsAll(resourceList));
  }, skip: shouldSkip);
}
