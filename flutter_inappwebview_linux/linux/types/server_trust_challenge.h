#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_

#include <flutter_linux/flutter_linux.h>
#include <gio/gio.h>

#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "ssl_certificate.h"

namespace flutter_inappwebview_plugin {

/**
 * SSL Error type - maps to Dart's SslErrorType.
 * Based on GTlsCertificateFlags.
 */
enum class SslErrorType {
  INVALID = 0,           // G_TLS_CERTIFICATE_GENERIC_ERROR
  NOT_YET_VALID = 1,     // G_TLS_CERTIFICATE_NOT_ACTIVATED
  EXPIRED = 2,           // G_TLS_CERTIFICATE_EXPIRED
  IDMISMATCH = 3,        // G_TLS_CERTIFICATE_BAD_IDENTITY
  UNTRUSTED = 4,         // G_TLS_CERTIFICATE_UNKNOWN_CA
  REVOKED = 5,           // G_TLS_CERTIFICATE_REVOKED
  INSECURE = 6,          // G_TLS_CERTIFICATE_INSECURE
};

/**
 * SSL Error information - maps to Dart's SslError class.
 */
class SslError {
 public:
  SslErrorType code;
  std::optional<std::string> message;

  SslError(SslErrorType code, const std::optional<std::string>& message);
  ~SslError() = default;

  FlValue* toFlValue() const;

  static SslError fromGTlsCertificateFlags(GTlsCertificateFlags flags);
};

/**
 * URL Protection Space for server trust authentication.
 * Extended version that includes SSL certificate and error info.
 */
class ServerTrustURLProtectionSpace {
 public:
  std::string host;
  int64_t port;
  std::optional<std::string> protocol;
  std::shared_ptr<SslCertificate> sslCertificate;
  std::shared_ptr<SslError> sslError;

  ServerTrustURLProtectionSpace(const std::string& host, int64_t port,
                                 const std::optional<std::string>& protocol,
                                 std::shared_ptr<SslCertificate> sslCertificate,
                                 std::shared_ptr<SslError> sslError);
  ~ServerTrustURLProtectionSpace() = default;

  FlValue* toFlValue() const;
};

/**
 * Server Trust Challenge - sent when a TLS error occurs.
 * Maps to Dart's ServerTrustChallenge class.
 */
class ServerTrustChallenge {
 public:
  std::shared_ptr<ServerTrustURLProtectionSpace> protectionSpace;

  explicit ServerTrustChallenge(std::shared_ptr<ServerTrustURLProtectionSpace> protectionSpace);
  ~ServerTrustChallenge() = default;

  FlValue* toFlValue() const;

  /**
   * Create a ServerTrustChallenge from WPE WebKit TLS error parameters.
   */
  static std::unique_ptr<ServerTrustChallenge> fromTlsError(
      const std::string& failingUri, GTlsCertificate* certificate, GTlsCertificateFlags errors);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_CHALLENGE_H_
