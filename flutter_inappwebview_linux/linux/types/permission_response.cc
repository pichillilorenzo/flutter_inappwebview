#include "permission_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

PermissionResponse::PermissionResponse() : action(PermissionResponseAction::DENY) {}

PermissionResponse::PermissionResponse(FlValue* map) : action(PermissionResponseAction::DENY) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<PermissionResponseAction>(actionInt);

  FlValue* resourcesValue = fl_value_lookup_string(map, "resources");
  if (resourcesValue != nullptr && fl_value_get_type(resourcesValue) == FL_VALUE_TYPE_LIST) {
    size_t len = fl_value_get_length(resourcesValue);
    for (size_t i = 0; i < len; i++) {
      FlValue* item = fl_value_get_list_value(resourcesValue, i);
      if (fl_value_get_type(item) == FL_VALUE_TYPE_INT) {
        resources.push_back(fl_value_get_int(item));
      }
    }
  }
}

}  // namespace flutter_inappwebview_plugin
