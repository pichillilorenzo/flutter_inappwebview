// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferred_content_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the content mode to prefer when loading and rendering a webpage.
class UserPreferredContentMode {
  final int _value;
  final int _nativeValue;
  const UserPreferredContentMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory UserPreferredContentMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      UserPreferredContentMode._internal(value, nativeValue());

  ///Represents content targeting desktop browsers.
  static const DESKTOP = UserPreferredContentMode._internal(2, 2);

  ///Represents content targeting mobile browsers.
  static const MOBILE = UserPreferredContentMode._internal(1, 1);

  ///The recommended content mode for the current platform.
  static const RECOMMENDED = UserPreferredContentMode._internal(0, 0);

  ///Set of all values of [UserPreferredContentMode].
  static final Set<UserPreferredContentMode> values = [
    UserPreferredContentMode.DESKTOP,
    UserPreferredContentMode.MOBILE,
    UserPreferredContentMode.RECOMMENDED,
  ].toSet();

  ///Gets a possible [UserPreferredContentMode] instance from [int] value.
  static UserPreferredContentMode? fromValue(int? value) {
    if (value != null) {
      try {
        return UserPreferredContentMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [UserPreferredContentMode] instance from a native value.
  static UserPreferredContentMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return UserPreferredContentMode.values
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
        return 'DESKTOP';
      case 1:
        return 'MOBILE';
      case 0:
        return 'RECOMMENDED';
    }
    return _value.toString();
  }
}
