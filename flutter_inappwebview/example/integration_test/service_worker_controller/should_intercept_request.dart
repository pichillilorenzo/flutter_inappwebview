part of 'main.dart';

void shouldInterceptRequest() {
  final shouldSkip = !ServiceWorkerController.isMethodSupported(
    PlatformServiceWorkerControllerMethod.setServiceWorkerClient,
  );

  skippableTestWidgets('shouldInterceptRequest', (WidgetTester tester) async {
    final Completer completer = Completer();

    var swAvailable = await WebViewFeature.isFeatureSupported(
      WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
    );
    var swInterceptAvailable = await WebViewFeature.isFeatureSupported(
      WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
    );

    if (swAvailable && swInterceptAvailable) {
      ServiceWorkerController serviceWorkerController =
          ServiceWorkerController.instance();

      await serviceWorkerController.setServiceWorkerClient(
        ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (!completer.isCompleted) {
              completer.complete();
            }
            return null;
          },
        ),
      );
    } else {
      completer.complete();
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_SERVICE_WORKER_URL),
        ),
      ),
    );

    await expectLater(completer.future, completes);
  }, skip: shouldSkip);
}
