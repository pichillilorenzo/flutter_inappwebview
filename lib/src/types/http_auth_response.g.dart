// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_auth_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onReceivedHttpAuthRequest] event.
class HttpAuthResponse {
  ///Represents the username used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String username;

  ///Represents the password used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String password;

  ///Indicate if the given credentials need to be saved permanently.
  bool permanentPersistence;

  ///Indicate the [HttpAuthResponseAction] to take in response of the authentication challenge.
  HttpAuthResponseAction? action;
  HttpAuthResponse(
      {this.username = "",
      this.password = "",
      this.permanentPersistence = false,
      this.action = HttpAuthResponseAction.CANCEL});

  ///Gets a possible [HttpAuthResponse] instance from a [Map] value.
  static HttpAuthResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = HttpAuthResponse();
    instance.username = map['username'];
    instance.password = map['password'];
    instance.permanentPersistence = map['permanentPersistence'];
    instance.action = HttpAuthResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
      "permanentPersistence": permanentPersistence,
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'HttpAuthResponse{username: $username, password: $password, permanentPersistence: $permanentPersistence, action: $action}';
  }
}
