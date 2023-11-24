// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_duplex_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the orientation of a [PlatformPrintJobController].
class PrintJobDuplexMode {
  final String _value;
  final int? _nativeValue;
  const PrintJobDuplexMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobDuplexMode._internalMultiPlatform(
          String value, Function nativeValue) =>
      PrintJobDuplexMode._internal(value, nativeValue());

  ///Duplex printing that flips the back page along the long edge of the paper.
  ///Pages are turned sideways along the long edge - like a book.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final LONG_EDGE =
      PrintJobDuplexMode._internalMultiPlatform('LONG_EDGE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 2;
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///No double-sided (duplex) printing; single-sided printing only.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final NONE = PrintJobDuplexMode._internalMultiPlatform('NONE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      case TargetPlatform.iOS:
        return 0;
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Duplex print that flips the back page along the short edge of the paper.
  ///Pages are turned upwards along the short edge - like a notepad.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final SHORT_EDGE =
      PrintJobDuplexMode._internalMultiPlatform('SHORT_EDGE', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 4;
      case TargetPlatform.iOS:
        return 2;
      case TargetPlatform.macOS:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobDuplexMode].
  static final Set<PrintJobDuplexMode> values = [
    PrintJobDuplexMode.LONG_EDGE,
    PrintJobDuplexMode.NONE,
    PrintJobDuplexMode.SHORT_EDGE,
  ].toSet();

  ///Gets a possible [PrintJobDuplexMode] instance from [String] value.
  static PrintJobDuplexMode? fromValue(String? value) {
    if (value != null) {
      try {
        return PrintJobDuplexMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobDuplexMode] instance from a native value.
  static PrintJobDuplexMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobDuplexMode.values
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
