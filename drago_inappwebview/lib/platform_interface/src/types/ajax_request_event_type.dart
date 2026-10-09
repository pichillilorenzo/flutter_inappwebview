import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'ajax_request_event.dart';

part 'ajax_request_event_type.g.dart';

///Class used by [AjaxRequestEvent] class.
@ExchangeableEnum()
class AjaxRequestEventType_ {
  // ignore: unused_field
  final String _value;
  const AjaxRequestEventType_._internal(this._value);

  ///The LOADSTART event is fired when a request has started to load data.
  static const LOADSTART = AjaxRequestEventType_._internal("loadstart");

  ///The LOAD event is fired when an `XMLHttpRequest` transaction completes successfully.
  static const LOAD = AjaxRequestEventType_._internal("load");

  ///The LOADEND event is fired when a request has completed, whether successfully (after [AjaxRequestEventType.LOAD]) or
  ///unsuccessfully (after [AjaxRequestEventType.ABORT] or [AjaxRequestEventType.ERROR]).
  static const LOADEND = AjaxRequestEventType_._internal("loadend");

  ///The PROGRESS event is fired periodically when a request receives more data.
  static const PROGRESS = AjaxRequestEventType_._internal("progress");

  ///The ERROR event is fired when the request encountered an error.
  static const ERROR = AjaxRequestEventType_._internal("error");

  ///The ABORT event is fired when a request has been aborted.
  static const ABORT = AjaxRequestEventType_._internal("abort");

  ///The TIMEOUT event is fired when progression is terminated due to preset time expiring.
  static const TIMEOUT = AjaxRequestEventType_._internal("timeout");
}
