//
//  File.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 03/03/21.
//

import Foundation
import Flutter

public class PullToRefreshControl : UIRefreshControl, FlutterPlugin {
    
    var channel: FlutterMethodChannel?
    var options: PullToRefreshOptions?
    var shouldCallOnRefresh = false
    var delegate: PullToRefreshDelegate?
    
    public init(channel: FlutterMethodChannel?, options: PullToRefreshOptions?) {
        super.init()
        self.channel = channel
        self.options = options
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    public func prepare() {
        self.channel?.setMethodCallHandler(self.handle)
        if let options = options {
            if options.enabled {
                delegate?.enablePullToRefresh()
            }
            if let color = options.color, !color.isEmpty {
                tintColor = UIColor(hexString: color)
            }
            if let backgroundTintColor = options.backgroundColor, !backgroundTintColor.isEmpty {
                backgroundColor = UIColor(hexString: backgroundTintColor)
            }
            if let attributedTitleMap = options.attributedTitle {
                attributedTitle = NSAttributedString.fromMap(map: attributedTitleMap)
            }
        }
        addTarget(self, action: #selector(updateShouldCallOnRefresh), for: .valueChanged)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
        case "setEnabled":
            let enabled = arguments!["enabled"] as! Bool
            if enabled {
                delegate?.enablePullToRefresh()
            } else {
                delegate?.disablePullToRefresh()
            }
            result(true)
            break
        case "setRefreshing":
            let refreshing = arguments!["refreshing"] as! Bool
            if refreshing {
                self.beginRefreshing()
            } else {
                self.endRefreshing()
            }
            result(true)
            break
        case "setColor":
            let color = arguments!["color"] as! String
            tintColor = UIColor(hexString: color)
            result(true)
            break
        case "setBackgroundColor":
            let color = arguments!["color"] as! String
            backgroundColor = UIColor(hexString: color)
            result(true)
            break
        case "setAttributedTitle":
            let attributedTitleMap = arguments!["attributedTitle"] as! [String: Any?]
            attributedTitle = NSAttributedString.fromMap(map: attributedTitleMap)
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func onRefresh() {
        shouldCallOnRefresh = false
        let arguments: [String: Any?] = [:]
        self.channel?.invokeMethod("onRefresh", arguments: arguments)
    }
    
    @objc public func updateShouldCallOnRefresh() {
        shouldCallOnRefresh = true
    }
    
    public func dispose() {
        channel?.setMethodCallHandler(nil)
        removeTarget(self, action: #selector(updateShouldCallOnRefresh), for: .valueChanged)
        delegate = nil
    }
    
    deinit {
        print("PullToRefreshControl - dealloc")
        dispose()
    }
}
