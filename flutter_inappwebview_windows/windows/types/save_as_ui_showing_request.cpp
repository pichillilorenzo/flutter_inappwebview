#include "save_as_ui_showing_request.h"

namespace flutter_inappwebview_plugin
{
  SaveAsUIShowingRequest::SaveAsUIShowingRequest(const std::optional<std::string>& contentMimeType,
    const std::optional<bool>& cancel,
    const std::optional<bool>& suppressDefaultDialog,
    const std::optional<std::string>& saveAsFilePath,
    const std::optional<bool>& allowReplace,
    const std::optional<SaveAsKind>& kind)
    : contentMimeType(contentMimeType), cancel(cancel), suppressDefaultDialog(suppressDefaultDialog),
    saveAsFilePath(saveAsFilePath), allowReplace(allowReplace), kind(kind)
  {}

  SaveAsUIShowingRequest::SaveAsUIShowingRequest(const flutter::EncodableMap& map)
    : SaveAsUIShowingRequest(get_optional_fl_map_value<std::string>(map, "contentMimeType"),
      get_optional_fl_map_value<bool>(map, "cancel"),
      get_optional_fl_map_value<bool>(map, "suppressDefaultDialog"),
      get_optional_fl_map_value<std::string>(map, "saveAsFilePath"),
      get_optional_fl_map_value<bool>(map, "allowReplace"),
      SaveAsKindFromOptionalInteger(get_optional_fl_map_value<int64_t>(map, "kind")))
  {}

  flutter::EncodableMap SaveAsUIShowingRequest::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"contentMimeType", make_fl_value(contentMimeType)},
      {"cancel", make_fl_value(cancel)},
      {"suppressDefaultDialog", make_fl_value(suppressDefaultDialog)},
      {"saveAsFilePath", make_fl_value(saveAsFilePath)},
      {"allowReplace", make_fl_value(allowReplace)},
      {"kind", make_fl_value(SaveAsKindToInteger(kind))}
    };
  }
}