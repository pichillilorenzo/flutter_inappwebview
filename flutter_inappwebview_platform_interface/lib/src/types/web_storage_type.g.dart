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
