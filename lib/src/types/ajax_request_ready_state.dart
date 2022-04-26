import 'ajax_request.dart';

///Class used by [AjaxRequest] class. It represents the state of an [AjaxRequest].
class AjaxRequestReadyState {
  final int _value;

  const AjaxRequestReadyState._internal(this._value);

  ///Set of all values of [AjaxRequestReadyState].
  static final Set<AjaxRequestReadyState> values = [
    AjaxRequestReadyState.UNSENT,
    AjaxRequestReadyState.OPENED,
    AjaxRequestReadyState.HEADERS_RECEIVED,
    AjaxRequestReadyState.LOADING,
    AjaxRequestReadyState.DONE,
  ].toSet();

  ///Gets a possible [AjaxRequestReadyState] instance from an [int] value.
  static AjaxRequestReadyState? fromValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestReadyState.values
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
      case 1:
        return "OPENED";
      case 2:
        return "HEADERS_RECEIVED";
      case 3:
        return "LOADING";
      case 4:
        return "DONE";
      case 0:
      default:
        return "UNSENT";
    }
  }

  ///Client has been created. `XMLHttpRequest.open()` not called yet.
  static const UNSENT = const AjaxRequestReadyState._internal(0);

  ///`XMLHttpRequest.open()` has been called.
  static const OPENED = const AjaxRequestReadyState._internal(1);

  ///`XMLHttpRequest.send()` has been called, and [AjaxRequest.headers] and [AjaxRequest.status] are available.
  static const HEADERS_RECEIVED = const AjaxRequestReadyState._internal(2);

  ///Downloading; [AjaxRequest.responseText] holds partial data.
  static const LOADING = const AjaxRequestReadyState._internal(3);

  ///The operation is complete.
  static const DONE = const AjaxRequestReadyState._internal(4);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}