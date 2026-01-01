#include "js_confirm_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

JsConfirmResponse::JsConfirmResponse()
    : handledByClient(false), action(JsConfirmResponseAction::CANCEL) {}

JsConfirmResponse::JsConfirmResponse(FlValue* map)
    : handledByClient(false), action(JsConfirmResponseAction::CANCEL) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  handledByClient = get_fl_map_value(map, "handledByClient", handledByClient);
  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<JsConfirmResponseAction>(actionInt);
}

}  // namespace flutter_inappwebview_plugin
