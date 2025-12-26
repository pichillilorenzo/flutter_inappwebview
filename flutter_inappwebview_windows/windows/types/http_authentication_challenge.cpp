#include "../utils/flutter.h"
#include "http_authentication_challenge.h"

namespace flutter_inappwebview_plugin
{
  HttpAuthenticationChallenge::HttpAuthenticationChallenge(const std::shared_ptr<URLProtectionSpace> protectionSpace,
    const int64_t& previousFailureCount,
    const std::optional<std::shared_ptr<URLCredential>> proposedCredential)
    : URLAuthenticationChallenge(protectionSpace), previousFailureCount(previousFailureCount), proposedCredential(proposedCredential)
  {}

  flutter::EncodableMap HttpAuthenticationChallenge::toEncodableMap() const
  {
    auto map = URLAuthenticationChallenge::toEncodableMap();
    map.insert({ "previousFailureCount", make_fl_value(previousFailureCount) });
    map.insert({ "proposedCredential", proposedCredential.has_value() ? proposedCredential.value()->toEncodableMap() : make_fl_value() });
    return map;
  }
}