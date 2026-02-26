// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_to_refresh_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Pull-To-Refresh Settings for [PlatformPullToRefreshController].
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView
///- iOS WKWebView
class PullToRefreshSettings {
  ///The title text to display in the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  AttributedString? attributedTitle;

  ///The background color of the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  Color? backgroundColor;

  ///The color of the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  Color? color;

  ///The distance to trigger a sync in dips.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  int? distanceToTriggerSync;

  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  bool? enabled;

  ///The size of the refresh indicator.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  PullToRefreshSize? size;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  int? slingshotDistance;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  PullToRefreshSettings({
    this.attributedTitle,
    this.backgroundColor,
    this.color,
    this.distanceToTriggerSync,
    this.enabled = true,
    this.size,
    this.slingshotDistance,
  });

  ///Gets a possible [PullToRefreshSettings] instance from a [Map] value.
  static PullToRefreshSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = PullToRefreshSettings(
      attributedTitle: AttributedString.fromMap(
        map['attributedTitle']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
      backgroundColor: map['backgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['backgroundColor'])
          : null,
      color: map['color'] != null
          ? UtilColor.fromStringRepresentation(map['color'])
          : null,
      distanceToTriggerSync: map['distanceToTriggerSync'],
      size: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => PullToRefreshSize.fromNativeValue(
          map['size'],
        ),
        EnumMethod.value => PullToRefreshSize.fromValue(map['size']),
        EnumMethod.name => PullToRefreshSize.byName(map['size']),
      },
      slingshotDistance: map['slingshotDistance'],
    );
    instance.enabled = map['enabled'];
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PullToRefreshSettingsProperty property, {
    TargetPlatform? platform,
  }) => _PullToRefreshSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "attributedTitle": attributedTitle?.toMap(enumMethod: enumMethod),
      "backgroundColor": backgroundColor?.toHex(),
      "color": color?.toHex(),
      "distanceToTriggerSync": distanceToTriggerSync,
      "enabled": enabled,
      "size": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => size?.toNativeValue(),
        EnumMethod.value => size?.toValue(),
        EnumMethod.name => size?.name(),
      },
      "slingshotDistance": slingshotDistance,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of PullToRefreshSettings.
  PullToRefreshSettings copy() {
    return PullToRefreshSettings.fromMap(toMap()) ?? PullToRefreshSettings();
  }

  @override
  String toString() {
    return 'PullToRefreshSettings{attributedTitle: $attributedTitle, backgroundColor: $backgroundColor, color: $color, distanceToTriggerSync: $distanceToTriggerSync, enabled: $enabled, size: $size, slingshotDistance: $slingshotDistance}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [PullToRefreshSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum PullToRefreshSettingsProperty {
  ///Can be used to check if the [PullToRefreshSettings.attributedTitle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PullToRefreshSettings.attributedTitle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PullToRefreshSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  attributedTitle,

  ///Can be used to check if the [PullToRefreshSettings.backgroundColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PullToRefreshSettings.backgroundColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PullToRefreshSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  backgroundColor,

  ///Can be used to check if the [PullToRefreshSettings.color] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PullToRefreshSettings.color.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PullToRefreshSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  color,

  ///Can be used to check if the [PullToRefreshSettings.distanceToTriggerSync] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PullToRefreshSettings.distanceToTriggerSync.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PullToRefreshSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  distanceToTriggerSync,

  ///Can be used to check if the [PullToRefreshSettings.enabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PullToRefreshSettings.enabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PullToRefreshSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  enabled,

  ///Can be used to check if the [PullToRefreshSettings.size] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PullToRefreshSettings.size.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PullToRefreshSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  size,

  ///Can be used to check if the [PullToRefreshSettings.slingshotDistance] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PullToRefreshSettings.slingshotDistance.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PullToRefreshSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  slingshotDistance,
}

extension _PullToRefreshSettingsPropertySupported on PullToRefreshSettings {
  static bool isPropertySupported(
    PullToRefreshSettingsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PullToRefreshSettingsProperty.attributedTitle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PullToRefreshSettingsProperty.backgroundColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PullToRefreshSettingsProperty.color:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PullToRefreshSettingsProperty.distanceToTriggerSync:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PullToRefreshSettingsProperty.enabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PullToRefreshSettingsProperty.size:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PullToRefreshSettingsProperty.slingshotDistance:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
