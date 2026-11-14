// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_as_kind.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the Save As kind.
class SaveAsKind {
  final int _value;
  final int? _nativeValue;
  const SaveAsKind._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory SaveAsKind._internalMultiPlatform(int value, Function nativeValue) =>
      SaveAsKind._internal(value, nativeValue());

  ///Save the page with a resources directory.
  static const COMPLETE = SaveAsKind._internal(3, 3);

  ///Default kind to save non-HTML content.
  static const DEFAULT = SaveAsKind._internal(0, 0);

  ///Save the page as HTML only.
  static const HTML_ONLY = SaveAsKind._internal(1, 1);

  ///Save the page as a single file (MHTML).
  static const SINGLE_FILE = SaveAsKind._internal(2, 2);

  ///Set of all values of [SaveAsKind].
  static final Set<SaveAsKind> values = [
    SaveAsKind.COMPLETE,
    SaveAsKind.DEFAULT,
    SaveAsKind.HTML_ONLY,
    SaveAsKind.SINGLE_FILE,
  ].toSet();

  ///Gets a possible [SaveAsKind] instance from [int] value.
  static SaveAsKind? fromValue(int? value) {
    if (value != null) {
      try {
        return SaveAsKind.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [SaveAsKind] instance from a native value.
  static SaveAsKind? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return SaveAsKind.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [SaveAsKind] instance value with name [name].
  ///
  /// Goes through [SaveAsKind.values] looking for a value with
  /// name [name], as reported by [SaveAsKind.name].
  /// Returns the first value with the given name, otherwise `null`.
  static SaveAsKind? byName(String? name) {
    if (name != null) {
      try {
        return SaveAsKind.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [SaveAsKind] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, SaveAsKind> asNameMap() => <String, SaveAsKind>{
    for (final value in SaveAsKind.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 3:
        return 'COMPLETE';
      case 0:
        return 'DEFAULT';
      case 1:
        return 'HTML_ONLY';
      case 2:
        return 'SINGLE_FILE';
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
