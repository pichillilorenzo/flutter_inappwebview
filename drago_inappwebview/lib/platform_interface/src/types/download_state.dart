import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'download_progress.dart';

part 'download_state.g.dart';

///Class representing the state of a native download reported by [DownloadProgress].
@ExchangeableEnum()
class DownloadState_ {
  // ignore: unused_field
  final int _value;
  const DownloadState_._internal(this._value);

  ///The download is in progress.
  static const IN_PROGRESS = DownloadState_._internal(0);

  ///The download completed successfully.
  static const COMPLETED = DownloadState_._internal(1);

  ///The download failed. See [DownloadProgress.error].
  static const FAILED = DownloadState_._internal(2);

  ///The download was canceled.
  static const CANCELED = DownloadState_._internal(3);
}
