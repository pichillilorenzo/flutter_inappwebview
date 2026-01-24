#include "custom_scheme_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

CustomSchemeResponse::CustomSchemeResponse()
    : contentType("application/octet-stream"), contentEncoding("utf-8") {}

CustomSchemeResponse::CustomSchemeResponse(FlValue* map)
    : contentType(get_fl_map_value<std::string>(map, "contentType", "application/octet-stream")),
      contentEncoding(get_fl_map_value<std::string>(map, "contentEncoding", "utf-8")) {
  // Parse data (Uint8List) - needs special handling for byte arrays
  auto data_opt = get_optional_fl_map_value<std::vector<uint8_t>>(map, "data");
  if (data_opt.has_value()) {
    data = data_opt.value();
  }
}

FlValue* CustomSchemeResponse::toFlValue() const {
  return to_fl_map({
      {"data", make_fl_value(data)},
      {"contentType", make_fl_value(contentType)},
      {"contentEncoding", make_fl_value(contentEncoding)},
  });
}

}  // namespace flutter_inappwebview_plugin
