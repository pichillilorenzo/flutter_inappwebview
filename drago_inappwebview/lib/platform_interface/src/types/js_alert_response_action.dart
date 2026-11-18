import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'js_alert_response.dart';

part 'js_alert_response_action.g.dart';

///Class used by [JsAlertResponse] class.
@ExchangeableEnum()
class JsAlertResponseAction_ {
  // ignore: unused_field
  final int _value;
  const JsAlertResponseAction_._internal(this._value);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = JsAlertResponseAction_._internal(0);
}
