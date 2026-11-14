#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_

#include <flutter_linux/flutter_linux.h>

#include <map>
#include <optional>
#include <string>
#include <vector>

namespace drago_inappwebview_plugin {

class URLRequest {
 public:
  const std::optional<std::string> url;
  const std::optional<std::string> method;
  const std::optional<std::map<std::string, std::string>> headers;
  const std::optional<std::vector<uint8_t>> body;

  URLRequest(const std::optional<std::string>& url, const std::optional<std::string>& method,
             const std::optional<std::map<std::string, std::string>>& headers,
             const std::optional<std::vector<uint8_t>>& body);

  URLRequest(FlValue* map);

  ~URLRequest() = default;

  FlValue* toFlValue() const;
};

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_
