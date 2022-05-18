///Class that represents a floating-point value that determines the rate of deceleration after the user lifts their finger.
class ScrollViewDecelerationRate {
  final String _value;

  const ScrollViewDecelerationRate._internal(this._value);

  ///Set of all values of [ScrollViewDecelerationRate].
  static final Set<ScrollViewDecelerationRate> values = [
    ScrollViewDecelerationRate.NORMAL,
    ScrollViewDecelerationRate.FAST,
  ].toSet();

  ///Gets a possible [ScrollViewDecelerationRate] instance from a [String] value.
  static ScrollViewDecelerationRate? fromValue(String? value) {
    if (value != null) {
      try {
        return ScrollViewDecelerationRate.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///The default deceleration rate for a scroll view: `0.998`.
  static const NORMAL = const ScrollViewDecelerationRate._internal("NORMAL");

  ///A fast deceleration rate for a scroll view: `0.99`.
  static const FAST = const ScrollViewDecelerationRate._internal("FAST");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents a floating-point value that determines the rate of deceleration after the user lifts their finger.
///Use [ScrollViewDecelerationRate] instead.
@Deprecated("Use ScrollViewDecelerationRate instead")
class IOSUIScrollViewDecelerationRate {
  final String _value;

  const IOSUIScrollViewDecelerationRate._internal(this._value);

  ///Set of all values of [IOSUIScrollViewDecelerationRate].
  static final Set<IOSUIScrollViewDecelerationRate> values = [
    IOSUIScrollViewDecelerationRate.NORMAL,
    IOSUIScrollViewDecelerationRate.FAST,
  ].toSet();

  ///Gets a possible [IOSUIScrollViewDecelerationRate] instance from a [String] value.
  static IOSUIScrollViewDecelerationRate? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSUIScrollViewDecelerationRate.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///The default deceleration rate for a scroll view: `0.998`.
  static const NORMAL =
  const IOSUIScrollViewDecelerationRate._internal("NORMAL");

  ///A fast deceleration rate for a scroll view: `0.99`.
  static const FAST = const IOSUIScrollViewDecelerationRate._internal("FAST");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}