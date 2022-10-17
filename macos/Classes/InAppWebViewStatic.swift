//
//  InAppWebViewStatic.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/12/2019.
//

import Foundation
import WebKit
import FlutterMacOS

public class InAppWebViewStatic: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_static"
    static var registrar: FlutterPluginRegistrar?
    static var webViewForUserAgent: WKWebView?
    static var defaultUserAgent: String?
    
    init(registrar: FlutterPluginRegistrar) {
        super.init(channel: FlutterMethodChannel(name: InAppWebViewStatic.METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger))
        InAppWebViewStatic.registrar = registrar
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
            case "getDefaultUserAgent":
                InAppWebViewStatic.getDefaultUserAgent(completionHandler: { (value) in
                    result(value)
                })
                break
            case "handlesURLScheme":
                let urlScheme = arguments!["urlScheme"] as! String
                if #available(macOS 10.13, *) {
                    result(WKWebView.handlesURLScheme(urlScheme))
                } else {
                    result(false)
                }
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    static public func getDefaultUserAgent(completionHandler: @escaping (_ value: String?) -> Void) {
        if defaultUserAgent == nil {
            InAppWebViewStatic.webViewForUserAgent = WKWebView()
            InAppWebViewStatic.webViewForUserAgent?.evaluateJavaScript("navigator.userAgent") { (value, error) in

                if error != nil {
                    print("Error occured to get userAgent")
                    self.webViewForUserAgent = nil
                    completionHandler(nil)
                    return
                }

                if let unwrappedUserAgent = value as? String {
                    InAppWebViewStatic.defaultUserAgent = unwrappedUserAgent
                    completionHandler(defaultUserAgent)
                } else {
                    print("Failed to get userAgent")
                }
                self.webViewForUserAgent = nil
            }
        } else {
            completionHandler(defaultUserAgent)
        }
    }
    
    public override func dispose() {
        super.dispose()
        InAppWebViewStatic.registrar = nil
        InAppWebViewStatic.webViewForUserAgent = nil
        InAppWebViewStatic.defaultUserAgent = nil
    }
    
    deinit {
        dispose()
    }
}
