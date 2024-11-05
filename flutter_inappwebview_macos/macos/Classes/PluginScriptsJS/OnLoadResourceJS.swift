//
//  resourceObserverJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class OnLoadResourceJS {
    
    public static let ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT"
    
    public static func FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE() -> String {
        return "window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._useOnLoadResource"
    }
    
    public static func ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?, forMainFrameOnly: Bool) -> PluginScript {
        return PluginScript(
            groupName: ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: ON_LOAD_RESOURCE_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: forMainFrameOnly,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static func ON_LOAD_RESOURCE_JS_SOURCE() -> String {
        return """
        \(FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE()) = true;
        (function() {
            var observer = new PerformanceObserver(function(list) {
                list.getEntries().forEach(function(entry) {
                    if (\(FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE()) == null || \(FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE()) == true) {
                        var resource = {
                            "url": entry.name,
                            "initiatorType": entry.initiatorType,
                            "startTime": entry.startTime,
                            "duration": entry.duration
                        };
                        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler("onLoadResource", resource);
                    }
                });
            });
            observer.observe({entryTypes: ['resource']});
        })();
        """
    }
}
