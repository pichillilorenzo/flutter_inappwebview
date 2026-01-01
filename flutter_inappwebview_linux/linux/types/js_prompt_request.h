#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JS_PROMPT_REQUEST_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JS_PROMPT_REQUEST_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * Represents a JavaScript prompt() dialog request.
 */
class JsPromptRequest {
 public:
  std::optional<std::string> url;
  std::string message;
  std::optional<std::string> defaultValue;
  bool isMainFrame;

  JsPromptRequest(const std::optional<std::string>& url, const std::string& message,
                  const std::optional<std::string>& defaultValue, bool isMainFrame);
  ~JsPromptRequest() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_JS_PROMPT_REQUEST_H_
