#include "web_resource_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

WebResourceResponse::WebResourceResponse(
    const std::optional<std::string>& contentType,
    const std::optional<std::string>& contentEncoding, const std::optional<int64_t>& statusCode,
    const std::optional<std::string>& reasonPhrase,
    const std::optional<std::map<std::string, std::string>>& headers,
    const std::optional<std::vector<uint8_t>>& data)
    : contentType(contentType),
      contentEncoding(contentEncoding),
      statusCode(statusCode),
      reasonPhrase(reasonPhrase),
      headers(headers),
      data(data) {}

WebResourceResponse::WebResourceResponse(FlValue* map)
    : contentType(get_optional_fl_map_value<std::string>(map, "contentType")),
      contentEncoding(get_optional_fl_map_value<std::string>(map, "contentEncoding")),
      statusCode(get_optional_fl_map_value<int64_t>(map, "statusCode")),
      reasonPhrase(get_optional_fl_map_value<std::string>(map, "reasonPhrase")),
      headers(get_optional_fl_map_value<std::map<std::string, std::string>>(map, "headers")),
      data(get_optional_fl_map_value<std::vector<uint8_t>>(map, "data")) {}

FlValue* WebResourceResponse::toFlValue() const {
  return to_fl_map({
      {"contentType", make_fl_value(contentType)},
      {"contentEncoding", make_fl_value(contentEncoding)},
      {"statusCode", make_fl_value(statusCode)},
      {"reasonPhrase", make_fl_value(reasonPhrase)},
      {"headers", make_fl_value(headers)},
      {"data", make_fl_value(data)},
  });
}

}  // namespace flutter_inappwebview_plugin
