#include "../utils/flutter.h"
#include "ssl_error.h"

namespace flutter_inappwebview_plugin
{
  SslError::SslError(const COREWEBVIEW2_WEB_ERROR_STATUS& code, const std::optional<std::string>& message)
    : code(code), message(message)
  {}

  flutter::EncodableMap SslError::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"code", make_fl_value((int64_t)code)},
      {"message", make_fl_value(message)}
    };
  }
}