import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'download_start_response.dart';

part 'download_start_response_action.g.dart';

///Class representing the action of a [DownloadStartResponse].
@ExchangeableEnum()
class DownloadStartResponseAction_ {
  // ignore: unused_field
  final int _value;
  const DownloadStartResponseAction_._internal(this._value);

  ///Cancel the download.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 0)])
  static const CANCEL = const DownloadStartResponseAction_._internal(0);
}
