#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JS_ALERT_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JS_ALERT_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * Response action for JS alert dialogs.
 */
enum class JsAlertResponseAction { CONFIRM = 0 };

/**
 * Response to a JavaScript alert() dialog.
 */
class JsAlertResponse {
 public:
  bool handledByClient;
  JsAlertResponseAction action;
  std::optional<std::string> message;

  JsAlertResponse();
  JsAlertResponse(FlValue* map);
  ~JsAlertResponse() = default;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_JS_ALERT_RESPONSE_H_
