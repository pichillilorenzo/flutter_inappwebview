// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [ClientCertResponse] class.
class ClientCertResponseAction {
  final int _value;
  final int _nativeValue;
  const ClientCertResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ClientCertResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      ClientCertResponseAction._internal(value, nativeValue());

  ///Cancel this request.
  static const CANCEL = ClientCertResponseAction._internal(0, 0);

  ///Ignore the request for now.
  static const IGNORE = ClientCertResponseAction._internal(2, 2);

  ///Proceed with the specified certificate.
  static const PROCEED = ClientCertResponseAction._internal(1, 1);

  ///Set of all values of [ClientCertResponseAction].
  static final Set<ClientCertResponseAction> values = [
    ClientCertResponseAction.CANCEL,
    ClientCertResponseAction.IGNORE,
    ClientCertResponseAction.PROCEED,
  ].toSet();

  ///Gets a possible [ClientCertResponseAction] instance from [int] value.
  static ClientCertResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return ClientCertResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ClientCertResponseAction] instance from a native value.
  static ClientCertResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ClientCertResponseAction.values
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
      case 2:
        return 'IGNORE';
      case 1:
        return 'PROCEED';
    }
    return _value.toString();
  }
}
