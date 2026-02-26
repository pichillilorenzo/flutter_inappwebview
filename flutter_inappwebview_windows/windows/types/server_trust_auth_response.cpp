#include "../utils/flutter.h"
#include "server_trust_auth_response.h"

namespace flutter_inappwebview_plugin
{
  ServerTrustAuthResponse::ServerTrustAuthResponse(
    const std::optional<ServerTrustAuthResponseAction>& action)
    : action(action)
  {}

  ServerTrustAuthResponse::ServerTrustAuthResponse(const flutter::EncodableMap& map)
    : ServerTrustAuthResponse(
      ServerTrustAuthResponseActionFromInteger(get_optional_fl_map_value<int64_t>(map, "action")))
  {}

  flutter::EncodableMap ServerTrustAuthResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
    {"action", make_fl_value(ServerTrustAuthResponseActionToInteger(action))}
    };
  }
}