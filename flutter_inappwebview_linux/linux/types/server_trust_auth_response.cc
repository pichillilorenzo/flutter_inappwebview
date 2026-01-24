#include "server_trust_auth_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

ServerTrustAuthResponse::ServerTrustAuthResponse(ServerTrustAuthResponseAction action)
    : action(action) {}

std::optional<ServerTrustAuthResponse> ServerTrustAuthResponse::fromFlValue(FlValue* value) {
  if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
    return std::nullopt;
  }

  if (fl_value_get_type(value) != FL_VALUE_TYPE_MAP) {
    return std::nullopt;
  }

  // Get the action field
  FlValue* actionValue = fl_value_lookup_string(value, "action");
  if (actionValue == nullptr || fl_value_get_type(actionValue) == FL_VALUE_TYPE_NULL) {
    return ServerTrustAuthResponse(ServerTrustAuthResponseAction::CANCEL);
  }

  int64_t actionInt = fl_value_get_int(actionValue);
  ServerTrustAuthResponseAction action;
  switch (actionInt) {
    case 1:
      action = ServerTrustAuthResponseAction::PROCEED;
      break;
    case 0:
    default:
      action = ServerTrustAuthResponseAction::CANCEL;
      break;
  }

  return ServerTrustAuthResponse(action);
}

}  // namespace flutter_inappwebview_plugin
