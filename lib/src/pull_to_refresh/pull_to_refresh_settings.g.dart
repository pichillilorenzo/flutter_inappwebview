// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_to_refresh_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Pull-To-Refresh Settings
class PullToRefreshSettings {
  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool? enabled;

  ///The color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Color? color;

  ///The background color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Color? backgroundColor;

  ///The distance to trigger a sync in dips.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  int? distanceToTriggerSync;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  int? slingshotDistance;

  ///The size of the refresh indicator.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  PullToRefreshSize? size;

  ///The title text to display in the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  AttributedString? attributedTitle;
  PullToRefreshSettings(
      {this.enabled = true,
      this.color,
      this.backgroundColor,
      this.distanceToTriggerSync,
      this.slingshotDistance,
      this.size,
      this.attributedTitle});

  ///Gets a possible [PullToRefreshSettings] instance from a [Map] value.
  static PullToRefreshSettings? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = PullToRefreshSettings(
      color: map['color'] != null
          ? UtilColor.fromStringRepresentation(map['color'])
          : null,
      backgroundColor: map['backgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['backgroundColor'])
          : null,
      distanceToTriggerSync: map['distanceToTriggerSync'],
      slingshotDistance: map['slingshotDistance'],
      size: PullToRefreshSize.fromNativeValue(map['size']),
      attributedTitle: AttributedString.fromMap(
          map['attributedTitle']?.cast<String, dynamic>()),
    );
    instance.enabled = map['enabled'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "enabled": enabled,
      "color": color?.toHex(),
      "backgroundColor": backgroundColor?.toHex(),
      "distanceToTriggerSync": distanceToTriggerSync,
      "slingshotDistance": slingshotDistance,
      "size": size?.toNativeValue(),
      "attributedTitle": attributedTitle?.toMap(),
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
    return 'PullToRefreshSettings{enabled: $enabled, color: $color, backgroundColor: $backgroundColor, distanceToTriggerSync: $distanceToTriggerSync, slingshotDistance: $slingshotDistance, size: $size, attributedTitle: $attributedTitle}';
  }
}
