import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'memory_usage_target_level.g.dart';

///Constants that describe memory usage target levels.
@ExchangeableEnum()
class MemoryUsageTargetLevel_ {
  // ignore: unused_field
  final int _value;
  const MemoryUsageTargetLevel_._internal(this._value);

  ///Normal memory usage target level.
  static const NORMAL = MemoryUsageTargetLevel_._internal(0);

  ///Low memory usage target level.
  static const LOW = MemoryUsageTargetLevel_._internal(1);
}
