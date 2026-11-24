//
//  HeadlessInAppWebView.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 26/03/21.
//

import Foundation
import Flutter

public class HeadlessInAppWebView: Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_headless_inappwebview_"

    var id: String
    var channelDelegate: HeadlessWebViewChannelDelegate?
    var flutterWebView: FlutterWebViewController?
    var plugin: InAppWebViewFlutterPlugin?
    
    public init(plugin: InAppWebViewFlutterPlugin, id: String, flutterWebView: FlutterWebViewController) {
        self.id = id
        self.flutterWebView = flutterWebView
        self.plugin = plugin
        let channel = FlutterMethodChannel(name: HeadlessInAppWebView.METHOD_CHANNEL_NAME_PREFIX + id,
                                           binaryMessenger: plugin.registrar.messenger())
        self.channelDelegate = HeadlessWebViewChannelDelegate(headlessWebView: self, channel: channel)
    }
    
    public func onWebViewCreated() {
        channelDelegate?.onWebViewCreated()
    }
    
    private var requestedSize = Size2D(width: -1, height: -1)

    public func prepare(params: NSDictionary) {
        if let view = flutterWebView?.view() {
            view.alpha = 0.01
            let initialSize = params["initialSize"] as? [String: Any?]
            setSize(size: Size2D.fromMap(map: initialSize) ?? requestedSize)
            attachToWindowIfNeeded()
        }
    }

    func attachToWindowIfNeeded() {
        guard let view = flutterWebView?.view(), view.superview == nil,
              let window = plugin?.window else {
            return
        }
        // WKWebView needs a view hierarchy to reliably execute JavaScript and
        // take screenshots. Retry when the scene activates if created at launch.
        window.insertSubview(view, at: 0)
        window.sendSubviewToBack(view)
        setSize(size: requestedSize)
    }

    public func setSize(size: Size2D) {
        requestedSize = size
        if let view = flutterWebView?.view() {
            let bounds = plugin?.window?.bounds ?? .zero
            let width = size.width == -1.0 ? bounds.width : CGFloat(size.width)
            let height = size.height == -1.0 ? bounds.height : CGFloat(size.height)
            view.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        }
    }

    public func getSize() -> Size2D? {
        if let view = flutterWebView?.view() {
            return Size2D(width: Double(view.frame.width), height: Double(view.frame.height))
        }
        return nil
    }
    
    public func disposeAndGetFlutterWebView(withFrame frame: CGRect) -> FlutterWebViewController? {
        let newFlutterWebView = flutterWebView
        if let view = flutterWebView?.view() {
            // restore WebView frame and alpha
            view.frame = frame
            view.alpha = 1.0
            // remove from parent
            view.removeFromSuperview()
            dispose(disposeWebView: false)
        }
        return newFlutterWebView
    }
    
    public func dispose(disposeWebView: Bool) {
        channelDelegate?.dispose()
        channelDelegate = nil
        plugin?.headlessInAppWebViewManager?.webViews[id] = nil
        if disposeWebView {
            flutterWebView?.dispose(removeFromSuperview: true)
        }
        flutterWebView = nil
        plugin = nil
    }
    
    public func dispose() {
        dispose(disposeWebView: true)
    }
    
    deinit {
        debugPrint("HeadlessInAppWebView - dealloc")
        dispose()
    }
}
