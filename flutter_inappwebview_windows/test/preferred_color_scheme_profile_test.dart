import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  test('setSettings compares preferred color scheme with shared profile', () {
    final source = _readNativeSource(
      'windows/in_app_webview/in_app_webview.cpp',
    );
    final start = source.indexOf(
      '// Updating one WebView changes every WebView that shares this profile',
    );
    final end = source.indexOf('settings = newSettings;', start);
    expect(start, isNonNegative);
    expect(end, greaterThan(start));
    final section = source.substring(start, end);

    expect(
      section,
      contains(
        'fl_map_contains_not_null(newSettingsMap, "preferredColorScheme")',
      ),
    );
    expect(section, contains('profile->get_PreferredColorScheme'));
    expect(
      section,
      contains(
        'FAILED(getColorSchemeResult) || '
        'actualColorScheme != desiredColorScheme',
      ),
    );
    expect(
      section,
      contains('profile->put_PreferredColorScheme(desiredColorScheme)'),
    );
    expect(
      section,
      isNot(
        contains(
          'settings->preferredColorScheme != '
          'newSettings->preferredColorScheme',
        ),
      ),
    );
  });
}
