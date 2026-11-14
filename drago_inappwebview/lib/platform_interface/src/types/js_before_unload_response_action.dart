import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'js_before_unload_response.dart';

part 'js_before_unload_response_action.g.dart';

///Class used by [JsBeforeUnloadResponse] class.
@ExchangeableEnum()
class JsBeforeUnloadResponseAction_ {
  // ignore: unused_field
  final int _value;
  const JsBeforeUnloadResponseAction_._internal(this._value);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = JsBeforeUnloadResponseAction_._internal(0);

  ///Confirm that the user hit cancel button.
  static const CANCEL = JsBeforeUnloadResponseAction_._internal(1);
}
