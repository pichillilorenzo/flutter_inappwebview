//
//  ChromeSafariBrowserManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 18/12/2019.
//

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation
import SafariServices

public class ChromeSafariBrowserManager: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    
    var tmpWindow: UIWindow?
    private var previousStatusBarStyle = -1
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        ChromeSafariBrowserManager.registrar = registrar
        ChromeSafariBrowserManager.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_chromesafaribrowser", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: ChromeSafariBrowserManager.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let uuid: String = arguments!["uuid"] as! String

        switch call.method {
            case "open":
                let url = arguments!["url"] as! String
                let options = arguments!["options"] as! [String: Any?]
                let menuItemList = arguments!["menuItemList"] as! [[String: Any]]
                let uuidFallback = arguments!["uuidFallback"] as? String
                let headersFallback = arguments!["headersFallback"] as? [String: String]
                let optionsFallback = arguments!["optionsFallback"] as? [String: Any?]
                let contextMenuFallback = arguments!["contextMenuFallback"] as? [String: Any]
                open(uuid: uuid, url: url, options: options,  menuItemList: menuItemList, uuidFallback: uuidFallback, headersFallback: headersFallback, optionsFallback: optionsFallback, contextMenuFallback: contextMenuFallback, result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func open(uuid: String, url: String, options: [String: Any?], menuItemList: [[String: Any]], uuidFallback: String?, headersFallback: [String: String]?, optionsFallback: [String: Any?]?, contextMenuFallback: [String: Any]?, result: @escaping FlutterResult) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        
        if self.previousStatusBarStyle == -1 {
            self.previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        }
        
        if !(self.tmpWindow != nil) {
            let frame: CGRect = UIScreen.main.bounds
            self.tmpWindow = UIWindow(frame: frame)
        }
        
        let tmpController = UIViewController()
        let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
        self.tmpWindow!.rootViewController = tmpController
        self.tmpWindow!.windowLevel = UIWindow.Level(baseWindowLevel!.rawValue + 1.0)
        self.tmpWindow!.makeKeyAndVisible()
        
        if #available(iOS 9.0, *) {
            let safariOptions = SafariBrowserOptions()
            let _ = safariOptions.parse(options: options)
            
            let safari: SafariViewController
            
            if #available(iOS 11.0, *) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = safariOptions.entersReaderIfAvailable
                config.barCollapsingEnabled = safariOptions.barCollapsingEnabled
                
                safari = SafariViewController(url: absoluteUrl, configuration: config)
            } else {
                // Fallback on earlier versions
                safari = SafariViewController(url: absoluteUrl)
            }
            
            safari.uuid = uuid
            safari.menuItemList = menuItemList
            safari.prepareMethodChannel()
            safari.delegate = safari
            safari.tmpWindow = tmpWindow
            safari.safariOptions = safariOptions
            safari.prepareSafariBrowser()
            
            tmpController.present(safari, animated: true) {
                result(true)
            }
            return
        }
        else {
            if uuidFallback == nil {
                print("No WebView fallback declared.")
                result(true)
                
                return
            }
            SwiftFlutterPlugin.instance!.inAppBrowserManager!.openUrl(uuid: uuidFallback!, url: url, options: optionsFallback ?? [:], headers: headersFallback ?? [:], contextMenu: contextMenuFallback ?? [:])
        }
    }
}
