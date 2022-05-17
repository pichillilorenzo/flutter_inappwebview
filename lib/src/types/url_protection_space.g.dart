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
  ///**NOTE**: available only on iOS.
  URLProtectionSpaceAuthenticationMethod? authenticationMethod;

  ///Use [distinguishedNames] instead.
  @Deprecated('Use distinguishedNames instead')
  List<X509Certificate>? iosDistinguishedNames;

  ///The acceptable certificate-issuing authorities for client certificate authentication.
  ///This value is `null` if the authentication method of the protection space is not client certificate.
  ///The returned issuing authorities are encoded with Distinguished Encoding Rules (DER).
  ///
  ///**NOTE**: available only on iOS.
  List<X509Certificate>? distinguishedNames;

  ///Use [receivesCredentialSecurely] instead.
  @Deprecated('Use receivesCredentialSecurely instead')
  bool? iosReceivesCredentialSecurely;

  ///A Boolean value that indicates whether the credentials for the protection space can be sent securely.
  ///This value is `true` if the credentials for the protection space represented by the receiver can be sent securely, `false` otherwise.
  ///
  ///**NOTE**: available only on iOS.
  bool? receivesCredentialSecurely;

  ///Use [isProxy] instead.
  @Deprecated('Use isProxy instead')
  bool? iosIsProxy;

  ///Returns a Boolean value that indicates whether the receiver does not descend from `NSObject`.
  ///
  ///**NOTE**: available only on iOS.
  bool? isProxy;

  ///Use [proxyType] instead.
  @Deprecated('Use proxyType instead')
  IOSNSURLProtectionSpaceProxyType? iosProxyType;

  ///The receiver's proxy type.
  ///This value is `null` if the receiver does not represent a proxy protection space.
  ///The supported proxy types are listed in [URLProtectionSpaceProxyType.values].
  ///
  ///**NOTE**: available only on iOS.
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
      @Deprecated('Use isProxy instead')
          this.iosIsProxy,
      this.isProxy,
      @Deprecated('Use proxyType instead')
          this.iosProxyType,
      this.proxyType}) {
    authenticationMethod = authenticationMethod ??
        URLProtectionSpaceAuthenticationMethod.fromNativeValue(
            iosAuthenticationMethod?.toNativeValue());
    distinguishedNames = distinguishedNames ?? iosDistinguishedNames;
    receivesCredentialSecurely =
        receivesCredentialSecurely ?? iosReceivesCredentialSecurely;
    isProxy = isProxy ?? iosIsProxy;
    proxyType = proxyType ??
        URLProtectionSpaceProxyType.fromValue(iosProxyType?.toValue());
  }

  ///Gets a possible [URLProtectionSpace] instance from a [Map] value.
  static URLProtectionSpace? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = URLProtectionSpace(
      host: map['host'],
    );
    instance.protocol = map['protocol'];
    instance.realm = map['realm'];
    instance.port = map['port'];
    instance.sslCertificate =
        SslCertificate.fromMap(map['sslCertificate']?.cast<String, dynamic>());
    instance.sslError =
        SslError.fromMap(map['sslError']?.cast<String, dynamic>());
    instance.iosAuthenticationMethod =
        IOSNSURLProtectionSpaceAuthenticationMethod.fromNativeValue(
            map['authenticationMethod']);
    instance.authenticationMethod =
        URLProtectionSpaceAuthenticationMethod.fromNativeValue(
            map['authenticationMethod']);
    instance.iosDistinguishedNames =
        _distinguishedNamesDeserializer(map['distinguishedNames']);
    instance.distinguishedNames =
        _distinguishedNamesDeserializer(map['distinguishedNames']);
    instance.iosReceivesCredentialSecurely = map['receivesCredentialSecurely'];
    instance.receivesCredentialSecurely = map['receivesCredentialSecurely'];
    instance.iosIsProxy = map['isProxy'];
    instance.isProxy = map['isProxy'];
    instance.iosProxyType =
        IOSNSURLProtectionSpaceProxyType.fromValue(map['proxyType']);
    instance.proxyType =
        URLProtectionSpaceProxyType.fromValue(map['proxyType']);
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
      "isProxy": isProxy,
      "proxyType": proxyType?.toValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLProtectionSpace{host: $host, protocol: $protocol, realm: $realm, port: $port, sslCertificate: $sslCertificate, sslError: $sslError, authenticationMethod: $authenticationMethod, distinguishedNames: $distinguishedNames, receivesCredentialSecurely: $receivesCredentialSecurely, isProxy: $isProxy, proxyType: $proxyType}';
  }
}
