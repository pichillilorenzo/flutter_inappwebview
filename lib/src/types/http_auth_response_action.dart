import 'http_auth_response.dart';

///Class used by [HttpAuthResponse] class.
class HttpAuthResponseAction {
  final int _value;

  const HttpAuthResponseAction._internal(this._value);

  ///Gets [int] value.
  int toValue() => _value;

  ///Instructs the WebView to cancel the authentication request.
  static const CANCEL = const HttpAuthResponseAction._internal(0);

  ///Instructs the WebView to proceed with the authentication with the given credentials.
  static const PROCEED = const HttpAuthResponseAction._internal(1);

  ///Uses the credentials stored for the current host.
  static const USE_SAVED_HTTP_AUTH_CREDENTIALS =
  const HttpAuthResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}