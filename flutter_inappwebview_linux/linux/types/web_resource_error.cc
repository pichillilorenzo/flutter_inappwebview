#include "web_resource_error.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

WebResourceError::WebResourceError(const std::string& description, int64_t type)
    : description(description), type(type) {}

WebResourceError::WebResourceError(FlValue* map)
    : description(get_fl_map_value<std::string>(map, "description", "")),
      type(get_fl_map_value<int64_t>(map, "type", 399)) {}

FlValue* WebResourceError::toFlValue() const {
  return to_fl_map({
      {"description", make_fl_value(description)},
      {"type", make_fl_value(type)},
  });
}

}  // namespace flutter_inappwebview_plugin
