part of 'main.dart';

void clearClientCertPreferences() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  skippableTest('clearClientCertPreferences', () async {
    await expectLater(
        InAppWebViewController.clearClientCertPreferences(), completes);
  }, skip: shouldSkip);
}
