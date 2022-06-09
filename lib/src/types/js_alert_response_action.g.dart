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

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return 'CONFIRM';
    }
    return _value.toString();
  }
}
