// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_trust_auth_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest] event.
class ServerTrustAuthResponse {
  ///Indicate the [ServerTrustAuthResponseAction] to take in response of the server trust authentication challenge.
  ServerTrustAuthResponseAction? action;
  ServerTrustAuthResponse({this.action = ServerTrustAuthResponseAction.CANCEL});

  ///Gets a possible [ServerTrustAuthResponse] instance from a [Map] value.
  static ServerTrustAuthResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ServerTrustAuthResponse();
    instance.action =
        ServerTrustAuthResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ServerTrustAuthResponse{action: $action}';
  }
}
