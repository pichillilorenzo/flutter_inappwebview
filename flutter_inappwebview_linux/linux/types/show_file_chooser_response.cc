#include "show_file_chooser_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

ShowFileChooserResponse::ShowFileChooserResponse()
    : handledByClient(false), filePaths(std::nullopt) {}

ShowFileChooserResponse::ShowFileChooserResponse(
    bool handledByClient, std::optional<std::vector<std::string>> filePaths)
    : handledByClient(handledByClient), filePaths(std::move(filePaths)) {}

ShowFileChooserResponse ShowFileChooserResponse::fromFlValue(FlValue* value) {
  if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
    return ShowFileChooserResponse();
  }

  if (fl_value_get_type(value) != FL_VALUE_TYPE_MAP) {
    return ShowFileChooserResponse();
  }

  auto handledByClient = get_fl_map_value<bool>(value, "handledByClient", false);
  auto filePaths = get_optional_fl_map_value<std::vector<std::string>>(value, "filePaths");

  return ShowFileChooserResponse(handledByClient, std::move(filePaths));
}

FlValue* ShowFileChooserResponse::toFlValue() const {
  return to_fl_map({
      {"handledByClient", make_fl_value(handledByClient)},
      {"filePaths", make_fl_value(filePaths)},
  });
}

}  // namespace flutter_inappwebview_plugin
