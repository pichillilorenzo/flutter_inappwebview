// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_tabs_share_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the share state that should be applied to the custom tab.
class CustomTabsShareState {
  final int _value;
  final int _nativeValue;
  const CustomTabsShareState._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory CustomTabsShareState._internalMultiPlatform(
          int value, Function nativeValue) =>
      CustomTabsShareState._internal(value, nativeValue());

  ///Applies the default share settings depending on the browser.
  static const SHARE_STATE_DEFAULT = CustomTabsShareState._internal(0, 0);

  ///Explicitly does not show a share option in the tab.
  static const SHARE_STATE_OFF = CustomTabsShareState._internal(2, 2);

  ///Shows a share option in the tab.
  static const SHARE_STATE_ON = CustomTabsShareState._internal(1, 1);

  ///Set of all values of [CustomTabsShareState].
  static final Set<CustomTabsShareState> values = [
    CustomTabsShareState.SHARE_STATE_DEFAULT,
    CustomTabsShareState.SHARE_STATE_OFF,
    CustomTabsShareState.SHARE_STATE_ON,
  ].toSet();

  ///Gets a possible [CustomTabsShareState] instance from [int] value.
  static CustomTabsShareState? fromValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsShareState.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CustomTabsShareState] instance from a native value.
  static CustomTabsShareState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsShareState.values
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
      case 0:
        return 'SHARE_STATE_DEFAULT';
      case 2:
        return 'SHARE_STATE_OFF';
      case 1:
        return 'SHARE_STATE_ON';
    }
    return _value.toString();
  }
}
