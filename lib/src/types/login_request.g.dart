// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class used by [WebView.onReceivedLoginRequest] event.
class LoginRequest {
  ///The account realm used to look up accounts.
  String realm;

  ///An optional account. If not `null`, the account should be checked against accounts on the device.
  ///If it is a valid account, it should be used to log in the user. This value may be `null`.
  String? account;

  ///Authenticator specific arguments used to log in the user.
  String args;
  LoginRequest({required this.realm, this.account, required this.args});

  ///Gets a possible [LoginRequest] instance from a [Map] value.
  static LoginRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = LoginRequest(
      realm: map['realm'],
      account: map['account'],
      args: map['args'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "realm": realm,
      "account": account,
      "args": args,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'LoginRequest{realm: $realm, account: $account, args: $args}';
  }
}
