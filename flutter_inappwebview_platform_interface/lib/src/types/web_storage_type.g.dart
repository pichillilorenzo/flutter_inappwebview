// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_storage_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the type of Web Storage: `localStorage` or `sessionStorage`.
///Used by the [PlatformStorage] class.
class WebStorageType {
  final String _value;
  final String _nativeValue;
  const WebStorageType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WebStorageType._internalMultiPlatform(
          String value, Function nativeValue) =>
      WebStorageType._internal(value, nativeValue());

  ///`window.localStorage`: same as [SESSION_STORAGE], but persists even when the browser is closed and reopened.
  static const LOCAL_STORAGE =
      WebStorageType._internal('localStorage', 'localStorage');

  ///`window.sessionStorage`: maintains a separate storage area for each given origin that's available for the duration
  ///of the page session (as long as the browser is open, including page reloads and restores).
  static const SESSION_STORAGE =
      WebStorageType._internal('sessionStorage', 'sessionStorage');

  ///Set of all values of [WebStorageType].
  static final Set<WebStorageType> values = [
    WebStorageType.LOCAL_STORAGE,
    WebStorageType.SESSION_STORAGE,
  ].toSet();

  ///Gets a possible [WebStorageType] instance from [String] value.
  static WebStorageType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebStorageType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebStorageType] instance from a native value.
  static WebStorageType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WebStorageType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebStorageType] instance value with name [name].
  ///
  /// Goes through [WebStorageType.values] looking for a value with
  /// name [name], as reported by [WebStorageType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebStorageType? byName(String? name) {
    if (name != null) {
      try {
        return WebStorageType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebStorageType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebStorageType> asNameMap() => <String, WebStorageType>{
        for (final value in WebStorageType.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'localStorage':
        return 'LOCAL_STORAGE';
      case 'sessionStorage':
        return 'SESSION_STORAGE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
