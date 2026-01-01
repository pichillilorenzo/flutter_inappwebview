#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTHENTICATION_CHALLENGE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTHENTICATION_CHALLENGE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

#include "url_protection_space.h"

namespace flutter_inappwebview_plugin {

/**
 * HTTP authentication challenge - sent when server requires authentication.
 */
class HttpAuthenticationChallenge {
 public:
  URLProtectionSpace protectionSpace;
  std::optional<std::string> previousFailureCount;  // Number of retry attempts
  bool isRetry;

  HttpAuthenticationChallenge(const URLProtectionSpace& protectionSpace, bool isRetry);
  ~HttpAuthenticationChallenge() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTHENTICATION_CHALLENGE_H_
