#include "javascript_handler_function_data.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

JavaScriptHandlerFunctionData::JavaScriptHandlerFunctionData(const std::string& origin,
                                                             const std::string& requestUrl,
                                                             bool isMainFrame,
                                                             const std::string& args)
    : origin(origin), requestUrl(requestUrl), isMainFrame(isMainFrame), args(args) {}

JavaScriptHandlerFunctionData::JavaScriptHandlerFunctionData(FlValue* map)
    : origin(get_fl_map_value<std::string>(map, "origin", "")),
      requestUrl(get_fl_map_value<std::string>(map, "requestUrl", "")),
      isMainFrame(get_fl_map_value<bool>(map, "isMainFrame", false)),
      args(get_fl_map_value<std::string>(map, "args", "")) {}

FlValue* JavaScriptHandlerFunctionData::toFlValue() const {
  FlValue* map = fl_value_new_map();
  fl_value_set_string_take(map, "origin", fl_value_new_string(origin.c_str()));
  fl_value_set_string_take(map, "requestUrl", fl_value_new_string(requestUrl.c_str()));
  fl_value_set_string_take(map, "isMainFrame", fl_value_new_bool(isMainFrame));
  fl_value_set_string_take(map, "args", fl_value_new_string(args.c_str()));
  return map;
}

}  // namespace flutter_inappwebview_plugin
