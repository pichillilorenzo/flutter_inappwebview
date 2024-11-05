#include "../utils/flutter.h"
#include "client_cert_response.h"

namespace flutter_inappwebview_plugin
{
  ClientCertResponse::ClientCertResponse(const int64_t& selectedCertificate,
    const std::optional<ClientCertResponseAction>& action)
    : selectedCertificate(selectedCertificate), action(action)
  {}

  ClientCertResponse::ClientCertResponse(const flutter::EncodableMap& map)
    : ClientCertResponse(get_fl_map_value<int64_t>(map, "selectedCertificate"),
      ClientCertResponseActionFromInteger(get_optional_fl_map_value<int64_t>(map, "action")))
  {}

  flutter::EncodableMap ClientCertResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
    {"selectedCertificate", make_fl_value(selectedCertificate)},
    {"action", make_fl_value(ClientCertResponseActionToInteger(action))}
    };
  }
}