part of 'main.dart';

void clearCache() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableTestWidgets('clearAllCache', (WidgetTester tester) async {
    await expectLater(
        InAppWebViewController.clearAllCache(includeDiskFiles: true),
        completes);
  }, skip: shouldSkip);
}
