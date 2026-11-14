import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

part 'scrollview_deceleration_rate.g.dart';

///Class that represents a floating-point value that determines the rate of deceleration after the user lifts their finger.
@ExchangeableEnum()
class ScrollViewDecelerationRate_ {
  // ignore: unused_field
  final String _value;
  const ScrollViewDecelerationRate_._internal(this._value);

  ///The default deceleration rate for a scroll view: `0.998`.
  static const NORMAL = ScrollViewDecelerationRate_._internal("NORMAL");

  ///A fast deceleration rate for a scroll view: `0.99`.
  static const FAST = ScrollViewDecelerationRate_._internal("FAST");
}

///Class that represents a floating-point value that determines the rate of deceleration after the user lifts their finger.
///Use [ScrollViewDecelerationRate] instead.
@Deprecated("Use ScrollViewDecelerationRate instead")
@ExchangeableEnum()
class IOSUIScrollViewDecelerationRate_ {
  // ignore: unused_field
  final String _value;
  const IOSUIScrollViewDecelerationRate_._internal(this._value);

  ///The default deceleration rate for a scroll view: `0.998`.
  static const NORMAL = IOSUIScrollViewDecelerationRate_._internal(
    "NORMAL",
  );

  ///A fast deceleration rate for a scroll view: `0.99`.
  static const FAST = IOSUIScrollViewDecelerationRate_._internal("FAST");
}
