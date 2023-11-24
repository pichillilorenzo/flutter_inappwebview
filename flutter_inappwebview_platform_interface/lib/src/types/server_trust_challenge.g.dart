// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_trust_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest] event.
///It provides all the information about the challenge.
class ServerTrustChallenge extends URLAuthenticationChallenge {
  ServerTrustChallenge({required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace);

  ///Gets a possible [ServerTrustChallenge] instance from a [Map] value.
  static ServerTrustChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ServerTrustChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>())!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ServerTrustChallenge{protectionSpace: $protectionSpace}';
  }
}
