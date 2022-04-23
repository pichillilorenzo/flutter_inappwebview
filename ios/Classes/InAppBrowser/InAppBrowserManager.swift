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
let NAV_STORYBOARD_CONTROLLER_ID = "navController"

public class InAppBrowserManager: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    
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
            case "open":
                open(arguments: arguments!)
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
        if previousStatusBarStyle == -1 {
            previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        }
        
        let browserOptions = InAppBrowserOptions()
        let _ = browserOptions.parse(options: options)
        
        let webViewOptions = InAppWebViewOptions()
        let _ = webViewOptions.parse(options: options)
        
        let webViewController = InAppBrowserWebViewController()
        webViewController.browserOptions = browserOptions
        webViewController.webViewOptions = webViewOptions
        webViewController.previousStatusBarStyle = previousStatusBarStyle
        return webViewController
    }
    
    public func open(arguments: NSDictionary) {
        let id = arguments["id"] as! String
        let urlRequest = arguments["urlRequest"] as? [String:Any?]
        let assetFilePath = arguments["assetFilePath"] as? String
        let data = arguments["data"] as? String
        let mimeType = arguments["mimeType"] as? String
        let encoding = arguments["encoding"] as? String
        let baseUrl = arguments["baseUrl"] as? String
        let options = arguments["options"] as! [String: Any?]
        let contextMenu = arguments["contextMenu"] as! [String: Any]
        let windowId = arguments["windowId"] as? Int64
        let initialUserScripts = arguments["initialUserScripts"] as? [[String: Any]]
        let pullToRefreshInitialOptions = arguments["pullToRefreshOptions"] as! [String: Any?]
        
        let webViewController = prepareInAppBrowserWebViewController(options: options)
        
        webViewController.id = id
        webViewController.initialUrlRequest = urlRequest != nil ? URLRequest.init(fromPluginMap: urlRequest!) : nil
        webViewController.initialFile = assetFilePath
        webViewController.initialData = data
        webViewController.initialMimeType = mimeType
        webViewController.initialEncoding = encoding
        webViewController.initialBaseUrl = baseUrl
        webViewController.contextMenu = contextMenu
        webViewController.windowId = windowId
        webViewController.initialUserScripts = initialUserScripts ?? []
        webViewController.pullToRefreshInitialOptions = pullToRefreshInitialOptions
        
        presentViewController(webViewController: webViewController)
    }
    
    public func presentViewController(webViewController: InAppBrowserWebViewController) {
        let storyboard = UIStoryboard(name: WEBVIEW_STORYBOARD, bundle: Bundle(for: InAppWebViewFlutterPlugin.self))
        let navController = storyboard.instantiateViewController(withIdentifier: NAV_STORYBOARD_CONTROLLER_ID) as! InAppBrowserNavigationController
        webViewController.edgesForExtendedLayout = []
        navController.pushViewController(webViewController, animated: false)
        webViewController.prepareNavigationControllerBeforeViewWillAppear()
        
        let frame: CGRect = UIScreen.main.bounds
        let tmpWindow = UIWindow(frame: frame)
        
        let tmpController = UIViewController()
        let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
        tmpWindow.rootViewController = tmpController
        tmpWindow.windowLevel = UIWindow.Level(baseWindowLevel!.rawValue + 1.0)
        tmpWindow.makeKeyAndVisible()
        navController.tmpWindow = tmpWindow
        
        var animated = true
        if let browserOptions = webViewController.browserOptions, browserOptions.hidden {
            tmpWindow.isHidden = true
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            animated = false
        }
        tmpWindow.rootViewController!.present(navController, animated: animated, completion: nil)
    }
    
    public func openWithSystemBrowser(url: String, result: @escaping FlutterResult) {
        let absoluteUrl = URL(string: url)!.absoluteURL
        if !UIApplication.shared.canOpenURL(absoluteUrl) {
            result(FlutterError(code: "InAppBrowserManager", message: url + " cannot be opened!", details: nil))
            return
        }
        else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(absoluteUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(absoluteUrl)
            }
        }
        result(true)
    }
    
    public func dispose() {
        InAppBrowserManager.channel?.setMethodCallHandler(nil)
        InAppBrowserManager.channel = nil
        InAppBrowserManager.registrar = nil
    }
}
