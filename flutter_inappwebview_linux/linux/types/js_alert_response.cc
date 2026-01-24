#include "js_alert_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

JsAlertResponse::JsAlertResponse()
    : handledByClient(false), action(JsAlertResponseAction::CONFIRM) {}

JsAlertResponse::JsAlertResponse(FlValue* map)
    : handledByClient(false), action(JsAlertResponseAction::CONFIRM) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  handledByClient = get_fl_map_value(map, "handledByClient", handledByClient);
  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<JsAlertResponseAction>(actionInt);
  message = get_optional_fl_map_value<std::string>(map, "message");
}

}  // namespace flutter_inappwebview_plugin
