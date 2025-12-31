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

  FlValue* rulesValue = fl_value_lookup_string(map, "allowedOriginRules");
  if (rulesValue != nullptr && fl_value_get_type(rulesValue) == FL_VALUE_TYPE_LIST) {
    std::vector<std::string> rules;
    size_t len = fl_value_get_length(rulesValue);
    for (size_t i = 0; i < len; i++) {
      FlValue* item = fl_value_get_list_value(rulesValue, i);
      if (fl_value_get_type(item) == FL_VALUE_TYPE_STRING) {
        rules.push_back(fl_value_get_string(item));
      }
    }
    allowedOriginRules = rules;
  }

  FlValue* contentWorldValue = fl_value_lookup_string(map, "contentWorld");
  if (contentWorldValue != nullptr && fl_value_get_type(contentWorldValue) == FL_VALUE_TYPE_MAP) {
    contentWorld = std::make_shared<ContentWorld>(contentWorldValue);
  } else {
    contentWorld = ContentWorld::page();
  }
}

FlValue* UserScript::toFlValue() const {
  FlValue* map = fl_value_new_map();

  if (groupName.has_value()) {
    fl_value_set_string_take(map, "groupName", fl_value_new_string(groupName->c_str()));
  } else {
    fl_value_set_string_take(map, "groupName", fl_value_new_null());
  }

  fl_value_set_string_take(map, "source", fl_value_new_string(source.c_str()));
  fl_value_set_string_take(map, "injectionTime",
                           fl_value_new_int(static_cast<int64_t>(injectionTime)));
  fl_value_set_string_take(map, "forMainFrameOnly", fl_value_new_bool(forMainFrameOnly));

  if (allowedOriginRules.has_value()) {
    FlValue* rulesArray = fl_value_new_list();
    for (const auto& rule : *allowedOriginRules) {
      fl_value_append_take(rulesArray, fl_value_new_string(rule.c_str()));
    }
    fl_value_set_string_take(map, "allowedOriginRules", rulesArray);
  } else {
    fl_value_set_string_take(map, "allowedOriginRules", fl_value_new_null());
  }

  if (contentWorld) {
    fl_value_set_string_take(map, "contentWorld", contentWorld->toFlValue());
  } else {
    fl_value_set_string_take(map, "contentWorld", fl_value_new_null());
  }

  return map;
}

bool UserScript::operator==(const UserScript& other) const {
  return groupName == other.groupName && source == other.source &&
         injectionTime == other.injectionTime && forMainFrameOnly == other.forMainFrameOnly;
}

}  // namespace flutter_inappwebview_plugin
