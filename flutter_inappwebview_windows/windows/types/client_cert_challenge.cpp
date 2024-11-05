#include "../utils/flutter.h"
#include "client_cert_challenge.h"

namespace flutter_inappwebview_plugin
{
  ClientCertChallenge::ClientCertChallenge(const std::shared_ptr<URLProtectionSpace> protectionSpace,
    const std::vector<std::string>& allowedCertificateAuthorities,
    const bool& isProxy,
    const std::vector<std::shared_ptr<SslCertificate>>& mutuallyTrustedCertificates)
    : URLAuthenticationChallenge(protectionSpace), allowedCertificateAuthorities(allowedCertificateAuthorities), isProxy(isProxy), mutuallyTrustedCertificates(mutuallyTrustedCertificates)
  {}

  flutter::EncodableMap ClientCertChallenge::toEncodableMap() const
  {
    auto map = URLAuthenticationChallenge::toEncodableMap();
    map.insert({ "allowedCertificateAuthorities", make_fl_value(allowedCertificateAuthorities) });
    map.insert({ "isProxy", make_fl_value(isProxy) });
    map.insert({ "mutuallyTrustedCertificates", make_fl_value(functional_map(mutuallyTrustedCertificates, [](const std::shared_ptr<SslCertificate>& item) { return item->toEncodableMap(); })) });
    return map;
  }
}