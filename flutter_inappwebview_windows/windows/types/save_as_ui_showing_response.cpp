#include "save_as_ui_showing_response.h"

namespace flutter_inappwebview_plugin
{
  SaveAsUIShowingResponse::SaveAsUIShowingResponse(const std::optional<bool>& cancel,
    const std::optional<bool>& suppressDefaultDialog,
    const std::optional<std::string>& saveAsFilePath,
    const std::optional<bool>& allowReplace,
    const std::optional<SaveAsKind>& kind)
    : cancel(cancel), suppressDefaultDialog(suppressDefaultDialog), saveAsFilePath(saveAsFilePath),
    allowReplace(allowReplace), kind(kind)
  {}

  SaveAsUIShowingResponse::SaveAsUIShowingResponse(const flutter::EncodableMap& map)
    : SaveAsUIShowingResponse(get_optional_fl_map_value<bool>(map, "cancel"),
      get_optional_fl_map_value<bool>(map, "suppressDefaultDialog"),
      get_optional_fl_map_value<std::string>(map, "saveAsFilePath"),
      get_optional_fl_map_value<bool>(map, "allowReplace"),
      SaveAsKindFromOptionalInteger(get_optional_fl_map_value<int64_t>(map, "kind")))
  {}

  flutter::EncodableMap SaveAsUIShowingResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"cancel", make_fl_value(cancel)},
      {"suppressDefaultDialog", make_fl_value(suppressDefaultDialog)},
      {"saveAsFilePath", make_fl_value(saveAsFilePath)},
      {"allowReplace", make_fl_value(allowReplace)},
      {"kind", make_fl_value(SaveAsKindToInteger(kind))}
    };
  }
}