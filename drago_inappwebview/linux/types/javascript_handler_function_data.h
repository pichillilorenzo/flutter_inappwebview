#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_HANDLER_FUNCTION_DATA_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_HANDLER_FUNCTION_DATA_H_

#include <flutter_linux/flutter_linux.h>

#include <string>

namespace drago_inappwebview_plugin {

class JavaScriptHandlerFunctionData {
 public:
  const std::string origin;
  const std::string requestUrl;
  const bool isMainFrame;
  const std::string args;

  JavaScriptHandlerFunctionData(const std::string& origin, const std::string& requestUrl,
                                bool isMainFrame, const std::string& args);
  JavaScriptHandlerFunctionData(FlValue* map);
  ~JavaScriptHandlerFunctionData() = default;

  FlValue* toFlValue() const;
};

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_HANDLER_FUNCTION_DATA_H_
