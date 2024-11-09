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

  /// Gets a possible [PrintJobDisposition] instance value with name [name].
  ///
  /// Goes through [PrintJobDisposition.values] looking for a value with
  /// name [name], as reported by [PrintJobDisposition.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PrintJobDisposition? byName(String? name) {
    if (name != null) {
      try {
        return PrintJobDisposition.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PrintJobDisposition] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PrintJobDisposition> asNameMap() =>
      <String, PrintJobDisposition>{
        for (final value in PrintJobDisposition.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'CANCEL':
        return 'CANCEL';
      case 'PREVIEW':
        return 'PREVIEW';
      case 'SAVE':
        return 'SAVE';
      case 'SPOOL':
        return 'SPOOL';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
