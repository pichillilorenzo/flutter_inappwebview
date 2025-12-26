import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../webview_environment/platform_webview_environment.dart';

part 'environment_release_channels.g.dart';

///The WebView2 release channels searched for during [PlatformWebViewEnvironment] creation.
@ExchangeableEnum(bitwiseOrOperator: true)
class EnvironmentReleaseChannels_ {
  // ignore: unused_field
  final int _value;
  const EnvironmentReleaseChannels_._internal(this._value);

  ///No release channel. Passing only this value results in `HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)`.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 0)])
  static const NONE = EnvironmentReleaseChannels_._internal(0);

  ///The stable WebView2 Runtime that is released every 4 weeks.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 1)])
  static const STABLE = EnvironmentReleaseChannels_._internal(1);

  ///The Beta release channel that is released every 4 weeks, a week before the stable release.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 2)])
  static const BETA = EnvironmentReleaseChannels_._internal(2);

  ///The Dev release channel that is released weekly.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 4)])
  static const DEV = EnvironmentReleaseChannels_._internal(4);

  ///The Canary release channel that is released daily.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 8)])
  static const CANARY = EnvironmentReleaseChannels_._internal(8);
}
