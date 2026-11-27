import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

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
      URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodDefault",
      );

  ///Use HTTP basic authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_BASIC =
      URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPBasic",
      );

  ///Use HTTP digest authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_DIGEST =
      URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPDigest",
      );

  ///Use HTML form authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTML_FORM =
      URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTMLForm",
      );

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodClientCertificate",
      );

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNegotiate",
      );

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      URLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNTLM",
      );

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      URLProtectionSpaceAuthenticationMethod_._internal(
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
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodDefault",
      );

  ///Use HTTP basic authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_BASIC =
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPBasic",
      );

  ///Use HTTP digest authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTTP_DIGEST =
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTTPDigest",
      );

  ///Use HTML form authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_HTML_FORM =
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodHTMLForm",
      );

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodClientCertificate",
      );

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNegotiate",
      );

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodNTLM",
      );

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      IOSNSURLProtectionSpaceAuthenticationMethod_._internal(
        "NSURLAuthenticationMethodServerTrust",
      );
}
