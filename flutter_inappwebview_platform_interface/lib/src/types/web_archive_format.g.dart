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
