//
//  LastTouchedAnchorOrImageJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class LastTouchedAnchorOrImageJS {
    
    public static let LAST_TOUCHED_ANCHOR_OR_IMAGE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_LAST_TOUCHED_ANCHOR_OR_IMAGE_JS_PLUGIN_SCRIPT"
    
    // This plugin is only for main frame
    public static func LAST_TOUCHED_ANCHOR_OR_IMAGE_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: LAST_TOUCHED_ANCHOR_OR_IMAGE_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: LAST_TOUCHED_ANCHOR_OR_IMAGE_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }
    
    public static func LAST_TOUCHED_ANCHOR_OR_IMAGE_JS_SOURCE() -> String {
        return """
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._lastAnchorOrImageTouched = null;
        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._lastImageTouched = null;
        (function() {
            document.addEventListener('touchstart', function(event) {
                var target = event.target;
                while (target) {
                    if (target.tagName === 'IMG') {
                        var img = target;
                        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._lastImageTouched = {
                            url: img.src
                        };
                        var parent = img.parentNode;
                        while (parent) {
                            if (parent.tagName === 'A') {
                                window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._lastAnchorOrImageTouched = {
                                    title: parent.textContent,
                                    url: parent.href,
                                    src: img.src
                                };
                                break;
                            }
                            parent = parent.parentNode;
                        }
                        return;
                    } else if (target.tagName === 'A') {
                        var link = target;
                        var images = link.getElementsByTagName('img');
                        var img = (images.length > 0) ? images[0] : null;
                        var imgSrc = (img != null) ? img.src : null;
                        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._lastImageTouched = (img != null) ? {url: imgSrc} : window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._lastImageTouched;
                        window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._lastAnchorOrImageTouched = {
                            title: link.textContent,
                            url: link.href,
                            src: imgSrc
                        };
                        return;
                    }
                    target = target.parentNode;
                }
            });
        })();
        """
    }
}
