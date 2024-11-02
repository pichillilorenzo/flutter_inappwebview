#include "../utils/flutter.h"
#include "url_protection_space.h"

namespace flutter_inappwebview_plugin
{
  URLProtectionSpace::URLProtectionSpace(const std::string& host, const std::string& protocol,
    const std::optional<std::string>& realm, const int64_t& port,
    const std::optional<std::shared_ptr<SslCertificate>> sslCertificate,
    const std::optional<std::shared_ptr<SslError>> sslError)
    : host(host), protocol(protocol), realm(realm), port(port), sslCertificate(sslCertificate), sslError(sslError)
  {}

  flutter::EncodableMap URLProtectionSpace::toEncodableMap() const
  {
    return flutter::EncodableMap{
    {"host", make_fl_value(host)},
    {"protocol", make_fl_value(protocol)},
    {"realm", make_fl_value(realm)},
    {"port", make_fl_value(port)},
    {"sslCertificate", sslCertificate.has_value() ? sslCertificate.value()->toEncodableMap() : make_fl_value()},
    {"sslError", sslError.has_value() ? sslError.value()->toEncodableMap() : make_fl_value()},
    };
  }
}