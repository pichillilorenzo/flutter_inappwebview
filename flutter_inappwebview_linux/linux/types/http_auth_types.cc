#include "http_auth_types.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

// === URLProtectionSpace ===

URLProtectionSpace::URLProtectionSpace(const std::string& host,
                                       int64_t port,
                                       const std::optional<std::string>& protocol,
                                       const std::optional<std::string>& realm,
                                       HttpAuthScheme authenticationMethod,
                                       bool isProxy)
    : host(host),
      port(port),
      protocol(protocol),
      realm(realm),
      authenticationMethod(authenticationMethod),
      isProxy(isProxy) {}

FlValue* URLProtectionSpace::toFlValue() const {
  FlValue* map = fl_value_new_map();
  
  fl_value_set_string_take(map, "host", fl_value_new_string(host.c_str()));
  fl_value_set_string_take(map, "port", fl_value_new_int(port));
  
  if (protocol.has_value()) {
    fl_value_set_string_take(map, "protocol",
                             fl_value_new_string(protocol.value().c_str()));
  } else {
    fl_value_set_string_take(map, "protocol", fl_value_new_null());
  }
  
  if (realm.has_value()) {
    fl_value_set_string_take(map, "realm",
                             fl_value_new_string(realm.value().c_str()));
  } else {
    fl_value_set_string_take(map, "realm", fl_value_new_null());
  }
  
  fl_value_set_string_take(map, "authenticationMethod",
                           fl_value_new_int(static_cast<int64_t>(authenticationMethod)));
  fl_value_set_string_take(map, "isProxy", fl_value_new_bool(isProxy));
  
  // SSL certificate info - not easily available from WebKitGTK auth request
  fl_value_set_string_take(map, "sslCertificate", fl_value_new_null());
  fl_value_set_string_take(map, "sslError", fl_value_new_null());
  
  return map;
}

HttpAuthScheme URLProtectionSpace::fromWebKitScheme(
    WebKitAuthenticationScheme scheme) {
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

// === HttpAuthenticationChallenge ===

HttpAuthenticationChallenge::HttpAuthenticationChallenge(
    const URLProtectionSpace& protectionSpace,
    bool isRetry)
    : protectionSpace(protectionSpace), isRetry(isRetry) {}

FlValue* HttpAuthenticationChallenge::toFlValue() const {
  FlValue* map = fl_value_new_map();
  
  fl_value_set_string_take(map, "protectionSpace", protectionSpace.toFlValue());
  
  // previousFailureCount is just a string representation
  if (previousFailureCount.has_value()) {
    fl_value_set_string_take(
        map, "previousFailureCount",
        fl_value_new_string(previousFailureCount.value().c_str()));
  }
  
  // proposedCredential - not readily available from WebKitGTK
  fl_value_set_string_take(map, "proposedCredential", fl_value_new_null());
  
  // failureResponse - not available
  fl_value_set_string_take(map, "failureResponse", fl_value_new_null());
  
  // error - not available in the same form
  fl_value_set_string_take(map, "error", fl_value_new_null());
  
  return map;
}

// === HttpAuthResponse ===

HttpAuthResponse::HttpAuthResponse()
    : action(HttpAuthResponseAction::CANCEL), permanentPersistence(false) {}

HttpAuthResponse::HttpAuthResponse(FlValue* map)
    : action(HttpAuthResponseAction::CANCEL), permanentPersistence(false) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }
  
  username = get_optional_fl_map_value<std::string>(map, "username");
  password = get_optional_fl_map_value<std::string>(map, "password");
  
  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<HttpAuthResponseAction>(actionInt);
  
  permanentPersistence = get_fl_map_value(map, "permanentPersistence", false);
}

// === URLCredential ===

URLCredential::URLCredential() {}

URLCredential::URLCredential(const std::optional<std::string>& username,
                             const std::optional<std::string>& password)
    : username(username), password(password) {}

URLCredential::URLCredential(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }
  
  username = get_optional_fl_map_value<std::string>(map, "username");
  password = get_optional_fl_map_value<std::string>(map, "password");
}

FlValue* URLCredential::toFlValue() const {
  FlValue* map = fl_value_new_map();
  
  if (username.has_value()) {
    fl_value_set_string_take(map, "username",
                             fl_value_new_string(username.value().c_str()));
  } else {
    fl_value_set_string_take(map, "username", fl_value_new_null());
  }
  
  if (password.has_value()) {
    fl_value_set_string_take(map, "password",
                             fl_value_new_string(password.value().c_str()));
  } else {
    fl_value_set_string_take(map, "password", fl_value_new_null());
  }
  
  return map;
}

}  // namespace flutter_inappwebview_plugin
