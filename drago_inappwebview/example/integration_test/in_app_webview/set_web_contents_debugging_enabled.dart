part of 'main.dart';

void setWebContentsDebuggingEnabled() {
  final shouldSkip = !InAppWebViewController.isMethodSupported(
    PlatformInAppWebViewControllerMethod.setWebContentsDebuggingEnabled,
  );

  skippableTest('setWebContentsDebuggingEnabled', () async {
    expect(
      InAppWebViewController.setWebContentsDebuggingEnabled(true),
      completes,
    );
  }, skip: shouldSkip);
}
