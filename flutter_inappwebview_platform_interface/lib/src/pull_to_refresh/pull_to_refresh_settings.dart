import 'dart:ui';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/attributed_string.dart';
import '../types/pull_to_refresh_size.dart';
import '../util.dart';
import '../types/main.dart';

part 'pull_to_refresh_settings.g.dart';

///Pull-To-Refresh Settings
@ExchangeableObject(copyMethod: true)
class PullToRefreshSettings_ {
  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool? enabled;

  ///The color of the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Color_? color;

  ///The background color of the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Color_? backgroundColor;

  ///The distance to trigger a sync in dips.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  int? distanceToTriggerSync;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  int? slingshotDistance;

  ///The size of the refresh indicator.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  PullToRefreshSize_? size;

  ///The title text to display in the refresh control.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  AttributedString_? attributedTitle;

  PullToRefreshSettings_(
      {this.enabled = true,
      this.color,
      this.backgroundColor,
      this.distanceToTriggerSync,
      this.slingshotDistance,
      this.size,
      this.attributedTitle});
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
