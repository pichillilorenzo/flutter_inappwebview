//
//  WebMessageChannel.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/03/21.
//

import Foundation

public class WebMessageChannel : FlutterMethodCallDelegate {
    var id: String
    var channel: FlutterMethodChannel?
    var webView: InAppWebView?
    var ports: [WebMessagePort] = []
    
    public init(id: String) {
        self.id = id
        super.init()
        self.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappwebview_web_message_channel_" + id,
                                       binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        self.channel?.setMethodCallHandler(self.handle)
        self.ports = [
            WebMessagePort(name: "port1", webMessageChannel: self),
            WebMessagePort(name: "port2", webMessageChannel: self)
        ]
    }
    
    public func initJsInstance(webView: InAppWebView, completionHandler: ((WebMessageChannel) -> Void)? = nil) {
        self.webView = webView
        if let webView = self.webView {
            webView.evaluateJavascript(source: """
            (function() {
                \(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)["\(id)"] = new MessageChannel();
            })();
            """) { (_) in
                completionHandler?(self)
            }
        } else {
            completionHandler?(self)
        }
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
        case "setWebMessageCallback":
            if let _ = webView, ports.count > 0 {
                let index = arguments!["index"] as! Int
                let port = ports[index]
                do {
                    try port.setWebMessageCallback { (_) in
                        result(true)
                    }
                } catch let error as NSError {
                    result(FlutterError(code: "WebMessageChannel", message: error.domain, details: nil))
                }
                
            } else {
               result(true)
            }
            break
        case "postMessage":
            if let webView = webView, ports.count > 0 {
                let index = arguments!["index"] as! Int
                let port = ports[index]
                let message = arguments!["message"] as! [String: Any?]
                
                var webMessagePorts: [WebMessagePort] = []
                let portsMap = message["ports"] as? [[String: Any?]]
                if let portsMap = portsMap {
                    for portMap in portsMap {
                        let webMessageChannelId = portMap["webMessageChannelId"] as! String
                        let index = portMap["index"] as! Int
                        if let webMessageChannel = webView.webMessageChannels[webMessageChannelId] {
                            webMessagePorts.append(webMessageChannel.ports[index])
                        }
                    }
                }
                let webMessage = WebMessage(data: message["data"] as? String, ports: webMessagePorts)
                do {
                    try port.postMessage(message: webMessage) { (_) in
                        result(true)
                    }
                } catch let error as NSError {
                    result(FlutterError(code: "WebMessageChannel", message: error.domain, details: nil))
                }
            } else {
                result(true)
            }
            break
        case "close":
            if let _ = webView, ports.count > 0 {
                let index = arguments!["index"] as! Int
                let port = ports[index]
                do {
                    try port.close { (_) in
                        result(true)
                    }
                } catch let error as NSError {
                    result(FlutterError(code: "WebMessageChannel", message: error.domain, details: nil))
                }
            } else {
                result(true)
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func onMessage(index: Int64, message: String?) {
        let arguments: [String:Any?] = [
            "index": index,
            "message": message
        ]
        channel?.invokeMethod("onMessage", arguments: arguments)
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "id": id
        ]
    }
    
    public func dispose() {
        channel?.setMethodCallHandler(nil)
        channel = nil
        for port in ports {
            port.dispose()
        }
        ports.removeAll()
        webView?.evaluateJavascript(source: """
        (function() {
            var webMessageChannel = \(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)["\(id)"];
            if (webMessageChannel != null) {
                webMessageChannel.port1.close();
                webMessageChannel.port2.close();
                delete \(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)["\(id)"];
            }
        })();
        """)
        webView = nil
    }
    
    deinit {
        print("WebMessageChannel - dealloc")
        dispose()
    }
}
