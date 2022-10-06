// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_orientation.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the orientation of a [PrintJobController].
class PrintJobOrientation {
  final int _value;
  final int _nativeValue;
  const PrintJobOrientation._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobOrientation._internalMultiPlatform(
          int value, Function nativeValue) =>
      PrintJobOrientation._internal(value, nativeValue());

  ///Pages are printed in portrait orientation.
  static const PORTRAIT = PrintJobOrientation._internal(0, 0);

  ///Pages are printed in landscape orientation.
  static const LANDSCAPE = PrintJobOrientation._internal(1, 1);

  ///Set of all values of [PrintJobOrientation].
  static final Set<PrintJobOrientation> values = [
    PrintJobOrientation.PORTRAIT,
    PrintJobOrientation.LANDSCAPE,
  ].toSet();

  ///Gets a possible [PrintJobOrientation] instance from [int] value.
  static PrintJobOrientation? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOrientation.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobOrientation] instance from a native value.
  static PrintJobOrientation? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOrientation.values
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
      case 0:
        return 'PORTRAIT';
      case 1:
        return 'LANDSCAPE';
    }
    return _value.toString();
  }
}
