import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'js_confirm_response.dart';

part 'js_confirm_response_action.g.dart';

///Class used by [JsConfirmResponse] class.
@ExchangeableEnum()
class JsConfirmResponseAction_ {
  // ignore: unused_field
  final int _value;
  const JsConfirmResponseAction_._internal(this._value);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = const JsConfirmResponseAction_._internal(0);

  ///Confirm that the user hit cancel button.
  static const CANCEL = const JsConfirmResponseAction_._internal(1);
}
