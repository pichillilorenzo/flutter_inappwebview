import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_disposition.g.dart';

///Class representing the constants that specify values for the print job disposition of a [PlatformPrintJobController].
@ExchangeableEnum()
class PrintJobDisposition_ {
  // ignore: unused_field
  final String _value;
  const PrintJobDisposition_._internal(this._value);

  ///Normal print job.
  @EnumSupportedPlatforms(platforms: [EnumMacOSPlatform(value: 'spool')])
  static const SPOOL = PrintJobDisposition_._internal('SPOOL');

  ///Send to Preview application.
  @EnumSupportedPlatforms(platforms: [EnumMacOSPlatform(value: 'preview')])
  static const PREVIEW = PrintJobDisposition_._internal("PREVIEW");

  ///Save to a file.
  @EnumSupportedPlatforms(platforms: [EnumMacOSPlatform(value: 'save')])
  static const SAVE = PrintJobDisposition_._internal("SAVE");

  ///Cancel print job.
  @EnumSupportedPlatforms(platforms: [EnumMacOSPlatform(value: 'cancel')])
  static const CANCEL = PrintJobDisposition_._internal("CANCEL");
}
