// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_as_ui_result.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the result of a programmatic Save As call.
class SaveAsUIResult {
  final int _value;
  final int? _nativeValue;
  const SaveAsUIResult._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory SaveAsUIResult._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => SaveAsUIResult._internal(value, nativeValue());

  ///The user cancelled the Save As operation.
  static const CANCELLED = SaveAsUIResult._internal(4, 4);

  ///The destination file path already exists.
  static const FILE_ALREADY_EXISTS = SaveAsUIResult._internal(2, 2);

  ///The destination file path is invalid.
  static const INVALID_PATH = SaveAsUIResult._internal(1, 1);

  ///The selected Save As kind is not supported.
  static const KIND_NOT_SUPPORTED = SaveAsUIResult._internal(3, 3);

  ///The Save As operation completed successfully.
  static const SUCCESS = SaveAsUIResult._internal(0, 0);

  ///Set of all values of [SaveAsUIResult].
  static final Set<SaveAsUIResult> values = [
    SaveAsUIResult.CANCELLED,
    SaveAsUIResult.FILE_ALREADY_EXISTS,
    SaveAsUIResult.INVALID_PATH,
    SaveAsUIResult.KIND_NOT_SUPPORTED,
    SaveAsUIResult.SUCCESS,
  ].toSet();

  ///Gets a possible [SaveAsUIResult] instance from [int] value.
  static SaveAsUIResult? fromValue(int? value) {
    if (value != null) {
      try {
        return SaveAsUIResult.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [SaveAsUIResult] instance from a native value.
  static SaveAsUIResult? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return SaveAsUIResult.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [SaveAsUIResult] instance value with name [name].
  ///
  /// Goes through [SaveAsUIResult.values] looking for a value with
  /// name [name], as reported by [SaveAsUIResult.name].
  /// Returns the first value with the given name, otherwise `null`.
  static SaveAsUIResult? byName(String? name) {
    if (name != null) {
      try {
        return SaveAsUIResult.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [SaveAsUIResult] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, SaveAsUIResult> asNameMap() => <String, SaveAsUIResult>{
    for (final value in SaveAsUIResult.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 4:
        return 'CANCELLED';
      case 2:
        return 'FILE_ALREADY_EXISTS';
      case 1:
        return 'INVALID_PATH';
      case 3:
        return 'KIND_NOT_SUPPORTED';
      case 0:
        return 'SUCCESS';
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
    return name();
  }
}
