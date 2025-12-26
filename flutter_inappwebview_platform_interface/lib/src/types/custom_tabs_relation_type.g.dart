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
  ///- Android WebView
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
  ///- Android WebView
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

  /// Gets a possible [CustomTabsRelationType] instance value with name [name].
  ///
  /// Goes through [CustomTabsRelationType.values] looking for a value with
  /// name [name], as reported by [CustomTabsRelationType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static CustomTabsRelationType? byName(String? name) {
    if (name != null) {
      try {
        return CustomTabsRelationType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [CustomTabsRelationType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, CustomTabsRelationType> asNameMap() =>
      <String, CustomTabsRelationType>{
        for (final value in CustomTabsRelationType.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 2:
        return 'HANDLE_ALL_URLS';
      case 1:
        return 'USE_AS_ORIGIN';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return toNativeValue() != null;
  }

  @override
  String toString() {
    return name();
  }
}
