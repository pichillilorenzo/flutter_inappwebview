#include "js_dialog_types.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

// === JsAlertRequest ===

JsAlertRequest::JsAlertRequest(const std::optional<std::string>& url, const std::string& message,
                               bool isMainFrame)
    : url(url), message(message), isMainFrame(isMainFrame) {}

FlValue* JsAlertRequest::toFlValue() const {
  FlValue* map = fl_value_new_map();

  if (url.has_value()) {
    fl_value_set_string_take(map, "url", fl_value_new_string(url.value().c_str()));
  } else {
    fl_value_set_string_take(map, "url", fl_value_new_null());
  }
  fl_value_set_string_take(map, "message", fl_value_new_string(message.c_str()));
  fl_value_set_string_take(map, "isMainFrame", fl_value_new_bool(isMainFrame));

  return map;
}

// === JsConfirmRequest ===

JsConfirmRequest::JsConfirmRequest(const std::optional<std::string>& url,
                                   const std::string& message, bool isMainFrame)
    : url(url), message(message), isMainFrame(isMainFrame) {}

FlValue* JsConfirmRequest::toFlValue() const {
  FlValue* map = fl_value_new_map();

  if (url.has_value()) {
    fl_value_set_string_take(map, "url", fl_value_new_string(url.value().c_str()));
  } else {
    fl_value_set_string_take(map, "url", fl_value_new_null());
  }
  fl_value_set_string_take(map, "message", fl_value_new_string(message.c_str()));
  fl_value_set_string_take(map, "isMainFrame", fl_value_new_bool(isMainFrame));

  return map;
}

// === JsPromptRequest ===

JsPromptRequest::JsPromptRequest(const std::optional<std::string>& url, const std::string& message,
                                 const std::optional<std::string>& defaultValue, bool isMainFrame)
    : url(url), message(message), defaultValue(defaultValue), isMainFrame(isMainFrame) {}

FlValue* JsPromptRequest::toFlValue() const {
  FlValue* map = fl_value_new_map();

  if (url.has_value()) {
    fl_value_set_string_take(map, "url", fl_value_new_string(url.value().c_str()));
  } else {
    fl_value_set_string_take(map, "url", fl_value_new_null());
  }
  fl_value_set_string_take(map, "message", fl_value_new_string(message.c_str()));
  if (defaultValue.has_value()) {
    fl_value_set_string_take(map, "defaultValue",
                             fl_value_new_string(defaultValue.value().c_str()));
  } else {
    fl_value_set_string_take(map, "defaultValue", fl_value_new_null());
  }
  fl_value_set_string_take(map, "isMainFrame", fl_value_new_bool(isMainFrame));

  return map;
}

// === JsAlertResponse ===

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

// === JsConfirmResponse ===

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

// === JsPromptResponse ===

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

// === JsBeforeUnloadResponse ===

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
