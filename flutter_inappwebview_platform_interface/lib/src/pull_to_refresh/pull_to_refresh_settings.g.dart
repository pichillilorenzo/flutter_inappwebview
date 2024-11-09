// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_to_refresh_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Pull-To-Refresh Settings
class PullToRefreshSettings {
  ///The title text to display in the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  AttributedString? attributedTitle;

  ///The background color of the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Color? backgroundColor;

  ///The color of the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Color? color;

  ///The distance to trigger a sync in dips.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  int? distanceToTriggerSync;

  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool? enabled;

  ///The size of the refresh indicator.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  PullToRefreshSize? size;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  int? slingshotDistance;
  PullToRefreshSettings(
      {this.attributedTitle,
      this.backgroundColor,
      this.color,
      this.distanceToTriggerSync,
      this.enabled = true,
      this.size,
      this.slingshotDistance});

  ///Gets a possible [PullToRefreshSettings] instance from a [Map] value.
  static PullToRefreshSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = PullToRefreshSettings(
      attributedTitle: AttributedString.fromMap(
          map['attributedTitle']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      backgroundColor: map['backgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['backgroundColor'])
          : null,
      color: map['color'] != null
          ? UtilColor.fromStringRepresentation(map['color'])
          : null,
      distanceToTriggerSync: map['distanceToTriggerSync'],
      size: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          PullToRefreshSize.fromNativeValue(map['size']),
        EnumMethod.value => PullToRefreshSize.fromValue(map['size']),
        EnumMethod.name => PullToRefreshSize.byName(map['size'])
      },
      slingshotDistance: map['slingshotDistance'],
    );
    instance.enabled = map['enabled'];
    return instance;
  }

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
        EnumMethod.name => size?.name()
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
