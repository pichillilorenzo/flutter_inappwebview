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
            var frameId = null;
            var frameToken = 0;
            var pendingX = null;
            var pendingY = null;
            var lastX = null;
            var lastY = null;

            function flushPendingScroll() {
                if (frameId !== null) {
                    window.cancelAnimationFrame(frameId);
                    frameId = null;
                }
                frameToken++;
                if (pendingX === null || pendingY === null) return;
                var x = pendingX;
                var y = pendingY;
                pendingX = null;
                pendingY = null;
                if (x === lastX && y === lastY) return;
                lastX = x;
                lastY = y;
                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._callHandlerOneWay('onScrollChanged', {
                    'x': x,
                    'y': y
                });
            }

            document.addEventListener('scroll', function(e) {
                pendingX = Math.trunc(window.scrollX);
                pendingY = Math.trunc(window.scrollY);
                if (document.hidden) {
                    flushPendingScroll();
                    return;
                }
                if (frameId !== null) return;
                var token = ++frameToken;
                frameId = window.requestAnimationFrame(function() {
                    if (token !== frameToken) return;
                    frameId = null;
                    flushPendingScroll();
                });
            });
            document.addEventListener('visibilitychange', function() {
                if (document.hidden) flushPendingScroll();
            });
            window.addEventListener('pagehide', flushPendingScroll);
        })();
        """
    }
}
