import 'js_before_unload_response.dart';

///Class used by [JsBeforeUnloadResponse] class.
class JsBeforeUnloadResponseAction {
  final int _value;

  const JsBeforeUnloadResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Confirm that the user hit confirm button.
  static const CONFIRM = const JsBeforeUnloadResponseAction._internal(0);

  ///Confirm that the user hit cancel button.
  static const CANCEL = const JsBeforeUnloadResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}