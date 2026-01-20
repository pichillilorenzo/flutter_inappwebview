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

/// Enum representing known WebViewEnvironmentSettings properties.
enum EnvironmentSettingProperty {
  browserExecutableFolder,
  userDataFolder,
  additionalBrowserArguments,
  targetCompatibleBrowserVersion,
  channelSearchKind,
  releaseChannels,
  language,
  preferredLanguages,
  timeZoneOverride,
  spellCheckingEnabled,
  spellCheckingLanguages,
  areBrowserExtensionsEnabled,
  webProcessExtensionsDirectory,
  allowSingleSignOnUsingOSPrimaryAccount,
  enableTrackingPrevention,
  exclusiveUserDataFolderAccess,
  sandboxPaths,
  automationAllowed,
  isCustomCrashReportingEnabled,
  scrollbarStyle,
  cacheModel,
  customSchemeRegistrations,
}

/// Definition of a single environment setting.
class EnvironmentSettingDefinition {
  final String name;
  final String description;
  final EnvironmentSettingType type;
  final dynamic defaultValue;
  final Map<String, dynamic>? enumValues;
  final String? hint;
  final EnvironmentSettingProperty property;

  const EnvironmentSettingDefinition({
    required this.name,
    required this.description,
    required this.type,
    this.defaultValue,
    this.enumValues,
    this.hint,
    required this.property,
  });

  String get key => property.name;

  bool isSupportedOnPlatform(TargetPlatform platform) {
    return const PlatformWebViewEnvironmentCreationParams().isPropertySupported(
      PlatformWebViewEnvironmentCreationParamsProperty.settings,
      platform: platform,
    );
  }

  bool get isSupportedOnCurrentPlatform {
    if (kIsWeb) return true;
    return const PlatformWebViewEnvironmentCreationParams().isPropertySupported(
      PlatformWebViewEnvironmentCreationParamsProperty.settings,
    );
  }

  bool get hasPlatformLimitations {
    if (kIsWeb) return false;
    final nativePlatforms = TargetPlatform.values;
    return nativePlatforms.any((platform) => !isSupportedOnPlatform(platform));
  }
}
