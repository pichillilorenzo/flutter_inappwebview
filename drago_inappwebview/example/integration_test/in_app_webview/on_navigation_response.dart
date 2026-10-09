part of 'main.dart';

void onNavigationResponse() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onNavigationResponse,
  );

  skippableGroup('onNavigationResponse', () {
    skippableTestWidgets('allow navigation', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<String> onNavigationResponseCompleter =
          Completer<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onNavigationResponse: (controller, navigationResponse) async {
              onNavigationResponseCompleter.complete(
                navigationResponse.response!.url.toString(),
              );
              return NavigationResponseAction.ALLOW;
            },
          ),
        ),
      );

      await pageLoaded.future;
      final String url = await onNavigationResponseCompleter.future;
      expect(url, TEST_URL_1.toString());
    });

    skippableTestWidgets('cancel navigation', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<String> onNavigationResponseCompleter =
          Completer<String>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onNavigationResponse: (controller, navigationResponse) async {
              onNavigationResponseCompleter.complete(
                navigationResponse.response!.url.toString(),
              );
              return NavigationResponseAction.CANCEL;
            },
          ),
        ),
      );

      final String url = await onNavigationResponseCompleter.future;
      expect(url, TEST_URL_1.toString());
      expect(pageLoaded.future, doesNotComplete);
    });
  }, skip: shouldSkip);
}
