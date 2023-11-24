// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_color_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing how the printed content of a [PlatformPrintJobController] should be laid out.
class PrintJobColorMode {
  final int _value;
  final dynamic _nativeValue;
  const PrintJobColorMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobColorMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      PrintJobColorMode._internal(value, nativeValue());

  ///Color color scheme, for example many colors are used.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  static final COLOR = PrintJobColorMode._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      case TargetPlatform.macOS:
        return 'RGB';
      default:
        break;
    }
    return null;
  });

  ///Monochrome color scheme, for example one color is used.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  static final MONOCHROME = PrintJobColorMode._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      case TargetPlatform.macOS:
        return 'Gray';
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobColorMode].
  static final Set<PrintJobColorMode> values = [
    PrintJobColorMode.COLOR,
    PrintJobColorMode.MONOCHROME,
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
  static PrintJobColorMode? fromNativeValue(dynamic value) {
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

  ///Gets [dynamic] native value.
  dynamic toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 2:
        return 'COLOR';
      case 1:
        return 'MONOCHROME';
    }
    return _value.toString();
  }
}
