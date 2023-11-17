import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'ajax_request.dart';

part 'ajax_request_action.g.dart';

///Class used by [AjaxRequest] class.
@ExchangeableEnum()
class AjaxRequestAction_ {
  // ignore: unused_field
  final int _value;
  const AjaxRequestAction_._internal(this._value);

  ///Aborts the current [AjaxRequest].
  static const ABORT = const AjaxRequestAction_._internal(0);

  ///Proceeds with the current [AjaxRequest].
  static const PROCEED = const AjaxRequestAction_._internal(1);
}
