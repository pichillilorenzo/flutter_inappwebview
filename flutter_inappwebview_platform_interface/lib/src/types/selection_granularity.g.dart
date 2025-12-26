// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_granularity.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to set the level of granularity with which the user can interactively select content in the web view.
class SelectionGranularity {
  final int _value;
  final int _nativeValue;
  const SelectionGranularity._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory SelectionGranularity._internalMultiPlatform(
          int value, Function nativeValue) =>
      SelectionGranularity._internal(value, nativeValue());

  ///Selection endpoints can be placed at any character boundary.
  static const CHARACTER = SelectionGranularity._internal(1, 1);

  ///Selection granularity varies automatically based on the selection.
  static const DYNAMIC = SelectionGranularity._internal(0, 0);

  ///Set of all values of [SelectionGranularity].
  static final Set<SelectionGranularity> values = [
    SelectionGranularity.CHARACTER,
    SelectionGranularity.DYNAMIC,
  ].toSet();

  ///Gets a possible [SelectionGranularity] instance from [int] value.
  static SelectionGranularity? fromValue(int? value) {
    if (value != null) {
      try {
        return SelectionGranularity.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [SelectionGranularity] instance from a native value.
  static SelectionGranularity? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return SelectionGranularity.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [SelectionGranularity] instance value with name [name].
  ///
  /// Goes through [SelectionGranularity.values] looking for a value with
  /// name [name], as reported by [SelectionGranularity.name].
  /// Returns the first value with the given name, otherwise `null`.
  static SelectionGranularity? byName(String? name) {
    if (name != null) {
      try {
        return SelectionGranularity.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [SelectionGranularity] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, SelectionGranularity> asNameMap() =>
      <String, SelectionGranularity>{
        for (final value in SelectionGranularity.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'CHARACTER';
      case 0:
        return 'DYNAMIC';
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

///An iOS-specific class used to set the level of granularity with which the user can interactively select content in the web view.
///Use [SelectionGranularity] instead.
@Deprecated('Use SelectionGranularity instead')
class IOSWKSelectionGranularity {
  final int _value;
  final int _nativeValue;
  const IOSWKSelectionGranularity._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSWKSelectionGranularity._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSWKSelectionGranularity._internal(value, nativeValue());

  ///Selection endpoints can be placed at any character boundary.
  static const CHARACTER = IOSWKSelectionGranularity._internal(1, 1);

  ///Selection granularity varies automatically based on the selection.
  static const DYNAMIC = IOSWKSelectionGranularity._internal(0, 0);

  ///Set of all values of [IOSWKSelectionGranularity].
  static final Set<IOSWKSelectionGranularity> values = [
    IOSWKSelectionGranularity.CHARACTER,
    IOSWKSelectionGranularity.DYNAMIC,
  ].toSet();

  ///Gets a possible [IOSWKSelectionGranularity] instance from [int] value.
  static IOSWKSelectionGranularity? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSWKSelectionGranularity.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSWKSelectionGranularity] instance from a native value.
  static IOSWKSelectionGranularity? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSWKSelectionGranularity.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSWKSelectionGranularity] instance value with name [name].
  ///
  /// Goes through [IOSWKSelectionGranularity.values] looking for a value with
  /// name [name], as reported by [IOSWKSelectionGranularity.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSWKSelectionGranularity? byName(String? name) {
    if (name != null) {
      try {
        return IOSWKSelectionGranularity.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSWKSelectionGranularity] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSWKSelectionGranularity> asNameMap() =>
      <String, IOSWKSelectionGranularity>{
        for (final value in IOSWKSelectionGranularity.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'CHARACTER';
      case 0:
        return 'DYNAMIC';
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
