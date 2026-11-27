#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_AS_UI_SHOWING_REQUEST_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_AS_UI_SHOWING_REQUEST_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

#include "../utils/flutter.h"
#include "save_as_kind.h"

namespace drago_inappwebview_plugin
{
  class SaveAsUIShowingRequest
  {
  public:
    const std::optional<std::string> contentMimeType;
    const std::optional<bool> cancel;
    const std::optional<bool> suppressDefaultDialog;
    const std::optional<std::string> saveAsFilePath;
    const std::optional<bool> allowReplace;
    const std::optional<SaveAsKind> kind;

    SaveAsUIShowingRequest(const std::optional<std::string>& contentMimeType,
      const std::optional<bool>& cancel,
      const std::optional<bool>& suppressDefaultDialog,
      const std::optional<std::string>& saveAsFilePath,
      const std::optional<bool>& allowReplace,
      const std::optional<SaveAsKind>& kind);
    SaveAsUIShowingRequest(const flutter::EncodableMap& map);
    ~SaveAsUIShowingRequest() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_AS_UI_SHOWING_REQUEST_H_