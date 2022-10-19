//
//  FlutterWebViewFactory.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 13/11/18.
//

import SwiftUI
import Cocoa
import FlutterMacOS
import Foundation

public class FlutterWebViewFactory: NSObject, FlutterPlatformViewFactory {
    static let VIEW_TYPE_ID = "com.pichillilorenzo/flutter_inappwebview"
    private var registrar: FlutterPluginRegistrar?
    
    init(registrar: FlutterPluginRegistrar?) {
        super.init()
        self.registrar = registrar
    }
    
    public func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    public func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        let arguments = args as? NSDictionary
        let webviewController = FlutterWebViewController(registrar: registrar!,
                                                         withFrame: .zero,
                                                         viewIdentifier: viewId,
                                                         params: arguments!)
        webviewController.makeInitialLoad(params: arguments!)
        return webviewController.view()
    }
}
