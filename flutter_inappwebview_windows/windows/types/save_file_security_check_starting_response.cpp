#include "save_file_security_check_starting_response.h"

namespace flutter_inappwebview_plugin
{
  SaveFileSecurityCheckStartingResponse::SaveFileSecurityCheckStartingResponse(const std::optional<bool>& cancelSave,
    const std::optional<bool>& suppressDefaultPolicy)
    : cancelSave(cancelSave), suppressDefaultPolicy(suppressDefaultPolicy)
  {}

  SaveFileSecurityCheckStartingResponse::SaveFileSecurityCheckStartingResponse(const flutter::EncodableMap& map)
    : SaveFileSecurityCheckStartingResponse(get_optional_fl_map_value<bool>(map, "cancelSave"),
      get_optional_fl_map_value<bool>(map, "suppressDefaultPolicy"))
  {}

  flutter::EncodableMap SaveFileSecurityCheckStartingResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"cancelSave", make_fl_value(cancelSave)},
      {"suppressDefaultPolicy", make_fl_value(suppressDefaultPolicy)}
    };
  }
}