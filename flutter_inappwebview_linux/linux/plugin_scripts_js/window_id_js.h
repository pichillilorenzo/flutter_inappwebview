#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WINDOW_ID_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WINDOW_ID_JS_H_

#include <string>

#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for managing window IDs in multi-window scenarios.
 *
 * This matches the iOS WindowIdJS.swift implementation.
 * Window IDs are used to route JavaScript bridge calls to the correct
 * webview when using window.open() or similar multi-window features.
 *
 * Note: The WINDOW_ID_VARIABLE_JS_SOURCE() function is now in JavaScriptBridgeJS
 * to avoid circular dependencies. This class provides the initialization script.
 */
class WindowIdJS {
 public:
  inline static const std::string WINDOW_ID_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_WINDOW_ID_JS_PLUGIN_SCRIPT";

  /**
   * Placeholder value that will be replaced with the actual window ID.
   */
  inline static const std::string VAR_PLACEHOLDER_VALUE = "$PLACEHOLDER_VALUE";

  /**
   * Returns JavaScript code to initialize the window ID.
   * The placeholder will be replaced with the actual window ID.
   * Match iOS: WINDOW_ID_INITIALIZE_JS_SOURCE()
   */
  static std::string WINDOW_ID_INITIALIZE_JS_SOURCE() {
    return R"JS(
(function() {
    )JS" + JavaScriptBridgeJS::WINDOW_ID_VARIABLE_JS_SOURCE() +
           R"JS( = )JS" + VAR_PLACEHOLDER_VALUE + R"JS(;
    return )JS" +
           JavaScriptBridgeJS::WINDOW_ID_VARIABLE_JS_SOURCE() + R"JS(;
})()
)JS";
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WINDOW_ID_JS_H_
