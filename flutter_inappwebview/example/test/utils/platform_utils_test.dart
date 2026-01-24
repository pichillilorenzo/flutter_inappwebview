import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/utils/platform_utils.dart';

void main() {
  group('PlatformUtils', () {
    test('getPlatformName returns non-empty string', () {
      final platformName = PlatformUtils.getPlatformName();
      expect(platformName, isNotEmpty);
      expect(platformName, isA<String>());
    });

    test('getFlutterVersion returns non-empty string', () {
      final flutterVersion = PlatformUtils.getFlutterVersion();
      expect(flutterVersion, isNotEmpty);
      expect(flutterVersion, isA<String>());
    });

    test('getDartVersion returns non-empty string', () {
      final dartVersion = PlatformUtils.getDartVersion();
      expect(dartVersion, isNotEmpty);
      expect(dartVersion, isA<String>());
    });

    test('isWebPlatform returns boolean', () {
      final isWeb = PlatformUtils.isWebPlatform();
      expect(isWeb, isA<bool>());
    });

    test('isMobilePlatform returns boolean', () {
      final isMobile = PlatformUtils.isMobilePlatform();
      expect(isMobile, isA<bool>());
    });

    test('isDesktopPlatform returns boolean', () {
      final isDesktop = PlatformUtils.isDesktopPlatform();
      expect(isDesktop, isA<bool>());
    });

    test('platform type methods are mutually exclusive', () {
      final isWeb = PlatformUtils.isWebPlatform();
      final isMobile = PlatformUtils.isMobilePlatform();
      final isDesktop = PlatformUtils.isDesktopPlatform();

      // At most one should be true (could be none in test environment)
      final trueCount = [isWeb, isMobile, isDesktop].where((e) => e).length;
      expect(trueCount, lessThanOrEqualTo(1));
    });

    test('getPlatformIcon returns icon data', () {
      final icon = PlatformUtils.getPlatformIcon();
      expect(icon, isNotNull);
    });
  });
}
