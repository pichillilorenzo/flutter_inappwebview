#include "../utils/map.h"
#include "user_script.h"

namespace flutter_inappwebview_plugin
{
  UserScript::UserScript(
    const std::optional<std::string>& groupName,
    const std::string& source,
    const UserScriptInjectionTime& injectionTime,
    const std::vector<std::string>& allowedOriginRules
  ) : groupName(groupName), source(source), injectionTime(injectionTime), allowedOriginRules(allowedOriginRules)
  {}

  UserScript::UserScript(const flutter::EncodableMap& map)
    : groupName(get_optional_fl_map_value<std::string>(map, "groupName")),
    source(get_fl_map_value<std::string>(map, "source")),
    injectionTime(static_cast<UserScriptInjectionTime>(get_fl_map_value<int>(map, "injectionTime"))),
    allowedOriginRules(functional_map(get_fl_map_value<flutter::EncodableList>(map, "allowedOriginRules"), [](const flutter::EncodableValue& m) { return std::get<std::string>(m); }))
  {}

  UserScript::~UserScript()
  {}
}