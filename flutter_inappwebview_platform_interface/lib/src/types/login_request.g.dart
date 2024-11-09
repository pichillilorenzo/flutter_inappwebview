// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class used by [PlatformWebViewCreationParams.onReceivedLoginRequest] event.
class LoginRequest {
  ///An optional account. If not `null`, the account should be checked against accounts on the device.
  ///If it is a valid account, it should be used to log in the user. This value may be `null`.
  String? account;

  ///Authenticator specific arguments used to log in the user.
  String args;

  ///The account realm used to look up accounts.
  String realm;
  LoginRequest({this.account, required this.args, required this.realm});

  ///Gets a possible [LoginRequest] instance from a [Map] value.
  static LoginRequest? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = LoginRequest(
      account: map['account'],
      args: map['args'],
      realm: map['realm'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "account": account,
      "args": args,
      "realm": realm,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'LoginRequest{account: $account, args: $args, realm: $realm}';
  }
}
