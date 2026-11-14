// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajax_request_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [AjaxRequest] class.
class AjaxRequestAction {
  final int _value;
  final int? _nativeValue;
  const AjaxRequestAction._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory AjaxRequestAction._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => AjaxRequestAction._internal(value, nativeValue());

  ///Aborts the current [AjaxRequest].
  static const ABORT = AjaxRequestAction._internal(0, 0);

  ///Proceeds with the current [AjaxRequest].
  static const PROCEED = AjaxRequestAction._internal(1, 1);

  ///Set of all values of [AjaxRequestAction].
  static final Set<AjaxRequestAction> values = [
    AjaxRequestAction.ABORT,
    AjaxRequestAction.PROCEED,
  ].toSet();

  ///Gets a possible [AjaxRequestAction] instance from [int] value.
  static AjaxRequestAction? fromValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestAction.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AjaxRequestAction] instance from a native value.
  static AjaxRequestAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestAction.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AjaxRequestAction] instance value with name [name].
  ///
  /// Goes through [AjaxRequestAction.values] looking for a value with
  /// name [name], as reported by [AjaxRequestAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AjaxRequestAction? byName(String? name) {
    if (name != null) {
      try {
        return AjaxRequestAction.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AjaxRequestAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AjaxRequestAction> asNameMap() =>
      <String, AjaxRequestAction>{
        for (final value in AjaxRequestAction.values) value.name(): value,
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
