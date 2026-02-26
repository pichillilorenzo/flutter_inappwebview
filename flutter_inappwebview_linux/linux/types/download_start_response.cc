#include "download_start_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

// === DownloadStartResponse ===

DownloadStartResponse::DownloadStartResponse() : action(DownloadStartResponseAction::CANCEL) {}

DownloadStartResponse::DownloadStartResponse(FlValue* map)
    : action(DownloadStartResponseAction::CANCEL) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<DownloadStartResponseAction>(actionInt);

  destinationPath = get_optional_fl_map_value<std::string>(map, "destinationPath");
}

}  // namespace flutter_inappwebview_plugin
