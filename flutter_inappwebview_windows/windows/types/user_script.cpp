#include "user_script.h"

#include "../utils/log.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin
{
  UserScript::UserScript(
    const std::optional<std::string>& groupName,
    const std::string& source,
    const UserScriptInjectionTime& injectionTime,
    const bool& forMainFrameOnly,
    const std::optional<std::vector<std::string>>& allowedOriginRules,
    std::shared_ptr<ContentWorld> contentWorld
  ) : groupName(groupName), source(source),
    injectionTime(injectionTime), forMainFrameOnly(forMainFrameOnly), allowedOriginRules(allowedOriginRules), contentWorld(std::move(contentWorld))
  {}

  UserScript::UserScript(const flutter::EncodableMap& map)
    : UserScript(get_optional_fl_map_value<std::string>(map, "groupName"),
      get_fl_map_value<std::string>(map, "source"),
      static_cast<UserScriptInjectionTime>(get_fl_map_value<int>(map, "injectionTime")),
      get_fl_map_value<bool>(map, "forMainFrameOnly"),
      fl_map_contains_not_null(map, "allowedOriginRules") ?
      functional_map(get_fl_map_value<flutter::EncodableList>(map, "allowedOriginRules"), [](const flutter::EncodableValue& m) { return std::get<std::string>(m); })
      : std::optional<std::vector<std::string>>{},
      std::make_shared<ContentWorld>(get_fl_map_value<flutter::EncodableMap>(map, "contentWorld")))
  {}

  UserScript::~UserScript()
  {}
}
