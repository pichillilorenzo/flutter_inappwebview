#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "url_authentication_challenge.h"

namespace flutter_inappwebview_plugin
{
  class ServerTrustChallenge : URLAuthenticationChallenge
  {
  public:
    ServerTrustChallenge(const std::shared_ptr<URLProtectionSpace> protectionSpace);
    ~ServerTrustChallenge() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_