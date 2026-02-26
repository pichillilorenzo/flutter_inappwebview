//
//  PrintJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class PrintJS {
    
    public static let PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_PRINT_JS_PLUGIN_SCRIPT"
    
    public static func  PRINT_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?, forMainFrameOnly: Bool) -> PluginScript {
        return PluginScript(
            groupName: PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: PRINT_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: forMainFrameOnly,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: true,
            messageHandlerNames: [])
    }
    
    public static func PRINT_JS_SOURCE() -> String {
        return """
        window.print = function() {
            window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler("onPrintRequest", window.location.href);
        }
        """
    }
}
