#include "../utils/flutter.h"
#include "security_origin.h"

namespace flutter_inappwebview_plugin
{
  SecurityOrigin::SecurityOrigin(const std::string& host, const int64_t& port, const std::string& protocol)
    : host(host), port(port), protocol(protocol)
  {}

  flutter::EncodableMap SecurityOrigin::toEncodableMap() const
  {
    return flutter::EncodableMap{
        {"host", make_fl_value(host)},
        {"port", make_fl_value(port)},
        {"protocol", make_fl_value(protocol)}
    };
  }
}