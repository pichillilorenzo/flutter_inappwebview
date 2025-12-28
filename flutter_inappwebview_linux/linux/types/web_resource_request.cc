#include "web_resource_request.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

WebResourceRequest::WebResourceRequest(
    const std::optional<std::string>& url,
    const std::optional<std::string>& method,
    const std::optional<std::map<std::string, std::string>>& headers,
    const std::optional<bool>& isForMainFrame)
    : url(url), method(method), headers(headers), isForMainFrame(isForMainFrame) {}

WebResourceRequest::WebResourceRequest(FlValue* map)
    : url(get_optional_fl_map_value<std::string>(map, "url")),
      method(get_optional_fl_map_value<std::string>(map, "method")),
      headers(get_optional_fl_map_value<std::map<std::string, std::string>>(map, "headers")),
      isForMainFrame(get_optional_fl_map_value<bool>(map, "isForMainFrame")) {}

FlValue* WebResourceRequest::toFlValue() const {
  FlValue* map = fl_value_new_map();
  fl_value_set_string_take(map, "url", make_fl_value(url));
  fl_value_set_string_take(map, "method", make_fl_value(method));
  fl_value_set_string_take(map, "headers", make_fl_value(headers));
  fl_value_set_string_take(map, "isForMainFrame", make_fl_value(isForMainFrame));
  return map;
}

}  // namespace flutter_inappwebview_plugin
