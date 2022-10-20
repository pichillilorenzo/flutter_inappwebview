//
//  FlutterWebViewFactory.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 13/11/18.
//

import Flutter
import Foundation

public class FlutterWebViewFactory: NSObject, FlutterPlatformViewFactory {
    static let VIEW_TYPE_ID = "com.pichillilorenzo/flutter_inappwebview"
    private var registrar: FlutterPluginRegistrar?
    
    init(registrar: FlutterPluginRegistrar?) {
        super.init()
        self.registrar = registrar
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as? NSDictionary
        
        if let headlessWebViewId = arguments?["headlessWebViewId"] as? String,
           let headlessWebView = HeadlessInAppWebViewManager.webViews[headlessWebViewId],
           let platformView = headlessWebView?.disposeAndGetFlutterWebView(withFrame: frame) {
            return platformView
        }
        
        let webviewController = FlutterWebViewController(registrar: registrar!,
                                                         withFrame: frame,
                                                         viewIdentifier: viewId,
                                                         params: arguments!)
        webviewController.makeInitialLoad(params: arguments!)
        return webviewController
    }
}
