import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_color_mode.g.dart';

///Class representing how the printed content of a [PlatformPrintJobController] should be laid out.
@ExchangeableEnum()
class PrintJobColorMode_ {
  // ignore: unused_field
  final int _value;
  // ignore: unused_field
  final dynamic _nativeValue = null;
  const PrintJobColorMode_._internal(this._value);

  ///Monochrome color scheme, for example one color is used.
  @EnumSupportedPlatforms(
    platforms: [EnumAndroidPlatform(value: 0), EnumWindowsPlatform(value: 0)],
  )
  static const DEFAULT = const PrintJobColorMode_._internal(0);

  ///Monochrome color scheme, for example one color is used.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 1),
      EnumMacOSPlatform(value: "Gray"),
      EnumWindowsPlatform(value: 2),
    ],
  )
  static const MONOCHROME = const PrintJobColorMode_._internal(1);

  ///Color color scheme, for example many colors are used.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 2),
      EnumMacOSPlatform(value: "RGB"),
      EnumWindowsPlatform(value: 1),
    ],
  )
  static const COLOR = const PrintJobColorMode_._internal(2);
}
