part of 'main.dart';

void initialUrlRequest() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableGroup('initial url request', () {
    final shouldSkipTest2 = kIsWeb
        ? true
        : ![
            TargetPlatform.iOS,
            TargetPlatform.macOS,
          ].contains(defaultTargetPlatform);

    skippableTestWidgets(
        'launches with allowsBackForwardNavigationGestures true',
        (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 300,
            child: InAppWebView(
              key: GlobalKey(),
              initialUrlRequest: URLRequest(url: TEST_URL_1),
              initialSettings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: true),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                pageLoaded.complete();
              },
            ),
          ),
        ),
      );
      await pageLoaded.future;
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, TEST_URL_1.toString());
    }, skip: shouldSkipTest2);

    final shouldSkipTest1 = kIsWeb
        ? false
        : ![
            TargetPlatform.android,
            TargetPlatform.iOS,
            TargetPlatform.macOS,
          ].contains(defaultTargetPlatform);

    skippableTestWidgets('basic', (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      await pageLoaded.future;
      final InAppWebViewController controller =
          await controllerCompleter.future;
      final String? currentUrl = (await controller.getUrl())?.toString();

      expect(currentUrl, TEST_CROSS_PLATFORM_URL_1.toString());
    }, skip: shouldSkipTest1);
  }, skip: shouldSkip);
}
