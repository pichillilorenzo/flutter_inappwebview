// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_alert_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [JsAlertResponse] class.
class JsAlertResponseAction {
  final int _value;
  final int _nativeValue;
  const JsAlertResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory JsAlertResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      JsAlertResponseAction._internal(value, nativeValue());

  ///Confirm that the user hit confirm button.
  static const CONFIRM = JsAlertResponseAction._internal(0, 0);

  ///Set of all values of [JsAlertResponseAction].
  static final Set<JsAlertResponseAction> values = [
    JsAlertResponseAction.CONFIRM,
  ].toSet();

  ///Gets a possible [JsAlertResponseAction] instance from [int] value.
  static JsAlertResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return JsAlertResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [JsAlertResponseAction] instance from a native value.
  static JsAlertResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return JsAlertResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [JsAlertResponseAction] instance value with name [name].
  ///
  /// Goes through [JsAlertResponseAction.values] looking for a value with
  /// name [name], as reported by [JsAlertResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static JsAlertResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return JsAlertResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [JsAlertResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, JsAlertResponseAction> asNameMap() =>
      <String, JsAlertResponseAction>{
        for (final value in JsAlertResponseAction.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'CONFIRM';
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
