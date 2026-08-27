import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  test('FileProvider exposes only the app-scoped capture directory', () {
    final paths = _readSource('android/src/main/res/xml/provider_paths.xml');

    expect(
      paths,
      contains('<external-files-path name="app_captures" path="Captures/"/>'),
    );
    expect(paths, isNot(contains('<external-path')));
  });

  test('captured files validate the configured directory', () {
    final source = _readSource(
      'android/src/main/java/com/pichillilorenzo/'
      'flutter_inappwebview_android/webview/in_app_webview/'
      'InAppWebViewChromeClient.java',
    );

    expect(source, contains('getExternalFilesDir("Captures")'));
    expect(source, contains('if (storageDir == null)'));
    expect(
      source,
      contains('if (!storageDir.exists() && !storageDir.mkdirs())'),
    );
  });
}
