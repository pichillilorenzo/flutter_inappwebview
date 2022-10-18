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

public class InAppBrowserManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappbrowser"
    static let WEBVIEW_STORYBOARD = "WebView"
    static let WEBVIEW_STORYBOARD_CONTROLLER_ID = "viewController"
    static let NAV_STORYBOARD_CONTROLLER_ID = "navController"
    static var registrar: FlutterPluginRegistrar?
    
    private var previousStatusBarStyle = -1
    
    init(registrar: FlutterPluginRegistrar) {
        super.init(channel: FlutterMethodChannel(name: InAppBrowserManager.METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger()))
        InAppBrowserManager.registrar = registrar
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
    
    public func prepareInAppBrowserWebViewController(settings: [String: Any?]) -> InAppBrowserWebViewController {
        if previousStatusBarStyle == -1 {
            previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        }
        
        let browserSettings = InAppBrowserSettings()
        let _ = browserSettings.parse(settings: settings)
        
        let webViewSettings = InAppWebViewSettings()
        let _ = webViewSettings.parse(settings: settings)
        
        let webViewController = InAppBrowserWebViewController()
        webViewController.browserSettings = browserSettings
        webViewController.isHidden = browserSettings.hidden
        webViewController.webViewSettings = webViewSettings
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
        let settings = arguments["settings"] as! [String: Any?]
        let contextMenu = arguments["contextMenu"] as! [String: Any]
        let windowId = arguments["windowId"] as? Int64
        let initialUserScripts = arguments["initialUserScripts"] as? [[String: Any]]
        let pullToRefreshInitialSettings = arguments["pullToRefreshSettings"] as! [String: Any?]
        
        let webViewController = prepareInAppBrowserWebViewController(settings: settings)
        
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
        webViewController.pullToRefreshInitialSettings = pullToRefreshInitialSettings
        
        presentViewController(webViewController: webViewController)
    }
    
    public func presentViewController(webViewController: InAppBrowserWebViewController) {
        let storyboard = UIStoryboard(name: InAppBrowserManager.WEBVIEW_STORYBOARD, bundle: Bundle(for: InAppWebViewFlutterPlugin.self))
        let navController = storyboard.instantiateViewController(withIdentifier: InAppBrowserManager.NAV_STORYBOARD_CONTROLLER_ID) as! InAppBrowserNavigationController
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
        if let browserSettings = webViewController.browserSettings, browserSettings.hidden {
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
    
    public override func dispose() {
        super.dispose()
        InAppBrowserManager.registrar = nil
    }
    
    deinit {
        dispose()
    }
}
