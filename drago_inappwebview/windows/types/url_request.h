#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_

#include <flutter/standard_method_codec.h>
#include <optional>

namespace drago_inappwebview_plugin
{
  class URLRequest
  {
  public:
    const std::optional<std::string> url;
    const std::optional<std::string> method;
    const std::optional<std::map<std::string, std::string>> headers;
    const std::optional<std::vector<uint8_t>> body;

    URLRequest(const std::optional<std::string>& url, const std::optional<std::string>& method,
      const std::optional<std::map<std::string, std::string>>& headers, const std::optional<std::vector<uint8_t>>& body);
    URLRequest(const flutter::EncodableMap& map);
    ~URLRequest() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_