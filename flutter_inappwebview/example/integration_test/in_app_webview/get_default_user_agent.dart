part of 'main.dart';

void getDefaultUserAgent() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.getDefaultUserAgent,
  );

  skippableTest('getDefaultUserAgent', () async {
    expect(await InAppWebViewController.getDefaultUserAgent(), isNotNull);
  }, skip: shouldSkip);
}
