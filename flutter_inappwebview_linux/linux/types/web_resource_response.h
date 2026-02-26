#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_RESOURCE_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_RESOURCE_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

class WebResourceResponse {
 public:
  std::optional<std::string> contentType;
  std::optional<std::string> contentEncoding;
  std::optional<int64_t> statusCode;
  std::optional<std::string> reasonPhrase;
  std::optional<std::map<std::string, std::string>> headers;
  std::optional<std::vector<uint8_t>> data;

  WebResourceResponse(
      const std::optional<std::string>& contentType = std::nullopt,
      const std::optional<std::string>& contentEncoding = std::nullopt,
      const std::optional<int64_t>& statusCode = std::nullopt,
      const std::optional<std::string>& reasonPhrase = std::nullopt,
      const std::optional<std::map<std::string, std::string>>& headers = std::nullopt,
      const std::optional<std::vector<uint8_t>>& data = std::nullopt);
  WebResourceResponse(FlValue* map);
  ~WebResourceResponse() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_RESOURCE_RESPONSE_H_
