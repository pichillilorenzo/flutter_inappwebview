#include "http_auth_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

HttpAuthResponse::HttpAuthResponse()
    : action(HttpAuthResponseAction::CANCEL), permanentPersistence(false) {}

HttpAuthResponse::HttpAuthResponse(FlValue* map)
    : action(HttpAuthResponseAction::CANCEL), permanentPersistence(false) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  username = get_optional_fl_map_value<std::string>(map, "username");
  password = get_optional_fl_map_value<std::string>(map, "password");

  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<HttpAuthResponseAction>(actionInt);

  permanentPersistence = get_fl_map_value(map, "permanentPersistence", false);
}

}  // namespace flutter_inappwebview_plugin
