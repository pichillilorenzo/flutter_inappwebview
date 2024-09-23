// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_dark.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate the force dark mode.
class ForceDark {
  final int _value;
  final int _nativeValue;
  const ForceDark._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ForceDark._internalMultiPlatform(int value, Function nativeValue) =>
      ForceDark._internal(value, nativeValue());

  ///Enable force dark dependent on the state of the WebView parent view.
  static const AUTO = ForceDark._internal(1, 1);

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const OFF = ForceDark._internal(0, 0);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const ON = ForceDark._internal(2, 2);

  ///Set of all values of [ForceDark].
  static final Set<ForceDark> values = [
    ForceDark.AUTO,
    ForceDark.OFF,
    ForceDark.ON,
  ].toSet();

  ///Gets a possible [ForceDark] instance from [int] value.
  static ForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return ForceDark.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ForceDark] instance from a native value.
  static ForceDark? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ForceDark.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'AUTO';
      case 0:
        return 'OFF';
      case 2:
        return 'ON';
    }
    return _value.toString();
  }
}

///An Android-specific class used to indicate the force dark mode.
///
///**NOTE**: available on Android 29+.
///
///Use [ForceDark] instead.
@Deprecated('Use ForceDark instead')
class AndroidForceDark {
  final int _value;
  final int _nativeValue;
  const AndroidForceDark._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AndroidForceDark._internalMultiPlatform(
          int value, Function nativeValue) =>
      AndroidForceDark._internal(value, nativeValue());

  ///Enable force dark dependent on the state of the WebView parent view.
  static const FORCE_DARK_AUTO = AndroidForceDark._internal(1, 1);

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const FORCE_DARK_OFF = AndroidForceDark._internal(0, 0);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const FORCE_DARK_ON = AndroidForceDark._internal(2, 2);

  ///Set of all values of [AndroidForceDark].
  static final Set<AndroidForceDark> values = [
    AndroidForceDark.FORCE_DARK_AUTO,
    AndroidForceDark.FORCE_DARK_OFF,
    AndroidForceDark.FORCE_DARK_ON,
  ].toSet();

  ///Gets a possible [AndroidForceDark] instance from [int] value.
  static AndroidForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidForceDark.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidForceDark] instance from a native value.
  static AndroidForceDark? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidForceDark.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'FORCE_DARK_AUTO';
      case 0:
        return 'FORCE_DARK_OFF';
      case 2:
        return 'FORCE_DARK_ON';
    }
    return _value.toString();
  }
}
