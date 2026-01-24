#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SCREEN_CAPTURE_STARTING_REQUEST_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SCREEN_CAPTURE_STARTING_REQUEST_H_

#include <flutter/standard_method_codec.h>
#include <memory>
#include <optional>

#include "../utils/flutter.h"
#include "frame_info.h"

namespace flutter_inappwebview_plugin
{
  class ScreenCaptureStartingRequest
  {
  public:
    const std::optional<std::shared_ptr<FrameInfo>> frame;
    const std::optional<bool> cancel;
    const std::optional<bool> handled;

    ScreenCaptureStartingRequest(const std::optional<std::shared_ptr<FrameInfo>>& frame,
      const std::optional<bool>& cancel,
      const std::optional<bool>& handled);
    ~ScreenCaptureStartingRequest() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_SCREEN_CAPTURE_STARTING_REQUEST_H_