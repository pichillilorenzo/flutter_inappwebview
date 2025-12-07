// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_failed_reason.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate the kind of process failure that has occurred.
class ProcessFailedReason {
  final String _value;
  final int? _nativeValue;
  const ProcessFailedReason._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ProcessFailedReason._internalMultiPlatform(
          String value, Function nativeValue) =>
      ProcessFailedReason._internal(value, nativeValue());

  ///The process crashed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_PROCESS_FAILED_REASON_CRASHED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason))
  static final CRASHED =
      ProcessFailedReason._internalMultiPlatform('CRASHED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///The process failed to launch.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_PROCESS_FAILED_REASON_LAUNCH_FAILED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason))
  static final LAUNCH_FAILED =
      ProcessFailedReason._internalMultiPlatform('LAUNCH_FAILED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///The process terminated due to running out of memory.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_PROCESS_FAILED_REASON_OUT_OF_MEMORY](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason))
  static final OUT_OF_MEMORY =
      ProcessFailedReason._internalMultiPlatform('OUT_OF_MEMORY', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 5;
      default:
        break;
    }
    return null;
  });

  ///The process was terminated. For example, from Task Manager.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_PROCESS_FAILED_REASON_TERMINATED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason))
  static final TERMINATED =
      ProcessFailedReason._internalMultiPlatform('TERMINATED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///An unexpected process failure occurred.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_PROCESS_FAILED_REASON_UNEXPECTED](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason))
  static final UNEXPECTED =
      ProcessFailedReason._internalMultiPlatform('UNEXPECTED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///The process became unresponsive. This only applies to the main frame's render process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - COREWEBVIEW2_PROCESS_FAILED_REASON_UNRESPONSIVE](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_process_failed_reason))
  static final UNRESPONSIVE =
      ProcessFailedReason._internalMultiPlatform('UNRESPONSIVE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [ProcessFailedReason].
  static final Set<ProcessFailedReason> values = [
    ProcessFailedReason.CRASHED,
    ProcessFailedReason.LAUNCH_FAILED,
    ProcessFailedReason.OUT_OF_MEMORY,
    ProcessFailedReason.TERMINATED,
    ProcessFailedReason.UNEXPECTED,
    ProcessFailedReason.UNRESPONSIVE,
  ].toSet();

  ///Gets a possible [ProcessFailedReason] instance from [String] value.
  static ProcessFailedReason? fromValue(String? value) {
    if (value != null) {
      try {
        return ProcessFailedReason.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ProcessFailedReason] instance from a native value.
  static ProcessFailedReason? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ProcessFailedReason.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ProcessFailedReason] instance value with name [name].
  ///
  /// Goes through [ProcessFailedReason.values] looking for a value with
  /// name [name], as reported by [ProcessFailedReason.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ProcessFailedReason? byName(String? name) {
    if (name != null) {
      try {
        return ProcessFailedReason.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ProcessFailedReason] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ProcessFailedReason> asNameMap() =>
      <String, ProcessFailedReason>{
        for (final value in ProcessFailedReason.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'CRASHED':
        return 'CRASHED';
      case 'LAUNCH_FAILED':
        return 'LAUNCH_FAILED';
      case 'OUT_OF_MEMORY':
        return 'OUT_OF_MEMORY';
      case 'TERMINATED':
        return 'TERMINATED';
      case 'UNEXPECTED':
        return 'UNEXPECTED';
      case 'UNRESPONSIVE':
        return 'UNRESPONSIVE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return toNativeValue() != null;
  }

  @override
  String toString() {
    return _value;
  }
}
