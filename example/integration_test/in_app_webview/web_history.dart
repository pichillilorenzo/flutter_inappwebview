part of 'main.dart';

void webHistory() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableGroup('web history', () {
    final shouldSkipTest1 = kIsWeb
        ? true
        : ![
            TargetPlatform.android,
            TargetPlatform.iOS,
            TargetPlatform.macOS,
          ].contains(defaultTargetPlatform);

    skippableTestWidgets('get history list and go back/forward',
        (WidgetTester tester) async {
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
            onLoadStart: (controller, url) {
              // pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      await Future.delayed(Duration(seconds: 1));
      var url = (await controller.getUrl()).toString();
      var webHistory = await controller.getCopyBackForwardList();
      expect(url, TEST_CROSS_PLATFORM_URL_1.toString());
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 1);
      expect(webHistory.list![0].url.toString(),
          TEST_CROSS_PLATFORM_URL_1.toString());

      await controller.loadUrl(urlRequest: URLRequest(url: TEST_URL_1));
      await Future.delayed(Duration(seconds: 1));
      url = (await controller.getUrl()).toString();
      webHistory = await controller.getCopyBackForwardList();
      expect(url, TEST_URL_1.toString());
      expect(await controller.canGoBack(), true);
      expect(await controller.canGoForward(), false);
      expect(await controller.canGoBackOrForward(steps: -1), true);
      expect(await controller.canGoBackOrForward(steps: 1), false);
      expect(webHistory!.currentIndex, 1);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(),
          TEST_CROSS_PLATFORM_URL_1.toString());
      expect(webHistory.list![1].url.toString(), TEST_URL_1.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goBack();
      await Future.delayed(Duration(seconds: 1));
      url = (await controller.getUrl()).toString();
      webHistory = await controller.getCopyBackForwardList();
      expect(url, TEST_CROSS_PLATFORM_URL_1.toString());
      expect(await controller.canGoBack(), false);
      expect(await controller.canGoForward(), true);
      expect(await controller.canGoBackOrForward(steps: -1), false);
      expect(await controller.canGoBackOrForward(steps: 1), true);
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(),
          TEST_CROSS_PLATFORM_URL_1.toString());
      expect(webHistory.list![1].url.toString(), TEST_URL_1.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goForward();
      await Future.delayed(Duration(seconds: 1));
      url = (await controller.getUrl()).toString();
      webHistory = await controller.getCopyBackForwardList();
      expect(url, TEST_URL_1.toString());
      expect(await controller.canGoBack(), true);
      expect(await controller.canGoForward(), false);
      expect(await controller.canGoBackOrForward(steps: -1), true);
      expect(await controller.canGoBackOrForward(steps: 1), false);
      expect(webHistory!.currentIndex, 1);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(),
          TEST_CROSS_PLATFORM_URL_1.toString());
      expect(webHistory.list![1].url.toString(), TEST_URL_1.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goTo(historyItem: webHistory.list![0]);
      await Future.delayed(Duration(seconds: 1));
      url = (await controller.getUrl()).toString();
      webHistory = await controller.getCopyBackForwardList();
      expect(url, TEST_CROSS_PLATFORM_URL_1.toString());
      expect(await controller.canGoBack(), false);
      expect(await controller.canGoForward(), true);
      expect(await controller.canGoBackOrForward(steps: -1), false);
      expect(await controller.canGoBackOrForward(steps: 1), true);
      expect(webHistory!.currentIndex, 0);
      expect(webHistory.list!.length, 2);
      expect(webHistory.list![0].url.toString(),
          TEST_CROSS_PLATFORM_URL_1.toString());
      expect(webHistory.list![1].url.toString(), TEST_URL_1.toString());
    }, skip: shouldSkipTest1);

    final shouldSkipTest2 = !kIsWeb;

    skippableTestWidgets('go back/forward on web platform',
        (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_WEB_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      await tester.pump();

      var url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_1.toString());

      await controller.evaluateJavascript(
          source: "document.getElementById('link-page-2').click();");
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_2.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goBack();
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_1.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goForward();
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_2.toString());

      await Future.delayed(Duration(seconds: 1));
      await controller.goBackOrForward(steps: -1);
      url = await pageLoads.stream.first;
      expect(url, TEST_WEB_PLATFORM_URL_1.toString());

      pageLoads.close();
    }, skip: shouldSkipTest2);

    final shouldSkipTest3 = kIsWeb
        ? true
        : ![
            TargetPlatform.android,
          ].contains(defaultTargetPlatform);

    skippableTestWidgets('clearHistory', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();

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
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoads.stream.first;
      await controller.loadUrl(urlRequest: URLRequest(url: TEST_URL_1));
      await pageLoads.stream.first;

      var webHistory = await controller.getCopyBackForwardList();
      expect(webHistory!.list!.length, 2);

      await controller.clearHistory();

      webHistory = await controller.getCopyBackForwardList();
      expect(webHistory!.list!.length, 1);

      pageLoads.close();
    }, skip: shouldSkipTest3);
  }, skip: shouldSkip);
}
