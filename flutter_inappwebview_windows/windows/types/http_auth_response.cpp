#include "../utils/flutter.h"
#include "http_auth_response.h"

namespace flutter_inappwebview_plugin
{
  HttpAuthResponse::HttpAuthResponse(const std::string& username,
    const std::string& password,
    const bool& permanentPersistence,
    const std::optional<HttpAuthResponseAction>& action)
    : username(username), password(password), permanentPersistence(permanentPersistence), action(action)
  {}

  HttpAuthResponse::HttpAuthResponse(const flutter::EncodableMap& map)
    : HttpAuthResponse(get_fl_map_value<std::string>(map, "username"),
      get_fl_map_value<std::string>(map, "password"),
      get_fl_map_value<bool>(map, "permanentPersistence"),
      HttpAuthResponseActionFromInteger(get_optional_fl_map_value<int64_t>(map, "action")))
  {}

  flutter::EncodableMap HttpAuthResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
    {"username", make_fl_value(username)},
    {"password", make_fl_value(password)},
    {"permanentPersistence", make_fl_value(permanentPersistence)},
    {"action", make_fl_value(HttpAuthResponseActionToInteger(action))}
    };
  }
}