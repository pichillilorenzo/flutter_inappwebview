#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FAVICON_CHANGED_REQUEST_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FAVICON_CHANGED_REQUEST_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>
#include <vector>

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin
{
  class FaviconChangedRequest
  {
  public:
    const std::optional<std::vector<uint8_t>> icon;
    const std::optional<std::string> url;

    FaviconChangedRequest(const std::optional<std::vector<uint8_t>>& icon, const std::optional<std::string>& url);
    ~FaviconChangedRequest() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FAVICON_CHANGED_REQUEST_H_