part of 'main.dart';

void clearCache() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.clearAllCache,
  );

  skippableTestWidgets('clearAllCache', (WidgetTester tester) async {
    await expectLater(
      InAppWebViewController.clearAllCache(includeDiskFiles: true),
      completes,
    );
  }, skip: shouldSkip);
}
