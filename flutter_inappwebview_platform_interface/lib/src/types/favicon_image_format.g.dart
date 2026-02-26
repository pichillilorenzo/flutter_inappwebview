// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favicon_image_format.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the favicon image format.
class FaviconImageFormat {
  final int _value;
  final int? _nativeValue;
  const FaviconImageFormat._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory FaviconImageFormat._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => FaviconImageFormat._internal(value, nativeValue());

  ///JPEG image format.
  static const JPEG = FaviconImageFormat._internal(1, 1);

  ///PNG image format.
  static const PNG = FaviconImageFormat._internal(0, 0);

  ///Set of all values of [FaviconImageFormat].
  static final Set<FaviconImageFormat> values = [
    FaviconImageFormat.JPEG,
    FaviconImageFormat.PNG,
  ].toSet();

  ///Gets a possible [FaviconImageFormat] instance from [int] value.
  static FaviconImageFormat? fromValue(int? value) {
    if (value != null) {
      try {
        return FaviconImageFormat.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [FaviconImageFormat] instance from a native value.
  static FaviconImageFormat? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return FaviconImageFormat.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [FaviconImageFormat] instance value with name [name].
  ///
  /// Goes through [FaviconImageFormat.values] looking for a value with
  /// name [name], as reported by [FaviconImageFormat.name].
  /// Returns the first value with the given name, otherwise `null`.
  static FaviconImageFormat? byName(String? name) {
    if (name != null) {
      try {
        return FaviconImageFormat.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [FaviconImageFormat] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, FaviconImageFormat> asNameMap() =>
      <String, FaviconImageFormat>{
        for (final value in FaviconImageFormat.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'JPEG';
      case 0:
        return 'PNG';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
