//
//  FlutterWebViewController.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 13/11/18.
//

import Foundation

public class FlutterWebViewController: NSObject, FlutterPlatformView {
    
    private weak var registrar: FlutterPluginRegistrar?
    private var webView: InAppWebView?
    private var viewId: Int64 = 0
    private var channel: FlutterMethodChannel?
    
    init(registrar: FlutterPluginRegistrar, withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: NSDictionary) {
        super.init()
        self.registrar = registrar
        self.viewId = viewId
        webView = InAppWebView(frame: frame)
        let channelName = String(format: "com.pichillilorenzo/flutter_inappwebview_%lld", viewId)
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        self.channel?.setMethodCallHandler(self.handle)
        
        var initialUrl = (args["initialUrl"] as? String)!
        let initialFile = args["initialFile"] as? String
        let initialData = args["initialData"] as? [String: String]
        let initialHeaders = (args["initialHeaders"] as? [String: String])!
        let initialOptions = (args["initialOptions"] as? [String: Any])!
        
        webView!.load(URLRequest(url: URL(string: initialUrl)!))
    }
    
    public func view() -> UIView {
        return webView!
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
            //case "open":
                //self.open(uuid: uuid, arguments: arguments!, result: result)
                //break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
}
