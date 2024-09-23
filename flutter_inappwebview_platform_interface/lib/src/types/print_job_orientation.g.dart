// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_orientation.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the orientation of a [PlatformPrintJobController].
class PrintJobOrientation {
  final int _value;
  final int _nativeValue;
  const PrintJobOrientation._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobOrientation._internalMultiPlatform(
          int value, Function nativeValue) =>
      PrintJobOrientation._internal(value, nativeValue());

  ///Pages are printed in landscape orientation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  static final LANDSCAPE = PrintJobOrientation._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Pages are printed in portrait orientation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  static final PORTRAIT = PrintJobOrientation._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 0;
      case TargetPlatform.macOS:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobOrientation].
  static final Set<PrintJobOrientation> values = [
    PrintJobOrientation.LANDSCAPE,
    PrintJobOrientation.PORTRAIT,
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
      case 1:
        return 'LANDSCAPE';
      case 0:
        return 'PORTRAIT';
    }
    return _value.toString();
  }
}
