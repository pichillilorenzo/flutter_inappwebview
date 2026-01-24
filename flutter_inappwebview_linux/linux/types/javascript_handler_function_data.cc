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
  return to_fl_map({
      {"origin", make_fl_value(origin)},
      {"requestUrl", make_fl_value(requestUrl)},
      {"isMainFrame", make_fl_value(isMainFrame)},
      {"args", make_fl_value(args)},
  });
}

}  // namespace flutter_inappwebview_plugin
