#include "ssl_certificate.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

SslCertificate::SslCertificate(const std::optional<std::vector<uint8_t>>& x509Certificate)
    : x509Certificate(x509Certificate) {}

SslCertificate::SslCertificate(FlValue* map)
    : x509Certificate(get_optional_fl_map_value<std::vector<uint8_t>>(map, "x509Certificate")) {}

FlValue* SslCertificate::toFlValue() const {
  return to_fl_map({
      {"x509Certificate", make_fl_value(x509Certificate)},
  });
}

}  // namespace flutter_inappwebview_plugin
