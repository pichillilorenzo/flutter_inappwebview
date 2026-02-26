import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

/// Enum representing the type of a setting
enum SettingType { boolean, string, integer, double, enumeration }

/// Definition of a single setting
class SettingDefinition {
  final String name;
  final String description;
  final SettingType type;
  final dynamic defaultValue;
  final List<dynamic>? enumValues;

  /// The InAppWebViewSettings property for runtime support checking.
  /// If provided, use InAppWebViewSettings.isPropertySupported to check platform support.
  final InAppWebViewSettingsProperty property;

  const SettingDefinition({
    required this.name,
    required this.description,
    required this.type,
    required this.defaultValue,
    this.enumValues,
    required this.property,
  });

  static String enumDisplayName(dynamic value) {
    if (value == null) return '(none)';
    try {
      final dynamic result = (value as dynamic).name();
      if (result is String) return result;
    } catch (_) {}
    try {
      final dynamic result = (value as dynamic).name;
      if (result is String) return result;
    } catch (_) {}
    return value.toString();
  }

  static dynamic enumValueToNative(dynamic value) {
    if (value == null) return null;
    try {
      return (value as dynamic).toNativeValue();
    } catch (_) {
      return value;
    }
  }

  String get key => property.name;

  /// Check if this setting is supported on the given platform.
  /// Returns true if no property is specified (assumed to be cross-platform).
  /// Note: Web platform is not mapped to TargetPlatform, so it's not checkable.
  bool isSupportedOnPlatform(SupportedPlatform platform) {
    // Web is not mapped to TargetPlatform in Flutter
    if (platform == SupportedPlatform.web) return false;
    final targetPlatform = platform.targetPlatform;
    if (targetPlatform == null) return false;
    return InAppWebViewSettings.isPropertySupported(
      property,
      platform: targetPlatform,
    );
  }

  /// Check if this setting is supported on the current platform.
  bool get isSupportedOnCurrentPlatform {
    // On web, we can't check without TargetPlatform
    if (kIsWeb) return false;
    return InAppWebViewSettings.isPropertySupported(property);
  }

  /// Get the set of supported platforms for this setting.
  /// Note: Web platform cannot be checked via TargetPlatform.
  Set<SupportedPlatform> get supportedPlatforms {
    return SupportedPlatform.values
        .where((p) => p != SupportedPlatform.web && isSupportedOnPlatform(p))
        .toSet();
  }

  /// Check if this setting has platform-specific support (not available on all platforms).
  bool get hasPlatformLimitations {
    // Check if the property is NOT supported on all native platforms
    final nativePlatforms = SupportedPlatform.values.where(
      (p) => p != SupportedPlatform.web,
    );
    return nativePlatforms.any((p) => !isSupportedOnPlatform(p));
  }
}
