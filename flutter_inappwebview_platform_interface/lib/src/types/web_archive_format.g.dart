// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_archive_format.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the known Web Archive formats used when saving a web page.
class WebArchiveFormat {
  final String _value;
  final String _nativeValue;
  const WebArchiveFormat._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WebArchiveFormat._internalMultiPlatform(
          String value, Function nativeValue) =>
      WebArchiveFormat._internal(value, nativeValue());

  ///Web Archive format used only by Android.
  static const MHT = WebArchiveFormat._internal('mht', 'mht');

  ///Web Archive format used only by iOS.
  static const WEBARCHIVE =
      WebArchiveFormat._internal('webarchive', 'webarchive');

  ///Set of all values of [WebArchiveFormat].
  static final Set<WebArchiveFormat> values = [
    WebArchiveFormat.MHT,
    WebArchiveFormat.WEBARCHIVE,
  ].toSet();

  ///Gets a possible [WebArchiveFormat] instance from [String] value.
  static WebArchiveFormat? fromValue(String? value) {
    if (value != null) {
      try {
        return WebArchiveFormat.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebArchiveFormat] instance from a native value.
  static WebArchiveFormat? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WebArchiveFormat.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebArchiveFormat] instance value with name [name].
  ///
  /// Goes through [WebArchiveFormat.values] looking for a value with
  /// name [name], as reported by [WebArchiveFormat.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebArchiveFormat? byName(String? name) {
    if (name != null) {
      try {
        return WebArchiveFormat.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebArchiveFormat] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebArchiveFormat> asNameMap() =>
      <String, WebArchiveFormat>{
        for (final value in WebArchiveFormat.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'mht':
        return 'MHT';
      case 'webarchive':
        return 'WEBARCHIVE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

  @override
  String toString() {
    return _value;
  }
}
