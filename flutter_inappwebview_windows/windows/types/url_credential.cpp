#include "../utils/flutter.h"
#include "url_credential.h"

namespace flutter_inappwebview_plugin
{
  URLCredential::URLCredential(const std::optional<std::string>& username,
    const std::optional<std::string>& password)
    : username(username), password(password)
  {}

  flutter::EncodableMap URLCredential::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"username", make_fl_value(username)},
      {"password", make_fl_value(password)}
    };
  }
}