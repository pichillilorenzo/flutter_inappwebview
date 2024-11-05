#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTHENTICATION_CHALLENGE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTHENTICATION_CHALLENGE_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "url_authentication_challenge.h"
#include "url_credential.h"

namespace flutter_inappwebview_plugin
{
  class HttpAuthenticationChallenge : URLAuthenticationChallenge
  {
  public:
      const int64_t previousFailureCount;
      const std::optional<std::shared_ptr<URLCredential>> proposedCredential;

      HttpAuthenticationChallenge(const std::shared_ptr<URLProtectionSpace> protectionSpace,
                                  const int64_t& previousFailureCount,
                                  const std::optional<std::shared_ptr<URLCredential>> proposedCredential);
    ~HttpAuthenticationChallenge() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_HTTP_AUTHENTICATION_CHALLENGE_H_