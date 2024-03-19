part of 'main.dart';

void onLoadResource() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableTestWidgets('onLoadResource', (WidgetTester tester) async {
    List<String> resourceList = [
      "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
      "https://code.jquery.com/jquery-3.3.1.min.js",
      "https://via.placeholder.com/100x50"
    ];
    List<String> resourceLoaded = [];

    final Completer<void> loadedResourceCompleter = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_on_load_resource_test.html",
            initialSettings: InAppWebViewSettings(clearCache: true),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onLoadResource: (controller, response) async {
              resourceLoaded.add(response.url!.toString());
              if (resourceLoaded.length == resourceList.length) {
                loadedResourceCompleter.complete();
              }
            }),
      ),
    );

    await pageLoaded.future;
    await loadedResourceCompleter.future;

    expect(resourceLoaded, unorderedEquals(resourceList));
  }, skip: shouldSkip);
}
