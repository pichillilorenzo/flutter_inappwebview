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

  test('persistent storage permission maps to WebView2 kind 13', () {
    expect(
      PermissionResourceType.fromNativeValue(13),
      same(PermissionResourceType.PERSISTENT_STORAGE),
    );
    expect(PermissionResourceType.PERSISTENT_STORAGE.toNativeValue(), 13);
  });

  test('permission request preserves all enum serialization methods', () {
    const encodedValues = <EnumMethod, Object>{
      EnumMethod.nativeValue: 13,
      EnumMethod.value: 'PERSISTENT_STORAGE',
      EnumMethod.name: 'PERSISTENT_STORAGE',
    };

    for (final entry in encodedValues.entries) {
      final request = PermissionRequest.fromMap({
        'origin': 'https://example.com',
        'resources': [entry.value],
      }, enumMethod: entry.key)!;

      expect(request.resources, [
        same(PermissionResourceType.PERSISTENT_STORAGE),
      ]);
      expect(request.toMap(enumMethod: entry.key)['resources'], [entry.value]);
    }
  });

  test('future WebView2 permission kinds fall back to unknown', () {
    final request = PermissionRequest.fromMap({
      'origin': 'https://example.com',
      'resources': [999],
    })!;

    expect(request.resources, [same(PermissionResourceType.UNKNOWN)]);
  });
}
