//
//  InAppWebViewStatic.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/12/2019.
//

import Foundation
import WebKit

class InAppWebViewStatic: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    static var webViewForUserAgent: WKWebView?
    static var defaultUserAgent: String?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        InAppWebViewStatic.registrar = registrar
        InAppWebViewStatic.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappwebview_static", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: InAppWebViewStatic.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "getDefaultUserAgent":
                InAppWebViewStatic.getDefaultUserAgent(completionHandler: { (value) in
                    result(value)
                })
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
}
