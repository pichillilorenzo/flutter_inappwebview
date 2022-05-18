import '../print_job/main.dart';

///Class representing the state of a [PrintJobController].
class PrintJobState {
  final int _value;

  const PrintJobState._internal(this._value);

  ///Set of all values of [PrintJobState].
  static final Set<PrintJobState> values = [
    PrintJobState.CREATED,
    PrintJobState.QUEUED,
    PrintJobState.STARTED,
    PrintJobState.BLOCKED,
    PrintJobState.COMPLETED,
    PrintJobState.FAILED,
    PrintJobState.CANCELED,
  ].toSet();

  ///Gets a possible [PrintJobState] instance from an [int] value.
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

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 2:
        return "QUEUED";
      case 3:
        return "STARTED";
      case 4:
        return "BLOCKED";
      case 5:
        return "COMPLETED";
      case 6:
        return "FAILED";
      case 7:
        return "CANCELED";
      case 1:
      default:
        return "CREATED";
    }
  }

  ///Print job state: The print job is being created but not yet ready to be printed.
  ///
  ///Next valid states: [QUEUED].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_CREATED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_CREATED))
  ///- iOS
  static const CREATED = const PrintJobState._internal(1);

  ///Print job state: The print jobs is created, it is ready to be printed and should be processed.
  ///
  ///Next valid states: [STARTED], [FAILED], [CANCELED].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_QUEUED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_QUEUED))
  static const QUEUED = const PrintJobState._internal(2);

  ///Print job state: The print job is being printed.
  ///
  ///Next valid states: [COMPLETED], [FAILED], [CANCELED], [BLOCKED].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_STARTED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_STARTED))
  ///- iOS
  static const STARTED = const PrintJobState._internal(3);

  ///Print job state: The print job is blocked.
  ///
  ///Next valid states: [FAILED], [CANCELED], [STARTED].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_BLOCKED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_BLOCKED))
  static const BLOCKED = const PrintJobState._internal(4);

  ///Print job state: The print job is successfully printed. This is a terminal state.
  ///
  ///Next valid states: None.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_COMPLETED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_COMPLETED))
  ///- iOS
  static const COMPLETED = const PrintJobState._internal(5);


  ///Print job state: The print job was printing but printing failed.
  ///
  ///Next valid states: None.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_FAILED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_FAILED))
  ///- iOS
  static const FAILED = const PrintJobState._internal(6);

  ///Print job state: The print job is canceled. This is a terminal state.
  ///
  ///Next valid states: None.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJobInfo.STATE_CANCELED](https://developer.android.com/reference/android/print/PrintJobInfo#STATE_CANCELED))
  ///- iOS
  static const CANCELED = const PrintJobState._internal(7);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
