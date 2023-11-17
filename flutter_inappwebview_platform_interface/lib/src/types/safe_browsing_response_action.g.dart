// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_browsing_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [SafeBrowsingResponse] class.
class SafeBrowsingResponseAction {
  final int _value;
  final int _nativeValue;
  const SafeBrowsingResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory SafeBrowsingResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      SafeBrowsingResponseAction._internal(value, nativeValue());

  ///Act as if the user clicked the "back to safety" button.
  static const BACK_TO_SAFETY = SafeBrowsingResponseAction._internal(0, 0);

  ///Act as if the user clicked the "visit this unsafe site" button.
  static const PROCEED = SafeBrowsingResponseAction._internal(1, 1);

  ///Display the default interstitial.
  static const SHOW_INTERSTITIAL = SafeBrowsingResponseAction._internal(2, 2);

  ///Set of all values of [SafeBrowsingResponseAction].
  static final Set<SafeBrowsingResponseAction> values = [
    SafeBrowsingResponseAction.BACK_TO_SAFETY,
    SafeBrowsingResponseAction.PROCEED,
    SafeBrowsingResponseAction.SHOW_INTERSTITIAL,
  ].toSet();

  ///Gets a possible [SafeBrowsingResponseAction] instance from [int] value.
  static SafeBrowsingResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return SafeBrowsingResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [SafeBrowsingResponseAction] instance from a native value.
  static SafeBrowsingResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return SafeBrowsingResponseAction.values
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
        return 'BACK_TO_SAFETY';
      case 1:
        return 'PROCEED';
      case 2:
        return 'SHOW_INTERSTITIAL';
    }
    return _value.toString();
  }
}
