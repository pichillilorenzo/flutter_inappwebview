//
//  InAppBrowserManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 18/12/2019.
//

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation

let WEBVIEW_STORYBOARD = "WebView"
let WEBVIEW_STORYBOARD_CONTROLLER_ID = "viewController"

public class InAppBrowserManager: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    
    // var tmpWindow: UIWindow?
    private var previousStatusBarStyle = -1
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        InAppBrowserManager.registrar = registrar
        InAppBrowserManager.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: InAppBrowserManager.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary

        switch call.method {
            case "openUrl":
                let uuid = arguments!["uuid"] as! String
                let url = arguments!["url"] as! String
                let options = arguments!["options"] as! [String: Any?]
                let headers = arguments!["headers"] as! [String: String]
                let contextMenu = arguments!["contextMenu"] as! [String: Any]
                let windowId = arguments!["windowId"] as? Int64
                openUrl(uuid: uuid, url: url, options: options, headers: headers, contextMenu: contextMenu, windowId: windowId)
                result(true)
                break
            case "openFile":
                let uuid = arguments!["uuid"] as! String
                var url = arguments!["url"] as! String
                let key = InAppBrowserManager.registrar!.lookupKey(forAsset: url)
                let assetURL = Bundle.main.url(forResource: key, withExtension: nil)
                if assetURL == nil {
                    result(FlutterError(code: "InAppBrowserFlutterPlugin", message: url + " asset file cannot be found!", details: nil))
                    return
                } else {
                    url = assetURL!.absoluteString
                }
                let options = arguments!["options"] as! [String: Any?]
                let headers = arguments!["headers"] as! [String: String]
                let contextMenu = arguments!["contextMenu"] as! [String: Any]
                let windowId = arguments!["windowId"] as? Int64
                openUrl(uuid: uuid, url: url, options: options, headers: headers, contextMenu: contextMenu, windowId: windowId)
                result(true)
                break
            case "openData":
                let uuid = arguments!["uuid"] as! String
                let options = arguments!["options"] as! [String: Any?]
                let data = arguments!["data"] as! String
                let mimeType = arguments!["mimeType"] as! String
                let encoding = arguments!["encoding"] as! String
                let baseUrl = arguments!["baseUrl"] as! String
                let contextMenu = arguments!["contextMenu"] as! [String: Any]
                let windowId = arguments!["windowId"] as? Int64
                openData(uuid: uuid, options: options, data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl, contextMenu: contextMenu, windowId: windowId)
                result(true)
                break
            case "openWithSystemBrowser":
                let url = arguments!["url"] as! String
                openWithSystemBrowser(url: url, result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func prepareInAppBrowserWebViewController(options: [String: Any?]) -> InAppBrowserWebViewController {
        if self.previousStatusBarStyle == -1 {
            self.previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        }
        
        let frame: CGRect = UIScreen.main.bounds
        let tmpWindow = UIWindow(frame: frame)
        
        let tmpController = UIViewController()
        let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
        tmpWindow.rootViewController = tmpController
        tmpWindow.windowLevel = UIWindow.Level(baseWindowLevel!.rawValue + 1.0)
        tmpWindow.makeKeyAndVisible()
        
        let browserOptions = InAppBrowserOptions()
        let _ = browserOptions.parse(options: options)
        
        let webViewOptions = InAppWebViewOptions()
        let _ = webViewOptions.parse(options: options)
        
        let storyboard = UIStoryboard(name: WEBVIEW_STORYBOARD, bundle: Bundle(for: InAppWebViewFlutterPlugin.self))
        let webViewController = storyboard.instantiateViewController(withIdentifier: WEBVIEW_STORYBOARD_CONTROLLER_ID) as! InAppBrowserWebViewController
        webViewController.tmpWindow = tmpWindow
        webViewController.browserOptions = browserOptions
        webViewController.webViewOptions = webViewOptions
        webViewController.isHidden = browserOptions.hidden
        webViewController.previousStatusBarStyle = previousStatusBarStyle
        webViewController.prepareBeforeViewWillAppear()
        return webViewController
    }
    
    public func openUrl(uuid: String, url: String, options: [String: Any?], headers: [String: String],
                        contextMenu: [String: Any], windowId: Int64?) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        let webViewController = prepareInAppBrowserWebViewController(options: options)
        
        webViewController.uuid = uuid
        webViewController.prepareMethodChannel()
        webViewController.initURL = absoluteUrl
        webViewController.initHeaders = headers
        webViewController.contextMenu = contextMenu
        webViewController.windowId = windowId
        
        if webViewController.isHidden {
            webViewController.view.isHidden = true
            webViewController.tmpWindow!.rootViewController!.present(webViewController, animated: false, completion: {() -> Void in

            })
            webViewController.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                webViewController.tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            })
        }
        else {
            webViewController.tmpWindow!.rootViewController!.present(webViewController, animated: true, completion: {() -> Void in

            })
        }
    }
    
    public func openData(uuid: String, options: [String: Any?], data: String, mimeType: String, encoding: String,
                         baseUrl: String, contextMenu: [String: Any], windowId: Int64?) {
        let webViewController = prepareInAppBrowserWebViewController(options: options)
        
        webViewController.uuid = uuid
        webViewController.prepareMethodChannel()
        webViewController.initData = data
        webViewController.initMimeType = mimeType
        webViewController.initEncoding = encoding
        webViewController.initBaseUrl = baseUrl
        webViewController.contextMenu = contextMenu
        webViewController.windowId = windowId
        
        if webViewController.isHidden {
            webViewController.view.isHidden = true
            webViewController.tmpWindow!.rootViewController!.present(webViewController, animated: false, completion: {() -> Void in
                webViewController.webView.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
            })
            webViewController.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                webViewController.tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            })
        }
        else {
            webViewController.tmpWindow!.rootViewController!.present(webViewController, animated: true, completion: {() -> Void in
                webViewController.webView.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
            })
        }
    }
    
    public func openWithSystemBrowser(url: String, result: @escaping FlutterResult) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        if !UIApplication.shared.canOpenURL(absoluteUrl) {
            result(FlutterError(code: "InAppBrowserManager", message: url + " cannot be opened!", details: nil))
            return
        }
        else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(absoluteUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(absoluteUrl)
            }
        }
        result(true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
