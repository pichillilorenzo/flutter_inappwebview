part of 'main.dart';

void handlesURLScheme() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableTest('handlesURLScheme', () async {
    expect(await InAppWebViewController.handlesURLScheme("http"), true);
    expect(await InAppWebViewController.handlesURLScheme("https"), true);
  }, skip: shouldSkip);
}
