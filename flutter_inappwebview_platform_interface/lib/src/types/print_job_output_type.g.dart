// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_output_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the kind of printable content of a [PlatformPrintJobController].
class PrintJobOutputType {
  final int _value;
  final int _nativeValue;
  const PrintJobOutputType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobOutputType._internalMultiPlatform(
          int value, Function nativeValue) =>
      PrintJobOutputType._internal(value, nativeValue());

  ///Specifies that the printed content consists of mixed text, graphics, and images.
  ///The default paper is Letter, A4, or similar locale-specific designation.
  ///Output is normal quality, duplex.
  static const GENERAL = PrintJobOutputType._internal(0, 0);

  ///Specifies that the printed content is grayscale.
  ///Set the output type to this value when your printable content contains no color—for example, it’s black text only.
  ///The default paper is Letter/A4. Output is grayscale quality, duplex.
  ///This content type can produce a performance improvement in some cases.
  static const GRAYSCALE = PrintJobOutputType._internal(2, 2);

  ///Specifies that the printed content consists of black-and-white or color images.
  ///The default paper is 4x6, A6, or similar locale-specific designation.
  ///Output is high quality, simplex.
  static const PHOTO = PrintJobOutputType._internal(1, 1);

  ///Specifies that the printed content is a grayscale image.
  ///Set the output type to this value when your printable content contains no color—for example, it’s black text only.
  ///The default paper is Letter/A4.
  ///Output is high quality grayscale, duplex.
  static const PHOTO_GRAYSCALE = PrintJobOutputType._internal(3, 3);

  ///Set of all values of [PrintJobOutputType].
  static final Set<PrintJobOutputType> values = [
    PrintJobOutputType.GENERAL,
    PrintJobOutputType.GRAYSCALE,
    PrintJobOutputType.PHOTO,
    PrintJobOutputType.PHOTO_GRAYSCALE,
  ].toSet();

  ///Gets a possible [PrintJobOutputType] instance from [int] value.
  static PrintJobOutputType? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOutputType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobOutputType] instance from a native value.
  static PrintJobOutputType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobOutputType.values
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
        return 'GENERAL';
      case 2:
        return 'GRAYSCALE';
      case 1:
        return 'PHOTO';
      case 3:
        return 'PHOTO_GRAYSCALE';
    }
    return _value.toString();
  }
}
