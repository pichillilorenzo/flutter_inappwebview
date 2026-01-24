import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'process_failed_reason.g.dart';

///Class used to indicate the kind of process failure that has occurred.
@ExchangeableEnum()
class ProcessFailedReason_ {
  // ignore: unused_field
  final String _value;
  // ignore: unused_field
  final int? _nativeValue = null;
  const ProcessFailedReason_._internal(this._value);

  ///An unexpected process failure occurred.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_REASON_UNEXPECTED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason',
        value: 0,
      ),
    ],
  )
  static const UNEXPECTED = const ProcessFailedReason_._internal('UNEXPECTED');

  ///The process became unresponsive. This only applies to the main frame's render process.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_REASON_UNRESPONSIVE',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason',
        value: 1,
      ),
    ],
  )
  static const UNRESPONSIVE = const ProcessFailedReason_._internal(
    'UNRESPONSIVE',
  );

  ///The process was terminated. For example, from Task Manager.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_REASON_TERMINATED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason',
        value: 2,
      ),
    ],
  )
  static const TERMINATED = const ProcessFailedReason_._internal('TERMINATED');

  ///The process crashed.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_REASON_CRASHED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason',
        value: 3,
      ),
    ],
  )
  static const CRASHED = const ProcessFailedReason_._internal('CRASHED');

  ///The process failed to launch.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_REASON_LAUNCH_FAILED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason',
        value: 4,
      ),
    ],
  )
  static const LAUNCH_FAILED = const ProcessFailedReason_._internal(
    'LAUNCH_FAILED',
  );

  ///The process terminated due to running out of memory.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_PROCESS_FAILED_REASON_OUT_OF_MEMORY',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason',
        value: 5,
      ),
    ],
  )
  static const OUT_OF_MEMORY = const ProcessFailedReason_._internal(
    'OUT_OF_MEMORY',
  );
}
