#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_URL_PROTECTION_SPACE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_URL_PROTECTION_SPACE_H_

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
                     const std::optional<std::string>& realm, HttpAuthScheme authenticationMethod,
                     bool isProxy);
  ~URLProtectionSpace() = default;

  FlValue* toFlValue() const;

  static HttpAuthScheme fromWebKitScheme(WebKitAuthenticationScheme scheme);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_URL_PROTECTION_SPACE_H_
