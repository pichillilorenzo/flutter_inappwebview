// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dismiss_button_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to set the custom style for the dismiss button.
class DismissButtonStyle {
  final int _value;
  final int _nativeValue;
  const DismissButtonStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory DismissButtonStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      DismissButtonStyle._internal(value, nativeValue());

  ///Makes the button title the localized string "Cancel".
  static const CANCEL = DismissButtonStyle._internal(2, 2);

  ///Makes the button title the localized string "Close".
  static const CLOSE = DismissButtonStyle._internal(1, 1);

  ///Makes the button title the localized string "Done".
  static const DONE = DismissButtonStyle._internal(0, 0);

  ///Set of all values of [DismissButtonStyle].
  static final Set<DismissButtonStyle> values = [
    DismissButtonStyle.CANCEL,
    DismissButtonStyle.CLOSE,
    DismissButtonStyle.DONE,
  ].toSet();

  ///Gets a possible [DismissButtonStyle] instance from [int] value.
  static DismissButtonStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return DismissButtonStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [DismissButtonStyle] instance from a native value.
  static DismissButtonStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return DismissButtonStyle.values
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
      case 2:
        return 'CANCEL';
      case 1:
        return 'CLOSE';
      case 0:
        return 'DONE';
    }
    return _value.toString();
  }
}

///An iOS-specific class used to set the custom style for the dismiss button.
///
///**NOTE**: available on iOS 11.0+.
///
///Use [DismissButtonStyle] instead.
@Deprecated('Use DismissButtonStyle instead')
class IOSSafariDismissButtonStyle {
  final int _value;
  final int _nativeValue;
  const IOSSafariDismissButtonStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSSafariDismissButtonStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSSafariDismissButtonStyle._internal(value, nativeValue());

  ///Makes the button title the localized string "Cancel".
  static const CANCEL = IOSSafariDismissButtonStyle._internal(2, 2);

  ///Makes the button title the localized string "Close".
  static const CLOSE = IOSSafariDismissButtonStyle._internal(1, 1);

  ///Makes the button title the localized string "Done".
  static const DONE = IOSSafariDismissButtonStyle._internal(0, 0);

  ///Set of all values of [IOSSafariDismissButtonStyle].
  static final Set<IOSSafariDismissButtonStyle> values = [
    IOSSafariDismissButtonStyle.CANCEL,
    IOSSafariDismissButtonStyle.CLOSE,
    IOSSafariDismissButtonStyle.DONE,
  ].toSet();

  ///Gets a possible [IOSSafariDismissButtonStyle] instance from [int] value.
  static IOSSafariDismissButtonStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSSafariDismissButtonStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSSafariDismissButtonStyle] instance from a native value.
  static IOSSafariDismissButtonStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSSafariDismissButtonStyle.values
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
      case 2:
        return 'CANCEL';
      case 1:
        return 'CLOSE';
      case 0:
        return 'DONE';
    }
    return _value.toString();
  }
}
