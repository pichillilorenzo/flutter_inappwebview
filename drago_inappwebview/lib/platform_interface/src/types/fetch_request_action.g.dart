// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [FetchRequest] class.
class FetchRequestAction {
  final int _value;
  final int? _nativeValue;
  const FetchRequestAction._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory FetchRequestAction._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => FetchRequestAction._internal(value, nativeValue());

  ///Aborts the fetch request.
  static const ABORT = FetchRequestAction._internal(0, 0);

  ///Proceeds with the fetch request.
  static const PROCEED = FetchRequestAction._internal(1, 1);

  ///Set of all values of [FetchRequestAction].
  static final Set<FetchRequestAction> values = [
    FetchRequestAction.ABORT,
    FetchRequestAction.PROCEED,
  ].toSet();

  ///Gets a possible [FetchRequestAction] instance from [int] value.
  static FetchRequestAction? fromValue(int? value) {
    if (value != null) {
      try {
        return FetchRequestAction.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [FetchRequestAction] instance from a native value.
  static FetchRequestAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return FetchRequestAction.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [FetchRequestAction] instance value with name [name].
  ///
  /// Goes through [FetchRequestAction.values] looking for a value with
  /// name [name], as reported by [FetchRequestAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static FetchRequestAction? byName(String? name) {
    if (name != null) {
      try {
        return FetchRequestAction.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [FetchRequestAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, FetchRequestAction> asNameMap() =>
      <String, FetchRequestAction>{
        for (final value in FetchRequestAction.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'ABORT';
      case 1:
        return 'PROCEED';
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
