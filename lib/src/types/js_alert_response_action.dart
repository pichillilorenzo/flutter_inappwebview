import 'js_alert_response.dart';

///Class used by [JsAlertResponse] class.
class JsAlertResponseAction {
  final int _value;

  const JsAlertResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Confirm that the user hit confirm button.
  static const CONFIRM = const JsAlertResponseAction._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}