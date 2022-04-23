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

        switch call.method {
            case "open":
                let id: String = arguments!["id"] as! String
                let url = arguments!["url"] as! String
                let options = arguments!["options"] as! [String: Any?]
                let menuItemList = arguments!["menuItemList"] as! [[String: Any]]
                open(id: id, url: url, options: options,  menuItemList: menuItemList, result: result)
                break
            case "isAvailable":
                if #available(iOS 9.0, *) {
                    result(true)
                } else {
                    result(false)
                }
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func open(id: String, url: String, options: [String: Any?], menuItemList: [[String: Any]], result: @escaping FlutterResult) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        
        if #available(iOS 9.0, *) {
            
            if let flutterViewController = UIApplication.shared.delegate?.window.unsafelyUnwrapped?.rootViewController {
                // flutterViewController could be casted to FlutterViewController if needed
                
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
                
                safari.id = id
                safari.menuItemList = menuItemList
                safari.prepareMethodChannel()
                safari.delegate = safari
                safari.safariOptions = safariOptions
                safari.prepareSafariBrowser()
                
                flutterViewController.present(safari, animated: true) {
                    result(true)
                }
            }
            return
        }
        
        result(FlutterError.init(code: "ChromeSafariBrowserManager", message: "SafariViewController is not available!", details: nil))
    }
    
    public func dispose() {
        ChromeSafariBrowserManager.channel?.setMethodCallHandler(nil)
        ChromeSafariBrowserManager.channel = nil
        ChromeSafariBrowserManager.registrar = nil
    }
}
