import 'client_cert_response.dart';

///Class used by [ClientCertResponse] class.
class ClientCertResponseAction {
  final int _value;

  const ClientCertResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Cancel this request.
  static const CANCEL = const ClientCertResponseAction._internal(0);

  ///Proceed with the specified certificate.
  static const PROCEED = const ClientCertResponseAction._internal(1);

  ///Ignore the request for now.
  static const IGNORE = const ClientCertResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}