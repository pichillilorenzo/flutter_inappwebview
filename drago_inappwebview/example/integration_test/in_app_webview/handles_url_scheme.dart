part of 'main.dart';

void handlesURLScheme() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.handlesURLScheme,
  );

  skippableTest('handlesURLScheme', () async {
    expect(await InAppWebViewController.handlesURLScheme("http"), true);
    expect(await InAppWebViewController.handlesURLScheme("https"), true);
  }, skip: shouldSkip);
}
