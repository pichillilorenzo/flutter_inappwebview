#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONSOLE_LOG_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONSOLE_LOG_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for capturing console.log, console.error, etc.
 *
 * This script intercepts console methods and forwards them to the native
 * side via the JavaScript bridge. This approach is used because WebKit
 * (both GTK and WPE) doesn't have a direct "console-message" signal.
 */
class ConsoleLogJS {
 public:
  inline static const std::string CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_CONSOLE_LOG_JS_PLUGIN_SCRIPT";

  /**
   * JavaScript source code for console message interception.
   * This code wraps console.log, console.error, console.warn, console.info,
   * and console.debug to send messages to native code.
   *
   * Must match iOS/macOS implementation - uses JavaScript bridge callHandler.
   */
  static std::string CONSOLE_LOG_JS_SOURCE() {
    // Match iOS ConsoleLogJS.swift implementation exactly
    return R"JS(
(function(console) {

    function _callHandler(logLevel, args) {
        var message = '';
        for (var i in args) {
            try {
                message += message === '' ? args[i] : ' ' + args[i];
            } catch(_) {}
        }
        try {
            window.)JS" +
           JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           R"JS(.callHandler('onConsoleMessage', {'level': logLevel, 'message': message});
        } catch(_) {}
    }

    var oldLogs = {
        'consoleLog': console.log,
        'consoleDebug': console.debug,
        'consoleError': console.error,
        'consoleInfo': console.info,
        'consoleWarn': console.warn
    };

    for (var k in oldLogs) {
        (function(oldLog) {
            var logLevel = oldLog.replace('console', '').toLowerCase();
            console[logLevel] = function() {
                oldLogs[oldLog].apply(null, arguments);
                _callHandler(logLevel, arguments);
            }
        })(k);
    }
})(window.console);
)JS";
  }

  /**
   * Creates a PluginScript for console log interception.
   *
   * Note: This plugin is only for main frame. Using it on non-main frames
   * could cause issues such as https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738
   */
  static std::unique_ptr<PluginScript> CONSOLE_LOG_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules) {
    return std::make_unique<PluginScript>(
        CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME, CONSOLE_LOG_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentStart,
        true,  // forMainFrameOnly
        allowedOriginRules,
        nullptr,                    // contentWorld
        true,                       // requiredInAllContentWorlds
        std::vector<std::string>{}  // no additional message handlers needed
    );
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CONSOLE_LOG_JS_H_
