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
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
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
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
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
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
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

  /// Gets a possible [PrintJobDuplexMode] instance value with name [name].
  ///
  /// Goes through [PrintJobDuplexMode.values] looking for a value with
  /// name [name], as reported by [PrintJobDuplexMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PrintJobDuplexMode? byName(String? name) {
    if (name != null) {
      try {
        return PrintJobDuplexMode.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PrintJobDuplexMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PrintJobDuplexMode> asNameMap() =>
      <String, PrintJobDuplexMode>{
        for (final value in PrintJobDuplexMode.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'LONG_EDGE':
        return 'LONG_EDGE';
      case 'NONE':
        return 'NONE';
      case 'SHORT_EDGE':
        return 'SHORT_EDGE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return toNativeValue() != null;
  }

  @override
  String toString() {
    return _value;
  }
}
