//
//  HeadlessInAppWebViewManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/05/2020.
//

import Foundation

import FlutterMacOS
import AppKit
import WebKit
import Foundation
import AVFoundation

public class HeadlessInAppWebViewManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_headless_inappwebview"
    static var registrar: FlutterPluginRegistrar?
    static var webViews: [String: HeadlessInAppWebView?] = [:]
    
    init(registrar: FlutterPluginRegistrar) {
        super.init(channel: FlutterMethodChannel(name: HeadlessInAppWebViewManager.METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger))
        HeadlessInAppWebViewManager.registrar = registrar
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
    
    public override func dispose() {
        super.dispose()
        HeadlessInAppWebViewManager.registrar = nil
        let headlessWebViews = HeadlessInAppWebViewManager.webViews.values
        headlessWebViews.forEach { (headlessWebView: HeadlessInAppWebView?) in
            headlessWebView?.dispose()
        }
        HeadlessInAppWebViewManager.webViews.removeAll()
    }
    
    deinit {
        dispose()
    }
}
