#include "url_credential.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

URLCredential::URLCredential() {}

URLCredential::URLCredential(const std::optional<std::string>& username,
                             const std::optional<std::string>& password)
    : username(username), password(password) {}

URLCredential::URLCredential(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  username = get_optional_fl_map_value<std::string>(map, "username");
  password = get_optional_fl_map_value<std::string>(map, "password");
}

FlValue* URLCredential::toFlValue() const {
  return to_fl_map({
      {"username", make_fl_value(username)},
      {"password", make_fl_value(password)},
  });
}

}  // namespace flutter_inappwebview_plugin
