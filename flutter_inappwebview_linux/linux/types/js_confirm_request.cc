#include "js_confirm_request.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

JsConfirmRequest::JsConfirmRequest(const std::optional<std::string>& url,
                                   const std::string& message, bool isMainFrame)
    : url(url), message(message), isMainFrame(isMainFrame) {}

FlValue* JsConfirmRequest::toFlValue() const {
  return to_fl_map({
      {"url", make_fl_value(url)},
      {"message", make_fl_value(message)},
      {"isMainFrame", make_fl_value(isMainFrame)},
  });
}

}  // namespace flutter_inappwebview_plugin
