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
    var pendingMessages = [];
    var maxBatchSize = 64;
    var maxBatchCharacters = 65536;
    var pendingCharacters = 0;
    var flushTimer = null;
    var flushInProgress = false;

    function _callHandler(logLevel, args) {
        var message = '';
        for (var i in args) {
            try {
                message += message === '' ? args[i] : ' ' + args[i];
            } catch(_) {}
        }
        var messageSize = message.length + 48;
        if (pendingMessages.length > 0 && pendingCharacters + messageSize > maxBatchCharacters) {
            _flushMessages();
        }
        pendingMessages.push({'level': logLevel, 'message': message});
        pendingCharacters += messageSize;
        if (logLevel === 'warn' || logLevel === 'error' || pendingMessages.length >= maxBatchSize || pendingCharacters >= maxBatchCharacters) {
            _flushMessages();
        } else if (flushTimer === null) {
            flushTimer = window.setTimeout(_flushMessages, 25);
        }
    }

    function _flushMessages() {
        if (flushTimer !== null) {
            window.clearTimeout(flushTimer);
            flushTimer = null;
        }
        if (flushInProgress || pendingMessages.length === 0) return;
        var batchCount = 0;
        var batchCharacters = 0;
        while (batchCount < pendingMessages.length && batchCount < maxBatchSize) {
            var nextSize = pendingMessages[batchCount].message.length + 48;
            if (batchCount > 0 && batchCharacters + nextSize > maxBatchCharacters) break;
            batchCharacters += nextSize;
            batchCount++;
            if (batchCharacters >= maxBatchCharacters) break;
        }
        var batch = pendingMessages.splice(0, batchCount);
        pendingCharacters -= batchCharacters;
        flushInProgress = true;
        try {
            window.)JS" +
           JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           R"JS(.callHandler('onConsoleMessageBatch', {'messages': batch});
        } catch(_) {} finally {
            flushInProgress = false;
        }
        if (pendingMessages.length > 0 && flushTimer === null) {
            flushTimer = window.setTimeout(_flushMessages, 50);
        }
    }

    window.addEventListener('pagehide', _flushMessages);
    window.document.addEventListener('visibilitychange', function() {
        if (window.document.hidden) _flushMessages();
    });

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
