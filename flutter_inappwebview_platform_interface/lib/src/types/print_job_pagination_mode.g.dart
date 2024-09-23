// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_pagination_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the constants that specify the different ways in which an image is divided into pages of a [PlatformPrintJobController].
class PrintJobPaginationMode {
  final String _value;
  final int? _nativeValue;
  const PrintJobPaginationMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobPaginationMode._internalMultiPlatform(
          String value, Function nativeValue) =>
      PrintJobPaginationMode._internal(value, nativeValue());

  ///
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  static final AUTOMATIC =
      PrintJobPaginationMode._internalMultiPlatform('AUTOMATIC', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  static final CLIP = PrintJobPaginationMode._internalMultiPlatform('CLIP', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  static final FIT = PrintJobPaginationMode._internalMultiPlatform('FIT', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobPaginationMode].
  static final Set<PrintJobPaginationMode> values = [
    PrintJobPaginationMode.AUTOMATIC,
    PrintJobPaginationMode.CLIP,
    PrintJobPaginationMode.FIT,
  ].toSet();

  ///Gets a possible [PrintJobPaginationMode] instance from [String] value.
  static PrintJobPaginationMode? fromValue(String? value) {
    if (value != null) {
      try {
        return PrintJobPaginationMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobPaginationMode] instance from a native value.
  static PrintJobPaginationMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobPaginationMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [int?] native value.
  int? toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
