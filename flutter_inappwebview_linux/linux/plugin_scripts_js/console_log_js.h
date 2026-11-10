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
   * Update an existing publisher in this WebView's current document only.
   * Related WebViews share their user-content manager, so policy must never
   * be embedded into the shared document-start bootstrap.
   */
  static std::string CONSOLE_POLICY_JS_SOURCE(
      bool enabled, const std::optional<std::vector<int64_t>>& levels) {
    std::string levelsJSON = "null";
    if (levels) {
      levelsJSON = "[";
      for (const auto level : *levels) {
        if (levelsJSON.size() > 1) levelsJSON += ",";
        levelsJSON += std::to_string(level);
      }
      levelsJSON += "]";
    }
    const auto bridge = "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME();
    return "if (" + bridge + " && " + bridge + "._setConsoleMessagePolicy) {" +
        bridge + "._setConsoleMessagePolicy(" + (enabled ? "true" : "false") +
        "," + levelsJSON + ");}";
  }

  /**
   * Neutral bootstrap shared by related WebViews. Native filtering remains
   * authoritative until the owning view applies its document policy on load.
   * Keep early warnings/errors observable without inheriting a sibling's policy.
   */
  static std::string CONSOLE_LOG_JS_SOURCE() {
    return R"JS(
(function(console, bridge, enabled, levels) {
    if (!bridge) return;
    // Related views can install this same neutral bootstrap. Do not wrap
    // twice or reset a policy already applied to this document.
    if (bridge._setConsoleMessagePolicy) return;
    var pendingMessages = [];
    var pendingCharacters = 0;
    var maxBatchSize = 64;
    var maxBatchCharacters = 65536;
    var flushTimer = null;
    var flushInProgress = false;
    var suppressReentrant = false;
    var maxPendingMessages = 128;
    var oldLogs = {};
    var wrappers = {};
    var levelValues = {'debug': 0, 'log': 1, 'info': 1, 'warn': 2, 'error': 3};

    function _accepts(logLevel) {
        return enabled && (levels === null || levels.indexOf(levelValues[logLevel]) !== -1);
    }

    function _flushMessages() {
        if (flushTimer !== null) {
            window.clearTimeout(flushTimer);
            flushTimer = null;
        }
        if (flushInProgress || pendingMessages.length === 0) return;
        do {
            var count = 0;
            var characters = 0;
            while (count < pendingMessages.length && count < maxBatchSize) {
                var size = pendingMessages[count].message.length + 48;
                if (count > 0 && characters + size > maxBatchCharacters) break;
                characters += size;
                count++;
            }
            var entries = pendingMessages.splice(0, count);
            pendingCharacters -= characters;
            // Preserve one finite reentrant burst, but never forward recursive
            // output produced while forwarding that burst. The original
            // browser console still receives every call.
            suppressReentrant = entries.some(function(entry) { return entry.fromBridge; });
            var batch = entries.map(function(entry) { return {'level': entry.level, 'message': entry.message}; });
            flushInProgress = true;
            try {
                bridge.callHandler('onConsoleMessageBatch', {'messages': batch});
            } catch(_) {} finally {
                flushInProgress = false;
                suppressReentrant = false;
            }
        } while (pendingMessages.length > 0);
    }

    function _callHandler(logLevel, args) {
        // Filter before invoking user-defined toString or constructing payloads.
        if (!_accepts(logLevel) || (flushInProgress && suppressReentrant)) return;
        if (flushInProgress && (pendingMessages.length >= maxPendingMessages || pendingCharacters >= maxBatchCharacters)) return;
        var message = '';
        for (var i = 0; i < args.length; i++) {
            try {
                message += message === '' ? args[i] : ' ' + args[i];
            } catch(_) {}
        }
        // String conversion may itself call console or change the policy.
        if (!_accepts(logLevel) || (flushInProgress && suppressReentrant)) return;
        var messageSize = message.length + 48;
        if (pendingMessages.length > 0 && pendingCharacters + messageSize > maxBatchCharacters) {
            // A bridge callback cannot synchronously flush its own in-flight
            // send. Drop only overflow from that reentrant burst.
            if (flushInProgress) return;
            _flushMessages();
        }
        if (!_accepts(logLevel)) return;
        pendingMessages.push({'level': logLevel, 'message': message, 'fromBridge': flushInProgress});
        pendingCharacters += messageSize;
        // One oversized message remains intact in its own batch for compatibility.
        if (flushInProgress) return;
        if (logLevel === 'warn' || logLevel === 'error' || pendingMessages.length >= maxBatchSize || pendingCharacters >= maxBatchCharacters) {
            _flushMessages();
        } else if (flushTimer === null) {
            flushTimer = window.setTimeout(_flushMessages, 25);
        }
    }

    bridge._setConsoleMessagePolicy = function(newEnabled, newLevels) {
        enabled = newEnabled;
        levels = newLevels;
        pendingMessages = pendingMessages.filter(function(entry) { return _accepts(entry.level); });
        pendingCharacters = pendingMessages.reduce(function(total, entry) { return total + entry.message.length + 48; }, 0);
        if (pendingMessages.length === 0 && flushTimer !== null) {
            window.clearTimeout(flushTimer);
            flushTimer = null;
        }
        // Avoid intercepting calls at all while no listener is attached. Do not
        // overwrite console methods replaced by the page after installation.
        for (var logLevel in wrappers) {
            if (enabled && console[logLevel] === oldLogs[logLevel]) {
                console[logLevel] = wrappers[logLevel];
            } else if (!enabled && console[logLevel] === wrappers[logLevel]) {
                console[logLevel] = oldLogs[logLevel];
            }
        }
    };

    window.addEventListener('pagehide', _flushMessages);
    window.document.addEventListener('visibilitychange', function() {
        if (window.document.hidden) _flushMessages();
    });

    for (var logLevel in levelValues) {
        (function(logLevel) {
            oldLogs[logLevel] = console[logLevel];
            wrappers[logLevel] = function() {
                oldLogs[logLevel].apply(console, arguments);
                _callHandler(logLevel, arguments);
            };
        })(logLevel);
    }
    bridge._setConsoleMessagePolicy(enabled, levels);

})(window.console, window.)JS" + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + R"JS(, true, null);
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
