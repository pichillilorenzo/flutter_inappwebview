// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrollview_deceleration_rate.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents a floating-point value that determines the rate of deceleration after the user lifts their finger.
class ScrollViewDecelerationRate {
  final String _value;
  final String _nativeValue;
  const ScrollViewDecelerationRate._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ScrollViewDecelerationRate._internalMultiPlatform(
          String value, Function nativeValue) =>
      ScrollViewDecelerationRate._internal(value, nativeValue());

  ///A fast deceleration rate for a scroll view: `0.99`.
  static const FAST = ScrollViewDecelerationRate._internal('FAST', 'FAST');

  ///The default deceleration rate for a scroll view: `0.998`.
  static const NORMAL =
      ScrollViewDecelerationRate._internal('NORMAL', 'NORMAL');

  ///Set of all values of [ScrollViewDecelerationRate].
  static final Set<ScrollViewDecelerationRate> values = [
    ScrollViewDecelerationRate.FAST,
    ScrollViewDecelerationRate.NORMAL,
  ].toSet();

  ///Gets a possible [ScrollViewDecelerationRate] instance from [String] value.
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

  ///Gets a possible [ScrollViewDecelerationRate] instance from a native value.
  static ScrollViewDecelerationRate? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ScrollViewDecelerationRate.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}

///Class that represents a floating-point value that determines the rate of deceleration after the user lifts their finger.
///Use [ScrollViewDecelerationRate] instead.
@Deprecated('Use ScrollViewDecelerationRate instead')
class IOSUIScrollViewDecelerationRate {
  final String _value;
  final String _nativeValue;
  const IOSUIScrollViewDecelerationRate._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory IOSUIScrollViewDecelerationRate._internalMultiPlatform(
          String value, Function nativeValue) =>
      IOSUIScrollViewDecelerationRate._internal(value, nativeValue());

  ///A fast deceleration rate for a scroll view: `0.99`.
  static const FAST = IOSUIScrollViewDecelerationRate._internal('FAST', 'FAST');

  ///The default deceleration rate for a scroll view: `0.998`.
  static const NORMAL =
      IOSUIScrollViewDecelerationRate._internal('NORMAL', 'NORMAL');

  ///Set of all values of [IOSUIScrollViewDecelerationRate].
  static final Set<IOSUIScrollViewDecelerationRate> values = [
    IOSUIScrollViewDecelerationRate.FAST,
    IOSUIScrollViewDecelerationRate.NORMAL,
  ].toSet();

  ///Gets a possible [IOSUIScrollViewDecelerationRate] instance from [String] value.
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

  ///Gets a possible [IOSUIScrollViewDecelerationRate] instance from a native value.
  static IOSUIScrollViewDecelerationRate? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return IOSUIScrollViewDecelerationRate.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
