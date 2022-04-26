import 'ajax_request.dart';

///Class used by [AjaxRequest] class.
class AjaxRequestAction {
  final int _value;

  const AjaxRequestAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Aborts the current [AjaxRequest].
  static const ABORT = const AjaxRequestAction._internal(0);

  ///Proceeds with the current [AjaxRequest].
  static const PROCEED = const AjaxRequestAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}