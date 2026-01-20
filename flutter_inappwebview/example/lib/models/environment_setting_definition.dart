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
  final String key;
  final String name;
  final String description;
  final EnvironmentSettingType type;
  final dynamic defaultValue;
  final Map<String, dynamic>? enumValues;
  final String? hint;
  final PlatformWebViewEnvironmentCreationParamsProperty? property;

  const EnvironmentSettingDefinition({
    required this.key,
    required this.name,
    required this.description,
    required this.type,
    this.defaultValue,
    this.enumValues,
    this.hint,
    this.property,
  });

  PlatformWebViewEnvironmentCreationParamsProperty get _effectiveProperty =>
      property ?? PlatformWebViewEnvironmentCreationParamsProperty.settings;

  bool isSupportedOnPlatform(TargetPlatform platform) {
    return const PlatformWebViewEnvironmentCreationParams().isPropertySupported(
      _effectiveProperty,
      platform: platform,
    );
  }

  bool get isSupportedOnCurrentPlatform {
    if (kIsWeb) return true;
    return const PlatformWebViewEnvironmentCreationParams().isPropertySupported(
      _effectiveProperty,
    );
  }

  bool get hasPlatformLimitations {
    if (kIsWeb) return false;
    final nativePlatforms = TargetPlatform.values;
    return nativePlatforms.any((platform) => !isSupportedOnPlatform(platform));
  }
}
