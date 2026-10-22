// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_trust_auth_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest] event.
class ServerTrustAuthResponse {
  ///Indicate the [ServerTrustAuthResponseAction] to take in response of the server trust authentication challenge.
  ServerTrustAuthResponseAction? action;
  ServerTrustAuthResponse({ServerTrustAuthResponseAction? action})
    : action = action ?? ServerTrustAuthResponseAction.CANCEL;

  ///Gets a possible [ServerTrustAuthResponse] instance from a [Map] value.
  static ServerTrustAuthResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ServerTrustAuthResponse();
    instance.action = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => ServerTrustAuthResponseAction.fromNativeValue(
        map['action'],
      ),
      EnumMethod.value => ServerTrustAuthResponseAction.fromValue(
        map['action'],
      ),
      EnumMethod.name => ServerTrustAuthResponseAction.byName(map['action']),
    };
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name(),
      },
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
