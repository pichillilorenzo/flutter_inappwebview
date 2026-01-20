import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/settings_defaults.dart';

void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = null;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('default settings map matches constructor defaults', () {
    final defaults = defaultInAppWebViewSettings().toMap(
      enumMethod: EnumMethod.nativeValue,
    );
    final expected = InAppWebViewSettings().toMap(
      enumMethod: EnumMethod.nativeValue,
    );

    expect(defaults, expected);
  });

  test('default environment settings map matches constructor defaults', () {
    final defaults = defaultWebViewEnvironmentSettings().toMap(
      enumMethod: EnumMethod.nativeValue,
    );
    final expected = WebViewEnvironmentSettings().toMap(
      enumMethod: EnumMethod.nativeValue,
    );

    expect(defaults, expected);
  });
}
