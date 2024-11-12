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
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final LANDSCAPE = PrintJobOrientation._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
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
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static final PORTRAIT = PrintJobOrientation._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 0;
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

  /// Gets a possible [PrintJobOrientation] instance value with name [name].
  ///
  /// Goes through [PrintJobOrientation.values] looking for a value with
  /// name [name], as reported by [PrintJobOrientation.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PrintJobOrientation? byName(String? name) {
    if (name != null) {
      try {
        return PrintJobOrientation.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PrintJobOrientation] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PrintJobOrientation> asNameMap() =>
      <String, PrintJobOrientation>{
        for (final value in PrintJobOrientation.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'LANDSCAPE';
      case 0:
        return 'PORTRAIT';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}
