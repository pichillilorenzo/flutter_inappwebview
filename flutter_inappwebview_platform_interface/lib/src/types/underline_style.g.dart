// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'underline_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the constants for the underline style and strikethrough style attribute keys.
class UnderlineStyle {
  final int _value;
  final int _nativeValue;
  const UnderlineStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory UnderlineStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      UnderlineStyle._internal(value, nativeValue());

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = UnderlineStyle._internal(32768, 32768);

  ///Draw a double line.
  static const DOUBLE = UnderlineStyle._internal(9, 9);

  ///Draw a line of dashes.
  static const PATTERN_DASH = UnderlineStyle._internal(512, 512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = UnderlineStyle._internal(768, 768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = UnderlineStyle._internal(1024, 1024);

  ///Draw a line of dots.
  static const PATTERN_DOT = UnderlineStyle._internal(256, 256);

  ///Draw a single line.
  static const SINGLE = UnderlineStyle._internal(1, 1);

  ///Do not draw a line.
  static const STYLE_NONE = UnderlineStyle._internal(0, 0);

  ///Draw a thick line.
  static const THICK = UnderlineStyle._internal(2, 2);

  ///Set of all values of [UnderlineStyle].
  static final Set<UnderlineStyle> values = [
    UnderlineStyle.BY_WORD,
    UnderlineStyle.DOUBLE,
    UnderlineStyle.PATTERN_DASH,
    UnderlineStyle.PATTERN_DASH_DOT,
    UnderlineStyle.PATTERN_DASH_DOT_DOT,
    UnderlineStyle.PATTERN_DOT,
    UnderlineStyle.SINGLE,
    UnderlineStyle.STYLE_NONE,
    UnderlineStyle.THICK,
  ].toSet();

  ///Gets a possible [UnderlineStyle] instance from [int] value.
  static UnderlineStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return UnderlineStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [UnderlineStyle] instance from a native value.
  static UnderlineStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return UnderlineStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [UnderlineStyle] instance value with name [name].
  ///
  /// Goes through [UnderlineStyle.values] looking for a value with
  /// name [name], as reported by [UnderlineStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static UnderlineStyle? byName(String? name) {
    if (name != null) {
      try {
        return UnderlineStyle.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [UnderlineStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, UnderlineStyle> asNameMap() => <String, UnderlineStyle>{
        for (final value in UnderlineStyle.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 32768:
        return 'BY_WORD';
      case 9:
        return 'DOUBLE';
      case 512:
        return 'PATTERN_DASH';
      case 768:
        return 'PATTERN_DASH_DOT';
      case 1024:
        return 'PATTERN_DASH_DOT_DOT';
      case 256:
        return 'PATTERN_DOT';
      case 1:
        return 'SINGLE';
      case 0:
        return 'STYLE_NONE';
      case 2:
        return 'THICK';
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
    return name();
  }
}

///An iOS-specific Class that represents the constants for the underline style and strikethrough style attribute keys.
///Use [UnderlineStyle] instead.
@Deprecated('Use UnderlineStyle instead')
class IOSNSUnderlineStyle {
  final int _value;
  final int _nativeValue;
  const IOSNSUnderlineStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSNSUnderlineStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSNSUnderlineStyle._internal(value, nativeValue());

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = IOSNSUnderlineStyle._internal(32768, 32768);

  ///Draw a double line.
  static const DOUBLE = IOSNSUnderlineStyle._internal(9, 9);

  ///Draw a line of dashes.
  static const PATTERN_DASH = IOSNSUnderlineStyle._internal(512, 512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = IOSNSUnderlineStyle._internal(768, 768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = IOSNSUnderlineStyle._internal(1024, 1024);

  ///Draw a line of dots.
  static const PATTERN_DOT = IOSNSUnderlineStyle._internal(256, 256);

  ///Draw a single line.
  static const SINGLE = IOSNSUnderlineStyle._internal(1, 1);

  ///Do not draw a line.
  static const STYLE_NONE = IOSNSUnderlineStyle._internal(0, 0);

  ///Draw a thick line.
  static const THICK = IOSNSUnderlineStyle._internal(2, 2);

  ///Set of all values of [IOSNSUnderlineStyle].
  static final Set<IOSNSUnderlineStyle> values = [
    IOSNSUnderlineStyle.BY_WORD,
    IOSNSUnderlineStyle.DOUBLE,
    IOSNSUnderlineStyle.PATTERN_DASH,
    IOSNSUnderlineStyle.PATTERN_DASH_DOT,
    IOSNSUnderlineStyle.PATTERN_DASH_DOT_DOT,
    IOSNSUnderlineStyle.PATTERN_DOT,
    IOSNSUnderlineStyle.SINGLE,
    IOSNSUnderlineStyle.STYLE_NONE,
    IOSNSUnderlineStyle.THICK,
  ].toSet();

  ///Gets a possible [IOSNSUnderlineStyle] instance from [int] value.
  static IOSNSUnderlineStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSNSUnderlineStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSNSUnderlineStyle] instance from a native value.
  static IOSNSUnderlineStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSNSUnderlineStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSNSUnderlineStyle] instance value with name [name].
  ///
  /// Goes through [IOSNSUnderlineStyle.values] looking for a value with
  /// name [name], as reported by [IOSNSUnderlineStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSNSUnderlineStyle? byName(String? name) {
    if (name != null) {
      try {
        return IOSNSUnderlineStyle.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSNSUnderlineStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSNSUnderlineStyle> asNameMap() =>
      <String, IOSNSUnderlineStyle>{
        for (final value in IOSNSUnderlineStyle.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 32768:
        return 'BY_WORD';
      case 9:
        return 'DOUBLE';
      case 512:
        return 'PATTERN_DASH';
      case 768:
        return 'PATTERN_DASH_DOT';
      case 1024:
        return 'PATTERN_DASH_DOT_DOT';
      case 256:
        return 'PATTERN_DOT';
      case 1:
        return 'SINGLE';
      case 0:
        return 'STYLE_NONE';
      case 2:
        return 'THICK';
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
    return name();
  }
}
