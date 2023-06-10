part of 'main.dart';

void getCurrentWebViewPackage() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  skippableTest('getCurrentWebViewPackage', () async {
    expect(await InAppWebViewController.getCurrentWebViewPackage(), isNotNull);
  }, skip: shouldSkip);
}
