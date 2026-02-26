#include "screen_capture_starting_request.h"

namespace flutter_inappwebview_plugin
{
  ScreenCaptureStartingRequest::ScreenCaptureStartingRequest(const std::optional<std::shared_ptr<FrameInfo>>& frame,
    const std::optional<bool>& cancel,
    const std::optional<bool>& handled)
    : frame(frame), cancel(cancel), handled(handled)
  {}

  flutter::EncodableMap ScreenCaptureStartingRequest::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"frame", frame.has_value() ? frame.value()->toEncodableMap() : make_fl_value()},
      {"cancel", make_fl_value(cancel)},
      {"handled", make_fl_value(handled)}
    };
  }
}