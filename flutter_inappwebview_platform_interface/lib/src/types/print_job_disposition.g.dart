// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_disposition.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the constants that specify values for the print job disposition of a [PlatformPrintJobController].
class PrintJobDisposition {
  final String _value;
  final String _nativeValue;
  const PrintJobDisposition._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobDisposition._internalMultiPlatform(
          String value, Function nativeValue) =>
      PrintJobDisposition._internal(value, nativeValue());

  ///Cancel print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  static final CANCEL =
      PrintJobDisposition._internalMultiPlatform('CANCEL', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'cancel';
      default:
        break;
    }
    return null;
  });

  ///Send to Preview application.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  static final PREVIEW =
      PrintJobDisposition._internalMultiPlatform('PREVIEW', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'preview';
      default:
        break;
    }
    return null;
  });

  ///Save to a file.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  static final SAVE = PrintJobDisposition._internalMultiPlatform('SAVE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'save';
      default:
        break;
    }
    return null;
  });

  ///Normal print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  static final SPOOL = PrintJobDisposition._internalMultiPlatform('SPOOL', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'spool';
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobDisposition].
  static final Set<PrintJobDisposition> values = [
    PrintJobDisposition.CANCEL,
    PrintJobDisposition.PREVIEW,
    PrintJobDisposition.SAVE,
    PrintJobDisposition.SPOOL,
  ].toSet();

  ///Gets a possible [PrintJobDisposition] instance from [String] value.
  static PrintJobDisposition? fromValue(String? value) {
    if (value != null) {
      try {
        return PrintJobDisposition.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobDisposition] instance from a native value.
  static PrintJobDisposition? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return PrintJobDisposition.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
