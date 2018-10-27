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
    
    static var registrar: FlutterPluginRegistrar?
    
    var webViewControllers: [String: InAppBrowserWebViewController?] = [:]
    var safariViewControllers: [String: Any?] = [:]
    
    var tmpWindow: UIWindow?
    var channel: FlutterMethodChannel
    private var previousStatusBarStyle = -1
    
    public init(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser", binaryMessenger: registrar.messenger())
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        SwiftFlutterPlugin.registrar = registrar
        
        let channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPlugin(with: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        if #available(iOS 11.0, *) {
            MyCookieManager(registrar: registrar)
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let uuid: String = arguments!["uuid"] as! String

        switch call.method {
            case "open":
                self.open(uuid: uuid, arguments: arguments!, result: result)
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
                    webViewController?.reload()
                }
                result(true)
                break
            case "goBack":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController?.goBack()
                }
                result(true)
                break
            case "canGoBack":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController?.canGoBack() ?? false)
                }
                else {
                    result(false)
                }
                break
            case "goForward":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController?.goForward()
                }
                result(true)
                break
            case "canGoForward":
                if let webViewController = self.webViewControllers[uuid] {
                    result(webViewController?.canGoForward() ?? false)
                }
                else {
                    result(false)
                }
                break
            case "isLoading":
                if let webViewController = self.webViewControllers[uuid] {
                    result((webViewController?.webView.isLoading ?? false) == true)
                }
                else {
                    result(false)
                }
                break
            case "stopLoading":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController?.webView.stopLoading()
                }
                result(true)
                break
            case "isHidden":
                if let webViewController = self.webViewControllers[uuid] {
                    result((webViewController?.isHidden ?? false) == true)
                }
                else {
                    result(false)
                }
                break
            case "injectScriptCode":
                self.injectScriptCode(uuid: uuid, arguments: arguments!, result: result)
                break
            case "injectScriptFile":
                self.injectScriptFile(uuid: uuid, arguments: arguments!, result: nil)
                result(true)
                break
            case "injectStyleCode":
                self.injectStyleCode(uuid: uuid, arguments: arguments!, result: nil)
                result(true)
                break
            case "injectStyleFile":
                self.injectStyleFile(uuid: uuid, arguments: arguments!, result: nil)
                result(true)
                break
            case "takeScreenshot":
                if let webViewController = self.webViewControllers[uuid] {
                    webViewController?.takeScreenshot(completionHandler: { (screenshot) -> Void in
                        result(screenshot)
                    })
                }
                else {
                    result(nil)
                }
                break
            case "setOptions":
                let optionsType = arguments!["optionsType"] as! String;
                switch (optionsType){
                    case "InAppBrowserOptions":
                        let inAppBrowserOptions = InAppBrowserOptions();
                        let inAppBroeserOptionsMap = arguments!["options"] as! [String: Any];
                        inAppBrowserOptions.parse(options: inAppBroeserOptionsMap);
                        self.setOptions(uuid: uuid, options: inAppBrowserOptions, optionsMap: inAppBroeserOptionsMap);
                        break;
                    default:
                        result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "Options " + optionsType + " not available.", details: nil))
                }
                result(true)
                break
            case "getOptions":
                result(self.getOptions(uuid: uuid))
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
        let url: String = (arguments["url"] as? String)!

        let headers = (arguments["headers"] as? [String: String])!
        var absoluteUrl = URL(string: url)?.absoluteURL

        let useChromeSafariBrowser = (arguments["useChromeSafariBrowser"] as? Bool)!
        
        if useChromeSafariBrowser {
            let uuidFallback = (arguments["uuidFallback"] as? String)!
            let safariOptions = (arguments["options"] as? [String: Any])!
            
            let optionsFallback = (arguments["optionsFallback"] as? [String: Any])!
            
            open(uuid: uuid, uuidFallback: uuidFallback, inAppBrowser: absoluteUrl!, headers: headers, withOptions: safariOptions, useChromeSafariBrowser: true, withOptionsFallback: optionsFallback, result: result);
        }
        else {
            let options = (arguments["options"] as? [String: Any])!
            
            let isLocalFile = (arguments["isLocalFile"] as? Bool)!
            var openWithSystemBrowser = (arguments["openWithSystemBrowser"] as? Bool)!
            
            if isLocalFile {
                let key = SwiftFlutterPlugin.registrar!.lookupKey(forAsset: url)
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
        self.tmpWindow?.windowLevel = UIWindowLevel(baseWindowLevel! + 1)
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
        
        let storyboard = UIStoryboard(name: WEBVIEW_STORYBOARD, bundle: Bundle(for: InAppBrowserFlutterPlugin.self))
        let vc = storyboard.instantiateViewController(withIdentifier: WEBVIEW_STORYBOARD_CONTROLLER_ID)
        self.webViewControllers[uuid] = vc as? InAppBrowserWebViewController
        let webViewController: InAppBrowserWebViewController = self.webViewControllers[uuid] as! InAppBrowserWebViewController
        webViewController.uuid = uuid
        webViewController.browserOptions = browserOptions
        webViewController.webViewOptions = webViewOptions
        webViewController.isHidden = browserOptions.hidden
        webViewController.tmpWindow = tmpWindow
        webViewController.currentURL = url
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
                self.tmpWindow?.windowLevel = 0.0
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            })
        }
        else {
            tmpController.present(webViewController, animated: true, completion: nil)
        }
        
        result(true)
    }
    
    public func loadUrl(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        let webViewController: InAppBrowserWebViewController = self.webViewControllers[uuid] as! InAppBrowserWebViewController
        if let url = arguments["url"] as? String {
            let headers = (arguments["headers"] as? [String: String])!
            let absoluteUrl = URL(string: url)!.absoluteURL
            webViewController.loadUrl(url: absoluteUrl, headers: headers)
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "url is empty", details: nil))
            return
        }
        result(true)
    }
    
    public func loadData(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        let webViewController: InAppBrowserWebViewController = self.webViewControllers[uuid] as! InAppBrowserWebViewController
        let data = (arguments["data"] as? String)!
        let mimeType = (arguments["mimeType"] as? String)!
        let encoding = (arguments["encoding"] as? String)!
        let baseUrl = (arguments["baseUrl"] as? String)!
        webViewController.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
        result(true)
    }
    
    public func postUrl(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        let webViewController: InAppBrowserWebViewController = self.webViewControllers[uuid] as! InAppBrowserWebViewController
        if let url = arguments["url"] as? String {
            let postData = (arguments["postData"] as? FlutterStandardTypedData)!
            let absoluteUrl = URL(string: url)!.absoluteURL
            webViewController.postUrl(url: absoluteUrl, postData: postData.data, result: result)
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "url is empty", details: nil))
            return
        }
    }
    
    public func loadFile(uuid: String, arguments: NSDictionary, result: @escaping FlutterResult) {
        let webViewController: InAppBrowserWebViewController = self.webViewControllers[uuid] as! InAppBrowserWebViewController
        if let url = arguments["url"] as? String {
            let headers = (arguments["headers"] as? [String: String])!

            let key = SwiftFlutterPlugin.registrar!.lookupKey(forAsset: url)
            let assetURL = Bundle.main.url(forResource: key, withExtension: nil)
            if assetURL == nil {
                result(FlutterError(code: "InAppBrowserFlutterPlugin", message: url + " asset file cannot be found!", details: nil))
                return
            }
            let absoluteUrl = URL(string: url)!.absoluteURL
            webViewController.loadUrl(url: absoluteUrl, headers: headers)
        }
        else {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "url is empty", details: nil))
            return
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
                        self.tmpWindow?.windowLevel = UIWindowLevel(baseWindowLevel! + 1)
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
                            self.tmpWindow?.windowLevel = 0.0
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
    
    func open(inSystem url: URL, result: @escaping FlutterResult) {
        if !UIApplication.shared.canOpenURL(url) {
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: url.absoluteString + " cannot be opened!", details: nil))
            return
        }
        else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        result(true)
    }
    
    // This is a helper method for the inject{Script|Style}{Code|File} API calls, which
    // provides a consistent method for injecting JavaScript code into the document.
    //
    // If a wrapper string is supplied, then the source string will be JSON-encoded (adding
    // quotes) and wrapped using string formatting. (The wrapper string should have a single
    // '%@' marker).
    //
    // If no wrapper is supplied, then the source string is executed directly.
    func injectDeferredObject(uuid: String, source: String, withWrapper jsWrapper: String, result: FlutterResult?) {
        if let webViewController = self.webViewControllers[uuid] {
            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
            let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
            if sourceArrayString != nil {
                let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.count ?? 0) - 2))
                let jsToInject = String(format: jsWrapper, sourceString!)
                
                webViewController?.webView?.evaluateJavaScript(jsToInject, completionHandler: {(value, error) in
                    if result == nil {
                        return
                    }
                    
                    if error != nil {
                        let userInfo = (error! as NSError).userInfo
                        self.onConsoleMessage(uuid: uuid, sourceURL: (userInfo["WKJavaScriptExceptionSourceURL"] as? URL)?.absoluteString ?? "", lineNumber: userInfo["WKJavaScriptExceptionLineNumber"] as! Int, message: userInfo["WKJavaScriptExceptionMessage"] as! String, messageLevel: "ERROR")
                    }
                    
                    if value == nil {
                        result!("")
                        return
                    }
                    
                    do {
                        let data: Data = ("[" + String(describing: value!) + "]").data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        let json: Array<Any> = try JSONSerialization.jsonObject(with: data, options: []) as! Array<Any>
                        if json[0] is String {
                            result!(json[0])
                        }
                        else {
                            result!(value)
                        }
                    } catch let error as NSError {
                        result!(FlutterError(code: "InAppBrowserFlutterPlugin", message: "Failed to load: \(error.localizedDescription)", details: error))
                    }
                    
                })
            }
        }
    }
    
    public func injectScriptCode(uuid: String, arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(){return JSON.stringify(eval(%@));})();"
        injectDeferredObject(uuid: uuid, source: arguments["source"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    public func injectScriptFile(uuid: String, arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(uuid: uuid, source: arguments["urlFile"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    public func injectStyleCode(uuid: String, arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(uuid: uuid, source: arguments["source"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    public func injectStyleFile(uuid: String, arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet', c.type='text/css'; c.href = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(uuid: uuid, source: arguments["urlFile"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    func onLoadStart(uuid: String, webView: WKWebView) {
        if let webViewController = self.webViewControllers[uuid] {
            let url: String = webViewController!.currentURL!.absoluteString
            channel.invokeMethod("onLoadStart", arguments: ["uuid": uuid, "url": url])
        }
    }
    
    func onLoadStop(uuid: String, webView: WKWebView) {
        if let webViewController = self.webViewControllers[uuid] {
            let url: String = webViewController!.currentURL!.absoluteString
            channel.invokeMethod("onLoadStop", arguments: ["uuid": uuid, "url": url])
        }
    }
    
    func onLoadError(uuid: String, webView: WKWebView, error: Error) {
        if let webViewController = self.webViewControllers[uuid] {
            let url: String = webViewController!.currentURL!.absoluteString
            let arguments = ["uuid": uuid, "url": url, "code": error._code, "message": error.localizedDescription] as [String : Any]
            channel.invokeMethod("onLoadError", arguments: arguments)
        }
    }
    
    func onProgressChanged(uuid: String, webView: WKWebView, progress: Int) {
        if let webViewController = self.webViewControllers[uuid] {
            channel.invokeMethod("onProgressChanged", arguments: ["uuid": uuid, "progress": progress])
        }
    }
    
    func onLoadResource(uuid: String, webView: WKWebView, response: URLResponse, fromRequest request: URLRequest?, withData data: Data, startTime: Int, duration: Int) {
        if self.webViewControllers[uuid] != nil {
            var headersResponse = (response as! HTTPURLResponse).allHeaderFields as! [String: String]
            headersResponse.lowercaseKeys()
            
            var headersRequest = request!.allHTTPHeaderFields! as [String: String]
            headersRequest.lowercaseKeys()
            
            let arguments: [String : Any] = [
                "uuid": uuid,
                "response": [
                    "url": response.url!.absoluteString,
                    "statusCode": (response as! HTTPURLResponse).statusCode,
                    "headers": headersResponse,
                    "startTime": startTime,
                    "duration": duration,
                    "data": data
                ],
                "request": [
                    "url": request!.url!.absoluteString,
                    "headers": headersRequest,
                    "method": request!.httpMethod!
                ]
            ]
            channel.invokeMethod("onLoadResource", arguments: arguments)
        }
    }
    
    func onExit(uuid: String) {
        channel.invokeMethod("onExit", arguments: ["uuid": uuid])
    }
    
    func shouldOverrideUrlLoading(uuid: String, webView: WKWebView, url: URL) {
        if self.webViewControllers[uuid] != nil {
            channel.invokeMethod("shouldOverrideUrlLoading", arguments: ["uuid": uuid, "url": url.absoluteString])
        }
    }
    
    func onConsoleMessage(uuid: String, sourceURL: String, lineNumber: Int, message: String, messageLevel: String) {
        if self.webViewControllers[uuid] != nil {
            channel.invokeMethod("onConsoleMessage", arguments: ["uuid": uuid, "sourceURL": sourceURL, "lineNumber": lineNumber, "message": message, "messageLevel": messageLevel])
        }
    }
    
    func onChromeSafariBrowserOpened(uuid: String) {
        if self.safariViewControllers[uuid] != nil {
            channel.invokeMethod("onChromeSafariBrowserOpened", arguments: ["uuid": uuid])
        }
    }
    
    func onChromeSafariBrowserLoaded(uuid: String) {
        if self.safariViewControllers[uuid] != nil {
            channel.invokeMethod("onChromeSafariBrowserLoaded", arguments: ["uuid": uuid])
        }
    }
    
    func onChromeSafariBrowserClosed(uuid: String) {
        channel.invokeMethod("onChromeSafariBrowserClosed", arguments: ["uuid": uuid])
    }
    
    func onCallJsHandler(uuid: String, webView: WKWebView, handlerName: String, args: String) {
        channel.invokeMethod("onCallJsHandler", arguments: ["uuid": uuid, "handlerName": handlerName, "args": args])
    }
    
    func safariExit(uuid: String) {
        if let safariViewController = self.safariViewControllers[uuid] {
            if #available(iOS 9.0, *) {
                (safariViewController as! SafariViewController).statusDelegate = nil
                (safariViewController as! SafariViewController).delegate = nil
            }
            self.safariViewControllers[uuid] = nil
            onChromeSafariBrowserClosed(uuid: uuid)
        }
    }
    
    func browserExit(uuid: String) {
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
    
    func setOptions(uuid: String, options: InAppBrowserOptions, optionsMap: [String: Any]) {
        if let webViewController = self.webViewControllers[uuid] {
            webViewController!.setOptions(newOptions: options, newOptionsMap: optionsMap)
        }
    }
    
    func getOptions(uuid: String) -> [String: Any]? {
        if let webViewController = self.webViewControllers[uuid] {
            return webViewController!.getOptions()
        }
        return nil
    }
    
}
