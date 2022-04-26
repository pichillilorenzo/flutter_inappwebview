import 'js_prompt_response.dart';

///Class used by [JsPromptResponse] class.
class JsPromptResponseAction {
  final int _value;

  const JsPromptResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Confirm that the user hit confirm button.
  static const CONFIRM = const JsPromptResponseAction._internal(0);

  ///Confirm that the user hit cancel button.
  static const CANCEL = const JsPromptResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}