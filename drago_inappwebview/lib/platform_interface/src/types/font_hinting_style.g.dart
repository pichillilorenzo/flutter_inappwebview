// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_hinting_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Font hinting style used for text rendering on Linux.
class FontHintingStyle {
  final int _value;
  final int? _nativeValue;
  const FontHintingStyle._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory FontHintingStyle._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => FontHintingStyle._internal(value, nativeValue());

  ///Full hinting. Maximum hinting is applied for crispest text.
  static const FULL = FontHintingStyle._internal(3, 3);

  ///Medium hinting. A moderate amount of hinting is applied.
  static const MEDIUM = FontHintingStyle._internal(2, 2);

  ///No hinting. Text is rendered without any hinting.
  static const NONE = FontHintingStyle._internal(0, 0);

  ///Slight hinting. A minimal amount of hinting is applied.
  static const SLIGHT = FontHintingStyle._internal(1, 1);

  ///Set of all values of [FontHintingStyle].
  static final Set<FontHintingStyle> values = [
    FontHintingStyle.FULL,
    FontHintingStyle.MEDIUM,
    FontHintingStyle.NONE,
    FontHintingStyle.SLIGHT,
  ].toSet();

  ///Gets a possible [FontHintingStyle] instance from [int] value.
  static FontHintingStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return FontHintingStyle.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [FontHintingStyle] instance from a native value.
  static FontHintingStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return FontHintingStyle.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [FontHintingStyle] instance value with name [name].
  ///
  /// Goes through [FontHintingStyle.values] looking for a value with
  /// name [name], as reported by [FontHintingStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static FontHintingStyle? byName(String? name) {
    if (name != null) {
      try {
        return FontHintingStyle.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [FontHintingStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, FontHintingStyle> asNameMap() =>
      <String, FontHintingStyle>{
        for (final value in FontHintingStyle.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 3:
        return 'FULL';
      case 2:
        return 'MEDIUM';
      case 0:
        return 'NONE';
      case 1:
        return 'SLIGHT';
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
