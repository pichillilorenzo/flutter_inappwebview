#include "url_protection_space.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

// Convert HttpAuthScheme to the string values expected by the platform interface
static std::optional<std::string> authSchemeToString(HttpAuthScheme scheme) {
  switch (scheme) {
    case HttpAuthScheme::DEFAULT:
      return "NSURLAuthenticationMethodDefault";
    case HttpAuthScheme::HTTP_BASIC:
      return "NSURLAuthenticationMethodHTTPBasic";
    case HttpAuthScheme::HTTP_DIGEST:
      return "NSURLAuthenticationMethodHTTPDigest";
    case HttpAuthScheme::HTML_FORM:
      return "NSURLAuthenticationMethodHTMLForm";
    case HttpAuthScheme::NTLM:
      return "NSURLAuthenticationMethodNTLM";
    case HttpAuthScheme::NEGOTIATE:
      return "NSURLAuthenticationMethodNegotiate";
    case HttpAuthScheme::CLIENT_CERTIFICATE:
      return "NSURLAuthenticationMethodClientCertificate";
    case HttpAuthScheme::SERVER_TRUST:
      return "NSURLAuthenticationMethodServerTrust";
    case HttpAuthScheme::UNKNOWN:
    default:
      return std::nullopt;
  }
}

URLProtectionSpace::URLProtectionSpace(const std::string& host, int64_t port,
                                       const std::optional<std::string>& protocol,
                                       const std::optional<std::string>& realm,
                                       HttpAuthScheme authenticationMethod, bool isProxy)
    : host(host),
      port(port),
      protocol(protocol),
      realm(realm),
      authenticationMethod(authenticationMethod),
      isProxy(isProxy) {}

FlValue* URLProtectionSpace::toFlValue() const {
  auto authMethodStr = authSchemeToString(authenticationMethod);
  return to_fl_map({
      {"host", make_fl_value(host)},
      {"port", make_fl_value(port)},
      {"protocol", make_fl_value(protocol)},
      {"realm", make_fl_value(realm)},
      {"authenticationMethod", make_fl_value(authMethodStr)},
      {"isProxy", make_fl_value(isProxy)},
      {"sslCertificate", make_fl_value()},
      {"sslError", make_fl_value()},
  });
}

HttpAuthScheme URLProtectionSpace::fromWebKitScheme(WebKitAuthenticationScheme scheme) {
  switch (scheme) {
    case WEBKIT_AUTHENTICATION_SCHEME_DEFAULT:
      return HttpAuthScheme::DEFAULT;
    case WEBKIT_AUTHENTICATION_SCHEME_HTTP_BASIC:
      return HttpAuthScheme::HTTP_BASIC;
    case WEBKIT_AUTHENTICATION_SCHEME_HTTP_DIGEST:
      return HttpAuthScheme::HTTP_DIGEST;
    case WEBKIT_AUTHENTICATION_SCHEME_HTML_FORM:
      return HttpAuthScheme::HTML_FORM;
    case WEBKIT_AUTHENTICATION_SCHEME_NTLM:
      return HttpAuthScheme::NTLM;
    case WEBKIT_AUTHENTICATION_SCHEME_NEGOTIATE:
      return HttpAuthScheme::NEGOTIATE;
    case WEBKIT_AUTHENTICATION_SCHEME_CLIENT_CERTIFICATE_REQUESTED:
      return HttpAuthScheme::CLIENT_CERTIFICATE;
    case WEBKIT_AUTHENTICATION_SCHEME_SERVER_TRUST_EVALUATION_REQUESTED:
      return HttpAuthScheme::SERVER_TRUST;
    default:
      return HttpAuthScheme::UNKNOWN;
  }
}

}  // namespace flutter_inappwebview_plugin
