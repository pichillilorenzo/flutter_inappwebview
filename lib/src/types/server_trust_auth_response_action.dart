import 'server_trust_auth_response.dart';

///Class used by [ServerTrustAuthResponse] class.
class ServerTrustAuthResponseAction {
  final int _value;

  const ServerTrustAuthResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Instructs the WebView to cancel the authentication challenge.
  static const CANCEL = const ServerTrustAuthResponseAction._internal(0);

  ///Instructs the WebView to proceed with the authentication challenge.
  static const PROCEED = const ServerTrustAuthResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}