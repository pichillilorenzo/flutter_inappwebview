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
    
    // the message needs to be concatenated with '' in order to have the same behavior like on Android
    public static func CONSOLE_LOG_JS_SOURCE() -> String {
        return """
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
                    window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._callHandlerOneWay('onConsoleMessageBatch', {'messages': batch});
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
        """
    }
}
