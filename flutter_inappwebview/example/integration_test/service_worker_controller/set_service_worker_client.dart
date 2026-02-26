part of 'main.dart';

void setServiceWorkerClient() {
  final shouldSkip = !ServiceWorkerController.isMethodSupported(
    PlatformServiceWorkerControllerMethod.setServiceWorkerClient,
  );

  skippableTestWidgets('setServiceWorkerClient to null', (
    WidgetTester tester,
  ) async {
    final Completer<String> pageLoaded = Completer<String>();

    var swAvailable = await WebViewFeature.isFeatureSupported(
      WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
    );
    var swInterceptAvailable = await WebViewFeature.isFeatureSupported(
      WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
    );

    if (swAvailable && swInterceptAvailable) {
      ServiceWorkerController serviceWorkerController =
          ServiceWorkerController.instance();

      await serviceWorkerController.setServiceWorkerClient(null);
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_SERVICE_WORKER_URL),
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final String url = await pageLoaded.future;
    expect(url, TEST_SERVICE_WORKER_URL.toString());
  }, skip: shouldSkip);
}
