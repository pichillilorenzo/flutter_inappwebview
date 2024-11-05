//
//  EnableViewportScaleJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class EnableViewportScaleJS {
    
    public static let ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT"
    
    // This plugin is only for main frame
    public static func ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: ENABLE_VIEWPORT_SCALE_JS_SOURCE,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static let ENABLE_VIEWPORT_SCALE_JS_SOURCE = """
        (function() {
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width');
            document.getElementsByTagName('head')[0].appendChild(meta);
        })()
        """
    
    public static func NOT_ENABLE_VIEWPORT_SCALE_JS_SOURCE() -> String {
        return """
        (function() {
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._originalViewPortMetaTagContent);
            document.getElementsByTagName('head')[0].appendChild(meta);
        })()
        """
    }
}
