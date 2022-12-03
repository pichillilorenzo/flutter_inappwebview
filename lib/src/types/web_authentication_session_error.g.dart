// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_authentication_session_error.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the error code for a web authentication session error.
class WebAuthenticationSessionError {
  final int _value;
  final int _nativeValue;
  const WebAuthenticationSessionError._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WebAuthenticationSessionError._internalMultiPlatform(
          int value, Function nativeValue) =>
      WebAuthenticationSessionError._internal(value, nativeValue());

  ///The login has been canceled.
  static const CANCELED_LOGIN = WebAuthenticationSessionError._internal(1, 1);

  ///The context was invalid.
  static const PRESENTATION_CONTEXT_INVALID =
      WebAuthenticationSessionError._internal(3, 3);

  ///A context wasn’t provided.
  static const PRESENTATION_CONTEXT_NOT_PROVIDED =
      WebAuthenticationSessionError._internal(2, 2);

  ///Set of all values of [WebAuthenticationSessionError].
  static final Set<WebAuthenticationSessionError> values = [
    WebAuthenticationSessionError.CANCELED_LOGIN,
    WebAuthenticationSessionError.PRESENTATION_CONTEXT_INVALID,
    WebAuthenticationSessionError.PRESENTATION_CONTEXT_NOT_PROVIDED,
  ].toSet();

  ///Gets a possible [WebAuthenticationSessionError] instance from [int] value.
  static WebAuthenticationSessionError? fromValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSessionError.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebAuthenticationSessionError] instance from a native value.
  static WebAuthenticationSessionError? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSessionError.values
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
        return 'CANCELED_LOGIN';
      case 3:
        return 'PRESENTATION_CONTEXT_INVALID';
      case 2:
        return 'PRESENTATION_CONTEXT_NOT_PROVIDED';
    }
    return _value.toString();
  }
}
