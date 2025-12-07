// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_page_order.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the page order that will be used to generate the pages of a [PlatformPrintJobController].
class PrintJobPageOrder {
  final int _value;
  final int _nativeValue;
  const PrintJobPageOrder._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PrintJobPageOrder._internalMultiPlatform(
          int value, Function nativeValue) =>
      PrintJobPageOrder._internal(value, nativeValue());

  ///Ascending (back to front) page order.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final ASCENDING = PrintJobPageOrder._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Descending (front to back) page order.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final DESCENDING = PrintJobPageOrder._internalMultiPlatform(-1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return -1;
      default:
        break;
    }
    return null;
  });

  ///The spooler does not rearrange pages—they are printed in the order received by the spooler.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final SPECIAL = PrintJobPageOrder._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///No page order specified.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final UNKNOWN = PrintJobPageOrder._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [PrintJobPageOrder].
  static final Set<PrintJobPageOrder> values = [
    PrintJobPageOrder.ASCENDING,
    PrintJobPageOrder.DESCENDING,
    PrintJobPageOrder.SPECIAL,
    PrintJobPageOrder.UNKNOWN,
  ].toSet();

  ///Gets a possible [PrintJobPageOrder] instance from [int] value.
  static PrintJobPageOrder? fromValue(int? value) {
    if (value != null) {
      try {
        return PrintJobPageOrder.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PrintJobPageOrder] instance from a native value.
  static PrintJobPageOrder? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PrintJobPageOrder.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [PrintJobPageOrder] instance value with name [name].
  ///
  /// Goes through [PrintJobPageOrder.values] looking for a value with
  /// name [name], as reported by [PrintJobPageOrder.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PrintJobPageOrder? byName(String? name) {
    if (name != null) {
      try {
        return PrintJobPageOrder.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PrintJobPageOrder] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PrintJobPageOrder> asNameMap() =>
      <String, PrintJobPageOrder>{
        for (final value in PrintJobPageOrder.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ASCENDING';
      case -1:
        return 'DESCENDING';
      case 0:
        return 'SPECIAL';
      case 2:
        return 'UNKNOWN';
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
    return name();
  }
}
