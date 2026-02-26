//
//  WindowIdJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class WindowIdJS {
    
    public static let WINDOW_ID_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_WINDOW_ID_JS_PLUGIN_SCRIPT"
    
    public static func WINDOW_ID_VARIABLE_JS_SOURCE() -> String {
        return "window._\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())_windowId"
    }
    
    public static func WINDOW_ID_INITIALIZE_JS_SOURCE() -> String {
        return """
        (function() {
            \(WINDOW_ID_VARIABLE_JS_SOURCE()) = \(PluginScriptsUtil.VAR_PLACEHOLDER_VALUE);
            return \(WINDOW_ID_VARIABLE_JS_SOURCE());
        })()
        """
    }
}
