import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('WebView2 values and names remain stable', () {
    final expected = <PreferredColorScheme, (int, String)>{
      PreferredColorScheme.AUTO: (0, 'AUTO'),
      PreferredColorScheme.LIGHT: (1, 'LIGHT'),
      PreferredColorScheme.DARK: (2, 'DARK'),
    };

    for (final entry in expected.entries) {
      final (nativeValue, name) = entry.value;
      expect(entry.key.toValue(), nativeValue);
      expect(entry.key.toNativeValue(), nativeValue);
      expect(entry.key.name(), name);
      expect(entry.key.isSupported(), isTrue);
      expect(PreferredColorScheme.fromValue(nativeValue), same(entry.key));
      expect(
        PreferredColorScheme.fromNativeValue(nativeValue),
        same(entry.key),
      );
      expect(PreferredColorScheme.byName(name), same(entry.key));
    }
  });

  test('settings preserve every preferred color scheme', () {
    for (final scheme in PreferredColorScheme.values) {
      final settings = InAppWebViewSettings(preferredColorScheme: scheme);
      final encoded = settings.toMap();

      expect(encoded['preferredColorScheme'], scheme.toNativeValue());
      expect(
        InAppWebViewSettings.fromMap(encoded)!.preferredColorScheme,
        same(scheme),
      );
    }
  });

  test('omitted preferred color scheme remains null', () {
    final settings = InAppWebViewSettings.fromMap(const {})!;

    expect(settings.preferredColorScheme, isNull);
    expect(settings.toMap()['preferredColorScheme'], isNull);
  });
}
