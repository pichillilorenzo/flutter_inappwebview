part of 'main.dart';

void shouldOverrideUrlLoading() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.shouldOverrideUrlLoading,
  );

  skippableGroup('shouldOverrideUrlLoading', () {
    final String page =
        '''<!DOCTYPE html><head></head><body><a id="link" href="$TEST_URL_3">flutter_inappwebview</a></body></html>''';
    final String pageEncoded =
        'data:text/html;charset=utf-8;base64,' +
        base64Encode(const Utf8Encoder().convert(page));

    skippableTestWidgets('can allow requests', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return (navigationAction.request.url!.host.contains(
                    TEST_URL_4.host.replaceAll("www.", ""),
                  ))
                  ? NavigationActionPolicy.CANCEL
                  : NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: 'location.href = "$TEST_URL_EXAMPLE"',
      );

      await pageLoads.stream.first; // Wait for the next page load.
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, TEST_URL_EXAMPLE.toString());

      pageLoads.close();
    });

    final shouldSkipTest2 = !NavigationType.LINK_ACTIVATED.isSupported();
    testWidgets(
      'allow requests on iOS only if navigationType == NavigationType.LINK_ACTIVATED',
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
              initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var isFirstLoad =
                    navigationAction.request.url!.scheme == "data";
                return (isFirstLoad ||
                        navigationAction.navigationType ==
                            NavigationType.LINK_ACTIVATED)
                    ? NavigationActionPolicy.ALLOW
                    : NavigationActionPolicy.CANCEL;
              },
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );

        await pageLoads.stream.first; // Wait for initial page load.
        final InAppWebViewController controller =
            await controllerCompleter.future;
        await controller.evaluateJavascript(
          source: 'location.href = "$TEST_URL_2"',
        );

        // There should never be any second page load, since our new URL is
        // blocked. Still wait for a potential page change for some time in order
        // to give the test a chance to fail.
        await pageLoads.stream
            // ignore: unnecessary_cast
            .map((event) => event as String?)
            .first
            .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
        String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, isNot(TEST_URL_2.toString()));

        await controller.evaluateJavascript(
          source: 'document.querySelector("#link").click();',
        );
        await pageLoads.stream.first; // Wait for the next page load.
        currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, TEST_URL_3.toString());

        pageLoads.close();
      },
      skip: shouldSkipTest2,
    );

    skippableTestWidgets('can block requests', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return (navigationAction.request.url!.host.contains(
                    TEST_URL_4.host.replaceAll("www.", ""),
                  ))
                  ? NavigationActionPolicy.CANCEL
                  : NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: 'location.href = "$TEST_URL_4"',
      );

      // There should never be any second page load, since our new URL is
      // blocked. Still wait for a potential page change for some time in order
      // to give the test a chance to fail.
      await pageLoads.stream
          // ignore: unnecessary_cast
          .map((event) => event as String?)
          .first
          .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(
        currentUrl,
        isNot(contains(TEST_URL_4.host.replaceAll("www.", ""))),
      );

      pageLoads.close();
    });

    skippableTestWidgets('supports asynchronous decisions', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final StreamController<String> pageLoads =
          StreamController<String>.broadcast();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri(pageEncoded)),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var action = NavigationActionPolicy.CANCEL;
              action = await Future<NavigationActionPolicy>.delayed(
                const Duration(milliseconds: 10),
                () => NavigationActionPolicy.ALLOW,
              );
              return action;
            },
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      await pageLoads.stream.first; // Wait for initial page load.
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: 'location.href = "$TEST_URL_EXAMPLE"',
      );

      await pageLoads.stream.first; // Wait for second page to load.
      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(currentUrl, TEST_URL_EXAMPLE.toString());

      pageLoads.close();
    });
  }, skip: shouldSkip);
}
