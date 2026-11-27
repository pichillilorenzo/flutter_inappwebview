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
    String value,
    Function nativeValue,
  ) => PrintJobPaginationMode._internal(value, nativeValue());

  ///
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final AUTOMATIC = PrintJobPaginationMode._internalMultiPlatform(
    'AUTOMATIC',
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.macOS:
          return 0;
        default:
          break;
      }
      return null;
    },
  );

  ///
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
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
  ///- macOS WKWebView
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
        return PrintJobPaginationMode.values.firstWhere(
          (element) => element.toValue() == value,
        );
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
        return PrintJobPaginationMode.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [PrintJobPaginationMode] instance value with name [name].
  ///
  /// Goes through [PrintJobPaginationMode.values] looking for a value with
  /// name [name], as reported by [PrintJobPaginationMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PrintJobPaginationMode? byName(String? name) {
    if (name != null) {
      try {
        return PrintJobPaginationMode.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PrintJobPaginationMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PrintJobPaginationMode> asNameMap() =>
      <String, PrintJobPaginationMode>{
        for (final value in PrintJobPaginationMode.values) value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'AUTOMATIC':
        return 'AUTOMATIC';
      case 'CLIP':
        return 'CLIP';
      case 'FIT':
        return 'FIT';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return _value;
  }
}
