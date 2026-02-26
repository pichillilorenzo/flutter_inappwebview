#include "client_cert_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

ClientCertResponse::ClientCertResponse()
    : action(ClientCertResponseAction::CANCEL), selectedCertificate(-1) {}

ClientCertResponse::ClientCertResponse(FlValue* map)
    : action(ClientCertResponseAction::CANCEL), selectedCertificate(-1) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  // Parse action
  FlValue* actionValue = fl_value_lookup_string(map, "action");
  if (actionValue != nullptr && fl_value_get_type(actionValue) == FL_VALUE_TYPE_INT) {
    int actionInt = static_cast<int>(fl_value_get_int(actionValue));
    switch (actionInt) {
      case 0:
        action = ClientCertResponseAction::CANCEL;
        break;
      case 1:
        action = ClientCertResponseAction::PROCEED;
        break;
      case 2:
        action = ClientCertResponseAction::IGNORE;
        break;
      default:
        action = ClientCertResponseAction::CANCEL;
        break;
    }
  }

  // Parse certificatePath
  certificatePath = get_optional_fl_map_value<std::string>(map, "certificatePath");
  
  // Parse certificatePassword
  certificatePassword = get_optional_fl_map_value<std::string>(map, "certificatePassword");
  
  // Parse keyStoreType
  keyStoreType = get_optional_fl_map_value<std::string>(map, "keyStoreType");
  
  // Parse selectedCertificate
  FlValue* selectedValue = fl_value_lookup_string(map, "selectedCertificate");
  if (selectedValue != nullptr && fl_value_get_type(selectedValue) == FL_VALUE_TYPE_INT) {
    selectedCertificate = static_cast<int>(fl_value_get_int(selectedValue));
  }
}

std::optional<ClientCertResponse> ClientCertResponse::fromFlValue(FlValue* value) {
  if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
    return std::nullopt;
  }
  if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
    return ClientCertResponse(value);
  }
  return std::nullopt;
}

}  // namespace flutter_inappwebview_plugin
