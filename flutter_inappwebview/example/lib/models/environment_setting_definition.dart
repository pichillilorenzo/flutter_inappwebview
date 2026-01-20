import 'package:flutter_inappwebview_example/utils/support_checker.dart';

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
  final List<SupportedPlatform> supportedPlatforms;

  const EnvironmentSettingDefinition({
    required this.key,
    required this.name,
    required this.description,
    required this.type,
    this.defaultValue,
    this.enumValues,
    this.hint,
    this.supportedPlatforms = const [],
  });
}
