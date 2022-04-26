import 'dart:typed_data';

import '../x509_certificate/x509_certificate.dart';
import 'url_protection_space_proxy_type.dart';
import 'url_protection_space_authentication_method.dart';
import 'ssl_error.dart';
import 'ssl_certificate.dart';

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
  @Deprecated("Use authenticationMethod instead")
  IOSNSURLProtectionSpaceAuthenticationMethod? iosAuthenticationMethod;

  ///The authentication method used by the receiver.
  ///
  ///**NOTE**: available only on iOS.
  URLProtectionSpaceAuthenticationMethod? authenticationMethod;

  ///Use [distinguishedNames] instead.
  @Deprecated("Use distinguishedNames instead")
  List<X509Certificate>? iosDistinguishedNames;

  ///The acceptable certificate-issuing authorities for client certificate authentication.
  ///This value is `null` if the authentication method of the protection space is not client certificate.
  ///The returned issuing authorities are encoded with Distinguished Encoding Rules (DER).
  ///
  ///**NOTE**: available only on iOS.
  List<X509Certificate>? distinguishedNames;

  ///Use [receivesCredentialSecurely] instead.
  @Deprecated("Use receivesCredentialSecurely instead")
  bool? iosReceivesCredentialSecurely;

  ///A Boolean value that indicates whether the credentials for the protection space can be sent securely.
  ///This value is `true` if the credentials for the protection space represented by the receiver can be sent securely, `false` otherwise.
  ///
  ///**NOTE**: available only on iOS.
  bool? receivesCredentialSecurely;

  ///Use [isProxy] instead.
  @Deprecated("Use isProxy instead")
  bool? iosIsProxy;

  ///Returns a Boolean value that indicates whether the receiver does not descend from `NSObject`.
  ///
  ///**NOTE**: available only on iOS.
  bool? isProxy;

  ///Use [proxyType] instead.
  @Deprecated("Use proxyType instead")
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
        @Deprecated("Use authenticationMethod instead")
        this.iosAuthenticationMethod,
        this.authenticationMethod,
        @Deprecated("Use distinguishedNames instead")
        this.iosDistinguishedNames,
        this.distinguishedNames,
        @Deprecated("Use receivesCredentialSecurely instead")
        this.iosReceivesCredentialSecurely,
        this.receivesCredentialSecurely,
        @Deprecated("Use isProxy instead")
        this.iosIsProxy,
        this.isProxy,
        @Deprecated("Use proxyType instead")
        this.iosProxyType,
        this.proxyType}) {
    this.authenticationMethod = this.authenticationMethod ??
        URLProtectionSpaceAuthenticationMethod.fromValue(
          // ignore: deprecated_member_use_from_same_package
            this.iosAuthenticationMethod?.toValue());
    this.distinguishedNames =
    // ignore: deprecated_member_use_from_same_package
    this.distinguishedNames ?? this.iosDistinguishedNames;
    this.receivesCredentialSecurely =
    // ignore: deprecated_member_use_from_same_package
    this.receivesCredentialSecurely ?? this.iosReceivesCredentialSecurely;
    // ignore: deprecated_member_use_from_same_package
    this.isProxy = this.isProxy ?? this.iosIsProxy;
    this.proxyType = this.proxyType ??
        // ignore: deprecated_member_use_from_same_package
        URLProtectionSpaceProxyType.fromValue(this.iosProxyType?.toValue());
  }

  ///Gets a possible [URLProtectionSpace] instance from a [Map] value.
  static URLProtectionSpace? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    List<X509Certificate>? distinguishedNames;
    if (map["distinguishedNames"] != null) {
      distinguishedNames = <X509Certificate>[];
      (map["distinguishedNames"].cast<Uint8List>() as List<Uint8List>)
          .forEach((data) {
        try {
          distinguishedNames!.add(X509Certificate.fromData(data: data));
        } catch (e, stacktrace) {
          print(e);
          print(stacktrace);
        }
      });
    }

    return URLProtectionSpace(
      host: map["host"],
      protocol: map["protocol"],
      realm: map["realm"],
      port: map["port"],
      sslCertificate: SslCertificate.fromMap(
          map["sslCertificate"]?.cast<String, dynamic>()),
      sslError: SslError.fromMap(map["sslError"]?.cast<String, dynamic>()),
      // ignore: deprecated_member_use_from_same_package
      iosAuthenticationMethod:
      // ignore: deprecated_member_use_from_same_package
      IOSNSURLProtectionSpaceAuthenticationMethod.fromValue(
          map["authenticationMethod"]),
      authenticationMethod: URLProtectionSpaceAuthenticationMethod.fromValue(
          map["authenticationMethod"]),
      // ignore: deprecated_member_use_from_same_package
      iosDistinguishedNames: distinguishedNames,
      distinguishedNames: distinguishedNames,
      // ignore: deprecated_member_use_from_same_package
      iosReceivesCredentialSecurely: map["receivesCredentialSecurely"],
      receivesCredentialSecurely: map["receivesCredentialSecurely"],
      // ignore: deprecated_member_use_from_same_package
      iosIsProxy: map["isProxy"],
      isProxy: map["isProxy"],
      // ignore: deprecated_member_use_from_same_package
      iosProxyType:
      // ignore: deprecated_member_use_from_same_package
      IOSNSURLProtectionSpaceProxyType.fromValue(map["proxyType"]),
      proxyType: URLProtectionSpaceProxyType.fromValue(map["proxyType"]),
    );
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
      "iosAuthenticationMethod":
      // ignore: deprecated_member_use_from_same_package
      authenticationMethod ?? iosAuthenticationMethod,
      // ignore: deprecated_member_use_from_same_package
      "authenticationMethod": authenticationMethod ?? iosAuthenticationMethod,
      // ignore: deprecated_member_use_from_same_package
      "iosDistinguishedNames": (distinguishedNames ?? iosDistinguishedNames)
          ?.map((e) => e.toMap())
          .toList(),
      // ignore: deprecated_member_use_from_same_package
      "distinguishedNames": (distinguishedNames ?? iosDistinguishedNames)
          ?.map((e) => e.toMap())
          .toList(),
      "iosReceivesCredentialSecurely":
      // ignore: deprecated_member_use_from_same_package
      receivesCredentialSecurely ?? iosReceivesCredentialSecurely,
      "receivesCredentialSecurely":
      // ignore: deprecated_member_use_from_same_package
      receivesCredentialSecurely ?? iosReceivesCredentialSecurely,
      // ignore: deprecated_member_use_from_same_package
      "iosIsProxy": isProxy ?? iosIsProxy,
      // ignore: deprecated_member_use_from_same_package
      "isProxy": isProxy ?? iosIsProxy,
      // ignore: deprecated_member_use_from_same_package
      "iosProxyType": proxyType?.toValue() ?? iosProxyType?.toValue(),
      // ignore: deprecated_member_use_from_same_package
      "proxyType": proxyType?.toValue() ?? iosProxyType?.toValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}