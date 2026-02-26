#include "js_prompt_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

JsPromptResponse::JsPromptResponse()
    : handledByClient(false), action(JsPromptResponseAction::CANCEL) {}

JsPromptResponse::JsPromptResponse(FlValue* map)
    : handledByClient(false), action(JsPromptResponseAction::CANCEL) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  handledByClient = get_fl_map_value(map, "handledByClient", handledByClient);
  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<JsPromptResponseAction>(actionInt);
  value = get_optional_fl_map_value<std::string>(map, "value");
}

}  // namespace flutter_inappwebview_plugin
