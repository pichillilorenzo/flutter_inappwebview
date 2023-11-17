// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajax_request_ready_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [AjaxRequest] class. It represents the state of an [AjaxRequest].
class AjaxRequestReadyState {
  final int _value;
  final int _nativeValue;
  const AjaxRequestReadyState._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AjaxRequestReadyState._internalMultiPlatform(
          int value, Function nativeValue) =>
      AjaxRequestReadyState._internal(value, nativeValue());

  ///The operation is complete.
  static const DONE = AjaxRequestReadyState._internal(4, 4);

  ///`XMLHttpRequest.send()` has been called, and [AjaxRequest.headers] and [AjaxRequest.status] are available.
  static const HEADERS_RECEIVED = AjaxRequestReadyState._internal(2, 2);

  ///Downloading; [AjaxRequest.responseText] holds partial data.
  static const LOADING = AjaxRequestReadyState._internal(3, 3);

  ///`XMLHttpRequest.open()` has been called.
  static const OPENED = AjaxRequestReadyState._internal(1, 1);

  ///Client has been created. `XMLHttpRequest.open()` not called yet.
  static const UNSENT = AjaxRequestReadyState._internal(0, 0);

  ///Set of all values of [AjaxRequestReadyState].
  static final Set<AjaxRequestReadyState> values = [
    AjaxRequestReadyState.DONE,
    AjaxRequestReadyState.HEADERS_RECEIVED,
    AjaxRequestReadyState.LOADING,
    AjaxRequestReadyState.OPENED,
    AjaxRequestReadyState.UNSENT,
  ].toSet();

  ///Gets a possible [AjaxRequestReadyState] instance from [int] value.
  static AjaxRequestReadyState? fromValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestReadyState.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AjaxRequestReadyState] instance from a native value.
  static AjaxRequestReadyState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestReadyState.values
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
      case 4:
        return 'DONE';
      case 2:
        return 'HEADERS_RECEIVED';
      case 3:
        return 'LOADING';
      case 1:
        return 'OPENED';
      case 0:
        return 'UNSENT';
    }
    return _value.toString();
  }
}
