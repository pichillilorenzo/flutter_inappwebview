// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_tabs_relation_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Custom Tabs relation for which the result is available.
class CustomTabsRelationType {
  final int _value;
  final int? _nativeValue;
  const CustomTabsRelationType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory CustomTabsRelationType._internalMultiPlatform(
          int value, Function nativeValue) =>
      CustomTabsRelationType._internal(value, nativeValue());

  ///Requests the ability to handle all URLs from a given origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final HANDLE_ALL_URLS =
      CustomTabsRelationType._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///For App -> Web transitions, requests the app to use the declared origin to be used as origin for the client app in the web APIs context.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final USE_AS_ORIGIN =
      CustomTabsRelationType._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [CustomTabsRelationType].
  static final Set<CustomTabsRelationType> values = [
    CustomTabsRelationType.HANDLE_ALL_URLS,
    CustomTabsRelationType.USE_AS_ORIGIN,
  ].toSet();

  ///Gets a possible [CustomTabsRelationType] instance from [int] value.
  static CustomTabsRelationType? fromValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsRelationType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CustomTabsRelationType] instance from a native value.
  static CustomTabsRelationType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsRelationType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int?] native value.
  int? toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 2:
        return 'HANDLE_ALL_URLS';
      case 1:
        return 'USE_AS_ORIGIN';
    }
    return _value.toString();
  }
}
