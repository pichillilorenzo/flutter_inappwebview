//
//  javaScriptBridgeJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

let JAVASCRIPT_BRIDGE_NAME = "flutter_inappwebview"
let JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT"

let JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT = PluginScript(
    groupName: JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME,
    source: JAVASCRIPT_BRIDGE_JS_SOURCE,
    injectionTime: .atDocumentStart,
    forMainFrameOnly: false,
    requiredInAllContentWorlds: true,
    messageHandlerNames: ["callHandler"])

let JAVASCRIPT_BRIDGE_JS_SOURCE = """
window.\(JAVASCRIPT_BRIDGE_NAME) = {};
\(WEB_MESSAGE_CHANNELS_VARIABLE_NAME) = {};
window.\(JAVASCRIPT_BRIDGE_NAME).callHandler = function() {
    var _windowId = \(WINDOW_ID_VARIABLE_JS_SOURCE);
    var _callHandlerID = setTimeout(function(){});
    window.webkit.messageHandlers['callHandler'].postMessage( {'handlerName': arguments[0], '_callHandlerID': _callHandlerID, 'args': JSON.stringify(Array.prototype.slice.call(arguments, 1)), '_windowId': _windowId} );
    return new Promise(function(resolve, reject) {
        window.\(JAVASCRIPT_BRIDGE_NAME)[_callHandlerID] = resolve;
    });
};
\(WEB_MESSAGE_LISTENER_JS_SOURCE)
"""

let PLATFORM_READY_JS_SOURCE = "window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));";
