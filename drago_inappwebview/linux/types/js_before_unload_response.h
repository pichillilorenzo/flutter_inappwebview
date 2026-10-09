#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_JS_BEFORE_UNLOAD_RESPONSE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_JS_BEFORE_UNLOAD_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace drago_inappwebview_plugin {

/**
 * Response for beforeunload dialogs.
 */
class JsBeforeUnloadResponse {
 public:
  bool handledByClient;
  bool shouldAllowNavigation;
  std::optional<std::string> message;

  JsBeforeUnloadResponse();
  JsBeforeUnloadResponse(FlValue* map);
  ~JsBeforeUnloadResponse() = default;
};

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_PLUGIN_JS_BEFORE_UNLOAD_RESPONSE_H_
