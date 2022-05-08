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

public class ChromeSafariBrowserManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_chromesafaribrowser"
    static var registrar: FlutterPluginRegistrar?
    static var browsers: [String: SafariViewController?] = [:]
    
    init(registrar: FlutterPluginRegistrar) {
        super.init(channel: FlutterMethodChannel(name: ChromeSafariBrowserManager.METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger()))
        ChromeSafariBrowserManager.registrar = registrar
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary

        switch call.method {
            case "open":
                let id = arguments!["id"] as! String
                let url = arguments!["url"] as! String
                let settings = arguments!["settings"] as! [String: Any?]
                let menuItemList = arguments!["menuItemList"] as! [[String: Any]]
                open(id: id, url: url, settings: settings,  menuItemList: menuItemList, result: result)
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
    
    public func open(id: String, url: String, settings: [String: Any?], menuItemList: [[String: Any]], result: @escaping FlutterResult) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        
        if #available(iOS 9.0, *) {
            
            if let flutterViewController = UIApplication.shared.delegate?.window.unsafelyUnwrapped?.rootViewController {
                // flutterViewController could be casted to FlutterViewController if needed
                
                let safariSettings = SafariBrowserSettings()
                let _ = safariSettings.parse(settings: settings)
                
                let safari: SafariViewController
                
                if #available(iOS 11.0, *) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = safariSettings.entersReaderIfAvailable
                    config.barCollapsingEnabled = safariSettings.barCollapsingEnabled
                    
                    safari = SafariViewController(id: id, url: absoluteUrl, configuration: config,
                                                  menuItemList: menuItemList, safariSettings: safariSettings)
                } else {
                    // Fallback on earlier versions
                    safari = SafariViewController(id: id, url: absoluteUrl, entersReaderIfAvailable: safariSettings.entersReaderIfAvailable,
                                                  menuItemList: menuItemList, safariSettings: safariSettings)
                }
                
                safari.prepareSafariBrowser()
                
                flutterViewController.present(safari, animated: true) {
                    result(true)
                }
                
                ChromeSafariBrowserManager.browsers[id] = safari
            }
            return
        }
        
        result(FlutterError.init(code: "ChromeSafariBrowserManager", message: "SafariViewController is not available!", details: nil))
    }
    
    public override func dispose() {
        super.dispose()
        ChromeSafariBrowserManager.registrar = nil
        let browsers = ChromeSafariBrowserManager.browsers.values
        browsers.forEach { (browser: SafariViewController?) in
            browser?.close(result: nil)
            browser?.dispose()
        }
        ChromeSafariBrowserManager.browsers.removeAll()
    }
    
    deinit {
        dispose()
    }
}
