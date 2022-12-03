// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_confirm_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [JsConfirmResponse] class.
class JsConfirmResponseAction {
  final int _value;
  final int _nativeValue;
  const JsConfirmResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory JsConfirmResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      JsConfirmResponseAction._internal(value, nativeValue());

  ///Confirm that the user hit cancel button.
  static const CANCEL = JsConfirmResponseAction._internal(1, 1);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = JsConfirmResponseAction._internal(0, 0);

  ///Set of all values of [JsConfirmResponseAction].
  static final Set<JsConfirmResponseAction> values = [
    JsConfirmResponseAction.CANCEL,
    JsConfirmResponseAction.CONFIRM,
  ].toSet();

  ///Gets a possible [JsConfirmResponseAction] instance from [int] value.
  static JsConfirmResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return JsConfirmResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [JsConfirmResponseAction] instance from a native value.
  static JsConfirmResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return JsConfirmResponseAction.values
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
      case 1:
        return 'CANCEL';
      case 0:
        return 'CONFIRM';
    }
    return _value.toString();
  }
}
