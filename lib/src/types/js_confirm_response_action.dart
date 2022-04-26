import 'js_confirm_response.dart';

///Class used by [JsConfirmResponse] class.
class JsConfirmResponseAction {
  final int _value;

  const JsConfirmResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Confirm that the user hit confirm button.
  static const CONFIRM = const JsConfirmResponseAction._internal(0);

  ///Confirm that the user hit cancel button.
  static const CANCEL = const JsConfirmResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}