#include "favicon_changed_request.h"

namespace flutter_inappwebview_plugin
{
  FaviconChangedRequest::FaviconChangedRequest(const std::optional<std::vector<uint8_t>>& icon, const std::optional<std::string>& url)
    : icon(icon), url(url)
  {}

  flutter::EncodableMap FaviconChangedRequest::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"icon", make_fl_value(icon)},
      {"url", make_fl_value(url)}
    };
  }
}