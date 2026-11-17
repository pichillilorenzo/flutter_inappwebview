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
    public static func ON_SCROLL_CHANGED_EVENT_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?, enabled: Bool? = nil) -> PluginScript {
        var source = ON_SCROLL_CHANGED_EVENT_JS_SOURCE()
        if let enabled = enabled {
            source += """

            (function() {
                var bridge = window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME());
                if (bridge && bridge._setScrollChangedListener) bridge._setScrollChangedListener(\(enabled));
            })();
            """
        }
        return PluginScript(
            groupName: ON_SCROLL_CHANGED_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: source,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static func ON_SCROLL_CHANGED_EVENT_JS_SOURCE() -> String {
        return """
        (function(){
            var bridge = window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME());
            if (!bridge || bridge._setScrollChangedListener) return;
            // A document defines the control function without subscribing. Its
            // own native WebView supplies the policy, including for popups.
            var enabled = false;
            var frameId = null;
            var frameToken = 0;
            var pendingX = null;
            var pendingY = null;
            // Attaching alone should not report an unchanged initial position.
            var lastX = Math.trunc(window.scrollX);
            var lastY = Math.trunc(window.scrollY);

            function flushPendingScroll() {
                if (frameId !== null) {
                    window.cancelAnimationFrame(frameId);
                    frameId = null;
                }
                frameToken++;
                if (!enabled) return;
                if (pendingX === null || pendingY === null) return;
                var x = pendingX;
                var y = pendingY;
                pendingX = null;
                pendingY = null;
                if (x === lastX && y === lastY) return;
                lastX = x;
                lastY = y;
                bridge._callHandlerOneWay('onScrollChanged', {
                    'x': x,
                    'y': y
                });
            }

            function onScroll() {
                if (!enabled) return;
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
            }
            function onVisibilityChange() {
                if (document.hidden) flushPendingScroll();
            }
            bridge._setScrollChangedListener = function(value) {
                if (enabled === value) return;
                enabled = value;
                if (enabled) {
                    document.addEventListener('scroll', onScroll);
                    document.addEventListener('visibilitychange', onVisibilityChange);
                    window.addEventListener('pagehide', flushPendingScroll);
                    // Navigation/restoration can scroll before this document's
                    // native policy arrives. Reconcile it without waiting for
                    // another event, using the same coalesced/hidden flush.
                    if (Math.trunc(window.scrollX) !== lastX ||
                        Math.trunc(window.scrollY) !== lastY) onScroll();
                } else {
                    document.removeEventListener('scroll', onScroll);
                    document.removeEventListener('visibilitychange', onVisibilityChange);
                    window.removeEventListener('pagehide', flushPendingScroll);
                    if (frameId !== null) window.cancelAnimationFrame(frameId);
                    frameId = null;
                    frameToken++;
                    pendingX = pendingY = null;
                    // Keep the last delivered position for reattachment dedup
                    // and for movement that happens while no listener exists.
                }
            };
        })();
        """
    }
}
