import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../webview_environment/platform_webview_environment.dart';

part 'environment_scrollbar_style.g.dart';

///The ScrollBar style used during [PlatformWebViewEnvironment] creation.
@ExchangeableEnum()
class EnvironmentScrollbarStyle_ {
  // ignore: unused_field
  final int _value;
  const EnvironmentScrollbarStyle_._internal(this._value);

  ///Browser default ScrollBar style.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 0)])
  static const DEFAULT = EnvironmentScrollbarStyle_._internal(0);

  ///Window style fluent overlay scroll bar.
  ///Please see [Fluent UI](https://developer.microsoft.com/fluentui#/) for more details on fluent UI.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 1)])
  static const FLUENT_OVERLAY = EnvironmentScrollbarStyle_._internal(1);
}
