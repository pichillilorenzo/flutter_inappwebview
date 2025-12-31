#include "web_resource_error.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

WebResourceError::WebResourceError(const std::string& description, int64_t type)
    : description(description), type(type) {}

WebResourceError::WebResourceError(FlValue* map)
    : description(get_fl_map_value<std::string>(map, "description", "")),
      type(get_fl_map_value<int64_t>(map, "type", 0)) {}

FlValue* WebResourceError::toFlValue() const {
  FlValue* map = fl_value_new_map();
  fl_value_set_string_take(map, "description", fl_value_new_string(description.c_str()));
  fl_value_set_string_take(map, "type", fl_value_new_int(type));
  return map;
}

}  // namespace flutter_inappwebview_plugin
