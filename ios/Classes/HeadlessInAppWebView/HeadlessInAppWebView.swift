//
//  HeadlessInAppWebView.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 26/03/21.
//

import Foundation

public class HeadlessInAppWebView : FlutterMethodCallDelegate {
    var id: String
    var channel: FlutterMethodChannel?
    var flutterWebView: FlutterWebViewController?
    
    public init(id: String, flutterWebView: FlutterWebViewController) {
        self.id = id
        super.init()
        self.flutterWebView = flutterWebView
        self.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_headless_inappwebview_" + id,
                                       binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        self.channel?.setMethodCallHandler(self.handle)
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
        case "dispose":
            dispose()
            result(true)
            break
        case "setSize":
            let sizeMap = arguments!["size"] as? [String: Any?]
            if let size = Size2D.fromMap(map: sizeMap) {
                setSize(size: size)
            }
            result(true)
            break
        case "getSize":
            result(getSize()?.toMap())
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func onWebViewCreated() {
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onWebViewCreated", arguments: arguments)
    }
    
    public func prepare(params: NSDictionary) {
        if let view = flutterWebView?.view() {
            view.alpha = 0.01
            let initialSize = params["initialSize"] as? [String: Any?]
            if let size = Size2D.fromMap(map: initialSize) {
                setSize(size: size)
            } else {
                view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            if let keyWindow = UIApplication.shared.keyWindow {
                /// Note: The WKWebView behaves very unreliable when rendering offscreen
                /// on a device. This is especially true with JavaScript, which simply
                /// won't be executed sometimes.
                /// So, add the headless WKWebView to the view hierarchy.
                /// This way is also possible to take screenshots.
                keyWindow.insertSubview(view, at: 0)
                keyWindow.sendSubviewToBack(view)
            }
        }
    }
    
    public func setSize(size: Size2D) {
        if let view = flutterWebView?.view() {
            let width = size.width == -1.0 ? UIScreen.main.bounds.width : CGFloat(size.width)
            let height = size.height == -1.0 ? UIScreen.main.bounds.height : CGFloat(size.height)
            view.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        }
    }
    
    public func getSize() -> Size2D? {
        if let view = flutterWebView?.view() {
            return Size2D(width: Double(view.frame.width), height: Double(view.frame.height))
        }
        return nil
    }
    
    public func dispose() {
        channel?.setMethodCallHandler(nil)
        channel = nil
        HeadlessInAppWebViewManager.webViews[id] = nil
        flutterWebView = nil
    }
    
    deinit {
        print("HeadlessInAppWebView - dealloc")
        dispose()
    }
}
