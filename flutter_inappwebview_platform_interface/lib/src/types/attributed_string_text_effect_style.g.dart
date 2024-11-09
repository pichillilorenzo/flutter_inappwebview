// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attributed_string_text_effect_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the supported proxy types.
class AttributedStringTextEffectStyle {
  final String _value;
  final String _nativeValue;
  const AttributedStringTextEffectStyle._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory AttributedStringTextEffectStyle._internalMultiPlatform(
          String value, Function nativeValue) =>
      AttributedStringTextEffectStyle._internal(value, nativeValue());

  ///A graphical text effect that gives glyphs the appearance of letterpress printing, which involves pressing the type into the paper.
  static const LETTERPRESS_STYLE = AttributedStringTextEffectStyle._internal(
      'letterpressStyle', 'letterpressStyle');

  ///Set of all values of [AttributedStringTextEffectStyle].
  static final Set<AttributedStringTextEffectStyle> values = [
    AttributedStringTextEffectStyle.LETTERPRESS_STYLE,
  ].toSet();

  ///Gets a possible [AttributedStringTextEffectStyle] instance from [String] value.
  static AttributedStringTextEffectStyle? fromValue(String? value) {
    if (value != null) {
      try {
        return AttributedStringTextEffectStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AttributedStringTextEffectStyle] instance from a native value.
  static AttributedStringTextEffectStyle? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return AttributedStringTextEffectStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AttributedStringTextEffectStyle] instance value with name [name].
  ///
  /// Goes through [AttributedStringTextEffectStyle.values] looking for a value with
  /// name [name], as reported by [AttributedStringTextEffectStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AttributedStringTextEffectStyle? byName(String? name) {
    if (name != null) {
      try {
        return AttributedStringTextEffectStyle.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AttributedStringTextEffectStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AttributedStringTextEffectStyle> asNameMap() =>
      <String, AttributedStringTextEffectStyle>{
        for (final value in AttributedStringTextEffectStyle.values)
          value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'letterpressStyle':
        return 'LETTERPRESS_STYLE';
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

///An iOS-specific Class that represents the supported proxy types.
///Use [AttributedStringTextEffectStyle] instead.
@Deprecated('Use AttributedStringTextEffectStyle instead')
class IOSNSAttributedStringTextEffectStyle {
  final String _value;
  final String _nativeValue;
  const IOSNSAttributedStringTextEffectStyle._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory IOSNSAttributedStringTextEffectStyle._internalMultiPlatform(
          String value, Function nativeValue) =>
      IOSNSAttributedStringTextEffectStyle._internal(value, nativeValue());

  ///A graphical text effect that gives glyphs the appearance of letterpress printing, which involves pressing the type into the paper.
  static const LETTERPRESS_STYLE =
      IOSNSAttributedStringTextEffectStyle._internal(
          'letterpressStyle', 'letterpressStyle');

  ///Set of all values of [IOSNSAttributedStringTextEffectStyle].
  static final Set<IOSNSAttributedStringTextEffectStyle> values = [
    IOSNSAttributedStringTextEffectStyle.LETTERPRESS_STYLE,
  ].toSet();

  ///Gets a possible [IOSNSAttributedStringTextEffectStyle] instance from [String] value.
  static IOSNSAttributedStringTextEffectStyle? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSNSAttributedStringTextEffectStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSNSAttributedStringTextEffectStyle] instance from a native value.
  static IOSNSAttributedStringTextEffectStyle? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return IOSNSAttributedStringTextEffectStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSNSAttributedStringTextEffectStyle] instance value with name [name].
  ///
  /// Goes through [IOSNSAttributedStringTextEffectStyle.values] looking for a value with
  /// name [name], as reported by [IOSNSAttributedStringTextEffectStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSNSAttributedStringTextEffectStyle? byName(String? name) {
    if (name != null) {
      try {
        return IOSNSAttributedStringTextEffectStyle.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSNSAttributedStringTextEffectStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSNSAttributedStringTextEffectStyle> asNameMap() =>
      <String, IOSNSAttributedStringTextEffectStyle>{
        for (final value in IOSNSAttributedStringTextEffectStyle.values)
          value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'letterpressStyle':
        return 'LETTERPRESS_STYLE';
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
