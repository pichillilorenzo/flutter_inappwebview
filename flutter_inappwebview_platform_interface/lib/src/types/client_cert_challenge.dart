import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_authentication_challenge.dart';
import 'url_protection_space.dart';
import '../in_app_webview/platform_webview.dart';
import '../types/ssl_certificate.dart';
import 'enum_method.dart';

part 'client_cert_challenge.g.dart';

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
@ExchangeableObject()
class ClientCertChallenge_ extends URLAuthenticationChallenge_ {
  ///Use [principals] instead.
  @Deprecated('Use principals instead')
  List<String>? androidPrincipals;

  ///The acceptable certificate issuers for the certificate matching the private key.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "ClientCertRequest.getPrincipals",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/ClientCertRequest#getPrincipals()",
        available: "21",
      ),
    ],
  )
  List<String>? principals;

  ///Use [keyTypes] instead.
  @Deprecated('Use keyTypes instead')
  List<String>? androidKeyTypes;

  ///Returns the acceptable types of asymmetric keys.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: "ClientCertRequest.getKeyTypes",
        apiUrl:
            "https://developer.android.com/reference/android/webkit/ClientCertRequest#getKeyTypes()",
        available: "21",
      ),
    ],
  )
  List<String>? keyTypes;

  ///The collection contains Base64 encoding of DER encoded distinguished names
  ///of certificate authorities allowed by the server.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  List<String>? allowedCertificateAuthorities;

  ///If the server that issued this request is an http proxy.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  bool? isProxy;

  ///The collection contains mutually trusted CA certificates.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  List<SslCertificate_>? mutuallyTrustedCertificates;

  ClientCertChallenge_({
    required URLProtectionSpace_ protectionSpace,
    @Deprecated('Use principals instead') this.androidPrincipals,
    this.principals,
    @Deprecated('Use keyTypes instead') this.androidKeyTypes,
    this.keyTypes,
    this.allowedCertificateAuthorities,
    this.isProxy,
    this.mutuallyTrustedCertificates,
  }) : super(protectionSpace: protectionSpace);
}
