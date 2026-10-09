#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_CHALLENGE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_CHALLENGE_H_

#include <flutter/standard_method_codec.h>
#include <string>
#include <vector>

#include "url_authentication_challenge.h"

namespace drago_inappwebview_plugin
{
  class ClientCertChallenge : URLAuthenticationChallenge
  {
  public:
    const std::vector<std::string> allowedCertificateAuthorities;
    const bool isProxy;
    const std::vector<std::shared_ptr<SslCertificate>> mutuallyTrustedCertificates;

    ClientCertChallenge(const std::shared_ptr<URLProtectionSpace> protectionSpace,
      const std::vector<std::string>& allowedCertificateAuthorities,
      const bool& isProxy,
      const std::vector<std::shared_ptr<SslCertificate>>& mutuallyTrustedCertificates);
    ~ClientCertChallenge() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_CHALLENGE_H_