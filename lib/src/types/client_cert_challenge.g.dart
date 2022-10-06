// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [WebView.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
class ClientCertChallenge extends URLAuthenticationChallenge {
  ///Use [principals] instead.
  @Deprecated('Use principals instead')
  List<String>? androidPrincipals;

  ///The acceptable certificate issuers for the certificate matching the private key.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView 21+ ([Official API - ClientCertRequest.getPrincipals](https://developer.android.com/reference/android/webkit/ClientCertRequest#getPrincipals()))
  List<String>? principals;

  ///Use [keyTypes] instead.
  @Deprecated('Use keyTypes instead')
  List<String>? androidKeyTypes;

  ///Returns the acceptable types of asymmetric keys.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView 21+ ([Official API - ClientCertRequest.getKeyTypes](https://developer.android.com/reference/android/webkit/ClientCertRequest#getKeyTypes()))
  List<String>? keyTypes;
  ClientCertChallenge(
      {@Deprecated('Use principals instead') this.androidPrincipals,
      this.principals,
      @Deprecated('Use keyTypes instead') this.androidKeyTypes,
      this.keyTypes,
      required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace) {
    principals = principals ?? androidPrincipals;
    keyTypes = keyTypes ?? androidKeyTypes;
  }

  ///Gets a possible [ClientCertChallenge] instance from a [Map] value.
  static ClientCertChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ClientCertChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>())!,
      androidPrincipals: map['principals']?.cast<String>(),
      principals: map['principals']?.cast<String>(),
      androidKeyTypes: map['keyTypes']?.cast<String>(),
      keyTypes: map['keyTypes']?.cast<String>(),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace.toMap(),
      "principals": principals,
      "keyTypes": keyTypes,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ClientCertChallenge{protectionSpace: $protectionSpace, principals: $principals, keyTypes: $keyTypes}';
  }
}
