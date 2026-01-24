#include "server_trust_challenge.h"

#include <cstring>
#include <sstream>

#include "../utils/flutter.h"
#include "../utils/uri.h"

namespace flutter_inappwebview_plugin {

// === SslError ===

SslError::SslError(SslErrorType code, const std::optional<std::string>& message)
    : code(code), message(message) {}

FlValue* SslError::toFlValue() const {
  std::string codeStr;
  switch (code) {
    case SslErrorType::NOT_YET_VALID:
      codeStr = "NOT_YET_VALID";
      break;
    case SslErrorType::EXPIRED:
      codeStr = "EXPIRED";
      break;
    case SslErrorType::IDMISMATCH:
      codeStr = "IDMISMATCH";
      break;
    case SslErrorType::UNTRUSTED:
      codeStr = "UNTRUSTED";
      break;
    case SslErrorType::REVOKED:
      codeStr = "REVOKED";
      break;
    case SslErrorType::INSECURE:
      codeStr = "INSECURE";
      break;
    case SslErrorType::INVALID:
    default:
      codeStr = "INVALID";
      break;
  }

  return to_fl_map({
      {"code", make_fl_value(codeStr)},
      {"message", make_fl_value(message)},
  });
}

SslError SslError::fromGTlsCertificateFlags(GTlsCertificateFlags flags) {
  // Map the most significant error
  // WPE WebKit may set multiple flags, we pick the most relevant one
  SslErrorType code;
  std::string message;

  if (flags & G_TLS_CERTIFICATE_UNKNOWN_CA) {
    code = SslErrorType::UNTRUSTED;
    message = "The signing certificate authority is not known.";
  } else if (flags & G_TLS_CERTIFICATE_BAD_IDENTITY) {
    code = SslErrorType::IDMISMATCH;
    message = "The certificate does not match the expected identity of the site.";
  } else if (flags & G_TLS_CERTIFICATE_EXPIRED) {
    code = SslErrorType::EXPIRED;
    message = "The certificate has expired.";
  } else if (flags & G_TLS_CERTIFICATE_NOT_ACTIVATED) {
    code = SslErrorType::NOT_YET_VALID;
    message = "The certificate's activation time is still in the future.";
  } else if (flags & G_TLS_CERTIFICATE_REVOKED) {
    code = SslErrorType::REVOKED;
    message = "The certificate has been revoked.";
  } else if (flags & G_TLS_CERTIFICATE_INSECURE) {
    code = SslErrorType::INSECURE;
    message = "The certificate's algorithm is considered insecure.";
  } else if (flags & G_TLS_CERTIFICATE_GENERIC_ERROR) {
    code = SslErrorType::INVALID;
    message = "A generic error occurred validating the certificate.";
  } else {
    code = SslErrorType::INVALID;
    message = "Unknown TLS certificate error.";
  }

  return SslError(code, message);
}

// === ServerTrustURLProtectionSpace ===

ServerTrustURLProtectionSpace::ServerTrustURLProtectionSpace(
    const std::string& host, int64_t port,
    const std::optional<std::string>& protocol,
    std::shared_ptr<SslCertificate> sslCertificate,
    std::shared_ptr<SslError> sslError)
    : host(host), port(port), protocol(protocol), sslCertificate(sslCertificate),
      sslError(sslError) {}

FlValue* ServerTrustURLProtectionSpace::toFlValue() const {
  return to_fl_map({
      {"host", make_fl_value(host)},
      {"port", make_fl_value(port)},
      {"protocol", make_fl_value(protocol)},
      {"sslCertificate", sslCertificate ? sslCertificate->toFlValue() : fl_value_new_null()},
      {"sslError", sslError ? sslError->toFlValue() : fl_value_new_null()},
      // Include authenticationMethod as SERVER_TRUST
      {"authenticationMethod", make_fl_value(std::string("NSURLAuthenticationMethodServerTrust"))},
  });
}

// === ServerTrustChallenge ===

ServerTrustChallenge::ServerTrustChallenge(
    std::shared_ptr<ServerTrustURLProtectionSpace> protectionSpace)
    : protectionSpace(protectionSpace) {}

FlValue* ServerTrustChallenge::toFlValue() const {
  return to_fl_map({
      {"protectionSpace", protectionSpace ? protectionSpace->toFlValue() : fl_value_new_null()},
  });
}

std::unique_ptr<ServerTrustChallenge> ServerTrustChallenge::fromTlsError(
    const std::string& failingUri, GTlsCertificate* certificate, GTlsCertificateFlags errors) {

  // Parse host and port from the failing URI
  std::string host = get_host_from_url(failingUri);
  int64_t port = 443;  // Default to HTTPS port

  // Try to extract port from URL
  // Simple parsing - look for :port after host
  size_t schemeEnd = failingUri.find("://");
  if (schemeEnd != std::string::npos) {
    size_t hostStart = schemeEnd + 3;
    size_t pathStart = failingUri.find('/', hostStart);
    std::string hostPort = (pathStart != std::string::npos) ?
        failingUri.substr(hostStart, pathStart - hostStart) :
        failingUri.substr(hostStart);

    size_t colonPos = hostPort.rfind(':');
    if (colonPos != std::string::npos) {
      try {
        port = std::stoll(hostPort.substr(colonPos + 1));
      } catch (...) {
        // Keep default port
      }
    }
  }

  // Extract protocol
  std::optional<std::string> protocol;
  std::string scheme = get_scheme_from_url(failingUri);
  if (!scheme.empty()) {
    protocol = scheme;
  }

  // Extract certificate data
  std::shared_ptr<SslCertificate> sslCertificate;
  if (certificate != nullptr) {
    GByteArray* certData = nullptr;
    g_object_get(certificate, "certificate", &certData, nullptr);
    if (certData != nullptr) {
      std::vector<uint8_t> derData(certData->data, certData->data + certData->len);
      sslCertificate = std::make_shared<SslCertificate>(derData);
      g_byte_array_unref(certData);
    }
  }

  // Convert error flags to SslError
  auto sslError = std::make_shared<SslError>(SslError::fromGTlsCertificateFlags(errors));

  // Create protection space
  auto protectionSpace = std::make_shared<ServerTrustURLProtectionSpace>(
      host, port, protocol, sslCertificate, sslError);

  return std::make_unique<ServerTrustChallenge>(protectionSpace);
}

}  // namespace flutter_inappwebview_plugin
