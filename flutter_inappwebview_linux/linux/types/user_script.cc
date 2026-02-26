#include "user_script.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

UserScript::UserScript(const std::optional<std::string>& groupName, const std::string& source,
                       UserScriptInjectionTime injectionTime, bool forMainFrameOnly,
                       const std::optional<std::vector<std::string>>& allowedOriginRules,
                       std::shared_ptr<ContentWorld> contentWorld)
    : groupName(groupName),
      source(source),
      injectionTime(injectionTime),
      forMainFrameOnly(forMainFrameOnly),
      allowedOriginRules(allowedOriginRules),
      contentWorld(contentWorld ? contentWorld : ContentWorld::page()) {}

UserScript::UserScript(FlValue* map)
    : injectionTime(UserScriptInjectionTime::atDocumentStart), forMainFrameOnly(true) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  groupName = get_optional_fl_map_value<std::string>(map, "groupName");
  source = get_fl_map_value<std::string>(map, "source", "");

  int64_t injectionTimeValue = get_fl_map_value<int64_t>(map, "injectionTime", 0);
  injectionTime = static_cast<UserScriptInjectionTime>(injectionTimeValue);

  forMainFrameOnly = get_fl_map_value<bool>(map, "forMainFrameOnly", true);

  allowedOriginRules = get_optional_fl_map_value<std::vector<std::string>>(map, "allowedOriginRules");

  FlValue* contentWorldValue = fl_value_lookup_string(map, "contentWorld");
  if (contentWorldValue != nullptr && fl_value_get_type(contentWorldValue) == FL_VALUE_TYPE_MAP) {
    contentWorld = std::make_shared<ContentWorld>(contentWorldValue);
  } else {
    contentWorld = ContentWorld::page();
  }
}

FlValue* UserScript::toFlValue() const {
  return to_fl_map({
      {"groupName", make_fl_value(groupName)},
      {"source", make_fl_value(source)},
      {"injectionTime", make_fl_value(static_cast<int64_t>(injectionTime))},
      {"forMainFrameOnly", make_fl_value(forMainFrameOnly)},
      {"allowedOriginRules", make_fl_value(allowedOriginRules)},
      {"contentWorld", contentWorld ? contentWorld->toFlValue() : make_fl_value()},
  });
}

bool UserScript::operator==(const UserScript& other) const {
  return groupName == other.groupName && source == other.source &&
         injectionTime == other.injectionTime && forMainFrameOnly == other.forMainFrameOnly;
}

}  // namespace flutter_inappwebview_plugin
