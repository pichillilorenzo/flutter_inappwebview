/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation
import SafariServices

let WEBVIEW_STORYBOARD = "WebView"
let WEBVIEW_STORYBOARD_CONTROLLER_ID = "viewController"

extension Dictionary where Key: ExpressibleByStringLiteral {
    public mutating func lowercaseKeys() {
        for key in self.keys {
            self[String(describing: key).lowercased() as! Key] = self.removeValue(forKey: key)
        }
    }
}

public class SwiftFlutterPlugin: NSObject, FlutterPlugin {
    
    static var instance: SwiftFlutterPlugin?
    var registrar: FlutterPluginRegistrar?
    var channel: FlutterMethodChannel?
    
    var webViewControllers: [String: InAppBrowserWebViewController?] = [:]
    var safariViewControllers: [String: Any?] = [:]
    
    var tmpWindow: UIWindow?
    private var previousStatusBarStyle = -1
    
    public init(with registrar: FlutterPluginRegistrar) {
        super.init()
        
        self.registrar = registrar
        self.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: channel!)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftFlutterPlugin.instance = SwiftFlutterPlugin(with: registrar)
        registrar.register(FlutterWebViewFactory(registrar: registrar) as FlutterPlatformViewFactory, withId: "com.pichillilorenzo/flutter_inappwebview")
        
        InAppWebViewStatic(registrar: registrar)
        if #available(iOS 11.0, *) {
            MyCookieManager(registrar: registrar)
        }
        if #available(iOS 9.0, *) {
            MyWebStorageManager(registrar: registrar)
        }
        CredentialDatabase(registrar: registrar)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let uuid: String = arguments!["uuid"] as! String

        switch call.method {
            case "open":
                self.open(uuid: uuid, arguments: arguments!, result: result)
                break
            case "getUrl":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController!.webView.url?.absoluteString)
                }
                else {
                    result(nil)
                }
                break
            case "getTitle":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController!.webView.title)
                }
                else {
                    result(nil)
                }
                break
            case "getProgress":
                if let webViewController = self.webViewControllers[uuid] {
                    let progress = Int(webViewController!.webView.estimatedProgress * 100)
                    result(progress)
                }
                else {
                    result(nil)
                }
                break
            case "loadUrl":
                self.loadUrl(uuid: uuid, arguments: arguments!, result: result)
                break
            case "loadData":
                self.loadData(uuid: uuid, arguments: arguments!, result: result)
                break
            case "postUrl":
                self.postUrl(uuid: uuid, arguments: arguments!, result: result)
                break
            case "loadFile":
                self.loadFile(uuid: uuid, arguments: arguments!, result: result)
                break
            case "close":
                self.close(uuid: uuid)
                result(true)
                break
            case "show":
                self.show(uuid: uuid)
                result(true)
                break
            case "hide":
                self.hide(uuid: uuid)
                result(true)
                break
            case "reload":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController!.reload()
                }
                result(true)
                break
            case "goBack":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController!.goBack()
                }
                result(true)
                break
            case "canGoBack":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController!.canGoBack())
                }
                else {
                    result(false)
                }
                break
            case "goForward":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController!.goForward()
                }
                result(true)
                break
            case "canGoForward":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController!.canGoForward())
                }
                else {
                    result(false)
                }
                break
            case "goBackOrForward":
                if let webViewController = self.webViewControllers[uuid] {
                    let steps = arguments!["steps"] as! Int
                    webViewController!.goBackOrForward(steps: steps)
                }
                result(true)
                break
            case "canGoBackOrForward":
                if let webViewController = self.webViewControllers[uuid] {
                    let steps = arguments!["steps"] as! Int
                    result(webViewController!.canGoBackOrForward(steps: steps))
                }
                else {
                    result(false)
                }
                break
            case "isLoading":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController!.webView.isLoading == true)
                }
                else {
                    result(false)
                }
                break
            case "stopLoading":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController!.webView.stopLoading()
                }
                result(true)
                break
            case "isHidden":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController!.isHidden == true)
                }
                else {
                    result(false)
                }
                break
            case "evaluateJavascript":
                self.evaluateJavascript(uuid: uuid, arguments: arguments!, result: result)
                break
            case "injectJavascriptFileFromUrl":
                self.injectJavascriptFileFromUrl(uuid: uuid, arguments: arguments!)
                result(true)
                break
            case "injectCSSCode":
                self.injectCSSCode(uuid: uuid, arguments: arguments!)
                result(true)
                break
            case "injectCSSFileFromUrl":
                self.injectCSSFileFromUrl(uuid: uuid, arguments: arguments!)
                result(true)
                break
            case "takeScreenshot":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController!.webView.takeScreenshot(completionHandler: { (screenshot) -> Void in
                        result(screenshot)
                    })
                }
                else {
                    result(nil)
                }
                break
            case "setOptions":
                let optionsType = arguments!["optionsType"] as! String
                switch (optionsType){
                    case "InAppBrowserOptions":
                        let inAppBrowserOptions = InAppBrowserOptions()
                        let inAppBrowserOptionsMap = arguments!["options"] as! [String: Any]
                        inAppBrowserOptions.parse(options: inAppBrowserOptionsMap)
                        self.setOptions(uuid: uuid, options: inAppBrowserOptions, optionsMap: inAppBrowserOptionsMap)
                        break
                    default:
                        result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "Options " + optionsType + " not available.", details: nil))
                }
                result(true)
                break
            case "getOptions":
                result(self.getOptions(uuid: uuid))
                break
            case "getCopyBackForwardList":
                result(self.getCopyBackForwardList(uuid: uuid))
                break
            case "findAllAsync":
                let find = arguments!["find"] as! String
                self.findAllAsync(uuid: uuid, find: find)
                result(true)
                break
            case "findNext":
                let forward = arguments!["forward"] as! Bool
                self.findNext(uuid: uuid, forward: forward, result: result)
                break
            case "clearMatches":
                self.clearMatches(uuid: uuid, result: result)
                break
            case "clearCache":
                self.clearCache(uuid: uuid)
                result(true)
                break
            case "scrollTo":
                let x = arguments!["x"] as! Int
                let y = arguments!["y"] as! Int
                self.scrollTo(uuid: uuid, x: x, y: y)
                result(true)
                break
            case "scrollBy":
                let x = arguments!["x"] as! Int
                let y = arguments!["y"] as! Int
                self.scrollTo(uuid: uuid, x: x, y: y)
                result(true)
                break
            case "pauseTimers":
               self.pauseTimers(uuid: uuid)
               result(true)
               break
            case "resumeTimers":
                self.resumeTimers(uuid: uuid)
                result(true)
                break
            case "printCurrentPage":
                self.printCurrentPage(uuid: uuid, result: result)
                break
            case "getContentHeight":
                result(self.getContentHeight(uuid: uuid))
                break
            case "reloadFromOrigin":
                self.reloadFromOrigin(uuid: uuid)
                result(true)
                break
            case "getScale":
                result(self.getScale(uuid: uuid))
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    func close(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            // Things are cleaned up in browserExit.
            webViewController?.close()
        }
        else {
            print("IAB.close() called but it was already closed.")
        }
    }
    
    func isSystemUrl(_ url: URL) -> Bool {
        if (url.host == "itunes.apple.com") {
            return true
        }
        return false
    }
    
    public func open(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        let isData: Bool = (arguments["isData"] as? Bool)!
        
        if !isData {
            let url: String = (arguments["url"] as? String)!

            let headers = (arguments["headers"] as? [String: String])!
            var absoluteUrl = URL(string: url)?.absoluteURL

            let useChromeSafariBrowser = (arguments["useChromeSafariBrowser"] as? Bool)!
            
            if useChromeSafariBrowser {
                let uuidFallback = (arguments["uuidFallback"] as? String)!
                let safariOptions = (arguments["options"] as? [String: Any])!
                
                let optionsFallback = (arguments["optionsFallback"] as? [String: Any])!
                
                open(uuid: uuid, uuidFallback: uuidFallback, inAppBrowser: absoluteUrl!, headers: headers, withOptions: safariOptions, useChromeSafariBrowser: true, withOptionsFallback: optionsFallback, result: result)
            }
            else {
                let options = (arguments["options"] as? [String: Any])!
                
                let isLocalFile = (arguments["isLocalFile"] as? Bool)!
                var openWithSystemBrowser = (arguments["openWithSystemBrowser"] as? Bool)!
                
                if isLocalFile {
                    let key = self.registrar!.lookupKey(forAsset: url)
                    let assetURL = Bundle.main.url(forResource: key, withExtension: nil)
                    if assetURL == nil {
                        result(FlutterError(code: "InAppBrowserFlutterPlugin", message: url + " asset file cannot be found!", details: nil))
                        return
                    }
                    absoluteUrl = assetURL!
                }

                if isSystemUrl(absoluteUrl!) {
                    openWithSystemBrowser = true
                }
                
                if (openWithSystemBrowser) {
                    open(inSystem: absoluteUrl!, result: result)
                }
                else {
                    open(uuid: uuid, uuidFallback: nil, inAppBrowser: absoluteUrl!, headers: headers, withOptions: options, useChromeSafariBrowser: false, withOptionsFallback: nil, result: result)
                }
            }
        }
        else {
            let options = (arguments["options"] as? [String: Any])!
            let data = (arguments["data"] as? String)!
            let mimeType = (arguments["mimeType"] as? String)!
            let encoding = (arguments["encoding"] as? String)!
            let baseUrl = (arguments["baseUrl"] as? String)!
            open(uuid: uuid, options: options, data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
            result(true)
        }
    }
    
    func open(uuid: String, uuidFallback: String?, inAppBrowser url: URL, headers: [String: String], withOptions options: [String: Any], useChromeSafariBrowser: Bool, withOptionsFallback optionsFallback: [String: Any]?, result: @escaping FlutterResult) {
        
        var uuid = uuid
        
        if self.webViewControllers[uuid] != nil {
            close(uuid: uuid)
        }
        
        let safariViewController = self.safariViewControllers[uuid]
        if safariViewController != nil {
            if #available(iOS 9.0, *) {
                (safariViewController! as! SafariViewController).close()
                self.safariViewControllers[uuid] = nil
            } else {
                // Fallback on earlier versions
            }
        }
        
        if self.previousStatusBarStyle == -1 {
            self.previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        }
        
        if !(self.tmpWindow != nil) {
            let frame: CGRect = UIScreen.main.bounds
            self.tmpWindow = UIWindow(frame: frame)
        }
        
        let tmpController = UIViewController()
        let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
        self.tmpWindow?.rootViewController = tmpController
        self.tmpWindow?.windowLevel = UIWindow.Level(baseWindowLevel!.rawValue + 1.0)
        self.tmpWindow?.makeKeyAndVisible()
        
        let browserOptions: InAppBrowserOptions
        let webViewOptions: InAppWebViewOptions
        
        if useChromeSafariBrowser == true {
            if #available(iOS 9.0, *) {
                let safariOptions = SafariBrowserOptions()
                safariOptions.parse(options: options)
                
                let safari: SafariViewController
                
                if #available(iOS 11.0, *) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = safariOptions.entersReaderIfAvailable
                    config.barCollapsingEnabled = safariOptions.barCollapsingEnabled
                    
                    safari = SafariViewController(url: url, configuration: config)
                } else {
                    // Fallback on earlier versions
                    safari = SafariViewController(url: url)
                }
                
                safari.uuid = uuid
                safari.delegate = safari
                safari.statusDelegate = self
                safari.tmpWindow = tmpWindow
                safari.safariOptions = safariOptions
                
                self.safariViewControllers[uuid] = safari
                
                tmpController.present(self.safariViewControllers[uuid]! as! SFSafariViewController, animated: true)
                onChromeSafariBrowserOpened(uuid: uuid)
                result(true)
                
                return
            }
            else {
                if uuidFallback == nil {
                    print("No WebView fallback declared.")
                    result(true)
                    
                    return
                }
                uuid = uuidFallback!
                browserOptions = InAppBrowserOptions()
                browserOptions.parse(options: optionsFallback!)
                
                webViewOptions = InAppWebViewOptions()
                webViewOptions.parse(options: optionsFallback!)
            }
        }
        else {
            browserOptions = InAppBrowserOptions()
            browserOptions.parse(options: options)
            
            webViewOptions = InAppWebViewOptions()
            webViewOptions.parse(options: options)
        }
        
        let storyboard = UIStoryboard(name: WEBVIEW_STORYBOARD, bundle: Bundle(for: InAppWebViewFlutterPlugin.self))
        let vc = storyboard.instantiateViewController(withIdentifier: WEBVIEW_STORYBOARD_CONTROLLER_ID)
        self.webViewControllers[uuid] = vc as? InAppBrowserWebViewController
        let webViewController: InAppBrowserWebViewController = self.webViewControllers[uuid] as! InAppBrowserWebViewController
        webViewController.uuid = uuid
        webViewController.browserOptions = browserOptions
        webViewController.webViewOptions = webViewOptions
        webViewController.isHidden = browserOptions.hidden
        webViewController.tmpWindow = tmpWindow
        webViewController.initURL = url
        webViewController.initHeaders = headers
        webViewController.navigationDelegate = self
        
        if browserOptions.hidden {
            webViewController.view.isHidden = true
            tmpController.present(webViewController, animated: false, completion: {() -> Void in
//                if self.previousStatusBarStyle != -1 {
//                    UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: self.previousStatusBarStyle)!
//                }
            })
//            if self.previousStatusBarStyle != -1 {
//                UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: self.previousStatusBarStyle)!
//            }
            webViewController.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                self.tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            })
        }
        else {
            tmpController.present(webViewController, animated: true, completion: nil)
        }
        
        result(true)
    }
    
    func open(uuid: String, options: [String: Any], data: String, mimeType: String, encoding: String, baseUrl: String) {
        
        var uuid = uuid
        
        if self.webViewControllers[uuid] != nil {
            close(uuid: uuid)
        }
        
        if self.previousStatusBarStyle == -1 {
            self.previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        }
        
        if !(self.tmpWindow != nil) {
            let frame: CGRect = UIScreen.main.bounds
            self.tmpWindow = UIWindow(frame: frame)
        }
        
        let tmpController = UIViewController()
        let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
        self.tmpWindow?.rootViewController = tmpController
        self.tmpWindow?.windowLevel = UIWindow.Level(baseWindowLevel!.rawValue + 1.0)
        self.tmpWindow?.makeKeyAndVisible()
        
        let browserOptions: InAppBrowserOptions
        let webViewOptions: InAppWebViewOptions
        
        browserOptions = InAppBrowserOptions()
        browserOptions.parse(options: options)
        
        webViewOptions = InAppWebViewOptions()
        webViewOptions.parse(options: options)
        
        let storyboard = UIStoryboard(name: WEBVIEW_STORYBOARD, bundle: Bundle(for: InAppWebViewFlutterPlugin.self))
        let vc = storyboard.instantiateViewController(withIdentifier: WEBVIEW_STORYBOARD_CONTROLLER_ID)
        self.webViewControllers[uuid] = vc as? InAppBrowserWebViewController
        let webViewController: InAppBrowserWebViewController = self.webViewControllers[uuid] as! InAppBrowserWebViewController
        webViewController.uuid = uuid
        webViewController.browserOptions = browserOptions
        webViewController.webViewOptions = webViewOptions
        webViewController.isHidden = browserOptions.hidden
        webViewController.tmpWindow = tmpWindow
        webViewController.initData = data
        webViewController.initMimeType = mimeType
        webViewController.initEncoding = encoding
        webViewController.initBaseUrl = baseUrl
        webViewController.navigationDelegate = self
        
        if browserOptions.hidden {
            webViewController.view.isHidden = true
            tmpController.present(webViewController, animated: false, completion: {() -> Void in
                webViewController.webView.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
            })
            webViewController.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                self.tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            })
        }
        else {
            tmpController.present(webViewController, animated: true, completion: {() -> Void in
                webViewController.webView.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
            })
        }
        
    }
    
    func open(inSystem url: URL, result: @escaping FlutterResult) {
        if !UIApplication.shared.canOpenURL(url) {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: url.absoluteString + " cannot be opened!", details: nil))
            return
        }
        else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        result(true)
    }
    
    public func show(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            if webViewController != nil {
                webViewController?.isHidden = false
                webViewController?.view.isHidden = false
                
                // Run later to avoid the "took a long time" log message.
                DispatchQueue.main.async(execute: {() -> Void in
                    if webViewController != nil {
                        let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
                        self.tmpWindow?.windowLevel = UIWindow.Level(baseWindowLevel!.rawValue + 1.0)
                        self.tmpWindow?.makeKeyAndVisible()
                        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                        self.tmpWindow?.rootViewController?.present(webViewController!, animated: true, completion: nil)
                    }
                })
            }
            else {
                print("Tried to hide IAB after it was closed.")
            }
        }
    }

    public func hide(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            if webViewController != nil {
                webViewController?.isHidden = true
                
                // Run later to avoid the "took a long time" log message.
                DispatchQueue.main.async(execute: {() -> Void in
                    if webViewController != nil {
                        webViewController?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                            self.tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
                            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                            if self.previousStatusBarStyle != -1 {
                                UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: self.previousStatusBarStyle)!
                            }
                        })
                    }
                })
            }
            else {
                print("Tried to hide IAB after it was closed.")
            }
        }
    }
    
    public func loadUrl(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            if let url = arguments["url"] as? String {
                let headers = (arguments["headers"] as? [String: String])!
                let absoluteUrl = URL(string: url)!.absoluteURL
                webViewController!.loadUrl(url: absoluteUrl, headers: headers)
            }
            else {
                result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "url is empty", details: nil))
                return
            }
            result(true)
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "webView is null", details: nil))
        }
    }
    
    public func loadData(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            let data = (arguments["data"] as? String)!
            let mimeType = (arguments["mimeType"] as? String)!
            let encoding = (arguments["encoding"] as? String)!
            let baseUrl = (arguments["baseUrl"] as? String)!
            webViewController!.webView.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
            result(true)
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "webView is null", details: nil))
        }
    }
    
    public func postUrl(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            if let url = arguments["url"] as? String {
                let postData = (arguments["postData"] as? FlutterStandardTypedData)!
                let absoluteUrl = URL(string: url)!.absoluteURL
                webViewController!.webView.postUrl(url: absoluteUrl, postData: postData.data, completionHandler: { () -> Void in
                    result(true)
                })
            }
            else {
                result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "url is empty", details: nil))
                return
            }
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "webView is null", details: nil))
        }
    }
    
    public func loadFile(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            if let url = arguments["url"] as? String {
                let headers = (arguments["headers"] as? [String: String])!
                do {
                    try webViewController!.webView.loadFile(url: url, headers: headers)
                }
                catch let error as NSError {
                    dump(error)
                    result(FlutterError(code: "InAppBrowserFlutterPlugin", message: error.localizedDescription, details: nil))
                    return
                }
            }
            else {
                result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "url is empty", details: nil))
                return
            }
            result(true)
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "webView is null", details: nil))
        }
    }
    
    public func evaluateJavascript(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.evaluateJavascript(source: arguments["source"] as! String, result: result)
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "webView is null", details: nil))
        }
    }
    
    public func injectJavascriptFileFromUrl(uuid: String, arguments: NSDictionary) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.injectJavascriptFileFromUrl(urlFile: arguments["urlFile"] as! String)
        }
    }
    
    public func injectCSSCode(uuid: String, arguments: NSDictionary) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.injectCSSCode(source: arguments["source"] as! String)
        }
    }
    
    public func injectCSSFileFromUrl(uuid: String, arguments: NSDictionary) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.injectCSSFileFromUrl(urlFile: arguments["urlFile"] as! String)
        }
    }
    
    public func onBrowserCreated(uuid: String, webView: WKWebView) {
        if let webViewController = self.webViewControllers[uuid] {
            self.channel!.invokeMethod("onBrowserCreated", arguments: ["uuid": uuid])
        }
    }
    
    public func onExit(uuid: String) {
        self.channel!.invokeMethod("onExit", arguments: ["uuid": uuid])
    }
    
    public func onChromeSafariBrowserOpened(uuid: String) {
        if self.safariViewControllers[uuid] != nil {
            self.channel!.invokeMethod("onChromeSafariBrowserOpened", arguments: ["uuid": uuid])
        }
    }
    
    public func onChromeSafariBrowserLoaded(uuid: String) {
        if self.safariViewControllers[uuid] != nil {
            self.channel!.invokeMethod("onChromeSafariBrowserLoaded", arguments: ["uuid": uuid])
        }
    }
    
    public func onChromeSafariBrowserClosed(uuid: String) {
        self.channel!.invokeMethod("onChromeSafariBrowserClosed", arguments: ["uuid": uuid])
    }
    
    public func safariExit(uuid: String) {
        if let safariViewController = self.safariViewControllers[uuid] {
            if #available(iOS 9.0, *) {
                (safariViewController as! SafariViewController).statusDelegate = nil
                (safariViewController as! SafariViewController).delegate = nil
            }
            self.safariViewControllers[uuid] = nil
            onChromeSafariBrowserClosed(uuid: uuid)
        }
    }
    
    public func browserExit(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            // Set navigationDelegate to nil to ensure no callbacks are received from it.
            webViewController?.navigationDelegate = nil
            // Don't recycle the ViewController since it may be consuming a lot of memory.
            // Also - this is required for the PDF/User-Agent bug work-around.
            self.webViewControllers[uuid] = nil
            
            if previousStatusBarStyle != -1 {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: previousStatusBarStyle)!
            }
            
            onExit(uuid: uuid)
        }
    }
    
    public func setOptions(uuid: String, options: InAppBrowserOptions, optionsMap: [String: Any]) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.setOptions(newOptions: options, newOptionsMap: optionsMap)
        }
    }
    
    public func getOptions(uuid: String) -> [String: Any]? {
        if let webViewController = self.webViewControllers[uuid] {
            return webViewController!.getOptions()
        }
        return nil
    }
    
    public func getCopyBackForwardList(uuid: String) -> [String: Any]? {
        if let webViewController = self.webViewControllers[uuid] {
            return webViewController!.webView.getCopyBackForwardList()
        }
        return nil
    }
    
    public func findAllAsync(uuid: String, find: String) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.findAllAsync(find: find, completionHandler: nil)
        }
    }
    
    public func findNext(uuid: String, forward: Bool, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.findNext(forward: forward, completionHandler: {(value, error) in
                if error != nil {
                    result(FlutterError(code: "FlutterWebViewController", message: error?.localizedDescription, details: nil))
                    return
                }
                result(true)
            })
        } else {
            result(false)
        }
    }
    
    public func clearMatches(uuid: String, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.clearMatches(completionHandler: {(value, error) in
                if error != nil {
                    result(FlutterError(code: "FlutterWebViewController", message: error?.localizedDescription, details: nil))
                    return
                }
                result(true)
            })
        } else {
            result(false)
        }
    }
    
    public func clearCache(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.clearCache()
        }
    }
    
    public func scrollTo(uuid: String, x: Int, y: Int) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.scrollTo(x: x, y: y)
        }
    }
    
    public func scrollBy(uuid: String, x: Int, y: Int) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.scrollBy(x: x, y: y)
        }
    }
    
    public func pauseTimers(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.pauseTimers()
        }
    }
    
    public func resumeTimers(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.resumeTimers()
        }
    }
    
    public func printCurrentPage(uuid: String, result: @escaping FlutterResult) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.printCurrentPage(printCompletionHandler: {(completed, error) in
                if !completed, let e = error {
                    result(false)
                    return
                }
                result(true)
            })
        } else {
            result(false)
        }
    }
    
    public func getContentHeight(uuid: String) -> Int64? {
        if let webViewController = self.webViewControllers[uuid] {
            return webViewController!.webView.getContentHeight()
        }
        return nil
    }
    
    public func reloadFromOrigin(uuid: String) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.webView.reloadFromOrigin()
        }
    }
    
    public func getScale(uuid: String) -> Float? {
        if let webViewController = self.webViewControllers[uuid] {
            return webViewController!.webView.getScale()
        }
        return nil
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
