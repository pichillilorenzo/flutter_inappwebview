//
//  OriginalViewPortMetaTagContentJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class OriginalViewPortMetaTagContentJS {
    
    public static let ORIGINAL_VIEWPORT_METATAG_CONTENT_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_ORIGINAL_VIEWPORT_METATAG_CONTENT_JS_PLUGIN_SCRIPT"
    
    // This plugin is only for main frame
    public static func ORIGINAL_VIEWPORT_METATAG_CONTENT_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: ORIGINAL_VIEWPORT_METATAG_CONTENT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: ORIGINAL_VIEWPORT_METATAG_CONTENT_JS_SOURCE(),
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static func ORIGINAL_VIEWPORT_METATAG_CONTENT_JS_SOURCE() -> String {
        return """
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._originalViewPortMetaTagContent = "";
        (function() {
            var metaTagNodes = document.head.getElementsByTagName('meta');
            for (var i = 0; i < metaTagNodes.length; i++) {
                var metaTagNode = metaTagNodes[i];
                if (metaTagNode.name === "viewport") {
                    window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._originalViewPortMetaTagContent = metaTagNode.content;
                }
            }
        })();
        """
    }
}
