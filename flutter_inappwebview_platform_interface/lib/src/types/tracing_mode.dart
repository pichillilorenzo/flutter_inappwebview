import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'tracing_mode.g.dart';

///Constants that describe the results summary the find panel UI includes.
@ExchangeableEnum()
class TracingMode_ {
  // ignore: unused_field
  final int _value;
  const TracingMode_._internal(this._value);

  ///Record trace events until the internal tracing buffer is full.
  ///Typically the buffer memory usage is larger than [RECORD_CONTINUOUSLY].
  ///Depending on the implementation typically allows up to 256k events to be stored.
  static const RECORD_UNTIL_FULL = const TracingMode_._internal(0);

  ///Record trace events continuously using an internal ring buffer.
  ///Default tracing mode.
  ///Overwrites old events if they exceed buffer capacity.
  ///Uses less memory than the [RECORD_UNTIL_FULL] mode.
  ///Depending on the implementation typically allows up to 64k events to be stored.
  static const RECORD_CONTINUOUSLY = const TracingMode_._internal(1);
}
