import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_pagination_mode.g.dart';

///Class representing the constants that specify the different ways in which an image is divided into pages of a [PlatformPrintJobController].
@ExchangeableEnum()
class PrintJobPaginationMode_ {
  // ignore: unused_field
  final String _value;
  // ignore: unused_field
  final int? _nativeValue = null;
  const PrintJobPaginationMode_._internal(this._value);

  ///
  @EnumSupportedPlatforms(platforms: [EnumMacOSPlatform(value: 0)])
  static const AUTOMATIC = PrintJobPaginationMode_._internal('AUTOMATIC');

  ///
  @EnumSupportedPlatforms(platforms: [EnumMacOSPlatform(value: 1)])
  static const FIT = PrintJobPaginationMode_._internal("FIT");

  ///
  @EnumSupportedPlatforms(platforms: [EnumMacOSPlatform(value: 2)])
  static const CLIP = PrintJobPaginationMode_._internal("CLIP");
}
