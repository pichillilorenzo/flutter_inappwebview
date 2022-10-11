import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'fetch_request.dart';

part 'fetch_request_action.g.dart';

///Class used by [FetchRequest] class.
@ExchangeableEnum()
class FetchRequestAction_ {
  // ignore: unused_field
  final int _value;
  const FetchRequestAction_._internal(this._value);

  ///Aborts the fetch request.
  static const ABORT = const FetchRequestAction_._internal(0);

  ///Proceeds with the fetch request.
  static const PROCEED = const FetchRequestAction_._internal(1);
}
