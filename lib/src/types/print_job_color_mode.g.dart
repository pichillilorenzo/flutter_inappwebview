// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_color_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing how the printed content of a [PrintJobController] should be laid out.
class PrintJobColorMode {
  final int _value;
  final int _nativeValue;
  const PrintJobColorMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobColorMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      PrintJobColorMode._internal(value, nativeValue());

  ///Monochrome color scheme, for example one color is used.
  static const MONOCHROME = PrintJobColorMode._internal(1, 1);

  ///Color color scheme, for example many colors are used.
  static const COLOR = PrintJobColorMode._internal(2, 2);

  ///Set of all values of [PrintJobColorMode].
  static final Set<PrintJobColorMode> values = [
    PrintJobColorMode.MONOCHROME,
    PrintJobColorMode.COLOR,
  ].toSet();

  ///Gets a possible [PrintJobColorMode] instance from [int] value.
  static PrintJobColorMode? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobColorMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobColorMode] instance from a native value.
  static PrintJobColorMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobColorMode.values
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
        return 'MONOCHROME';
      case 2:
        return 'COLOR';
    }
    return _value.toString();
  }
}
