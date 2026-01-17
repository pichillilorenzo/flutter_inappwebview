import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'preferred_color_scheme.g.dart';

///Class used to indicate the preferred color scheme for the WebView.
@ExchangeableEnum()
class PreferredColorScheme_ {
  // ignore: unused_field
  final int _value;
  const PreferredColorScheme_._internal(this._value);

  ///Automatically matches the operating-system color scheme.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 0)])
  static const AUTO = PreferredColorScheme_._internal(0);

  ///Light color scheme.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 1)])
  static const LIGHT = PreferredColorScheme_._internal(1);

  ///Dark color scheme.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 2)])
  static const DARK = PreferredColorScheme_._internal(2);
}
