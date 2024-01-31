// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compress_format.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the known formats a bitmap can be compressed into.
class CompressFormat {
  final String _value;
  final String _nativeValue;
  const CompressFormat._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory CompressFormat._internalMultiPlatform(
          String value, Function nativeValue) =>
      CompressFormat._internal(value, nativeValue());

  ///Compress to the `JPEG` format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  static const JPEG = CompressFormat._internal('JPEG', 'JPEG');

  ///Compress to the `PNG` format.
  ///PNG is lossless, so `quality` is ignored.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  static const PNG = CompressFormat._internal('PNG', 'PNG');

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- Windows
  static const WEBP = CompressFormat._internal('WEBP', 'WEBP');

  ///Compress to the `WEBP` lossless format.
  ///Quality refers to how much effort to put into compression.
  ///A value of `0` means to compress quickly, resulting in a relatively large file size.
  ///`100` means to spend more time compressing, resulting in a smaller file.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView 30+
  static const WEBP_LOSSLESS =
      CompressFormat._internal('WEBP_LOSSLESS', 'WEBP_LOSSLESS');

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView 30+
  static const WEBP_LOSSY =
      CompressFormat._internal('WEBP_LOSSY', 'WEBP_LOSSY');

  ///Set of all values of [CompressFormat].
  static final Set<CompressFormat> values = [
    CompressFormat.JPEG,
    CompressFormat.PNG,
    CompressFormat.WEBP,
    CompressFormat.WEBP_LOSSLESS,
    CompressFormat.WEBP_LOSSY,
  ].toSet();

  ///Gets a possible [CompressFormat] instance from [String] value.
  static CompressFormat? fromValue(String? value) {
    if (value != null) {
      try {
        return CompressFormat.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CompressFormat] instance from a native value.
  static CompressFormat? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return CompressFormat.values
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
