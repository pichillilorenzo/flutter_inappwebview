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

  test('default settings map includes core defaults', () {
    final defaults = defaultInAppWebViewSettingsMap();

    expect(defaults['javaScriptEnabled'], true);
    expect(defaults['cacheMode'], CacheMode.LOAD_DEFAULT.toNativeValue());
  });

  test('default minimumFontSize respects platform override', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final androidDefaults = defaultInAppWebViewSettingsMap();

    expect(androidDefaults['minimumFontSize'], 8);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final iosDefaults = defaultInAppWebViewSettingsMap();

    expect(iosDefaults['minimumFontSize'], 0);
  });

  test('parseMixedContentMode returns enum for int values', () {
    final raw = MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW.toNativeValue();
    final parsed = parseMixedContentMode(raw);

    expect(parsed, MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW);
  });

  test('parseCacheMode defaults to LOAD_DEFAULT when null', () {
    expect(parseCacheMode(null), CacheMode.LOAD_DEFAULT);
  });
}
