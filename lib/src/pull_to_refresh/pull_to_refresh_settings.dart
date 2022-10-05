import 'dart:ui';
import '../util.dart';
import '../types/main.dart';

///Pull-To-Refresh Settings
class PullToRefreshSettings {
  ///Sets whether the pull-to-refresh feature is enabled or not.
  bool enabled;

  ///The color of the refresh control.
  Color? color;

  ///The background color of the refresh control.
  Color? backgroundColor;

  ///The distance to trigger a sync in dips.
  ///
  ///**NOTE**: Available only on Android.
  int? distanceToTriggerSync;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  ///
  ///**NOTE**: Available only on Android.
  int? slingshotDistance;

  ///The size of the refresh indicator.
  ///
  ///**NOTE**: Available only on Android.
  PullToRefreshSize? size;

  ///The title text to display in the refresh control.
  ///
  ///**NOTE**: Available only on iOS.
  AttributedString? attributedTitle;

  PullToRefreshSettings(
      {this.enabled = true,
      this.color,
      this.backgroundColor,
      this.distanceToTriggerSync,
      this.slingshotDistance,
      this.size,
      this.attributedTitle});

  Map<String, dynamic> toMap() {
    return {
      "enabled": enabled,
      "color": color?.toHex(),
      "backgroundColor": backgroundColor?.toHex(),
      "distanceToTriggerSync": distanceToTriggerSync,
      "slingshotDistance": slingshotDistance,
      "size": size?.toNativeValue(),
      "attributedTitle": attributedTitle?.toMap() ?? {}
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Use [PullToRefreshSettings] instead.
@Deprecated("Use PullToRefreshSettings instead")
class PullToRefreshOptions {
  ///Sets whether the pull-to-refresh feature is enabled or not.
  bool enabled;

  ///The color of the refresh control.
  Color? color;

  ///The background color of the refresh control.
  Color? backgroundColor;

  ///The distance to trigger a sync in dips.
  ///
  ///**NOTE**: Available only on Android.
  int? distanceToTriggerSync;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  ///
  ///**NOTE**: Available only on Android.
  int? slingshotDistance;

  ///The size of the refresh indicator.
  ///
  ///**NOTE**: Available only on Android.
  AndroidPullToRefreshSize? size;

  ///The title text to display in the refresh control.
  ///
  ///**NOTE**: Available only on iOS.
  IOSNSAttributedString? attributedTitle;

  PullToRefreshOptions(
      {this.enabled = true,
      this.color,
      this.backgroundColor,
      this.distanceToTriggerSync,
      this.slingshotDistance,
      this.size,
      this.attributedTitle});

  Map<String, dynamic> toMap() {
    return {
      "enabled": enabled,
      "color": color?.toHex(),
      "backgroundColor": backgroundColor?.toHex(),
      "distanceToTriggerSync": distanceToTriggerSync,
      "slingshotDistance": slingshotDistance,
      "size": size?.toNativeValue(),
      "attributedTitle": attributedTitle?.toMap() ?? {}
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
