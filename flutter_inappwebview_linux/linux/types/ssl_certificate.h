#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SSL_CERTIFICATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SSL_CERTIFICATE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

/// SSL Certificate information for HTTPS connections.
/// Maps to Dart's SslCertificate class.
class SslCertificate {
 public:
  /// The raw X.509 certificate data in DER format.
  const std::optional<std::vector<uint8_t>> x509Certificate;

  /// Constructor with raw certificate data.
  explicit SslCertificate(const std::optional<std::vector<uint8_t>>& x509Certificate);

  /// Constructor from FlValue map (for deserialization from Dart).
  explicit SslCertificate(FlValue* map);

  ~SslCertificate() = default;

  /// Convert to FlValue map for sending to Dart.
  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_SSL_CERTIFICATE_H_
