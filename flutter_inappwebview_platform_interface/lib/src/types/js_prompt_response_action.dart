import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'js_prompt_response.dart';

part 'js_prompt_response_action.g.dart';

///Class used by [JsPromptResponse] class.
@ExchangeableEnum()
class JsPromptResponseAction_ {
  // ignore: unused_field
  final int _value;
  const JsPromptResponseAction_._internal(this._value);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = const JsPromptResponseAction_._internal(0);

  ///Confirm that the user hit cancel button.
  static const CANCEL = const JsPromptResponseAction_._internal(1);
}
