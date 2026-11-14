part of 'main.dart';

void webViewWindows() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onCreateWindow,
  );

  skippableGroup('WebView Windows', () {
    final shouldSkipTest1 =
        kIsWeb ||
        !InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onCreateWindow,
        );

    skippableTestWidgets('onCreateWindow return false', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_on_create_window_test.html",
            initialSettings: InAppWebViewSettings(
              clearCache: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (url!.toString() == TEST_URL_EXAMPLE.toString()) {
                pageLoaded.complete();
              }
            },
            onCreateWindow: (controller, createNavigationAction) async {
              controller.loadUrl(urlRequest: createNavigationAction.request);
              return false;
            },
          ),
        ),
      );
      await tester.pump();
      await expectLater(pageLoaded.future, completes);
    }, skip: shouldSkipTest1);

    final shouldSkipTest2 =
        kIsWeb ||
        !InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.windowId,
        );

    skippableTestWidgets('onCreateWindow return true', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<int> onCreateWindowCompleter = Completer<int>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialFile:
                "test_assets/in_app_webview_on_create_window_test.html",
            initialSettings: InAppWebViewSettings(
              clearCache: true,
              javaScriptCanOpenWindowsAutomatically: true,
              supportMultipleWindows: true,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onCreateWindow: (controller, createNavigationAction) async {
              onCreateWindowCompleter.complete(createNavigationAction.windowId);
              return true;
            },
          ),
        ),
      );

      await tester.pump();

      var windowId = await onCreateWindowCompleter.future;

      final Completer windowControllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<String> windowPageLoaded = Completer<String>();
      final Completer<void> onCloseWindowCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            windowId: windowId,
            initialSettings: InAppWebViewSettings(clearCache: true),
            onWebViewCreated: (controller) {
              windowControllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) async {
              if (url!.scheme != "about" && !windowPageLoaded.isCompleted) {
                windowPageLoaded.complete(url.toString());
                await controller.evaluateJavascript(source: "window.close();");
              }
            },
            onCloseWindow: (controller) {
              onCloseWindowCompleter.complete();
            },
          ),
        ),
      );

      await tester.pump();

      final String windowUrlLoaded = await windowPageLoaded.future;

      expect(windowUrlLoaded, TEST_URL_EXAMPLE.toString());
      await expectLater(onCloseWindowCompleter.future, completes);
    }, skip: shouldSkipTest2);

    final shouldSkipTest3 =
        kIsWeb ||
        !InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onCreateWindow,
        );

    skippableTestWidgets(
      'window.open() with target _blank opens in same window',
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
              onWebViewCreated: (controller) {
                controllerCompleter.complete(controller);
              },
              initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
              onLoadStop: (controller, url) {
                pageLoads.add(url!.toString());
              },
            ),
          ),
        );
        await pageLoads.stream.first;
        final InAppWebViewController controller =
            await controllerCompleter.future;

        await controller.evaluateJavascript(
          source: 'window.open("$TEST_URL_ABOUT_BLANK", "_blank");',
        );
        await pageLoads.stream.first;
        final String? currentUrl = (await controller.getUrl())?.toString();
        expect(currentUrl, TEST_URL_ABOUT_BLANK.toString());

        pageLoads.close();
      },
      skip: shouldSkipTest3,
    );

    // on Android, for some reason, it works on an example app but not in this test
    final shouldSkipTest4 =
        kIsWeb || defaultTargetPlatform == TargetPlatform.android;
    skippableTestWidgets('can open new window and go back', (
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
            initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onLoadStop: (controller, url) {
              pageLoads.add(url!.toString());
            },
          ),
        ),
      );

      await tester.pump();

      final InAppWebViewController controller =
          await controllerCompleter.future;

      Future<String> waitForUrl(String expectedUrl) async {
        await for (final url in pageLoads.stream) {
          if (url == expectedUrl) {
            return url;
          }
        }
        throw Exception('Stream closed without receiving $expectedUrl');
      }

      // Wait for initial page load
      await waitForUrl(TEST_CROSS_PLATFORM_URL_1.toString());
      await controller.evaluateJavascript(
        source: 'window.open("$TEST_URL_1", "_blank");',
      );
      final currentUrl = await waitForUrl(TEST_URL_1.toString());
      expect(currentUrl, contains(TEST_URL_1.host));

      await controller.goBack();
      final urlAfterGoBack = await waitForUrl(
        TEST_CROSS_PLATFORM_URL_1.toString(),
      );
      expect(urlAfterGoBack, contains(TEST_CROSS_PLATFORM_URL_1.host));

      pageLoads.close();
    }, skip: shouldSkipTest4);

    // Android blocks javascript: URLs opened from iframes for security reasons
    final shouldSkipTest5 = defaultTargetPlatform != TargetPlatform.android;
    skippableTestWidgets('javascript does not run in parent window', (
      WidgetTester tester,
    ) async {
      final String iframe = '''
        <!DOCTYPE html>
        <script>
          window.onload = () => {
            window.open(`javascript:
              var elem = document.createElement("p");
              elem.innerHTML = "<b>Executed JS in parent origin: " + window.location.origin + "</b>";
              document.body.append(elem);
            `);
          };
        </script>
      ''';
      final String iframeTestBase64 = base64Encode(
        const Utf8Encoder().convert(iframe),
      );

      final String openWindowTest =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>XSS test</title>
        </head>
        <body>
          <iframe
            onload="window.iframeLoaded = true;"
            src="data:text/html;charset=utf-8;base64,$iframeTestBase64"></iframe>
        </body>
        </html>
      ''';
      final String openWindowTestBase64 = base64Encode(
        const Utf8Encoder().convert(openWindowTest),
      );
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoadCompleter = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri(
                'data:text/html;charset=utf-8;base64,$openWindowTestBase64',
              ),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onLoadStop: (controller, url) {
              pageLoadCompleter.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoadCompleter.future;

      final iframeLoaded = await controller.evaluateJavascript(
        source: 'iframeLoaded',
      );
      expect(iframeLoaded, true);

      final pElement = await controller.evaluateJavascript(
        source:
            'document.querySelector("p") && document.querySelector("p").textContent',
      );
      expect(pElement, null);
    }, skip: shouldSkipTest5);

    // final shouldSkipTest6 = !kIsWeb;
    final shouldSkipTest6 = true;
    // on Web, opening a new window during tests makes crash
    skippableTestWidgets('onCreateWindow called on Web', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<String> onCreateWindowCalled = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_WEB_PLATFORM_URL_1),
            initialSettings: InAppWebViewSettings(
              clearCache: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onCreateWindow: (controller, createNavigationAction) async {
              onCreateWindowCalled.complete(
                createNavigationAction.request.url.toString(),
              );
              return false;
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await controller.evaluateJavascript(
        source: "window.open('$TEST_CROSS_PLATFORM_URL_1');",
      );

      var url = await onCreateWindowCalled.future;
      expect(url, TEST_CROSS_PLATFORM_URL_1.toString());
    }, skip: shouldSkipTest6);
  }, skip: shouldSkip);
}
