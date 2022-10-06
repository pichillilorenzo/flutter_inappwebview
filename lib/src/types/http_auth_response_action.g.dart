// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_auth_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [HttpAuthResponse] class.
class HttpAuthResponseAction {
  final int _value;
  final int _nativeValue;
  const HttpAuthResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory HttpAuthResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      HttpAuthResponseAction._internal(value, nativeValue());

  ///Instructs the WebView to cancel the authentication request.
  static const CANCEL = HttpAuthResponseAction._internal(0, 0);

  ///Instructs the WebView to proceed with the authentication with the given credentials.
  static const PROCEED = HttpAuthResponseAction._internal(1, 1);

  ///Uses the credentials stored for the current host.
  static const USE_SAVED_HTTP_AUTH_CREDENTIALS =
      HttpAuthResponseAction._internal(2, 2);

  ///Set of all values of [HttpAuthResponseAction].
  static final Set<HttpAuthResponseAction> values = [
    HttpAuthResponseAction.CANCEL,
    HttpAuthResponseAction.PROCEED,
    HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS,
  ].toSet();

  ///Gets a possible [HttpAuthResponseAction] instance from [int] value.
  static HttpAuthResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return HttpAuthResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [HttpAuthResponseAction] instance from a native value.
  static HttpAuthResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return HttpAuthResponseAction.values
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
        return 'CANCEL';
      case 1:
        return 'PROCEED';
      case 2:
        return 'USE_SAVED_HTTP_AUTH_CREDENTIALS';
    }
    return _value.toString();
  }
}
