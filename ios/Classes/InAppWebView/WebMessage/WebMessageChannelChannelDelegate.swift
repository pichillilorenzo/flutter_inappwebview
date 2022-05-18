//
//  WebMessageChannelChannelDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 07/05/22.
//

import Foundation

public class WebMessageChannelChannelDelegate : ChannelDelegate {
    private weak var webMessageChannel: WebMessageChannel?
    
    public init(webMessageChannel: WebMessageChannel, channel: FlutterMethodChannel) {
        super.init(channel: channel)
        self.webMessageChannel = webMessageChannel
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
        case "setWebMessageCallback":
            if let _ = webMessageChannel?.webView, let ports = webMessageChannel?.ports, ports.count > 0 {
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
            if let webView = webMessageChannel?.webView, let ports = webMessageChannel?.ports, ports.count > 0 {
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
            if let _ = webMessageChannel?.webView, let ports = webMessageChannel?.ports, ports.count > 0 {
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
    
    public override func dispose() {
        super.dispose()
        webMessageChannel = nil
    }
    
    deinit {
        dispose()
    }
}
