part of 'main.dart';

void getCurrentWebViewPackage() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getCurrentWebViewPackage,
  );

  skippableTest('getCurrentWebViewPackage', () async {
    expect(await InAppWebViewController.getCurrentWebViewPackage(), isNotNull);
  }, skip: shouldSkip);
}
