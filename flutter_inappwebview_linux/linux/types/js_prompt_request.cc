#include "js_prompt_request.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

JsPromptRequest::JsPromptRequest(const std::optional<std::string>& url, const std::string& message,
                                 const std::optional<std::string>& defaultValue, bool isMainFrame)
    : url(url), message(message), defaultValue(defaultValue), isMainFrame(isMainFrame) {}

FlValue* JsPromptRequest::toFlValue() const {
  return to_fl_map({
      {"url", make_fl_value(url)},
      {"message", make_fl_value(message)},
      {"defaultValue", make_fl_value(defaultValue)},
      {"isMainFrame", make_fl_value(isMainFrame)},
  });
}

}  // namespace flutter_inappwebview_plugin
