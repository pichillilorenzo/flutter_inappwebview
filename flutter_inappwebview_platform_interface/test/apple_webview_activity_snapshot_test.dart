import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class OtherController extends PlatformInAppWebViewController {
  OtherController()
    : super.implementation(
        const PlatformInAppWebViewControllerCreationParams(id: 10),
      );
}

Map<String, dynamic> native({
  String platform = 'macos',
  bool attached = true,
}) => {
  'schemaVersion': 1,
  'availability': 'available',
  'platform': platform,
  'capturedAtMillisecondsSinceEpoch': 1700000000123,
  'windowAttached': attached,
  'viewIsHidden': false,
  'viewOrAncestorIsHidden': true,
  'applicationState': 'inactive',
  if (platform == 'macos') ...{
    'applicationIsHidden': false,
    if (attached) ...{
      'windowIsVisible': false,
      'windowIsMiniaturized': true,
      'windowIsOcclusionVisible': false,
    },
  },
  if (platform == 'ios' && attached) ...{
    'windowIsHidden': false,
    'windowSceneState': 'background',
  },
  'inactiveSchedulingPolicyIsSupported': true,
  'inactiveSchedulingPolicy': 'suspend',
  'inactiveSchedulingPolicyRawValue': 0,
};

void main() {
  test(
    'available metadata survives JSON without treating false as missing',
    () {
      final value = AppleWebViewActivitySnapshot.fromMap(native());
      expect(value.availability, AppleWebViewActivityAvailability.available);
      expect(value.platform, TargetPlatform.macOS);
      expect(value.windowAttached, true);
      expect(value.viewIsHidden, false);
      expect(value.viewOrAncestorIsHidden, true);
      expect(value.windowIsVisible, false);
      expect(value.windowIsMiniaturized, true);
      expect(value.windowIsOcclusionVisible, false);
      expect(value.windowIsHidden, isNull);
      expect(value.capturedAt!.isUtc, true);
      expect(value.capturedAt!.millisecondsSinceEpoch, 1700000000123);
      expect(
        AppleWebViewActivitySnapshot.fromMap(
          jsonDecode(jsonEncode(value)),
        ).toMap(),
        value.toMap(),
      );
    },
  );

  for (final platform in ['ios', 'macos']) {
    test('$platform detached is observed false, window fields unavailable', () {
      final value = AppleWebViewActivitySnapshot.fromMap(
        native(platform: platform, attached: false),
      );
      expect(value.windowAttached, false);
      expect(value.windowIsVisible, isNull);
      expect(value.windowIsMiniaturized, isNull);
      expect(value.windowIsOcclusionVisible, isNull);
      expect(value.windowIsHidden, isNull);
      expect(value.windowSceneState, isNull);
      expect(value.capturedAt, isNotNull);
    });
  }

  test('iOS scene may be background while the app is active elsewhere', () {
    final value = AppleWebViewActivitySnapshot.fromMap(
      native(platform: 'ios')..['applicationState'] = 'active',
    );
    expect(value.applicationState, AppleWebViewApplicationState.active);
    expect(value.windowSceneState, AppleWebViewWindowSceneState.background);
    expect(value.applicationIsHidden, isNull);
    expect(value.windowIsVisible, isNull);
    expect(value.windowIsHidden, false);
  });

  test('iOS without a scene does not invent scene state', () {
    final value = AppleWebViewActivitySnapshot.fromMap(
      native(platform: 'ios')..remove('windowSceneState'),
    );
    expect(value.windowAttached, true);
    expect(value.windowSceneState, isNull);
  });

  test('old OS reports the policy as unsupported, not suspend by default', () {
    final value = AppleWebViewActivitySnapshot.fromMap(
      native()
        ..['inactiveSchedulingPolicyIsSupported'] = false
        ..remove('inactiveSchedulingPolicy')
        ..remove('inactiveSchedulingPolicyRawValue'),
    );
    expect(value.inactiveSchedulingPolicyIsSupported, false);
    expect(value.inactiveSchedulingPolicy, isNull);
    expect(value.inactiveSchedulingPolicyRawValue, isNull);
  });

  test(
    'future native policy is explicitly unknown and preserves raw value',
    () {
      final value = AppleWebViewActivitySnapshot.fromMap(
        native()
          ..['inactiveSchedulingPolicy'] = 'unknown'
          ..['inactiveSchedulingPolicyRawValue'] = 99,
      );
      expect(value.inactiveSchedulingPolicyIsSupported, true);
      expect(
        value.inactiveSchedulingPolicy,
        AppleWebViewInactiveSchedulingPolicy.unknown,
      );
      expect(value.inactiveSchedulingPolicyRawValue, 99);
    },
  );

  for (final state in AppleWebViewActivityAvailability.values.where(
    (value) => value != AppleWebViewActivityAvailability.available,
  )) {
    test(
      '$state carries no observation, even if stale fields were supplied',
      () {
        final value = AppleWebViewActivitySnapshot.fromMap(
          native()..['availability'] = state.name,
        );
        expect(value.availability, state);
        expect(
          value.toMap().entries.where(
            (entry) => !['schemaVersion', 'availability'].contains(entry.key),
          ),
          everyElement(
            predicate<MapEntry<String, dynamic>>(
              (entry) => entry.value == null,
            ),
          ),
        );
        expect(
          AppleWebViewActivitySnapshot.fromMap(value.toMap()).availability,
          state,
        );
      },
    );
  }

  test('available cannot be manufactured by an unavailable constructor', () {
    expect(
      () => AppleWebViewActivitySnapshot.unavailable(
        AppleWebViewActivityAvailability.available,
      ),
      throwsArgumentError,
    );
  });

  final invalidFields = <String, Object?>{
    'schemaVersion': 2,
    'availability': 'maybe',
    'platform': 'linux',
    'capturedAtMillisecondsSinceEpoch': 1.1,
    'windowAttached': null,
    'viewIsHidden': 0,
    'viewOrAncestorIsHidden': 'false',
    'applicationState': 'suspended',
    'applicationIsHidden': null,
    'windowIsVisible': 1,
    'windowIsMiniaturized': null,
    'windowIsOcclusionVisible': null,
    'windowIsHidden': false,
    'windowSceneState': 'foregroundActive',
    'inactiveSchedulingPolicyIsSupported': null,
    'inactiveSchedulingPolicy': null,
    'inactiveSchedulingPolicyRawValue': '0',
  };
  for (final entry in invalidFields.entries) {
    test('rejects invalid or inconsistent ${entry.key}', () {
      expect(
        () => AppleWebViewActivitySnapshot.fromMap(
          native()..[entry.key] = entry.value,
        ),
        throwsFormatException,
      );
    });
  }
  test('rejects stale window data after detachment', () {
    expect(
      () => AppleWebViewActivitySnapshot.fromMap(
        native()..['windowAttached'] = false,
      ),
      throwsFormatException,
    );
  });
  test('rejects observed policy when API is unsupported', () {
    expect(
      () => AppleWebViewActivitySnapshot.fromMap(
        native()..['inactiveSchedulingPolicyIsSupported'] = false,
      ),
      throwsFormatException,
    );
  });
  for (final badTime in [-1, 8640000000000001]) {
    test('rejects invalid epoch $badTime', () {
      expect(
        () => AppleWebViewActivitySnapshot.fromMap(
          native()..['capturedAtMillisecondsSinceEpoch'] = badTime,
        ),
        throwsFormatException,
      );
    });
  }
  test(
    'base controller returns unsupported without a platform channel',
    () async {
      final value = await OtherController().getAppleWebViewActivitySnapshot();
      expect(
        value.availability,
        AppleWebViewActivityAvailability.unsupportedPlatform,
      );
      expect(value.capturedAt, isNull);
    },
  );
  test('runtime support metadata reports only Apple', () {
    for (final platform in TargetPlatform.values) {
      expect(
        OtherController().isMethodSupported(
          PlatformInAppWebViewControllerMethod.getAppleWebViewActivitySnapshot,
          platform: platform,
        ),
        [TargetPlatform.iOS, TargetPlatform.macOS].contains(platform),
      );
    }
  });
}
