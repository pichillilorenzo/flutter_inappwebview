//
//  FlutterWebViewFactory.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 13/11/18.
//

import Flutter
import Foundation

public class FlutterWebViewFactory: NSObject, FlutterPlatformViewFactory {
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
        let webviewController = FlutterWebViewController(registrar: registrar!,
                                                         withFrame: frame,
                                                         viewIdentifier: viewId,
                                                         params: arguments!)
        webviewController.makeInitialLoad(params: arguments!)
        return webviewController
    }
}
