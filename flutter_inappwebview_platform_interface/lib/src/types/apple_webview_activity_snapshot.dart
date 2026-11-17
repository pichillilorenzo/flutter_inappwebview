import 'package:flutter/foundation.dart';

/// Whether a native Apple activity observation was obtained for this call.
enum AppleWebViewActivityAvailability {
  available,

  /// The controller belongs to a platform other than iOS or macOS.
  unsupportedPlatform,

  /// The method channel has no implementation of this method. This can mean
  /// an older native plugin or a native channel that is no longer registered.
  methodUnavailable,

  /// There is no native view associated with the controller at capture time.
  noNativeView,

  /// This Dart controller was disposed, including a keepAlive detachment.
  disposed,
}

/// The application-wide native state, not the state of an individual WebView.
enum AppleWebViewApplicationState { active, inactive, background, unknown }

/// The activation state of the iOS scene owning the WebView's window.
enum AppleWebViewWindowSceneState {
  unattached,
  foregroundInactive,
  foregroundActive,
  background,
  unknown,
}

/// The configured WebKit policy. This does not report actual suspension.
enum AppleWebViewInactiveSchedulingPolicy { suspend, throttle, none, unknown }

/// An immutable, on-demand observation of public UIKit/AppKit/WebKit metadata.
///
/// A successful observation is read on the native main thread. It does not
/// evaluate JavaScript, poll, change WebKit preferences, or inspect a WebContent
/// process. It cannot establish whether JavaScript is suspended, a process is
/// alive, work is progressing, or the view is actually rendering visible pixels.
///
/// Null fields are unavailable, never an inferred `false`. An unavailable
/// snapshot contains no observation fields or capture timestamp. Capture and
/// delivery are separate: a snapshot describes capture time, not later state.
@immutable
class AppleWebViewActivitySnapshot {
  final AppleWebViewActivityAvailability availability;

  /// iOS or macOS for an available observation; otherwise null.
  final TargetPlatform? platform;

  /// UTC wall-clock time on the native host, with millisecond precision.
  /// Wall clocks can change. Measure elapsed intervals with a caller-owned
  /// monotonic clock (for example, Dart's Stopwatch), not this timestamp.
  final DateTime? capturedAt;

  /// Whether `WKWebView.window` was non-null, including a hidden/minimized
  /// window. This does not imply that Flutter is displaying the platform view.
  final bool? windowAttached;

  /// The view's own `isHidden` flag.
  final bool? viewIsHidden;

  /// Whether the view or any native ancestor has `isHidden` set. This excludes
  /// alpha, clipping, offscreen geometry, window occlusion and app state.
  final bool? viewOrAncestorIsHidden;

  /// iOS: `UIApplication.applicationState` (the most active scene in a
  /// scene-based app). macOS: active/inactive from `NSApplication.isActive`.
  final AppleWebViewApplicationState? applicationState;

  /// macOS `NSApplication.isHidden`; unavailable on iOS.
  final bool? applicationIsHidden;

  /// macOS `NSWindow.isVisible`. Unavailable without a window and on iOS;
  /// iOS window visibility is deliberately not inferred from `isHidden`.
  final bool? windowIsVisible;

  /// macOS `NSWindow.isMiniaturized`; unavailable without a macOS window.
  final bool? windowIsMiniaturized;

  /// macOS `NSWindow.occlusionState.contains(.visible)`. This is AppKit's
  /// reported window state, not a per-WebView visibility or rendering test.
  final bool? windowIsOcclusionVisible;

  /// iOS `UIWindow.isHidden`; unavailable without an iOS window.
  final bool? windowIsHidden;

  /// iOS 13+ `window.windowScene.activationState`. Unavailable on macOS,
  /// earlier iOS versions, or when the view has no window/associated scene.
  final AppleWebViewWindowSceneState? windowSceneState;

  /// Whether the public policy API exists on this OS (iOS 17+/macOS 14+).
  /// Null when the entire observation is unavailable.
  final bool? inactiveSchedulingPolicyIsSupported;

  /// The preference read from this view's configuration, without modification.
  /// Null on older OS versions. A future native value maps to `unknown` and is
  /// preserved in [inactiveSchedulingPolicyRawValue].
  final AppleWebViewInactiveSchedulingPolicy? inactiveSchedulingPolicy;
  final int? inactiveSchedulingPolicyRawValue;

  const AppleWebViewActivitySnapshot._({
    required this.availability,
    this.platform,
    this.capturedAt,
    this.windowAttached,
    this.viewIsHidden,
    this.viewOrAncestorIsHidden,
    this.applicationState,
    this.applicationIsHidden,
    this.windowIsVisible,
    this.windowIsMiniaturized,
    this.windowIsOcclusionVisible,
    this.windowIsHidden,
    this.windowSceneState,
    this.inactiveSchedulingPolicyIsSupported,
    this.inactiveSchedulingPolicy,
    this.inactiveSchedulingPolicyRawValue,
  });

  /// Creates a result without observation data. `available` is not allowed.
  factory AppleWebViewActivitySnapshot.unavailable(
    AppleWebViewActivityAvailability availability,
  ) {
    if (availability == AppleWebViewActivityAvailability.available) {
      throw ArgumentError.value(availability, 'availability');
    }
    return AppleWebViewActivitySnapshot._(availability: availability);
  }

  /// Decodes a native result. Malformed or unsupported schemas throw a
  /// [FormatException] rather than turn missing data into observations.
  factory AppleWebViewActivitySnapshot.fromMap(Map<dynamic, dynamic> map) {
    final availability = _enumValue(
      AppleWebViewActivityAvailability.values,
      map['availability'],
      'availability',
    );
    if (availability != AppleWebViewActivityAvailability.available) {
      return AppleWebViewActivitySnapshot.unavailable(availability);
    }
    if (map['schemaVersion'] is! int || map['schemaVersion'] != 1) {
      throw const FormatException('Unsupported Apple activity snapshot schema');
    }
    final platform = switch (map['platform']) {
      'ios' => TargetPlatform.iOS,
      'macos' => TargetPlatform.macOS,
      _ => throw const FormatException('Invalid Apple activity platform'),
    };
    final milliseconds = map['capturedAtMillisecondsSinceEpoch'];
    if (milliseconds is! int ||
        milliseconds < 0 ||
        milliseconds > 8640000000000000) {
      throw const FormatException('Invalid Apple activity capture time');
    }
    bool requiredBool(String key) {
      final value = map[key];
      if (value is! bool) throw FormatException('Invalid $key');
      return value;
    }

    bool? optionalBool(String key) {
      final value = map[key];
      if (value != null && value is! bool) {
        throw FormatException('Invalid $key');
      }
      return value as bool?;
    }

    final attached = requiredBool('windowAttached');
    final appHidden = optionalBool('applicationIsHidden');
    final visible = optionalBool('windowIsVisible');
    final minimized = optionalBool('windowIsMiniaturized');
    final occlusionVisible = optionalBool('windowIsOcclusionVisible');
    final windowHidden = optionalBool('windowIsHidden');
    final scene = map['windowSceneState'] == null
        ? null
        : _enumValue(
            AppleWebViewWindowSceneState.values,
            map['windowSceneState'],
            'windowSceneState',
          );
    if ((!attached &&
            [
              visible,
              minimized,
              occlusionVisible,
              windowHidden,
              scene,
            ].any((value) => value != null)) ||
        (platform == TargetPlatform.macOS &&
            (appHidden == null ||
                windowHidden != null ||
                scene != null ||
                (attached &&
                    [
                      visible,
                      minimized,
                      occlusionVisible,
                    ].any((value) => value == null)))) ||
        (platform == TargetPlatform.iOS &&
            (appHidden != null ||
                visible != null ||
                minimized != null ||
                occlusionVisible != null ||
                (attached && windowHidden == null)))) {
      throw const FormatException('Inconsistent Apple activity window fields');
    }
    final policySupported = requiredBool('inactiveSchedulingPolicyIsSupported');
    final policy = map['inactiveSchedulingPolicy'] == null
        ? null
        : _enumValue(
            AppleWebViewInactiveSchedulingPolicy.values,
            map['inactiveSchedulingPolicy'],
            'inactiveSchedulingPolicy',
          );
    final rawPolicy = map['inactiveSchedulingPolicyRawValue'];
    if ((policySupported && (policy == null || rawPolicy is! int)) ||
        (!policySupported && (policy != null || rawPolicy != null))) {
      throw const FormatException('Inconsistent Apple activity policy fields');
    }
    return AppleWebViewActivitySnapshot._(
      availability: availability,
      platform: platform,
      capturedAt: DateTime.fromMillisecondsSinceEpoch(
        milliseconds,
        isUtc: true,
      ),
      windowAttached: attached,
      viewIsHidden: requiredBool('viewIsHidden'),
      viewOrAncestorIsHidden: requiredBool('viewOrAncestorIsHidden'),
      applicationState: _enumValue(
        AppleWebViewApplicationState.values,
        map['applicationState'],
        'applicationState',
      ),
      applicationIsHidden: appHidden,
      windowIsVisible: visible,
      windowIsMiniaturized: minimized,
      windowIsOcclusionVisible: occlusionVisible,
      windowIsHidden: windowHidden,
      windowSceneState: scene,
      inactiveSchedulingPolicyIsSupported: policySupported,
      inactiveSchedulingPolicy: policy,
      inactiveSchedulingPolicyRawValue: rawPolicy as int?,
    );
  }

  /// A JSON-safe map retaining unavailable fields as null.
  Map<String, dynamic> toMap() => {
    'schemaVersion': 1,
    'availability': availability.name,
    'platform': switch (platform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      _ => null,
    },
    'capturedAtMillisecondsSinceEpoch': capturedAt?.millisecondsSinceEpoch,
    'windowAttached': windowAttached,
    'viewIsHidden': viewIsHidden,
    'viewOrAncestorIsHidden': viewOrAncestorIsHidden,
    'applicationState': applicationState?.name,
    'applicationIsHidden': applicationIsHidden,
    'windowIsVisible': windowIsVisible,
    'windowIsMiniaturized': windowIsMiniaturized,
    'windowIsOcclusionVisible': windowIsOcclusionVisible,
    'windowIsHidden': windowIsHidden,
    'windowSceneState': windowSceneState?.name,
    'inactiveSchedulingPolicyIsSupported': inactiveSchedulingPolicyIsSupported,
    'inactiveSchedulingPolicy': inactiveSchedulingPolicy?.name,
    'inactiveSchedulingPolicyRawValue': inactiveSchedulingPolicyRawValue,
  };

  Map<String, dynamic> toJson() => toMap();

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? value,
    String key,
  ) {
    for (final entry in values) {
      if (entry.name == value) return entry;
    }
    throw FormatException('Invalid $key');
  }
}
