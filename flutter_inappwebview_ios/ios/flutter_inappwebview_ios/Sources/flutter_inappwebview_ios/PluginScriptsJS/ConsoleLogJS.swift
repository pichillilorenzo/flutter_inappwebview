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
        
            function _callHandler(logLevel, args) {
                var message = '';
                function _stringify(v) {
                    try {
                        if (v === null || typeof v !== 'object') return String(v);
                        if (v instanceof Error) return v.name + ': ' + v.message + (v.stack ? '\\n' + v.stack : '');
                        // Only stringify plain objects/arrays; leave DOM nodes, host objects and
                        // proxies to String() so we don't trip their getters (e.g. .outerHTML).
                        var proto = Object.getPrototypeOf(v);
                        if (Array.isArray(v) || proto === Object.prototype || proto === null) {
                            var s = JSON.stringify(v);
                            if (typeof s === 'string') return s.length > 2000 ? s.slice(0, 2000) + '...(truncated)' : s;
                        }
                    } catch(_) {}
                    var str;
                    try { str = String(v); } catch(_) { return '[object]'; }
                    // Upgrade the generic [object Object] to the constructor name.
                    if (str === '[object Object]') {
                        try { var cn = v.constructor && v.constructor.name; if (cn) return '[object ' + cn + ']'; } catch(_) {}
                    }
                    return str;
                }
                for (var i in args) {
                    try {
                        message += (message === '' ? '' : ' ') + _stringify(args[i]);
                    } catch(_) {}
                }
                try {
                    window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onConsoleMessage', {'level': logLevel, 'message': message})
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
        """
    }
}
