import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

enum _FakeMethod { alpha }

enum _FakeProperty { beta }

void main() {
  group('SupportCheckHelper', () {
    test('targetPlatformFor maps to expected TargetPlatform', () {
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.android),
        TargetPlatform.android,
      );
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.ios),
        TargetPlatform.iOS,
      );
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.macos),
        TargetPlatform.macOS,
      );
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.windows),
        TargetPlatform.windows,
      );
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.linux),
        TargetPlatform.linux,
      );
      expect(
        SupportCheckHelper.targetPlatformFor(SupportedPlatform.web),
        isNull,
      );
    });

    test('isMethodSupportedForPlatform forwards target platform', () {
      final calledPlatforms = <TargetPlatform?>[];
      bool fakeChecker(_FakeMethod method, {TargetPlatform? platform}) {
        calledPlatforms.add(platform);
        return platform == TargetPlatform.android;
      }

      final result = SupportCheckHelper.isMethodSupportedForPlatform(
        platform: SupportedPlatform.android,
        method: _FakeMethod.alpha,
        checker: fakeChecker,
      );

      expect(result, isTrue);
      expect(calledPlatforms, [TargetPlatform.android]);
    });

    test('supportedPlatformsForMethod aggregates supported platforms', () {
      bool fakeChecker(_FakeMethod method, {TargetPlatform? platform}) {
        return platform == TargetPlatform.android ||
            platform == TargetPlatform.windows;
      }

      final supported = SupportCheckHelper.supportedPlatformsForMethod(
        method: _FakeMethod.alpha,
        checker: fakeChecker,
      );

      expect(supported, contains(SupportedPlatform.android));
      expect(supported, contains(SupportedPlatform.windows));
      expect(supported, isNot(contains(SupportedPlatform.ios)));
    });

    test('isPropertySupportedForPlatform forwards target platform', () {
      final calledPlatforms = <TargetPlatform?>[];
      bool fakeChecker(dynamic property, {TargetPlatform? platform}) {
        calledPlatforms.add(platform);
        return platform == TargetPlatform.macOS;
      }

      final result = SupportCheckHelper.isPropertySupportedForPlatform(
        platform: SupportedPlatform.macos,
        property: _FakeProperty.beta,
        checker: fakeChecker,
      );

      expect(result, isTrue);
      expect(calledPlatforms, [TargetPlatform.macOS]);
    });
  });
}
