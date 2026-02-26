part of 'main.dart';

void injectJavascriptFile() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.injectJavascriptFileFromUrl,
  );

  var url = !kIsWeb ? TEST_URL_ABOUT_BLANK : TEST_WEB_PLATFORM_URL_1;

  skippableGroup('inject javascript file', () {
    skippableTestWidgets('from url', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> jQueryLoaded = Completer<void>();
      final Completer<void> jQueryLoadError = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: url),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await tester.pump();
      await pageLoaded.future;

      await controller.injectJavascriptFileFromUrl(
        urlFile: WebUri('https://www.notawebsite..com/jquery-3.3.1.min.js'),
        scriptHtmlTagAttributes: ScriptHtmlTagAttributes(
          id: 'jquery-error',
          onError: () {
            jQueryLoadError.complete();
          },
        ),
      );
      await jQueryLoadError.future;
      expect(
        await controller.evaluateJavascript(
          source: "document.body.querySelector('#jquery-error') == null;",
        ),
        false,
      );
      expect(
        await controller.evaluateJavascript(source: "window.jQuery == null;"),
        true,
      );

      await controller.injectJavascriptFileFromUrl(
        urlFile: WebUri('https://code.jquery.com/jquery-3.3.1.min.js'),
        scriptHtmlTagAttributes: ScriptHtmlTagAttributes(
          id: 'jquery',
          onLoad: () {
            jQueryLoaded.complete();
          },
        ),
      );
      await jQueryLoaded.future;
      expect(
        await controller.evaluateJavascript(
          source: "document.body.querySelector('#jquery') == null;",
        ),
        false,
      );
      expect(
        await controller.evaluateJavascript(source: "window.jQuery == null;"),
        false,
      );
    });

    skippableTestWidgets('from asset', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: url),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await tester.pump();
      await pageLoaded.future;

      await controller.injectJavascriptFileFromAsset(
        assetFilePath: 'test_assets/js/jquery-3.3.1.min.js',
      );
      expect(
        await controller.evaluateJavascript(source: "window.jQuery == null;"),
        false,
      );
    });
  }, skip: shouldSkip);
}
