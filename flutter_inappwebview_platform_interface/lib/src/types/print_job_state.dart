import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../print_job/main.dart';

part 'print_job_state.g.dart';

///Class representing the state of a [PlatformPrintJobController].
@ExchangeableEnum()
class PrintJobState_ {
  // ignore: unused_field
  final int _value;
  // ignore: unused_field
  final int? _nativeValue = null;
  const PrintJobState_._internal(this._value);

  ///Print job state: The print job is being created but not yet ready to be printed.
  ///
  ///Next valid states: [QUEUED].
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PrintJobInfo.STATE_CREATED',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJobInfo#STATE_CREATED',
        value: 1,
      ),
      EnumIOSPlatform(value: 1),
      EnumMacOSPlatform(value: 1),
    ],
  )
  static const CREATED = const PrintJobState_._internal(1);

  ///Print job state: The print jobs is created, it is ready to be printed and should be processed.
  ///
  ///Next valid states: [STARTED], [FAILED], [CANCELED].
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PrintJobInfo.STATE_QUEUED',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJobInfo#STATE_QUEUED',
        value: 2,
      ),
    ],
  )
  static const QUEUED = const PrintJobState_._internal(2);

  ///Print job state: The print job is being printed.
  ///
  ///Next valid states: [COMPLETED], [FAILED], [CANCELED], [BLOCKED].
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PrintJobInfo.STATE_STARTED',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJobInfo#STATE_STARTED',
        value: 3,
      ),
      EnumIOSPlatform(value: 3),
      EnumMacOSPlatform(value: 3),
    ],
  )
  static const STARTED = const PrintJobState_._internal(3);

  ///Print job state: The print job is blocked.
  ///
  ///Next valid states: [FAILED], [CANCELED], [STARTED].
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PrintJobInfo.STATE_BLOCKED',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJobInfo#STATE_BLOCKED',
        value: 4,
      ),
    ],
  )
  static const BLOCKED = const PrintJobState_._internal(4);

  ///Print job state: The print job is successfully printed. This is a terminal state.
  ///
  ///Next valid states: None.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PrintJobInfo.STATE_COMPLETED',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJobInfo#STATE_COMPLETED',
        value: 5,
      ),
      EnumIOSPlatform(value: 5),
      EnumMacOSPlatform(value: 5),
    ],
  )
  static const COMPLETED = const PrintJobState_._internal(5);

  ///Print job state: The print job was printing but printing failed.
  ///
  ///Next valid states: None.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PrintJobInfo.STATE_FAILED',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJobInfo#STATE_FAILED',
        value: 6,
      ),
      EnumIOSPlatform(value: 6),
    ],
  )
  static const FAILED = const PrintJobState_._internal(6);

  ///Print job state: The print job is canceled. This is a terminal state.
  ///
  ///Next valid states: None.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'PrintJobInfo.STATE_CANCELED',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJobInfo#STATE_CANCELED',
        value: 7,
      ),
      EnumIOSPlatform(value: 7),
      EnumMacOSPlatform(value: 7),
    ],
  )
  static const CANCELED = const PrintJobState_._internal(7);
}
