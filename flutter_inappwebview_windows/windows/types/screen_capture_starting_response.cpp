#include "screen_capture_starting_response.h"

namespace flutter_inappwebview_plugin
{
  ScreenCaptureStartingResponse::ScreenCaptureStartingResponse(const std::optional<bool>& cancel,
    const std::optional<bool>& handled)
    : cancel(cancel), handled(handled)
  {}

  ScreenCaptureStartingResponse::ScreenCaptureStartingResponse(const flutter::EncodableMap& map)
    : ScreenCaptureStartingResponse(get_optional_fl_map_value<bool>(map, "cancel"),
      get_optional_fl_map_value<bool>(map, "handled"))
  {}

  flutter::EncodableMap ScreenCaptureStartingResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"cancel", make_fl_value(cancel)},
      {"handled", make_fl_value(handled)}
    };
  }
}