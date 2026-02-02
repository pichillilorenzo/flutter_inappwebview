part of 'main.dart';

void webArchive() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.saveWebArchive,
  );

  skippableGroup('web archive', () {
    final shouldSkipTest1 = !InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.createWebArchiveData,
    );

    skippableTestWidgets('create data', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

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

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      expect(await controller.createWebArchiveData(), isNotNull);
    }, skip: shouldSkipTest1);

    skippableTestWidgets('save', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

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
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      // wait a little bit after page load otherwise Android will not save the web archive
      await Future.delayed(Duration(seconds: 1));

      var supportDir = await getApplicationSupportDirectory();

      var fileName = "flutter-website.";
      if (WebArchiveFormat.MHT.isSupported()) {
        fileName = fileName + WebArchiveFormat.MHT.toValue();
      } else {
        fileName = fileName + WebArchiveFormat.WEBARCHIVE.toValue();
      }

      var fullPath = supportDir.path + Platform.pathSeparator + fileName;
      var path = await controller.saveWebArchive(filePath: fullPath);
      expect(path, isNotNull);
      expect(path, endsWith(fileName));

      path = await controller.saveWebArchive(
        filePath: supportDir.path,
        autoname: true,
      );
      expect(path, isNotNull);
    });
  }, skip: shouldSkip);
}
