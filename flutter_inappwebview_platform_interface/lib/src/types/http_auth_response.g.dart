// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_auth_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedHttpAuthRequest] event.
class HttpAuthResponse {
  ///Indicate the [HttpAuthResponseAction] to take in response of the authentication challenge.
  HttpAuthResponseAction? action;

  ///Represents the password used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String password;

  ///Indicate if the given credentials need to be saved permanently.
  bool permanentPersistence;

  ///Represents the username used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String username;
  HttpAuthResponse(
      {this.action = HttpAuthResponseAction.CANCEL,
      this.password = "",
      this.permanentPersistence = false,
      this.username = ""});

  ///Gets a possible [HttpAuthResponse] instance from a [Map] value.
  static HttpAuthResponse? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = HttpAuthResponse();
    instance.action = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        HttpAuthResponseAction.fromNativeValue(map['action']),
      EnumMethod.value => HttpAuthResponseAction.fromValue(map['action']),
      EnumMethod.name => HttpAuthResponseAction.byName(map['action'])
    };
    if (map['password'] != null) {
      instance.password = map['password'];
    }
    if (map['permanentPersistence'] != null) {
      instance.permanentPersistence = map['permanentPersistence'];
    }
    if (map['username'] != null) {
      instance.username = map['username'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name()
      },
      "password": password,
      "permanentPersistence": permanentPersistence,
      "username": username,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'HttpAuthResponse{action: $action, password: $password, permanentPersistence: $permanentPersistence, username: $username}';
  }
}
