import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Enum representing the type of an environment setting.
enum EnvironmentSettingType {
  boolean,
  string,
  stringList,
  enumeration,
  customSchemeRegistrations,
}

/// Definition of a single environment setting.
class EnvironmentSettingDefinition {
  final String name;
  final String description;
  final EnvironmentSettingType type;
  final dynamic defaultValue;
  final List<dynamic>? enumValues;
  final String? hint;
  final WebViewEnvironmentSettingsProperty property;

  const EnvironmentSettingDefinition({
    required this.name,
    required this.description,
    required this.type,
    this.defaultValue,
    this.enumValues,
    this.hint,
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

  bool isSupportedOnPlatform(TargetPlatform platform) {
    return WebViewEnvironmentSettings.isPropertySupported(
      property,
      platform: platform,
    );
  }

  bool get isSupportedOnCurrentPlatform {
    if (kIsWeb) return true;
    return WebViewEnvironmentSettings.isPropertySupported(property);
  }

  bool get hasPlatformLimitations {
    if (kIsWeb) return false;
    final nativePlatforms = TargetPlatform.values;
    return nativePlatforms.any((platform) => !isSupportedOnPlatform(platform));
  }
}
