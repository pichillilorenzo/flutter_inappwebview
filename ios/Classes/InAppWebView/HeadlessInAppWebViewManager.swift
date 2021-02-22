//
//  HeadlessInAppWebViewManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/05/2020.
//

import Foundation

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation

public class HeadlessInAppWebViewManager: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    var flutterWebViews: [String: FlutterWebViewController] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        HeadlessInAppWebViewManager.registrar = registrar
        HeadlessInAppWebViewManager.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_headless_inappwebview", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: HeadlessInAppWebViewManager.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let uuid: String = arguments!["uuid"] as! String

        switch call.method {
            case "createHeadlessWebView":
                let params = arguments!["params"] as! [String: Any?]
                createHeadlessWebView(uuid: uuid, params: params)
                result(true)
                break
            case "disposeHeadlessWebView":
                disposeHeadlessWebView(uuid: uuid)
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func createHeadlessWebView(uuid: String, params: [String: Any?]) {
        let controller = FlutterWebViewController(registrar: HeadlessInAppWebViewManager.registrar!,
            withFrame: CGRect.zero,
            viewIdentifier: uuid,
            arguments: params as NSDictionary)
        flutterWebViews[uuid] = controller
    }
    
    public func disposeHeadlessWebView(uuid: String) {
        if let _ = flutterWebViews[uuid] {
            flutterWebViews.removeValue(forKey: uuid)
        }
    }
}
