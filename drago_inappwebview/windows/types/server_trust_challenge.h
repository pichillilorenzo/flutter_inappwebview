#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "url_authentication_challenge.h"

namespace drago_inappwebview_plugin
{
  class ServerTrustChallenge : URLAuthenticationChallenge
  {
  public:
    ServerTrustChallenge(const std::shared_ptr<URLProtectionSpace> protectionSpace);
    ~ServerTrustChallenge() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_