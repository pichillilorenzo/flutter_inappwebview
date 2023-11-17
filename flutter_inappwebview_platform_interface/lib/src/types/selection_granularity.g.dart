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

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'CHARACTER';
      case 0:
        return 'DYNAMIC';
    }
    return _value.toString();
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

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'CHARACTER';
      case 0:
        return 'DYNAMIC';
    }
    return _value.toString();
  }
}
