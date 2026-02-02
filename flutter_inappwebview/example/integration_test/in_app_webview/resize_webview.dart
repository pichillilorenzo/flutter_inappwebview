part of 'main.dart';

void resizeWebView() {
  final shouldSkip =
      kIsWeb ||
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
      );

  skippableTestWidgets('resize webview', (WidgetTester tester) async {
    final String resizeTest = '''
        <!DOCTYPE html><html>
        <head><title>Resize test</title>
          <script type="text/javascript">
            function onResize() {
              window.flutter_inappwebview.callHandler('resize');
            }
            function onLoad() {
              window.onresize = onResize;
            }
          </script>
        </head>
        <body onload="onLoad();" bgColor="blue">
        </body>
        </html>
      ''';
    final String resizeTestBase64 = base64Encode(
      const Utf8Encoder().convert(resizeTest),
    );
    final Completer<void> resizeCompleter = Completer<void>();
    final Completer<void> pageStarted = Completer<void>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final GlobalKey key = GlobalKey();

    final InAppWebView webView = InAppWebView(
      key: key,
      initialUrlRequest: URLRequest(
        url: WebUri('data:text/html;charset=utf-8;base64,$resizeTestBase64'),
      ),
      onWebViewCreated: (controller) {
        controllerCompleter.complete(controller);

        controller.addJavaScriptHandler(
          handlerName: 'resize',
          callback: (args) {
            resizeCompleter.complete(true);
          },
        );
      },
      onLoadStart: (controller, url) {
        pageStarted.complete();
      },
      onLoadStop: (controller, url) {
        pageLoaded.complete();
      },
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[SizedBox(width: 200, height: 200, child: webView)],
        ),
      ),
    );

    await controllerCompleter.future;
    await pageStarted.future;
    await pageLoaded.future;

    expect(resizeCompleter.isCompleted, false);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[SizedBox(width: 400, height: 400, child: webView)],
        ),
      ),
    );

    await resizeCompleter.future;
  }, skip: shouldSkip);
}
