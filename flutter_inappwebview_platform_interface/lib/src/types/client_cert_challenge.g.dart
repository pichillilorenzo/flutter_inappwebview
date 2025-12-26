// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
class ClientCertChallenge extends URLAuthenticationChallenge {
  ///The collection contains Base64 encoding of DER encoded distinguished names
  ///of certificate authorities allowed by the server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  List<String>? allowedCertificateAuthorities;

  ///Use [keyTypes] instead.
  @Deprecated('Use keyTypes instead')
  List<String>? androidKeyTypes;

  ///Use [principals] instead.
  @Deprecated('Use principals instead')
  List<String>? androidPrincipals;

  ///If the server that issued this request is an http proxy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  bool? isProxy;

  ///Returns the acceptable types of asymmetric keys.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - ClientCertRequest.getKeyTypes](https://developer.android.com/reference/android/webkit/ClientCertRequest#getKeyTypes()))
  List<String>? keyTypes;

  ///The collection contains mutually trusted CA certificates.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  List<SslCertificate>? mutuallyTrustedCertificates;

  ///The acceptable certificate issuers for the certificate matching the private key.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 21+ ([Official API - ClientCertRequest.getPrincipals](https://developer.android.com/reference/android/webkit/ClientCertRequest#getPrincipals()))
  List<String>? principals;
  ClientCertChallenge(
      {this.allowedCertificateAuthorities,
      @Deprecated('Use keyTypes instead') this.androidKeyTypes,
      @Deprecated('Use principals instead') this.androidPrincipals,
      this.isProxy,
      this.keyTypes,
      this.mutuallyTrustedCertificates,
      this.principals,
      required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace) {
    keyTypes = keyTypes ?? androidKeyTypes;
    principals = principals ?? androidPrincipals;
  }

  ///Gets a possible [ClientCertChallenge] instance from a [Map] value.
  static ClientCertChallenge? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ClientCertChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>(),
          enumMethod: enumMethod)!,
      allowedCertificateAuthorities:
          map['allowedCertificateAuthorities'] != null
              ? List<String>.from(
                  map['allowedCertificateAuthorities']!.cast<String>())
              : null,
      androidKeyTypes: map['keyTypes'] != null
          ? List<String>.from(map['keyTypes']!.cast<String>())
          : null,
      androidPrincipals: map['principals'] != null
          ? List<String>.from(map['principals']!.cast<String>())
          : null,
      isProxy: map['isProxy'],
      keyTypes: map['keyTypes'] != null
          ? List<String>.from(map['keyTypes']!.cast<String>())
          : null,
      mutuallyTrustedCertificates: map['mutuallyTrustedCertificates'] != null
          ? List<SslCertificate>.from(map['mutuallyTrustedCertificates'].map(
              (e) => SslCertificate.fromMap(e?.cast<String, dynamic>(),
                  enumMethod: enumMethod)!))
          : null,
      principals: map['principals'] != null
          ? List<String>.from(map['principals']!.cast<String>())
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "protectionSpace": protectionSpace.toMap(enumMethod: enumMethod),
      "allowedCertificateAuthorities": allowedCertificateAuthorities,
      "isProxy": isProxy,
      "keyTypes": keyTypes,
      "mutuallyTrustedCertificates": mutuallyTrustedCertificates
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "principals": principals,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ClientCertChallenge{protectionSpace: $protectionSpace, allowedCertificateAuthorities: $allowedCertificateAuthorities, isProxy: $isProxy, keyTypes: $keyTypes, mutuallyTrustedCertificates: $mutuallyTrustedCertificates, principals: $principals}';
  }
}
