//
//  WebMessagePort.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/03/21.
//

import Foundation

public class WebMessagePort : NSObject {
    var name: String
    var webMessageChannel: WebMessageChannel?
    var isClosed = false
    var isTransferred = false
    var isStarted = false
    
    public init(name: String, webMessageChannel: WebMessageChannel) {
        self.name = name
        super.init()
        self.webMessageChannel = webMessageChannel
    }
    
    public func setWebMessageCallback(completionHandler: ((Any?) -> Void)? = nil) throws {
        if isClosed || isTransferred {
            throw NSError(domain: "Port is already closed or transferred", code: 0)
        }
        self.isStarted = true
        if let webMessageChannel = webMessageChannel, let webView = webMessageChannel.webView {
            let index = name == "port1" ? 0 : 1
            webView.evaluateJavascript(source: """
            (function() {
                var webMessageChannel = \(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)["\(webMessageChannel.id)"];
                if (webMessageChannel != null) {
                    webMessageChannel.\(self.name).onmessage = function (event) {
                        window.webkit.messageHandlers["onWebMessagePortMessageReceived"].postMessage({
                            "webMessageChannelId": "\(webMessageChannel.id)",
                            "index": \(String(index)),
                            "message": event.data
                        });
                    }
                }
            })();
            """) { (_) in
                completionHandler?(nil)
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    public func postMessage(message: WebMessage, completionHandler: ((Any?) -> Void)? = nil) throws {
        if isClosed || isTransferred {
            throw NSError(domain: "Port is already closed or transferred", code: 0)
        }
        if let webMessageChannel = webMessageChannel, let webView = webMessageChannel.webView {
            var portsString = "null"
            if let ports = message.ports {
                var portArrayString: [String] = []
                for port in ports {
                    if port == self {
                        throw NSError(domain: "Source port cannot be transferred", code: 0)
                    }
                    if port.isStarted {
                        throw NSError(domain: "Port is already started", code: 0)
                    }
                    if port.isClosed || port.isTransferred {
                        throw NSError(domain: "Port is already closed or transferred", code: 0)
                    }
                    port.isTransferred = true
                    portArrayString.append("\(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)['\(port.webMessageChannel!.id)'].\(port.name)")
                }
                portsString = "[" + portArrayString.joined(separator: ", ") + "]"
            }
            let data = message.data?.replacingOccurrences(of: "\'", with: "\\'") ?? "null"
            let source = """
            (function() {
                var webMessageChannel = \(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)["\(webMessageChannel.id)"];
                if (webMessageChannel != null) {
                    webMessageChannel.\(self.name).postMessage('\(data)', \(portsString));
                }
            })();
            """
            webView.evaluateJavascript(source: source) { (_) in
                completionHandler?(nil)
            }
        } else {
            completionHandler?(nil)
        }
        message.dispose()
    }
    
    public func close(completionHandler: ((Any?) -> Void)? = nil) throws {
        if isTransferred {
            throw NSError(domain: "Port is already transferred", code: 0)
        }
        isClosed = true
        if let webMessageChannel = webMessageChannel, let webView = webMessageChannel.webView {
            let source = """
            (function() {
                var webMessageChannel = \(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)["\(webMessageChannel.id)"];
                if (webMessageChannel != null) {
                    webMessageChannel.\(self.name).close();
                }
            })();
            """
            webView.evaluateJavascript(source: source) { (_) in
                completionHandler?(nil)
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    public func dispose() {
        isClosed = true
        webMessageChannel = nil
    }
    
    deinit {
        print("WebMessagePort - dealloc")
        dispose()
    }
}
