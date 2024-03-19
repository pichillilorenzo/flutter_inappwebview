// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_trust_auth_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [ServerTrustAuthResponse] class.
class ServerTrustAuthResponseAction {
  final int _value;
  final int _nativeValue;
  const ServerTrustAuthResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ServerTrustAuthResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      ServerTrustAuthResponseAction._internal(value, nativeValue());

  ///Instructs the WebView to cancel the authentication challenge.
  static const CANCEL = ServerTrustAuthResponseAction._internal(0, 0);

  ///Instructs the WebView to proceed with the authentication challenge.
  static const PROCEED = ServerTrustAuthResponseAction._internal(1, 1);

  ///Set of all values of [ServerTrustAuthResponseAction].
  static final Set<ServerTrustAuthResponseAction> values = [
    ServerTrustAuthResponseAction.CANCEL,
    ServerTrustAuthResponseAction.PROCEED,
  ].toSet();

  ///Gets a possible [ServerTrustAuthResponseAction] instance from [int] value.
  static ServerTrustAuthResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return ServerTrustAuthResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ServerTrustAuthResponseAction] instance from a native value.
  static ServerTrustAuthResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ServerTrustAuthResponseAction.values
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
    }
    return _value.toString();
  }
}
