//
//  WebMessageListenerJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/03/21.
//

import Foundation

public class WebMessageListenerJS {
    
    public static func WEB_MESSAGE_LISTENER_JS_SOURCE() -> String {
        return """
        function FlutterInAppWebViewWebMessageListener(jsObjectName) {
            this.jsObjectName = jsObjectName;
            this.listeners = [];
            this.onmessage = null;
        }
        FlutterInAppWebViewWebMessageListener.prototype.postMessage = function(data) {
            var message = {
                "data": window.ArrayBuffer != null && data instanceof ArrayBuffer ? Array.from(new Uint8Array(data)) : (data != null ? data.toString() : null),
                "type": window.ArrayBuffer != null && data instanceof ArrayBuffer ? 1 : 0
            };
            window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()).callHandler('onWebMessageListenerPostMessageReceived', {jsObjectName: this.jsObjectName, message: message});
        };
        FlutterInAppWebViewWebMessageListener.prototype.addEventListener = function(type, listener) {
            if (listener == null) {
                return;
            }
            this.listeners.push(listener);
        };
        FlutterInAppWebViewWebMessageListener.prototype.removeEventListener = function(type, listener) {
            if (listener == null) {
                return;
            }
            var index = this.listeners.indexOf(listener);
            if (index >= 0) {
                this.listeners.splice(index, 1);
            }
        };
        """
    }
}
