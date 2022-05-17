import 'dart:typed_data';

import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../x509_certificate/x509_certificate.dart';
import 'url_protection_space_proxy_type.dart';
import 'url_protection_space_authentication_method.dart';
import 'ssl_error.dart';
import 'ssl_certificate.dart';

part 'url_protection_space.g.dart';

List<X509Certificate>? _distinguishedNamesDeserializer(dynamic value) {
  List<X509Certificate>? distinguishedNames;
  if (value != null) {
    distinguishedNames = <X509Certificate>[];
    (value.cast<Uint8List>() as List<Uint8List>)
        .forEach((data) {
      try {
        distinguishedNames!.add(X509Certificate.fromData(data: data));
      } catch (e, stacktrace) {
        print(e);
        print(stacktrace);
      }
    });
  }
  return distinguishedNames;
}

///Class that represents a protection space requiring authentication.
@ExchangeableObject()
class URLProtectionSpace_ {
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
  SslCertificate_? sslCertificate;

  ///The SSL Error associated.
  SslError? sslError;

  ///Use [authenticationMethod] instead.
  @Deprecated("Use authenticationMethod instead")
  IOSNSURLProtectionSpaceAuthenticationMethod_? iosAuthenticationMethod;

  ///The authentication method used by the receiver.
  ///
  ///**NOTE**: available only on iOS.
  URLProtectionSpaceAuthenticationMethod_? authenticationMethod;

  ///Use [distinguishedNames] instead.
  @Deprecated("Use distinguishedNames instead")
  @ExchangeableObjectProperty(
      deserializer: _distinguishedNamesDeserializer
  )
  List<X509Certificate>? iosDistinguishedNames;

  ///The acceptable certificate-issuing authorities for client certificate authentication.
  ///This value is `null` if the authentication method of the protection space is not client certificate.
  ///The returned issuing authorities are encoded with Distinguished Encoding Rules (DER).
  ///
  ///**NOTE**: available only on iOS.
  @ExchangeableObjectProperty(
      deserializer: _distinguishedNamesDeserializer
  )
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

  URLProtectionSpace_(
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
        this.proxyType});
}