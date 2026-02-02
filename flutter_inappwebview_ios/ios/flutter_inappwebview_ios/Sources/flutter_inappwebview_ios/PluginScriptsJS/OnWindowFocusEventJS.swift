//
//  OnWindowFocusEventJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class OnWindowFocusEventJS {
    
    public static let ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT"
    
    // This plugin is only for main frame
    public static func ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: ON_WINDOW_FOCUS_EVENT_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static func ON_WINDOW_FOCUS_EVENT_JS_SOURCE() -> String {
        return """
        (function(){
            window.addEventListener('focus', function(e) {
                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onWindowFocus');
            });
        })();
        """
    }
}
