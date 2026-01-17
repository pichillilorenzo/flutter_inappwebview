// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferred_color_scheme.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate the preferred color scheme for the WebView.
class PreferredColorScheme {
  final int _value;
  final int _nativeValue;
  const PreferredColorScheme._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PreferredColorScheme._internalMultiPlatform(
          int value, Function nativeValue) =>
      PreferredColorScheme._internal(value, nativeValue());

  ///Automatically match the system color scheme.
  static const AUTO = PreferredColorScheme._internal(0, 0);

  ///Dark color scheme.
  static const DARK = PreferredColorScheme._internal(2, 2);

  ///Light color scheme.
  static const LIGHT = PreferredColorScheme._internal(1, 1);

  ///Set of all values of [PreferredColorScheme].
  static final Set<PreferredColorScheme> values = [
    PreferredColorScheme.AUTO,
    PreferredColorScheme.DARK,
    PreferredColorScheme.LIGHT,
  ].toSet();

  ///Gets a possible [PreferredColorScheme] instance from [int] value.
  static PreferredColorScheme? fromValue(int? value) {
    if (value != null) {
      try {
        return PreferredColorScheme.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PreferredColorScheme] instance from a native value.
  static PreferredColorScheme? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PreferredColorScheme.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [PreferredColorScheme] instance value with name [name].
  ///
  /// Goes through [PreferredColorScheme.values] looking for a value with
  /// name [name], as reported by [PreferredColorScheme.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PreferredColorScheme? byName(String? name) {
    if (name != null) {
      try {
        return PreferredColorScheme.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PreferredColorScheme] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PreferredColorScheme> asNameMap() =>
      <String, PreferredColorScheme>{
        for (final value in PreferredColorScheme.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 2:
        return 'AUTO';
      case 1:
        return 'DARK';
      case 0:
        return 'LIGHT';
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
