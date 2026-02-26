#include "../utils/flutter.h"
#include "../utils/string.h"
#include "javascript_handler_function_data.h"

namespace flutter_inappwebview_plugin
{
  JavaScriptHandlerFunctionData::JavaScriptHandlerFunctionData(const std::string& origin, const std::string& requestUrl, const bool& isMainFrame, const std::string& args)
    : origin(origin), requestUrl(requestUrl), isMainFrame(isMainFrame), args(args)
  {}

  JavaScriptHandlerFunctionData::JavaScriptHandlerFunctionData(const flutter::EncodableMap& map)
    : JavaScriptHandlerFunctionData(get_fl_map_value<std::string>(map, "origin"),
      get_fl_map_value<std::string>(map, "requestUrl"),
      get_fl_map_value<bool>(map, "isMainFrame"),
      get_fl_map_value<std::string>(map, "args"))
  {}

  flutter::EncodableMap JavaScriptHandlerFunctionData::toEncodableMap() const
  {
    return flutter::EncodableMap{
            {"origin", make_fl_value(origin)},
            {"requestUrl", make_fl_value(requestUrl)},
            {"isMainFrame", make_fl_value(isMainFrame)},
            {"args", make_fl_value(args)}
    };
  }
}
