import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_protection_space.dart';

part 'url_protection_space_authentication_method.g.dart';

///Class that represents the constants describing known values of the [URLProtectionSpace.authenticationMethod] property.
@ExchangeableEnum()
class URLProtectionSpaceAuthenticationMethod_ {
  // ignore: unused_field
  final String _value;
  const URLProtectionSpaceAuthenticationMethod_._internal(this._value);

  ///Use the default authentication method for a protocol.
  static const NSURL_AUTHENTICATION_METHOD_DEFAULT =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodDefault",
      );

  ///Use HTTP basic authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_BASIC =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPBasic",
      );

  ///Use HTTP digest authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_DIGEST =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPDigest",
      );

  ///Use HTML form authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTML_FORM =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTMLForm",
      );

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodClientCertificate",
      );

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNegotiate",
      );

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNTLM",
      );

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      const URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodServerTrust",
      );
}

///An iOS-specific Class that represents the constants describing known values of the [URLProtectionSpace.authenticationMethod] property.
///Use [URLProtectionSpaceAuthenticationMethod] instead.
@Deprecated("Use URLProtectionSpaceAuthenticationMethod instead")
@ExchangeableEnum()
class IOSNSURLProtectionSpaceAuthenticationMethod_ {
  // ignore: unused_field
  final String _value;
  const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(this._value);

  ///Use the default authentication method for a protocol.
  static const NSURL_AUTHENTICATION_METHOD_DEFAULT =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodDefault",
      );

  ///Use HTTP basic authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_BASIC =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPBasic",
      );

  ///Use HTTP digest authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_DIGEST =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPDigest",
      );

  ///Use HTML form authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTML_FORM =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTMLForm",
      );

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodClientCertificate",
      );

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNegotiate",
      );

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNTLM",
      );

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      const IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodServerTrust",
      );
}
