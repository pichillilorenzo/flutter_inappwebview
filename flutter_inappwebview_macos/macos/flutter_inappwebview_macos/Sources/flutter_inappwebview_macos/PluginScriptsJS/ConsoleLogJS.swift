//
//  ConsoleLogJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class ConsoleLogJS {

    public static let CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_CONSOLE_LOG_JS_PLUGIN_SCRIPT"

    // This plugin is only for main frame.
    // Using it also on non-main frames could cause issues
    // such as https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738
    public static func CONSOLE_LOG_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: CONSOLE_LOG_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: true,
            messageHandlerNames: [])
    }

    public static func CONSOLE_POLICY_JS_SOURCE(enabled: Bool, levels: [Int]?) -> String {
        let levelsJSON = levels.map { "[" + $0.map(String.init).joined(separator: ",") + "]" } ?? "null"
        return "window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._setConsoleMessagePolicy && window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._setConsoleMessagePolicy(\(enabled), \(levelsJSON));"
    }

    // the message needs to be concatenated with '' in order to have the same behavior like on Android
    public static func CONSOLE_LOG_JS_SOURCE() -> String {
        return """
        (function(console, bridge, enabled, levels) {
            if (!bridge) return;
            // Reinjection must not reset a document's policy to the bootstrap
            // defaults or wrap console twice. Refresh it from this WebView.
            if (bridge._setConsoleMessagePolicy) {
                try { bridge._callHandlerOneWay('onConsoleMessagePolicy', {}); } catch (_) {}
                return;
            }
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
                        bridge._callHandlerOneWay('onConsoleMessageBatch', {'messages': batch});
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
            // The shared WKUserContentController cannot hold per-WebView policy.
            // Native targets this document using WKScriptMessage.webView.
            try { bridge._callHandlerOneWay('onConsoleMessagePolicy', {}); } catch (_) {}
        })(window.console, window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()), true, null);
        """
    }
}
