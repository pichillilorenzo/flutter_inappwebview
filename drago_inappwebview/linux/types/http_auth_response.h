#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_RESPONSE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace drago_inappwebview_plugin {

/**
 * HTTP authentication response action.
 */
enum class HttpAuthResponseAction { CANCEL = 0, PROCEED = 1, USE_SAVED_CREDENTIAL = 2 };

/**
 * Response to an HTTP authentication challenge.
 */
class HttpAuthResponse {
 public:
  std::optional<std::string> username;
  std::optional<std::string> password;
  HttpAuthResponseAction action;
  bool permanentPersistence;

  HttpAuthResponse();
  HttpAuthResponse(FlValue* map);
  ~HttpAuthResponse() = default;
};

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_RESPONSE_H_
