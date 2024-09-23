// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the state of a [PlatformPrintJobController].
class PrintJobState {
  final int _value;
  final int? _nativeValue;
  const PrintJobState._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobState._internalMultiPlatform(
          int value, Function nativeValue) =>
      PrintJobState._internal(value, nativeValue());

  ///Print job state: The print job is blocked.
  ///
  ///Next valid states: [FAILED], [CANCELED], [STARTED].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_BLOCKED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_BLOCKED))
  static final BLOCKED = PrintJobState._internalMultiPlatform(4, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///Print job state: The print job is canceled. This is a terminal state.
  ///
  ///Next valid states: None.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_CANCELED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_CANCELED))
  ///- iOS
  ///- MacOS
  static final CANCELED = PrintJobState._internalMultiPlatform(7, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 7;
      case TargetPlatform.iOS:
        return 7;
      case TargetPlatform.macOS:
        return 7;
      default:
        break;
    }
    return null;
  });

  ///Print job state: The print job is successfully printed. This is a terminal state.
  ///
  ///Next valid states: None.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_COMPLETED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_COMPLETED))
  ///- iOS
  ///- MacOS
  static final COMPLETED = PrintJobState._internalMultiPlatform(5, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 5;
      case TargetPlatform.iOS:
        return 5;
      case TargetPlatform.macOS:
        return 5;
      default:
        break;
    }
    return null;
  });

  ///Print job state: The print job is being created but not yet ready to be printed.
  ///
  ///Next valid states: [QUEUED].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_CREATED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_CREATED))
  ///- iOS
  ///- MacOS
  static final CREATED = PrintJobState._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Print job state: The print job was printing but printing failed.
  ///
  ///Next valid states: None.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_FAILED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_FAILED))
  ///- iOS
  static final FAILED = PrintJobState._internalMultiPlatform(6, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 6;
      case TargetPlatform.iOS:
        return 6;
      default:
        break;
    }
    return null;
  });

  ///Print job state: The print jobs is created, it is ready to be printed and should be processed.
  ///
  ///Next valid states: [STARTED], [FAILED], [CANCELED].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_QUEUED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_QUEUED))
  static final QUEUED = PrintJobState._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Print job state: The print job is being printed.
  ///
  ///Next valid states: [COMPLETED], [FAILED], [CANCELED], [BLOCKED].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_STARTED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_STARTED))
  ///- iOS
  ///- MacOS
  static final STARTED = PrintJobState._internalMultiPlatform(3, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 3;
      case TargetPlatform.iOS:
        return 3;
      case TargetPlatform.macOS:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobState].
  static final Set<PrintJobState> values = [
    PrintJobState.BLOCKED,
    PrintJobState.CANCELED,
    PrintJobState.COMPLETED,
    PrintJobState.CREATED,
    PrintJobState.FAILED,
    PrintJobState.QUEUED,
    PrintJobState.STARTED,
  ].toSet();

  ///Gets a possible [PrintJobState] instance from [int] value.
  static PrintJobState? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobState.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobState] instance from a native value.
  static PrintJobState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobState.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int?] native value.
  int? toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 4:
        return 'BLOCKED';
      case 7:
        return 'CANCELED';
      case 5:
        return 'COMPLETED';
      case 1:
        return 'CREATED';
      case 6:
        return 'FAILED';
      case 2:
        return 'QUEUED';
      case 3:
        return 'STARTED';
    }
    return _value.toString();
  }
}
