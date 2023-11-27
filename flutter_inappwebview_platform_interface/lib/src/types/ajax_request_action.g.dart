// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajax_request_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [AjaxRequest] class.
class AjaxRequestAction {
  final int _value;
  final int _nativeValue;
  const AjaxRequestAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AjaxRequestAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      AjaxRequestAction._internal(value, nativeValue());

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
        return AjaxRequestAction.values
            .firstWhere((element) => element.toValue() == value);
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
        return AjaxRequestAction.values
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
        return 'ABORT';
      case 1:
        return 'PROCEED';
    }
    return _value.toString();
  }
}
