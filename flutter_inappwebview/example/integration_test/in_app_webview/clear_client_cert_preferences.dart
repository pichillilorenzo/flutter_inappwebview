part of 'main.dart';

void clearClientCertPreferences() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.clearClientCertPreferences,
  );

  skippableTest('clearClientCertPreferences', () async {
    await expectLater(
      InAppWebViewController.clearClientCertPreferences(),
      completes,
    );
  }, skip: shouldSkip);
}
