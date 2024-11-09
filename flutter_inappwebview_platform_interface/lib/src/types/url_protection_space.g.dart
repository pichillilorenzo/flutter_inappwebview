// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_protection_space.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a protection space requiring authentication.
class URLProtectionSpace {
  ///The authentication method used by the receiver.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.authenticationMethod](https://developer.apple.com/documentation/foundation/urlprotectionspace/1415028-authenticationmethod))
  ///- MacOS ([Official API - URLProtectionSpace.authenticationMethod](https://developer.apple.com/documentation/foundation/urlprotectionspace/1415028-authenticationmethod))
  URLProtectionSpaceAuthenticationMethod? authenticationMethod;

  ///The acceptable certificate-issuing authorities for client certificate authentication.
  ///This value is `null` if the authentication method of the protection space is not client certificate.
  ///The returned issuing authorities are encoded with Distinguished Encoding Rules (DER).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.distinguishedNames](https://developer.apple.com/documentation/foundation/urlprotectionspace/1417061-distinguishednames))
  ///- MacOS ([Official API - URLProtectionSpace.distinguishedNames](https://developer.apple.com/documentation/foundation/urlprotectionspace/1417061-distinguishednames))
  List<X509Certificate>? distinguishedNames;

  ///The hostname of the server.
  String host;

  ///Use [authenticationMethod] instead.
  @Deprecated('Use authenticationMethod instead')
  IOSNSURLProtectionSpaceAuthenticationMethod? iosAuthenticationMethod;

  ///Use [distinguishedNames] instead.
  @Deprecated('Use distinguishedNames instead')
  List<X509Certificate>? iosDistinguishedNames;

  ///Use [proxyType] instead.
  @Deprecated('Use proxyType instead')
  IOSNSURLProtectionSpaceProxyType? iosProxyType;

  ///Use [receivesCredentialSecurely] instead.
  @Deprecated('Use receivesCredentialSecurely instead')
  bool? iosReceivesCredentialSecurely;

  ///The port of the server.
  int? port;

  ///The protocol of the server - e.g. "http", "ftp", "https".
  String? protocol;

  ///The receiver's proxy type.
  ///This value is `null` if the receiver does not represent a proxy protection space.
  ///The supported proxy types are listed in [URLProtectionSpaceProxyType.values].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.proxyType](https://developer.apple.com/documentation/foundation/urlprotectionspace/1411924-proxytype))
  ///- MacOS ([Official API - URLProtectionSpace.proxyType](https://developer.apple.com/documentation/foundation/urlprotectionspace/1411924-proxytype))
  URLProtectionSpaceProxyType? proxyType;

  ///A string indicating a protocol-specific subdivision of a single host.
  ///For http and https, this maps to the realm string in http authentication challenges.
  ///For many other protocols it is unused.
  String? realm;

  ///A Boolean value that indicates whether the credentials for the protection space can be sent securely.
  ///This value is `true` if the credentials for the protection space represented by the receiver can be sent securely, `false` otherwise.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLProtectionSpace.receivesCredentialSecurely](https://developer.apple.com/documentation/foundation/urlprotectionspace/1415176-receivescredentialsecurely))
  ///- MacOS ([Official API - URLProtectionSpace.receivesCredentialSecurely](https://developer.apple.com/documentation/foundation/urlprotectionspace/1415176-receivescredentialsecurely))
  bool? receivesCredentialSecurely;

  ///The SSL certificate used.
  SslCertificate? sslCertificate;

  ///The SSL Error associated.
  SslError? sslError;
  URLProtectionSpace(
      {this.authenticationMethod,
      this.distinguishedNames,
      required this.host,
      @Deprecated('Use authenticationMethod instead')
      this.iosAuthenticationMethod,
      @Deprecated('Use distinguishedNames instead') this.iosDistinguishedNames,
      @Deprecated('Use proxyType instead') this.iosProxyType,
      @Deprecated('Use receivesCredentialSecurely instead')
      this.iosReceivesCredentialSecurely,
      this.port,
      this.protocol,
      this.proxyType,
      this.realm,
      this.receivesCredentialSecurely,
      this.sslCertificate,
      this.sslError}) {
    authenticationMethod = authenticationMethod ??
        URLProtectionSpaceAuthenticationMethod.fromNativeValue(
            iosAuthenticationMethod?.toNativeValue());
    distinguishedNames = distinguishedNames ?? iosDistinguishedNames;
    proxyType = proxyType ??
        URLProtectionSpaceProxyType.fromNativeValue(
            iosProxyType?.toNativeValue());
    receivesCredentialSecurely =
        receivesCredentialSecurely ?? iosReceivesCredentialSecurely;
  }

  ///Gets a possible [URLProtectionSpace] instance from a [Map] value.
  static URLProtectionSpace? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = URLProtectionSpace(
      authenticationMethod: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          URLProtectionSpaceAuthenticationMethod.fromNativeValue(
              map['authenticationMethod']),
        EnumMethod.value => URLProtectionSpaceAuthenticationMethod.fromValue(
            map['authenticationMethod']),
        EnumMethod.name => URLProtectionSpaceAuthenticationMethod.byName(
            map['authenticationMethod'])
      },
      distinguishedNames: _distinguishedNamesDeserializer(
          map['distinguishedNames'],
          enumMethod: enumMethod),
      host: map['host'],
      iosAuthenticationMethod: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          IOSNSURLProtectionSpaceAuthenticationMethod.fromNativeValue(
              map['authenticationMethod']),
        EnumMethod.value =>
          IOSNSURLProtectionSpaceAuthenticationMethod.fromValue(
              map['authenticationMethod']),
        EnumMethod.name => IOSNSURLProtectionSpaceAuthenticationMethod.byName(
            map['authenticationMethod'])
      },
      iosDistinguishedNames: _distinguishedNamesDeserializer(
          map['distinguishedNames'],
          enumMethod: enumMethod),
      iosProxyType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          IOSNSURLProtectionSpaceProxyType.fromNativeValue(map['proxyType']),
        EnumMethod.value =>
          IOSNSURLProtectionSpaceProxyType.fromValue(map['proxyType']),
        EnumMethod.name =>
          IOSNSURLProtectionSpaceProxyType.byName(map['proxyType'])
      },
      iosReceivesCredentialSecurely: map['receivesCredentialSecurely'],
      port: map['port'],
      protocol: map['protocol'],
      proxyType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          URLProtectionSpaceProxyType.fromNativeValue(map['proxyType']),
        EnumMethod.value =>
          URLProtectionSpaceProxyType.fromValue(map['proxyType']),
        EnumMethod.name => URLProtectionSpaceProxyType.byName(map['proxyType'])
      },
      realm: map['realm'],
      receivesCredentialSecurely: map['receivesCredentialSecurely'],
      sslCertificate: SslCertificate.fromMap(
          map['sslCertificate']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      sslError: SslError.fromMap(map['sslError']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "authenticationMethod": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => authenticationMethod?.toNativeValue(),
        EnumMethod.value => authenticationMethod?.toValue(),
        EnumMethod.name => authenticationMethod?.name()
      },
      "distinguishedNames": distinguishedNames
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "host": host,
      "port": port,
      "protocol": protocol,
      "proxyType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => proxyType?.toNativeValue(),
        EnumMethod.value => proxyType?.toValue(),
        EnumMethod.name => proxyType?.name()
      },
      "realm": realm,
      "receivesCredentialSecurely": receivesCredentialSecurely,
      "sslCertificate": sslCertificate?.toMap(enumMethod: enumMethod),
      "sslError": sslError?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLProtectionSpace{authenticationMethod: $authenticationMethod, distinguishedNames: $distinguishedNames, host: $host, port: $port, protocol: $protocol, proxyType: $proxyType, realm: $realm, receivesCredentialSecurely: $receivesCredentialSecurely, sslCertificate: $sslCertificate, sslError: $sslError}';
  }
}
