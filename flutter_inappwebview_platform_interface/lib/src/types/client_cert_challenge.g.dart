// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
class ClientCertChallenge extends URLAuthenticationChallenge {
  ///Use [keyTypes] instead.
  @Deprecated('Use keyTypes instead')
  List<String>? androidKeyTypes;

  ///Use [principals] instead.
  @Deprecated('Use principals instead')
  List<String>? androidPrincipals;

  ///Returns the acceptable types of asymmetric keys.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView 21+ ([Official API - ClientCertRequest.getKeyTypes](https://developer.android.com/reference/android/webkit/ClientCertRequest#getKeyTypes()))
  List<String>? keyTypes;

  ///The acceptable certificate issuers for the certificate matching the private key.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView 21+ ([Official API - ClientCertRequest.getPrincipals](https://developer.android.com/reference/android/webkit/ClientCertRequest#getPrincipals()))
  List<String>? principals;
  ClientCertChallenge(
      {@Deprecated('Use keyTypes instead') this.androidKeyTypes,
      @Deprecated('Use principals instead') this.androidPrincipals,
      this.keyTypes,
      this.principals,
      required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace) {
    keyTypes = keyTypes ?? androidKeyTypes;
    principals = principals ?? androidPrincipals;
  }

  ///Gets a possible [ClientCertChallenge] instance from a [Map] value.
  static ClientCertChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ClientCertChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>())!,
      androidKeyTypes: map['keyTypes'] != null
          ? List<String>.from(map['keyTypes']!.cast<String>())
          : null,
      androidPrincipals: map['principals'] != null
          ? List<String>.from(map['principals']!.cast<String>())
          : null,
      keyTypes: map['keyTypes'] != null
          ? List<String>.from(map['keyTypes']!.cast<String>())
          : null,
      principals: map['principals'] != null
          ? List<String>.from(map['principals']!.cast<String>())
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace.toMap(),
      "keyTypes": keyTypes,
      "principals": principals,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ClientCertChallenge{protectionSpace: $protectionSpace, keyTypes: $keyTypes, principals: $principals}';
  }
}
