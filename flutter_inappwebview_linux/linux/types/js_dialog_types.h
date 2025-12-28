#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JS_ALERT_REQUEST_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JS_ALERT_REQUEST_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * Represents a JavaScript alert() dialog request.
 */
class JsAlertRequest {
 public:
  std::optional<std::string> url;
  std::string message;
  bool isMainFrame;

  JsAlertRequest(const std::optional<std::string>& url,
                 const std::string& message,
                 bool isMainFrame);
  ~JsAlertRequest() = default;

  FlValue* toFlValue() const;
};

/**
 * Represents a JavaScript confirm() dialog request.
 */
class JsConfirmRequest {
 public:
  std::optional<std::string> url;
  std::string message;
  bool isMainFrame;

  JsConfirmRequest(const std::optional<std::string>& url,
                   const std::string& message,
                   bool isMainFrame);
  ~JsConfirmRequest() = default;

  FlValue* toFlValue() const;
};

/**
 * Represents a JavaScript prompt() dialog request.
 */
class JsPromptRequest {
 public:
  std::optional<std::string> url;
  std::string message;
  std::optional<std::string> defaultValue;
  bool isMainFrame;

  JsPromptRequest(const std::optional<std::string>& url,
                  const std::string& message,
                  const std::optional<std::string>& defaultValue,
                  bool isMainFrame);
  ~JsPromptRequest() = default;

  FlValue* toFlValue() const;
};

/**
 * Response action for JS dialogs.
 */
enum class JsAlertResponseAction {
  CONFIRM = 0
};

enum class JsConfirmResponseAction {
  CANCEL = 0,
  CONFIRM = 1
};

enum class JsPromptResponseAction {
  CANCEL = 0,
  CONFIRM = 1
};

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

/**
 * Response to a JavaScript confirm() dialog.
 */
class JsConfirmResponse {
 public:
  bool handledByClient;
  JsConfirmResponseAction action;

  JsConfirmResponse();
  JsConfirmResponse(FlValue* map);
  ~JsConfirmResponse() = default;
};

/**
 * Response to a JavaScript prompt() dialog.
 */
class JsPromptResponse {
 public:
  bool handledByClient;
  JsPromptResponseAction action;
  std::optional<std::string> value;

  JsPromptResponse();
  JsPromptResponse(FlValue* map);
  ~JsPromptResponse() = default;
};

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

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_JS_ALERT_REQUEST_H_
