import 'package:flutter/foundation.dart';

import '../print_job/main.dart';

///Class representing the orientation of a [PrintJobController].
class PrintJobDuplexMode {
  final String _value;
  final int _nativeValue;

  const PrintJobDuplexMode._internal(this._value, this._nativeValue);

  ///Set of all values of [PrintJobDuplexMode].
  static final Set<PrintJobDuplexMode> values = [
    PrintJobDuplexMode.NONE,
    PrintJobDuplexMode.LONG_EDGE,
    PrintJobDuplexMode.SHORT_EDGE,
  ].toSet();

  ///Gets a possible [PrintJobDuplexMode] instance from a [String] value.
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

  ///Gets a possible [PrintJobDuplexMode] instance from an [int] native value.
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

  ///Gets native value.
  int toNativeValue() => _nativeValue;

  @override
  String toString() => _value;

  ///No double-sided (duplex) printing; single-sided printing only.
  static final NONE = PrintJobDuplexMode._internal(
      'NONE',
      (defaultTargetPlatform == TargetPlatform.android)
          ? 1
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? 0
              : 0));

  ///Duplex printing that flips the back page along the long edge of the paper.
  ///Pages are turned sideways along the long edge - like a book.
  static final LONG_EDGE = PrintJobDuplexMode._internal(
      'LONG_EDGE',
      (defaultTargetPlatform == TargetPlatform.android)
          ? 2
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? 1
              : 0));

  ///Duplex print that flips the back page along the short edge of the paper.
  ///Pages are turned upwards along the short edge - like a notepad.
  static final SHORT_EDGE = PrintJobDuplexMode._internal(
      'SHORT_EDGE',
      (defaultTargetPlatform == TargetPlatform.android)
          ? 4
          : ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS)
              ? 2
              : 0));

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
