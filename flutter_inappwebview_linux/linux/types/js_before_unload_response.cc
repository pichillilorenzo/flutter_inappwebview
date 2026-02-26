#include "js_before_unload_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

JsBeforeUnloadResponse::JsBeforeUnloadResponse()
    : handledByClient(false), shouldAllowNavigation(true) {}

JsBeforeUnloadResponse::JsBeforeUnloadResponse(FlValue* map)
    : handledByClient(false), shouldAllowNavigation(true) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  handledByClient = get_fl_map_value(map, "handledByClient", handledByClient);
  // Action 1 = allow navigation
  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 1);
  shouldAllowNavigation = (actionInt == 1);
  message = get_optional_fl_map_value<std::string>(map, "message");
}

}  // namespace flutter_inappwebview_plugin
