// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_protection_space.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a protection space requiring authentication.
class URLProtectionSpace {
  ///The hostname of the server.
  String host;

  ///The protocol of the server - e.g. "http", "ftp", "https".
  String? protocol;

  ///A string indicating a protocol-specific subdivision of a single host.
  ///For http and https, this maps to the realm string in http authentication challenges.
  ///For many other protocols it is unused.
  String? realm;

  ///The port of the server.
  int? port;

  ///The SSL certificate used.
  SslCertificate? sslCertificate;

  ///The SSL Error associated.
  SslError? sslError;

  ///Use [authenticationMethod] instead.
  @Deprecated('Use authenticationMethod instead')
  IOSNSURLProtectionSpaceAuthenticationMethod? iosAuthenticationMethod;

  ///The authentication method used by the receiver.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.authenticationMethod](https://developer.apple.com/documentation/foundation/urlprotectionspace/1415028-authenticationmethod))
  URLProtectionSpaceAuthenticationMethod? authenticationMethod;

  ///Use [distinguishedNames] instead.
  @Deprecated('Use distinguishedNames instead')
  List<X509Certificate>? iosDistinguishedNames;

  ///The acceptable certificate-issuing authorities for client certificate authentication.
  ///This value is `null` if the authentication method of the protection space is not client certificate.
  ///The returned issuing authorities are encoded with Distinguished Encoding Rules (DER).
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.distinguishedNames](https://developer.apple.com/documentation/foundation/urlprotectionspace/1417061-distinguishednames))
  List<X509Certificate>? distinguishedNames;

  ///Use [receivesCredentialSecurely] instead.
  @Deprecated('Use receivesCredentialSecurely instead')
  bool? iosReceivesCredentialSecurely;

  ///A Boolean value that indicates whether the credentials for the protection space can be sent securely.
  ///This value is `true` if the credentials for the protection space represented by the receiver can be sent securely, `false` otherwise.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.receivesCredentialSecurely](https://developer.apple.com/documentation/foundation/urlprotectionspace/1415176-receivescredentialsecurely))
  bool? receivesCredentialSecurely;

  ///Use [proxyType] instead.
  @Deprecated('Use proxyType instead')
  IOSNSURLProtectionSpaceProxyType? iosProxyType;

  ///The receiver's proxy type.
  ///This value is `null` if the receiver does not represent a proxy protection space.
  ///The supported proxy types are listed in [URLProtectionSpaceProxyType.values].
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.proxyType](https://developer.apple.com/documentation/foundation/urlprotectionspace/1411924-proxytype))
  URLProtectionSpaceProxyType? proxyType;
  URLProtectionSpace(
      {required this.host,
      this.protocol,
      this.realm,
      this.port,
      this.sslCertificate,
      this.sslError,
      @Deprecated('Use authenticationMethod instead')
          this.iosAuthenticationMethod,
      this.authenticationMethod,
      @Deprecated('Use distinguishedNames instead')
          this.iosDistinguishedNames,
      this.distinguishedNames,
      @Deprecated('Use receivesCredentialSecurely instead')
          this.iosReceivesCredentialSecurely,
      this.receivesCredentialSecurely,
      @Deprecated('Use proxyType instead')
          this.iosProxyType,
      this.proxyType}) {
    authenticationMethod = authenticationMethod ??
        URLProtectionSpaceAuthenticationMethod.fromNativeValue(
            iosAuthenticationMethod?.toNativeValue());
    distinguishedNames = distinguishedNames ?? iosDistinguishedNames;
    receivesCredentialSecurely =
        receivesCredentialSecurely ?? iosReceivesCredentialSecurely;
    proxyType = proxyType ??
        URLProtectionSpaceProxyType.fromNativeValue(
            iosProxyType?.toNativeValue());
  }

  ///Gets a possible [URLProtectionSpace] instance from a [Map] value.
  static URLProtectionSpace? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = URLProtectionSpace(
      host: map['host'],
      protocol: map['protocol'],
      realm: map['realm'],
      port: map['port'],
      sslCertificate: SslCertificate.fromMap(
          map['sslCertificate']?.cast<String, dynamic>()),
      sslError: SslError.fromMap(map['sslError']?.cast<String, dynamic>()),
      iosAuthenticationMethod:
          IOSNSURLProtectionSpaceAuthenticationMethod.fromNativeValue(
              map['authenticationMethod']),
      authenticationMethod:
          URLProtectionSpaceAuthenticationMethod.fromNativeValue(
              map['authenticationMethod']),
      iosDistinguishedNames:
          _distinguishedNamesDeserializer(map['distinguishedNames']),
      distinguishedNames:
          _distinguishedNamesDeserializer(map['distinguishedNames']),
      iosReceivesCredentialSecurely: map['receivesCredentialSecurely'],
      receivesCredentialSecurely: map['receivesCredentialSecurely'],
      iosProxyType:
          IOSNSURLProtectionSpaceProxyType.fromNativeValue(map['proxyType']),
      proxyType: URLProtectionSpaceProxyType.fromNativeValue(map['proxyType']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "host": host,
      "protocol": protocol,
      "realm": realm,
      "port": port,
      "sslCertificate": sslCertificate?.toMap(),
      "sslError": sslError?.toMap(),
      "authenticationMethod": authenticationMethod?.toNativeValue(),
      "distinguishedNames": distinguishedNames?.map((e) => e.toMap()).toList(),
      "receivesCredentialSecurely": receivesCredentialSecurely,
      "proxyType": proxyType?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLProtectionSpace{host: $host, protocol: $protocol, realm: $realm, port: $port, sslCertificate: $sslCertificate, sslError: $sslError, authenticationMethod: $authenticationMethod, distinguishedNames: $distinguishedNames, receivesCredentialSecurely: $receivesCredentialSecurely, proxyType: $proxyType}';
  }
}
