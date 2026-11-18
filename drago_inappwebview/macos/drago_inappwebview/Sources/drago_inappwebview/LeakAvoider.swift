//
//  LeakAvoider.swift
//  drago_inappwebview
//
//  Created by Lorenzo Pichilli on 15/12/2019.
//

import Foundation
import WebKit
import FlutterMacOS

public class LeakAvoider: NSObject {
    weak var delegate : FlutterMethodCallDelegate?
    
    init(delegate: FlutterMethodCallDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.delegate?.handle(call, result: result)
    }
    
    deinit {
        debugPrint("LeakAvoider - dealloc")
    }
}

/// Weak proxy so WKUserContentController (which retains its script message
/// handlers strongly) does not keep the InAppWebView alive.
public class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        super.init()
        self.delegate = delegate
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
