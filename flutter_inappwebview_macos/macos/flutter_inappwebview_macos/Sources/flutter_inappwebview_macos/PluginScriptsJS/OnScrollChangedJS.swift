//
//  OnScrollEvent.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/10/22.
//

import Foundation

public class OnScrollChangedJS {
    
    public static let ON_SCROLL_CHANGED_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_ON_SCROLL_CHANGED_EVENT_JS_PLUGIN_SCRIPT"
    
    // This plugin is only for main frame
    public static func ON_SCROLL_CHANGED_EVENT_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: ON_SCROLL_CHANGED_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: ON_SCROLL_CHANGED_EVENT_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static func ON_SCROLL_CHANGED_EVENT_JS_SOURCE() -> String {
        return """
        (function(){
            document.addEventListener('scroll', function(e) {
                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onScrollChanged', {
                        'x': window.scrollX,
                        'y': window.scrollY
                    }
                );
            });
        })();
        """
    }
}
