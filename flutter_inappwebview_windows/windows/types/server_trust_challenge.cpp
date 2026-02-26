#include "../utils/flutter.h"
#include "server_trust_challenge.h"

namespace flutter_inappwebview_plugin
{
  ServerTrustChallenge::ServerTrustChallenge(const std::shared_ptr<URLProtectionSpace> protectionSpace)
    : URLAuthenticationChallenge(protectionSpace)
  {}

  flutter::EncodableMap ServerTrustChallenge::toEncodableMap() const
  {
    auto map = URLAuthenticationChallenge::toEncodableMap();
    return map;
  }
}