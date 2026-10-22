import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'download_start_response.dart';

part 'download_start_response_action.g.dart';

///Class representing the action of a [DownloadStartResponse].
@ExchangeableEnum()
class DownloadStartResponseAction_ {
  // ignore: unused_field
  final int _value;
  const DownloadStartResponseAction_._internal(this._value);

  ///Cancel the download.
  @EnumSupportedPlatforms(
    platforms: [EnumWindowsPlatform(value: 0), EnumLinuxPlatform(value: 0)],
  )
  static const CANCEL = DownloadStartResponseAction_._internal(0);

  ///Download the file natively (no app-side download code needed),
  ///to [DownloadStartResponse_.resultFilePath] or, when that is `null`,
  ///to the default Downloads folder with the suggested file name.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 1),
      EnumIOSPlatform(value: 1),
      EnumMacOSPlatform(value: 1),
    ],
  )
  static const SAVE = DownloadStartResponseAction_._internal(1);
}
