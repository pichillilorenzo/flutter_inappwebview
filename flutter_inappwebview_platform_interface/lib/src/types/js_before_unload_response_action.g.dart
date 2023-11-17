// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_before_unload_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [JsBeforeUnloadResponse] class.
class JsBeforeUnloadResponseAction {
  final int _value;
  final int _nativeValue;
  const JsBeforeUnloadResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory JsBeforeUnloadResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      JsBeforeUnloadResponseAction._internal(value, nativeValue());

  ///Confirm that the user hit cancel button.
  static const CANCEL = JsBeforeUnloadResponseAction._internal(1, 1);

  ///Confirm that the user hit confirm button.
  static const CONFIRM = JsBeforeUnloadResponseAction._internal(0, 0);

  ///Set of all values of [JsBeforeUnloadResponseAction].
  static final Set<JsBeforeUnloadResponseAction> values = [
    JsBeforeUnloadResponseAction.CANCEL,
    JsBeforeUnloadResponseAction.CONFIRM,
  ].toSet();

  ///Gets a possible [JsBeforeUnloadResponseAction] instance from [int] value.
  static JsBeforeUnloadResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return JsBeforeUnloadResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [JsBeforeUnloadResponseAction] instance from a native value.
  static JsBeforeUnloadResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return JsBeforeUnloadResponseAction.values
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
