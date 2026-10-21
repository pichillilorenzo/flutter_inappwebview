import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('audio capture falls back when no recorder can handle the intent', () {
    final source = File(
      'android/src/main/java/com/pichillilorenzo/'
      'flutter_inappwebview_android/webview/in_app_webview/'
      'InAppWebViewChromeClient.java',
    ).readAsStringSync().replaceAll('\r\n', '\n');

    final guardedDirectCapture = RegExp(
      r'if \(pickerIntent == null && audio && !images && !video\) \{\s*'
      r'Intent audioIntent = getAudioIntent\(\);\s*'
      r'if \(canResolveIntent\(audioIntent\)\) \{\s*'
      r'pickerIntent = audioIntent;',
    );

    expect(source, contains('MediaStore.Audio.Media.RECORD_SOUND_ACTION'));
    expect(guardedDirectCapture.allMatches(source), hasLength(2));
    expect(source, isNot(contains('pickerIntent = getAudioIntent();')));
  });
}
