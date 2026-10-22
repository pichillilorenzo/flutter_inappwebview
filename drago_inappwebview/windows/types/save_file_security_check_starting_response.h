#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_FILE_SECURITY_CHECK_STARTING_RESPONSE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_FILE_SECURITY_CHECK_STARTING_RESPONSE_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "../utils/flutter.h"

namespace drago_inappwebview_plugin
{
  class SaveFileSecurityCheckStartingResponse
  {
  public:
    const std::optional<bool> cancelSave;
    const std::optional<bool> suppressDefaultPolicy;

    SaveFileSecurityCheckStartingResponse(const std::optional<bool>& cancelSave,
      const std::optional<bool>& suppressDefaultPolicy);
    SaveFileSecurityCheckStartingResponse(const flutter::EncodableMap& map);
    ~SaveFileSecurityCheckStartingResponse() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_SAVE_FILE_SECURITY_CHECK_STARTING_RESPONSE_H_