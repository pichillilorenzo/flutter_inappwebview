#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_FILE_SECURITY_CHECK_STARTING_REQUEST_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_FILE_SECURITY_CHECK_STARTING_REQUEST_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

#include "../utils/flutter.h"

namespace drago_inappwebview_plugin
{
  class SaveFileSecurityCheckStartingRequest
  {
  public:
    const std::optional<std::string> documentOriginUri;
    const std::optional<std::string> fileExtension;
    const std::optional<std::string> filePath;
    const std::optional<bool> cancelSave;
    const std::optional<bool> suppressDefaultPolicy;

    SaveFileSecurityCheckStartingRequest(const std::optional<std::string>& documentOriginUri,
      const std::optional<std::string>& fileExtension,
      const std::optional<std::string>& filePath,
      const std::optional<bool>& cancelSave,
      const std::optional<bool>& suppressDefaultPolicy);
    SaveFileSecurityCheckStartingRequest(const flutter::EncodableMap& map);
    ~SaveFileSecurityCheckStartingRequest() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_FILE_SECURITY_CHECK_STARTING_REQUEST_H_