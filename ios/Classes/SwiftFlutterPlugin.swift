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

let WEBVIEW_STORYBOARD = "WebView"
let WEBVIEW_STORYBOARD_CONTROLLER_ID = "viewController"

public class SwiftFlutterPlugin: NSObject, FlutterPlugin {
    var webViewController: InAppBrowserWebViewController?
    
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
        case "injectScriptCode":
            self.injectScriptCode(arguments: arguments!)
            result(true)
            break
        case "injectScriptFile":
            self.injectScriptFile(arguments: arguments!)
            result(true)
            break
        case "injectStyleCode":
            self.injectStyleCode(arguments: arguments!)
            result(true)
            break
        case "injectStyleFile":
            self.injectStyleFile(arguments: arguments!)
            result(true)
            break
        default:
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
        let url: String? = (arguments["url"] as? String)!
        let headers = (arguments["headers"] as? [String: String])!
        var target: String? = (arguments["target"] as? String)!
        target = target != nil ? target : "_self"
        let options = (arguments["options"] as? [String: Any])!
        
        if url != nil {
            let absoluteUrl = URL(string: url!)?.absoluteURL
            
            if isSystemUrl(absoluteUrl!) {
                target = "_system"
            }
            
            if (target == "_self" || target == "_target") {
                open(inAppBrowser: absoluteUrl!, headers: headers, withOptions: options)
            }
            else if (target == "_system") {
                open(inSystem: absoluteUrl!)
            }
            else {
                // anything else
                open(inAppBrowser: absoluteUrl!, headers: headers,withOptions: options)
            }
        }
        else {
            print("url is empty")
            result(false)
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
            result(false)
        }
        result(true)
    }
    
    func open(inAppBrowser url: URL, headers: [String: String], withOptions options: [String: Any]) {
        
        let browserOptions = InAppBrowserOptions()
        browserOptions.parse(options: options)
        
        if webViewController == nil {

            if !(self.tmpWindow != nil) {
                let frame: CGRect = UIScreen.main.bounds
                self.tmpWindow = UIWindow(frame: frame)
            }
            
            let storyboard = UIStoryboard(name: WEBVIEW_STORYBOARD, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: WEBVIEW_STORYBOARD_CONTROLLER_ID)
            webViewController = vc as? InAppBrowserWebViewController
            webViewController?.browserOptions = browserOptions
            webViewController?.tmpWindow = tmpWindow
            webViewController?.currentURL = url
            webViewController?.initHeaders = headers
            webViewController?.navigationDelegate = self
        }
        
        if !browserOptions.hidden {
            show()
        }
    }
    
    public func show() {
        if webViewController == nil {
            print("Tried to show IAB after it was closed.")
            return
        }
        if previousStatusBarStyle != -1 {
            print("Tried to show IAB while already shown")
            return
        }
        
        weak var weakSelf: SwiftFlutterPlugin? = self
        
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            if weakSelf?.webViewController != nil {
                if !(self.tmpWindow != nil) {
                    let frame: CGRect = UIScreen.main.bounds
                    self.tmpWindow = UIWindow(frame: frame)
                }
                let tmpController = UIViewController()
                let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
                self.tmpWindow?.rootViewController = tmpController
                self.tmpWindow?.windowLevel = UIWindowLevel(baseWindowLevel! + 1)
                self.tmpWindow?.makeKeyAndVisible()
                
                tmpController.present(self.webViewController!, animated: true, completion: nil)
            }
        })
    }
    
    public func hide() {
        if webViewController == nil {
            print("Tried to hide IAB after it was closed.")
            return
        }
        if previousStatusBarStyle == -1 {
            print("Tried to hide IAB while already hidden")
            return
        }
        
        previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            if self.webViewController != nil {
                self.previousStatusBarStyle = -1
                self.webViewController?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                    self.tmpWindow?.windowLevel = 0.0
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
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
    func injectDeferredObject(_ source: String, withWrapper jsWrapper: String) {
        //if jsWrapper != nil {
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
        let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
        if sourceArrayString != nil {
            let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.characters.count ?? 0) - 2))
            let jsToInject = String(format: jsWrapper, sourceString!)
            webViewController?.webView?.evaluateJavaScript(jsToInject)
        }
        //}
        //else {
        //    webViewController?.webView?.evaluateJavaScript(source)
        //}
    }
    
    public func injectScriptCode(arguments: NSDictionary) {
        let jsWrapper = "(function(){JSON.stringify([eval(%@)])})()"
        injectDeferredObject(arguments["source"] as! String, withWrapper: jsWrapper)
    }
    
    public func injectScriptFile(arguments: NSDictionary) {
        let jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %@; d.body.appendChild(c); })(document)"
        injectDeferredObject(arguments["urlFile"] as! String, withWrapper: jsWrapper)
    }
    
    public func injectStyleCode(arguments: NSDictionary) {
        let jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %@; d.body.appendChild(c); })(document)"
        injectDeferredObject(arguments["source"] as! String, withWrapper: jsWrapper)
    }
    
    public func injectStyleFile(arguments: NSDictionary) {
        let jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet', c.type='text/css'; c.href = %@; d.body.appendChild(c); })(document)"
        injectDeferredObject(arguments["urlFile"] as! String, withWrapper: jsWrapper)
    }
    
    func webViewDidStartLoad(_ webView: WKWebView) {
        let url: String = webViewController!.currentURL!.absoluteString
        channel.invokeMethod("loadstart", arguments: ["url": url])
    }
    
    func webViewDidFinishLoad(_ webView: WKWebView) {
        let url: String = webViewController!.currentURL!.absoluteString
        channel.invokeMethod("loadstop", arguments: ["url": url])
    }
    
    func webView(_ webView: WKWebView, didFailLoadWithError error: Error) {
        let url: String = webViewController!.currentURL!.absoluteString
        let arguments = ["url": url, "code": error._code, "message": error.localizedDescription] as [String : Any]
        channel.invokeMethod("loaderror", arguments: arguments)
    }
    
    func browserExit() {
        
        channel.invokeMethod("exit", arguments: [])
        
        // Set navigationDelegate to nil to ensure no callbacks are received from it.
        webViewController?.navigationDelegate = nil
        // Don't recycle the ViewController since it may be consuming a lot of memory.
        // Also - this is required for the PDF/User-Agent bug work-around.
        webViewController = nil
        
        if previousStatusBarStyle != -1 {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: previousStatusBarStyle)!
        }
        
        previousStatusBarStyle = -1
        // this value was reset before reapplying it. caused statusbar to stay black on ios7
    }
    
}
