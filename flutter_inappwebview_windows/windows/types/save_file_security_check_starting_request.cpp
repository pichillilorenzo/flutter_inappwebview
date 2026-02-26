#include "save_file_security_check_starting_request.h"

namespace flutter_inappwebview_plugin
{
  SaveFileSecurityCheckStartingRequest::SaveFileSecurityCheckStartingRequest(const std::optional<std::string>& documentOriginUri,
    const std::optional<std::string>& fileExtension,
    const std::optional<std::string>& filePath,
    const std::optional<bool>& cancelSave,
    const std::optional<bool>& suppressDefaultPolicy)
    : documentOriginUri(documentOriginUri), fileExtension(fileExtension), filePath(filePath),
    cancelSave(cancelSave), suppressDefaultPolicy(suppressDefaultPolicy)
  {}

  SaveFileSecurityCheckStartingRequest::SaveFileSecurityCheckStartingRequest(const flutter::EncodableMap& map)
    : SaveFileSecurityCheckStartingRequest(get_optional_fl_map_value<std::string>(map, "documentOriginUri"),
      get_optional_fl_map_value<std::string>(map, "fileExtension"),
      get_optional_fl_map_value<std::string>(map, "filePath"),
      get_optional_fl_map_value<bool>(map, "cancelSave"),
      get_optional_fl_map_value<bool>(map, "suppressDefaultPolicy"))
  {}

  flutter::EncodableMap SaveFileSecurityCheckStartingRequest::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"documentOriginUri", make_fl_value(documentOriginUri)},
      {"fileExtension", make_fl_value(fileExtension)},
      {"filePath", make_fl_value(filePath)},
      {"cancelSave", make_fl_value(cancelSave)},
      {"suppressDefaultPolicy", make_fl_value(suppressDefaultPolicy)}
    };
  }
}