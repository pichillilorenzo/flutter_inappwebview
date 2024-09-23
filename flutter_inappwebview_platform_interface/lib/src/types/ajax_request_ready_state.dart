import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'ajax_request.dart';

part 'ajax_request_ready_state.g.dart';

///Class used by [AjaxRequest] class. It represents the state of an [AjaxRequest].
@ExchangeableEnum()
class AjaxRequestReadyState_ {
  // ignore: unused_field
  final int _value;
  const AjaxRequestReadyState_._internal(this._value);

  ///Client has been created. `XMLHttpRequest.open()` not called yet.
  static const UNSENT = const AjaxRequestReadyState_._internal(0);

  ///`XMLHttpRequest.open()` has been called.
  static const OPENED = const AjaxRequestReadyState_._internal(1);

  ///`XMLHttpRequest.send()` has been called, and [AjaxRequest.headers] and [AjaxRequest.status] are available.
  static const HEADERS_RECEIVED = const AjaxRequestReadyState_._internal(2);

  ///Downloading; [AjaxRequest.responseText] holds partial data.
  static const LOADING = const AjaxRequestReadyState_._internal(3);

  ///The operation is complete.
  static const DONE = const AjaxRequestReadyState_._internal(4);
}
