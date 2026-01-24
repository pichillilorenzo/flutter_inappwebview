#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_CHALLENGE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_CHALLENGE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>
#include <vector>

#include "url_protection_space.h"
#include "ssl_certificate.h"

namespace flutter_inappwebview_plugin {

/**
 * Client certificate challenge - sent when server requests a client certificate.
 * 
 * This is used for mTLS (mutual TLS) authentication scenarios.
 * 
 * NOTE: WPE WebKit's support for providing client certificates programmatically
 * is limited. The `webkit_credential_new_for_certificate()` API (since 2.34)
 * allows providing a certificate, but this may not be available on all systems.
 * When not available, the app can at least be notified of the request.
 */
class ClientCertChallenge {
 public:
  URLProtectionSpace protectionSpace;
  
  // Whether this is a proxy authentication request
  bool isProxy;
  
  // Key types accepted by the server (if available)
  std::vector<std::string> keyTypes;
  
  // Certificate authorities accepted by the server (Base64 DER encoded, if available)
  std::vector<std::string> principals;
  
  // Allowed certificate authorities (Base64 encoded, for Windows compatibility)
  std::vector<std::string> allowedCertificateAuthorities;
  
  // Mutually trusted certificates (if available)
  std::vector<SslCertificate> mutuallyTrustedCertificates;

  ClientCertChallenge(const URLProtectionSpace& protectionSpace, bool isProxy);
  ~ClientCertChallenge() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_CHALLENGE_H_
