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
    static var webViews: [String: HeadlessInAppWebView?] = [:]
    
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
        let id: String = arguments!["id"] as! String

        switch call.method {
            case "run":
                let params = arguments!["params"] as! [String: Any?]
                HeadlessInAppWebViewManager.run(id: id, params: params)
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public static func run(id: String, params: [String: Any?]) {
        let flutterWebView = FlutterWebViewController(registrar: HeadlessInAppWebViewManager.registrar!,
            withFrame: CGRect.zero,
            viewIdentifier: id,
            params: params as NSDictionary)
        let headlessInAppWebView = HeadlessInAppWebView(id: id, flutterWebView: flutterWebView)
        HeadlessInAppWebViewManager.webViews[id] = headlessInAppWebView
        
        headlessInAppWebView.prepare(params: params as NSDictionary)
        headlessInAppWebView.onWebViewCreated()
        flutterWebView.makeInitialLoad(params: params as NSDictionary)
    }
    
    public func dispose() {
        HeadlessInAppWebViewManager.channel?.setMethodCallHandler(nil)
        HeadlessInAppWebViewManager.channel = nil
        HeadlessInAppWebViewManager.registrar = nil
        let headlessWebViews = HeadlessInAppWebViewManager.webViews.values
        headlessWebViews.forEach { (headlessWebView: HeadlessInAppWebView?) in
            headlessWebView?.dispose()
        }
        HeadlessInAppWebViewManager.webViews.removeAll()
    }
}
