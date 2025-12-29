#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_TYPES_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_TYPES_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <cstdint>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * HTTP authentication scheme types.
 */
enum class HttpAuthScheme {
  DEFAULT = 0,
  HTTP_BASIC = 1,
  HTTP_DIGEST = 2,
  HTML_FORM = 3,
  NTLM = 4,
  NEGOTIATE = 5,
  CLIENT_CERTIFICATE = 6,
  SERVER_TRUST = 7,
  UNKNOWN = -1
};

/**
 * URL protection space - describes the realm requiring authentication.
 */
class URLProtectionSpace {
 public:
  std::string host;
  int64_t port;
  std::optional<std::string> protocol;
  std::optional<std::string> realm;
  HttpAuthScheme authenticationMethod;
  bool isProxy;

  URLProtectionSpace(const std::string& host, int64_t port,
                     const std::optional<std::string>& protocol,
                     const std::optional<std::string>& realm,
                     HttpAuthScheme authenticationMethod,
                     bool isProxy);
  ~URLProtectionSpace() = default;

  FlValue* toFlValue() const;
  
  static HttpAuthScheme fromWebKitScheme(WebKitAuthenticationScheme scheme);
};

/**
 * HTTP authentication challenge - sent when server requires authentication.
 */
class HttpAuthenticationChallenge {
 public:
  URLProtectionSpace protectionSpace;
  std::optional<std::string> previousFailureCount;  // Number of retry attempts
  bool isRetry;

  HttpAuthenticationChallenge(const URLProtectionSpace& protectionSpace,
                              bool isRetry);
  ~HttpAuthenticationChallenge() = default;

  FlValue* toFlValue() const;
};

/**
 * HTTP authentication response action.
 */
enum class HttpAuthResponseAction {
  CANCEL = 0,
  PROCEED = 1,
  USE_SAVED_CREDENTIAL = 2
};

/**
 * Response to an HTTP authentication challenge.
 */
class HttpAuthResponse {
 public:
  std::optional<std::string> username;
  std::optional<std::string> password;
  HttpAuthResponseAction action;
  bool permanentPersistence;

  HttpAuthResponse();
  HttpAuthResponse(FlValue* map);
  ~HttpAuthResponse() = default;
};

/**
 * URL credential for storing/providing authentication credentials.
 */
class URLCredential {
 public:
  std::optional<std::string> username;
  std::optional<std::string> password;

  URLCredential();
  URLCredential(const std::optional<std::string>& username,
                const std::optional<std::string>& password);
  URLCredential(FlValue* map);
  ~URLCredential() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_TYPES_H_
