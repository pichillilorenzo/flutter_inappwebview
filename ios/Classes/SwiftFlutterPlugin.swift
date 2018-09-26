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

public class SwiftFlutterPlugin: NSObject, FlutterPlugin {
    var webViewController: InAppBrowserWebViewController?
    var safariViewController: Any?
    
    var tmpWindow: UIWindow?
    var channel: FlutterMethodChannel
    private var previousStatusBarStyle = -1
    
    public init(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser", binaryMessenger: registrar.messenger())
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPlugin(with: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
        case "open":
            self.open(arguments: arguments!, result: result)
            break
        case "loadUrl":
            self.loadUrl(arguments: arguments!, result: result)
            break
        case "close":
            self.close()
            result(true)
            break
        case "show":
            self.show()
            result(true)
            break
        case "hide":
            self.hide()
            result(true)
            break
        case "reload":
            self.webViewController?.reload()
            result(true)
            break
        case "goBack":
            self.webViewController?.goBack()
            result(true)
            break
        case "canGoBack":
            result(self.webViewController?.canGoBack() ?? false)
            break
        case "goForward":
            self.webViewController?.goForward()
            result(true)
            break
        case "canGoForward":
            result(self.webViewController?.canGoForward() ?? false)
            break
        case "isLoading":
            result((self.webViewController?.webView.isLoading ?? false) == true)
            break
        case "stopLoading":
            self.webViewController?.webView.stopLoading()
            result(true)
            break
        case "isHidden":
            result((self.webViewController?.isHidden ?? false) == true)
            break
        case "injectScriptCode":
            self.injectScriptCode(arguments: arguments!, result: result)
            break
        case "injectScriptFile":
            self.injectScriptFile(arguments: arguments!, result: nil)
            result(true)
            break
        case "injectStyleCode":
            self.injectStyleCode(arguments: arguments!, result: nil)
            result(true)
            break
        case "injectStyleFile":
            self.injectStyleFile(arguments: arguments!, result: nil)
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    func close() {
        if webViewController == nil {
            print("IAB.close() called but it was already closed.")
            return
        }
        // Things are cleaned up in browserExit.
        webViewController?.close()
    }
    
    func isSystemUrl(_ url: URL) -> Bool {
        if (url.host == "itunes.apple.com") {
            return true
        }
        return false
    }
    
    public func open(arguments: NSDictionary, result: @escaping FlutterResult) {
        let url: String = (arguments["url"] as? String)!

        let headers = (arguments["headers"] as? [String: String])!
        var target: String? = (arguments["target"] as? String)!
        target = target != nil ? target : "_self"
        let absoluteUrl = URL(string: url)?.absoluteURL
        
        let useChromeSafariBrowser = (arguments["useChromeSafariBrowser"] as? Bool)
        
        if useChromeSafariBrowser! {
            let options = (arguments["options"] as? [String: Any])!
            let optionsFallback = (arguments["optionsFallback"] as? [String: Any])!
            
            open(inAppBrowser: absoluteUrl!, headers: headers, withOptions: options, useChromeSafariBrowser: true, withOptionsFallback: optionsFallback);
        }
        else {
            let options = (arguments["options"] as? [String: Any])!
            if isSystemUrl(absoluteUrl!) {
                target = "_system"
            }
            
            if (target == "_self" || target == "_target") {
                open(inAppBrowser: absoluteUrl!, headers: headers, withOptions: options, useChromeSafariBrowser: false, withOptionsFallback: nil)
            }
            else if (target == "_system") {
                open(inSystem: absoluteUrl!)
            }
            else {
                // anything else
                open(inAppBrowser: absoluteUrl!, headers: headers,withOptions: options, useChromeSafariBrowser: false, withOptionsFallback: nil)
            }
        }
        result(true)
    }
    
    public func loadUrl(arguments: NSDictionary, result: @escaping FlutterResult) {
        let url: String? = (arguments["url"] as? String)!
        let headers = (arguments["headers"] as? [String: String])!
        
        if url != nil {
            let absoluteUrl = URL(string: url!)!.absoluteURL
            webViewController?.loadUrl(url: absoluteUrl, headers: headers)
        }
        else {
            print("url is empty")
            result(FlutterError(code: "InAppBrowserFlutterPlugin", message: "url is empty", details: nil))
        }
        result(true)
    }
    
    func open(inAppBrowser url: URL, headers: [String: String], withOptions options: [String: Any], useChromeSafariBrowser: Bool, withOptionsFallback optionsFallback: [String: Any]?) {
        
        if webViewController != nil {
            close()
        }
        
        if safariViewController != nil {
            if #available(iOS 9.0, *) {
                (safariViewController! as! SafariViewController).close()
                safariViewController = nil
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
                
                safari.delegate = safari
                safari.statusDelegate = self
                safari.tmpWindow = tmpWindow
                safari.safariOptions = safariOptions
                
                safariViewController = safari
                
                tmpController.present(safariViewController! as! SFSafariViewController, animated: true)
                onChromeSafariBrowserOpened()
                
                return
            }
            else {
                browserOptions = InAppBrowserOptions()
                browserOptions.parse(options: optionsFallback!)
            }
        }
        else {
            browserOptions = InAppBrowserOptions()
            browserOptions.parse(options: options)
        }
        
        let storyboard = UIStoryboard(name: WEBVIEW_STORYBOARD, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: WEBVIEW_STORYBOARD_CONTROLLER_ID)
        webViewController = vc as? InAppBrowserWebViewController
        webViewController?.browserOptions = browserOptions
        webViewController?.isHidden = browserOptions.hidden
        webViewController?.tmpWindow = tmpWindow
        webViewController?.currentURL = url
        webViewController?.initHeaders = headers
        webViewController?.navigationDelegate = self
        
        if browserOptions.hidden {
            webViewController!.view.isHidden = true
            tmpController.present(self.webViewController!, animated: false, completion: {() -> Void in
//                if self.previousStatusBarStyle != -1 {
//                    UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: self.previousStatusBarStyle)!
//                }
            })
//            if self.previousStatusBarStyle != -1 {
//                UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: self.previousStatusBarStyle)!
//            }
            webViewController?.presentingViewController?.dismiss(animated: false, completion: {() -> Void in
                self.tmpWindow?.windowLevel = 0.0
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            })
        }
        else {
            tmpController.present(webViewController!, animated: true, completion: nil)
        }
    }
    
    public func show() {
        
        if webViewController == nil {
            print("Tried to hide IAB after it was closed.")
            return
        }
        
        self.webViewController?.isHidden = false
        self.webViewController!.view.isHidden = false
        
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            if self.webViewController != nil {
                let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
                self.tmpWindow?.windowLevel = UIWindowLevel(baseWindowLevel! + 1)
                self.tmpWindow?.makeKeyAndVisible()
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                self.tmpWindow?.rootViewController?.present(self.webViewController!, animated: true, completion: nil)
            }
        })
    }

    public func hide() {
        if webViewController == nil {
            print("Tried to hide IAB after it was closed.")
            return
        }
        
        if self.webViewController != nil {
            self.webViewController?.isHidden = true
        }
        
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            if self.webViewController != nil {
                self.webViewController?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                    self.tmpWindow?.windowLevel = 0.0
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                    if self.previousStatusBarStyle != -1 {
                        UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: self.previousStatusBarStyle)!
                    }
                })
            }
        })
    }
    
    func open(inSystem url: URL) {
        if UIApplication.shared.openURL(url) == false {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "CDVPluginHandleOpenURLNotification"), object: url))
        }
    }
    
    // This is a helper method for the inject{Script|Style}{Code|File} API calls, which
    // provides a consistent method for injecting JavaScript code into the document.
    //
    // If a wrapper string is supplied, then the source string will be JSON-encoded (adding
    // quotes) and wrapped using string formatting. (The wrapper string should have a single
    // '%@' marker).
    //
    // If no wrapper is supplied, then the source string is executed directly.
    func injectDeferredObject(_ source: String, withWrapper jsWrapper: String, result: FlutterResult?) {
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
        let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
        if sourceArrayString != nil {
            let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.characters.count ?? 0) - 2))
            let jsToInject = String(format: jsWrapper, sourceString!)
            
            webViewController?.webView?.evaluateJavaScript(jsToInject, completionHandler: {(value, error) in
                if result == nil {
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
                    print("Failed to load: \(error.localizedDescription)")
                    result!(FlutterError(code: "InAppBrowserFlutterPlugin", message: "Failed to load: \(error.localizedDescription)", details: error))
                }
                
            })
        }
    }
    
    public func injectScriptCode(arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(){return JSON.stringify(eval(%@));})();"
        injectDeferredObject(arguments["source"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    public func injectScriptFile(arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(arguments["urlFile"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    public func injectStyleCode(arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(arguments["source"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    public func injectStyleFile(arguments: NSDictionary, result: FlutterResult?) {
        let jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet', c.type='text/css'; c.href = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(arguments["urlFile"] as! String, withWrapper: jsWrapper, result: result)
    }
    
    func onLoadStart(_ webView: WKWebView) {
        let url: String = webViewController!.currentURL!.absoluteString
        channel.invokeMethod("onLoadStart", arguments: ["url": url])
    }
    
    func onLoadStop(_ webView: WKWebView) {
        let url: String = webViewController!.currentURL!.absoluteString
        channel.invokeMethod("onLoadStop", arguments: ["url": url])
    }
    
    func onLoadError(_ webView: WKWebView, error: Error) {
        let url: String = webViewController!.currentURL!.absoluteString
        let arguments = ["url": url, "code": error._code, "message": error.localizedDescription] as [String : Any]
        channel.invokeMethod("onLoadError", arguments: arguments)
    }
    
    func onExit() {
        channel.invokeMethod("onExit", arguments: [])
    }
    
    func shouldOverrideUrlLoading(_ webView: WKWebView, url: URL) {
        channel.invokeMethod("shouldOverrideUrlLoading", arguments: ["url": url.absoluteString])
    }
    
    func onChromeSafariBrowserOpened() {
        channel.invokeMethod("onChromeSafariBrowserOpened", arguments: [])
    }
    
    func onChromeSafariBrowserLoaded() {
        channel.invokeMethod("onChromeSafariBrowserLoaded", arguments: [])
    }
    
    func onChromeSafariBrowserClosed() {
        channel.invokeMethod("onChromeSafariBrowserClosed", arguments: [])
    }
    
    func safariExit() {
        if #available(iOS 9.0, *) {
            (safariViewController as! SafariViewController).statusDelegate = nil
            (safariViewController as! SafariViewController).delegate = nil
        }
        safariViewController = nil
        onChromeSafariBrowserClosed()
    }
    
    func browserExit() {
        // Set navigationDelegate to nil to ensure no callbacks are received from it.
        webViewController?.navigationDelegate = nil
        // Don't recycle the ViewController since it may be consuming a lot of memory.
        // Also - this is required for the PDF/User-Agent bug work-around.
        webViewController = nil
        
        if previousStatusBarStyle != -1 {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: previousStatusBarStyle)!
        }
        
        onExit()
    }
    
}
