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

let kInAppBrowserTargetSelf = "_self"
let kInAppBrowserTargetSystem = "_system"
let kInAppBrowserTargetBlank = "_blank"
let kInAppBrowserToolbarBarPositionBottom = "bottom"
let kInAppBrowserToolbarBarPositionTop = "top"
let TOOLBAR_HEIGHT: Float = 44.0
let STATUSBAR_HEIGHT: Float = 20.0
let LOCATIONBAR_HEIGHT: Float = 21.0
let FOOTER_HEIGHT: Float = (TOOLBAR_HEIGHT + LOCATIONBAR_HEIGHT)

@objcMembers
class CDVInAppBrowserOptions: NSObject {
    var location = false
    var toolbar = false
    var closebuttoncaption = ""
    var closebuttoncolor = ""
    var toolbarposition = ""
    var toolbarcolor = ""
    var toolbartranslucent = false
    var hidenavigationbuttons = false
    var navigationbuttoncolor = ""
    var clearcache = false
    var clearsessioncache = false
    var hidespinner = false
    var presentationstyle = ""
    var transitionstyle = ""
    var enableviewportscale = false
    var mediaplaybackrequiresuseraction = false
    var allowinlinemediaplayback = false
    var keyboarddisplayrequiresuseraction = false
    var suppressesincrementalrendering = false
    var hidden = false
    var disallowoverscroll = false
    
    override init() {
        super.init()
        
        // default values
        location = true
        toolbar = true
        closebuttoncaption = "Done"
        closebuttoncolor = "#FFFFFF"
        toolbarposition = kInAppBrowserToolbarBarPositionBottom
        clearcache = false
        clearsessioncache = false
        hidespinner = false
        enableviewportscale = false
        mediaplaybackrequiresuseraction = false
        allowinlinemediaplayback = false
        keyboarddisplayrequiresuseraction = true
        suppressesincrementalrendering = false
        hidden = false
        disallowoverscroll = false
        hidenavigationbuttons = false
        toolbarcolor = ""
        toolbartranslucent = true
        
    }
    
    class func parseOptions(_ options: String) -> CDVInAppBrowserOptions {
        let obj = CDVInAppBrowserOptions()
        // NOTE: this parsing does not handle quotes within values
        let pairs = options.components(separatedBy: ",")
        // parse keys and values, set the properties
        for pair: String in pairs {
            let keyvalue = pair.components(separatedBy: "=")
            if keyvalue.count == 2 {
                let key: String = keyvalue[0].lowercased()
                let value: String = keyvalue[1]
                let value_lc: String = value.lowercased()
                let isBoolean: Bool = (value_lc == "yes") || (value_lc == "no")
                let numberFormatter = NumberFormatter()
                numberFormatter.allowsFloats = true
                let isNumber: Bool = numberFormatter.number(from: value_lc) != nil
                // set the property according to the key name
                if obj.responds(to: NSSelectorFromString(key)) {
                    if isNumber {
                        obj.setValue(numberFormatter.number(from: value_lc), forKey: key)
                    }
                    else if isBoolean {
                        obj.setValue(((value_lc == "yes") ? 1 : 0), forKey: key)
                    }
                    else {
                        obj.setValue(value, forKey: key)
                    }
                }
            }
        }
        return obj
    }
}


public class SwiftFlutterPlugin: NSObject, FlutterPlugin {
    var inAppBrowserViewController: CDVInAppBrowserViewController?
    
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
    
    func setting(forKey key: String) -> Any {
        return ""//commandDelegate.settings[key.lowercased()]!
    }
    
    func onReset() {
        close()
    }
    
    func close() {
        if inAppBrowserViewController == nil {
            print("IAB.close() called but it was already closed.")
            return
        }
        // Things are cleaned up in browserExit.
        inAppBrowserViewController?.close()
    }
    
    func isSystemUrl(_ url: URL) -> Bool {
        if (url.host == "itunes.apple.com") {
            return true
        }
        return false
    }
    
    public func open(arguments: NSDictionary, result: @escaping FlutterResult) {
        let url: String? = (arguments["url"] as? String)!
        var target: String? = (arguments["target"] as? String)!
        target = target != nil ? target : kInAppBrowserTargetSelf
        let options = (arguments["options"] as? String)!

        if url != nil {
            let baseUrl: URL? = nil
            let absoluteUrl = URL(string: url!, relativeTo: baseUrl)?.absoluteURL
            
            if isSystemUrl(absoluteUrl!) {
                target = kInAppBrowserTargetSystem
            }
            
            if (target == kInAppBrowserTargetSelf) {
                open(inCordovaWebView: absoluteUrl!, withOptions: options)
            }
            else if (target == kInAppBrowserTargetSystem) {
                open(inSystem: absoluteUrl!)
            }
            else {
                // _blank or anything else
                openIn(inAppBrowser: absoluteUrl!, withOptions: options)
            }
        }
        else {
            result(false)
        }
        result(true)
    }
    
    func openIn(inAppBrowser url: URL, withOptions options: String) {
        let browserOptions = CDVInAppBrowserOptions.parseOptions(options)

        if browserOptions.clearcache {
            let _: HTTPCookie?
            let storage = HTTPCookieStorage.shared
            for cookie in storage.cookies! {
                if !(cookie.domain.isEqual(".^filecookies^") ) {
                    storage.deleteCookie(cookie)
                }
            }
        }
        
        if browserOptions.clearsessioncache {
            let _: HTTPCookie?
            let storage = HTTPCookieStorage.shared
            for cookie in storage.cookies! {
                if !(cookie.domain.isEqual(".^filecookies^") && cookie.isSessionOnly) {
                    storage.deleteCookie(cookie)
                }
            }
        }
        
        if inAppBrowserViewController == nil {
            var userAgent: String = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")!

            let overrideUserAgent: String = ""
            let appendUserAgent: String = ""
            if overrideUserAgent != "" {
                userAgent = overrideUserAgent
            }
            if appendUserAgent != "" {
                userAgent = userAgent + (appendUserAgent)
            }
            if !(self.tmpWindow != nil) {
                let frame: CGRect = UIScreen.main.bounds
                self.tmpWindow = UIWindow(frame: frame)
            }
            inAppBrowserViewController = CDVInAppBrowserViewController(userAgent: userAgent, prevUserAgent: userAgent, browserOptions: browserOptions, tmpWindow: tmpWindow)
            inAppBrowserViewController?.navigationDelegate = self
        }
        
        inAppBrowserViewController?.showLocationBar(browserOptions.location)
        inAppBrowserViewController?.showToolBar(browserOptions.toolbar, toolbarPosition: browserOptions.toolbarposition)
        if browserOptions.closebuttoncaption != nil || browserOptions.closebuttoncolor != nil {
            inAppBrowserViewController?.setCloseButtonTitle(browserOptions.closebuttoncaption, colorString: browserOptions.closebuttoncolor)
        }
        
        // Set Presentation Style
        var presentationStyle: UIModalPresentationStyle = .fullScreen
        // default
        if browserOptions.presentationstyle != nil {
            if (browserOptions.presentationstyle.lowercased() == "pagesheet") {
                presentationStyle = .pageSheet
            }
            else if (browserOptions.presentationstyle.lowercased() == "formsheet") {
                presentationStyle = .formSheet
            }
        }
        inAppBrowserViewController?.modalPresentationStyle = presentationStyle
        
        // Set Transition Style
        var transitionStyle: UIModalTransitionStyle = .coverVertical
        // default
        if browserOptions.transitionstyle != nil {
            if (browserOptions.transitionstyle.lowercased() == "fliphorizontal") {
                transitionStyle = .flipHorizontal
            }
            else if (browserOptions.transitionstyle.lowercased() == "crossdissolve") {
                transitionStyle = .crossDissolve
            }
        }
        inAppBrowserViewController?.modalTransitionStyle = transitionStyle
        
        // prevent webView from bouncing
        if browserOptions.disallowoverscroll {
            if inAppBrowserViewController?.webView?.responds(to: #selector(getter: inAppBrowserViewController?.webView?.scrollView)) ?? false {
                (inAppBrowserViewController?.webView?.scrollView)?.bounces = false
            }
            else {
                for subview: UIView in (inAppBrowserViewController?.webView?.subviews)! {
                    if subview is UIScrollView {
                        (subview as? UIScrollView)?.bounces = false
                    }
                }
            }
        }
        
        // UIWebView options
        inAppBrowserViewController?.webView?.scalesPageToFit = browserOptions.enableviewportscale
        inAppBrowserViewController?.webView?.mediaPlaybackRequiresUserAction = browserOptions.mediaplaybackrequiresuseraction
        inAppBrowserViewController?.webView?.allowsInlineMediaPlayback = browserOptions.allowinlinemediaplayback
        //if IsAtLeastiOSVersion("6.0") {
        inAppBrowserViewController?.webView?.keyboardDisplayRequiresUserAction = browserOptions.keyboarddisplayrequiresuseraction
        inAppBrowserViewController?.webView?.suppressesIncrementalRendering = browserOptions.suppressesincrementalrendering
        //}
        
        inAppBrowserViewController?.navigate(to: url)
        if !browserOptions.hidden {
            show()
        }
    }
    
    public func show() {
        if inAppBrowserViewController == nil {
            print("Tried to show IAB after it was closed.")
            return
        }
        if previousStatusBarStyle != -1 {
            print("Tried to show IAB while already shown")
            return
        }
        
        previousStatusBarStyle = UIApplication.shared.statusBarStyle.rawValue
        let nav = CDVInAppBrowserNavigationController(rootViewController: inAppBrowserViewController!)
        nav.orientationDelegate = inAppBrowserViewController
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = (inAppBrowserViewController?.modalPresentationStyle)!
        
        weak var weakSelf: SwiftFlutterPlugin? = self
        
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            if weakSelf?.inAppBrowserViewController != nil {
                if !(self.tmpWindow != nil) {
                    let frame: CGRect = UIScreen.main.bounds
                    self.tmpWindow = UIWindow(frame: frame)
                }
                let tmpController = UIViewController()
                let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
                self.tmpWindow?.rootViewController = tmpController
                self.tmpWindow?.windowLevel = UIWindowLevel(baseWindowLevel! + 1)
                self.tmpWindow?.makeKeyAndVisible()
                tmpController.present(nav, animated: true) { () -> Void in }
            }
        })
    }
    
    public func hide() {
        if inAppBrowserViewController == nil {
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
            if self.inAppBrowserViewController != nil {
                self.previousStatusBarStyle = -1
                self.inAppBrowserViewController?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                    self.tmpWindow?.windowLevel = 0.0
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                })
            }
        })
    }
    
    func open(inCordovaWebView url: URL, withOptions options: String) {
        _ = URLRequest(url: url)
        openIn(inAppBrowser: url, withOptions: options)
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
        if jsWrapper != nil {
            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
            let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
            if sourceArrayString != nil {
                let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.characters.count ?? 0) - 2))
                let jsToInject = String(format: jsWrapper, sourceString!)
                inAppBrowserViewController?.webView?.stringByEvaluatingJavaScript(from: jsToInject)
            }
        }
        else {
            inAppBrowserViewController?.webView?.stringByEvaluatingJavaScript(from: source)
        }
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
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        let url: String = inAppBrowserViewController!.currentURL!.absoluteString
        channel.invokeMethod("loadstart", arguments: ["type": "loadstart", "url": url])
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let url: String = inAppBrowserViewController!.currentURL!.absoluteString
        channel.invokeMethod("loadstop", arguments: ["type": "loadstop", "url": url])
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let url: String = inAppBrowserViewController!.currentURL!.absoluteString
        let arguments = ["type": "loaderror", "url": url, "code": error._code, "message": error.localizedDescription] as [String : Any]
        channel.invokeMethod("loaderror", arguments: arguments)
    }
    
    func browserExit() {
        
        channel.invokeMethod("exit", arguments: ["type": "exit"])

        // Set navigationDelegate to nil to ensure no callbacks are received from it.
        inAppBrowserViewController?.navigationDelegate = nil
        // Don't recycle the ViewController since it may be consuming a lot of memory.
        // Also - this is required for the PDF/User-Agent bug work-around.
        inAppBrowserViewController = nil
        
        //if (IsAtLeastiOSVersion(@"7.0")) {
            if previousStatusBarStyle != -1 {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: previousStatusBarStyle)!
            }
        //}
        
        previousStatusBarStyle = -1
        // this value was reset before reapplying it. caused statusbar to stay black on ios7
    }

}

class CDVInAppBrowserViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView!
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var toolbar: UIToolbar!
    weak var orientationDelegate: CDVInAppBrowserViewController?
    weak var navigationDelegate: SwiftFlutterPlugin?
    var currentURL: URL?
    var tmpWindow: UIWindow?
    
    private var userAgent = ""
    private var prevUserAgent = ""
    private var userAgentLockToken: Int = 0
    private var browserOptions: CDVInAppBrowserOptions?
    
    init(userAgent: String, prevUserAgent: String, browserOptions: CDVInAppBrowserOptions, tmpWindow: UIWindow?) {

        super.init(nibName: nil, bundle: nil)
        
        self.userAgent = userAgent
        self.prevUserAgent = prevUserAgent
        self.browserOptions = browserOptions
        self.tmpWindow = tmpWindow
        createViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Prevent crashes on closing windows
    deinit {
        webView?.delegate = nil
    }
    
    func createViews() {
        // We create the views in code for primarily for ease of upgrades and not requiring an external .xib to be included
        var webViewBounds: CGRect = view.bounds
        let toolbarIsAtBottom: Bool = !(browserOptions!.toolbarposition == kInAppBrowserToolbarBarPositionTop)
        webViewBounds.size.height -= CGFloat((browserOptions?.location)! ? FOOTER_HEIGHT : TOOLBAR_HEIGHT)
        webView = UIWebView(frame: webViewBounds)// as WKWebView
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(webView!)
        view.sendSubview(toBack: webView!)
        webView?.delegate = self
        webView?.backgroundColor = UIColor.white
        webView?.clearsContextBeforeDrawing = true
        webView?.clipsToBounds = true
        webView?.contentMode = .scaleToFill
        webView?.isMultipleTouchEnabled = true
        webView?.isOpaque = true
        webView?.scalesPageToFit = false
        webView?.isUserInteractionEnabled = true
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.alpha = 1.000
        spinner.autoresizesSubviews = true
        spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        spinner.clearsContextBeforeDrawing = false
        spinner.clipsToBounds = false
        spinner.contentMode = .scaleToFill
        spinner.frame = CGRect(x: (webView?.frame.midX)!, y: (webView?.frame.midY)!, width: 20.0, height: 20.0)
        spinner.isHidden = false
        spinner.hidesWhenStopped = true
        spinner.isMultipleTouchEnabled = false
        spinner.isOpaque = false
        spinner.isUserInteractionEnabled = false
        spinner.stopAnimating()
        
        closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))
        closeButton.isEnabled = true
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceButton.width = 20
        let toolbarY: Float = toolbarIsAtBottom ? Float(view.bounds.size.height) - TOOLBAR_HEIGHT : 0.0
        let toolbarFrame = CGRect(x: 0.0, y: CGFloat(toolbarY), width: view.bounds.size.width, height: CGFloat(TOOLBAR_HEIGHT))
        
        toolbar = UIToolbar(frame: toolbarFrame)
        toolbar.alpha = 1.000
        toolbar.autoresizesSubviews = true
        toolbar.autoresizingMask = toolbarIsAtBottom ? ([.flexibleWidth, .flexibleTopMargin]) : .flexibleWidth
        toolbar.barStyle = .blackOpaque
        toolbar.clearsContextBeforeDrawing = false
        toolbar.clipsToBounds = false
        toolbar.contentMode = .scaleToFill
        toolbar.isHidden = false
        toolbar.isMultipleTouchEnabled = false
        toolbar.isOpaque = false
        toolbar.isUserInteractionEnabled = true
        if browserOptions?.toolbarcolor != nil {
            // Set toolbar color if user sets it in options
            toolbar.barTintColor = color(fromHexString: (browserOptions?.toolbarcolor)!)
        }
        if !(browserOptions?.toolbartranslucent)! {
            // Set toolbar translucent to no if user sets it in options
            toolbar.isTranslucent = false
        }
        let labelInset: CGFloat = 5.0
        let locationBarY: Float = toolbarIsAtBottom ? Float(view.bounds.size.height) - FOOTER_HEIGHT : Float(view.bounds.size.height) - LOCATIONBAR_HEIGHT
        
        addressLabel = UILabel(frame: CGRect(x: labelInset, y: CGFloat(locationBarY), width: view.bounds.size.width - labelInset, height: CGFloat(LOCATIONBAR_HEIGHT)))
        addressLabel.adjustsFontSizeToFitWidth = false
        addressLabel.alpha = 1.000
        addressLabel.autoresizesSubviews = true
        addressLabel.autoresizingMask = [.flexibleWidth, .flexibleRightMargin, .flexibleTopMargin]
        addressLabel.backgroundColor = UIColor.clear// as? CGColor
        addressLabel.baselineAdjustment = .alignCenters
        addressLabel.clearsContextBeforeDrawing = true
        addressLabel.clipsToBounds = true
        addressLabel.contentMode = .scaleToFill
        addressLabel.isEnabled = true
        addressLabel.isHidden = false
        addressLabel.lineBreakMode = .byTruncatingTail
        
        if addressLabel.responds(to: NSSelectorFromString("setMinimumScaleFactor:")) {
            addressLabel.setValue((10.0 / UIFont.labelFontSize), forKey: "minimumScaleFactor")
        }
        else if addressLabel.responds(to: NSSelectorFromString("setMinimumFontSize:")) {
            addressLabel.setValue(10.0, forKey: "minimumFontSize")
        }
        
        addressLabel.isMultipleTouchEnabled = false
        addressLabel.numberOfLines = 1
        addressLabel.isOpaque = false
        addressLabel.shadowOffset = CGSize(width: 0.0, height: -1.0)
        addressLabel.text = NSLocalizedString("Loading...", comment: "")
        addressLabel.textAlignment = .left
        addressLabel.textColor = UIColor(white: 1.000, alpha: 1.000)
        addressLabel.isUserInteractionEnabled = false
        
        let frontArrowString = NSLocalizedString("►", comment: "")
        // create arrow from Unicode char
        forwardButton = UIBarButtonItem(title: frontArrowString, style: .plain, target: self, action: #selector(self.goForward))
        forwardButton.isEnabled = true
        forwardButton.imageInsets = UIEdgeInsets.zero as? UIEdgeInsets ?? UIEdgeInsets()
        if browserOptions?.navigationbuttoncolor != nil {
            // Set button color if user sets it in options
            forwardButton.tintColor = color(fromHexString: (browserOptions?.navigationbuttoncolor)!)
        }
        
        let backArrowString = NSLocalizedString("◄", comment: "")
        // create arrow from Unicode char
        backButton = UIBarButtonItem(title: backArrowString, style: .plain, target: self, action: #selector(self.goBack))
        backButton.isEnabled = true
        backButton.imageInsets = UIEdgeInsets.zero as? UIEdgeInsets ?? UIEdgeInsets()
        if browserOptions?.navigationbuttoncolor != nil {
            // Set button color if user sets it in options
            backButton.tintColor = color(fromHexString: (browserOptions?.navigationbuttoncolor)!)
        }
        
        // Filter out Navigation Buttons if user requests so
        if (browserOptions?.hidenavigationbuttons)! {
            toolbar.items = [closeButton, flexibleSpaceButton]
        }
        else {
            toolbar.items = [closeButton, flexibleSpaceButton, backButton, fixedSpaceButton, forwardButton]
        }
        view.backgroundColor = UIColor.gray// as? CGColor
        view.addSubview(toolbar)
        view.addSubview(addressLabel)
        view.addSubview(spinner)
    }
    
    func setWebViewFrame(_ frame: CGRect) {
        print("Setting the WebView's frame to \(NSStringFromCGRect(frame))")
        webView?.frame = frame
    }
    
    func setCloseButtonTitle(_ title: String, colorString: String) {
        // the advantage of using UIBarButtonSystemItemDone is the system will localize it for you automatically
        // but, if you want to set this yourself, knock yourself out (we can't set the title for a system Done button, so we have to create a new one)
        closeButton = nil
        // Initialize with title if title is set, otherwise the title will be 'Done' localized
        closeButton = title != nil ? UIBarButtonItem(title: title, style: .bordered, target: self, action: #selector(self.close)) : UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))
        closeButton.isEnabled = true
        // If color on closebutton is requested then initialize with that that color, otherwise use initialize with default
        closeButton.tintColor = colorString != nil ? color(fromHexString: colorString) : UIColor(red: 60.0 / 255.0, green: 136.0 / 255.0, blue: 230.0 / 255.0, alpha: 1)
        
        var items = toolbar.items
        items![0] = closeButton
        toolbar.items = items //as? [AVMetadataItem] ?? [AVMetadataItem]()
    }
    
    func showLocationBar(_ show: Bool) {
        var locationbarFrame: CGRect = addressLabel.frame
        let toolbarVisible: Bool = !toolbar.isHidden
        // prevent double show/hide
        if show == !addressLabel.isHidden {
            return
        }
        
        if show {
            addressLabel.isHidden = false
            if toolbarVisible {
                // toolBar at the bottom, leave as is
                // put locationBar on top of the toolBar
                var webViewBounds: CGRect = view.bounds
                webViewBounds.size.height -= CGFloat(FOOTER_HEIGHT)
                setWebViewFrame(webViewBounds)
                locationbarFrame.origin.y = webViewBounds.size.height
                addressLabel.frame = locationbarFrame
            }
            else {
                // no toolBar, so put locationBar at the bottom
                var webViewBounds: CGRect = view.bounds
                webViewBounds.size.height -= CGFloat(LOCATIONBAR_HEIGHT)
                setWebViewFrame(webViewBounds)
                locationbarFrame.origin.y = webViewBounds.size.height
                addressLabel.frame = locationbarFrame
            }
        }
        else {
            addressLabel.isHidden = true
            if toolbarVisible {
                // locationBar is on top of toolBar, hide locationBar
                // webView take up whole height less toolBar height
                var webViewBounds: CGRect = view.bounds
                webViewBounds.size.height -= CGFloat(TOOLBAR_HEIGHT)
                setWebViewFrame(webViewBounds)
            }
            else {
                // no toolBar, expand webView to screen dimensions
                setWebViewFrame(view.bounds)
            }
        }
    }
    
    func showToolBar(_ show: Bool, toolbarPosition: String) {
        var toolbarFrame: CGRect = toolbar.frame
        var locationbarFrame: CGRect = addressLabel.frame
        let locationbarVisible: Bool = !addressLabel.isHidden
        // prevent double show/hide
        if show == !toolbar.isHidden {
            return
        }
        if show {
            toolbar.isHidden = false
            var webViewBounds: CGRect = view.bounds
            
            if locationbarVisible {
                // locationBar at the bottom, move locationBar up
                // put toolBar at the bottom
                webViewBounds.size.height -= CGFloat(FOOTER_HEIGHT)
                locationbarFrame.origin.y = webViewBounds.size.height
                addressLabel.frame = locationbarFrame
                toolbar.frame = toolbarFrame
            }
            else {
                // no locationBar, so put toolBar at the bottom
                var webViewBounds: CGRect = view.bounds
                webViewBounds.size.height -= CGFloat(TOOLBAR_HEIGHT)
                toolbar.frame = toolbarFrame
            }
            
            if (toolbarPosition == kInAppBrowserToolbarBarPositionTop) {
                toolbarFrame.origin.y = 0
                webViewBounds.origin.y += toolbarFrame.size.height
                setWebViewFrame(webViewBounds)
            }
            else {
                toolbarFrame.origin.y = webViewBounds.size.height + CGFloat(LOCATIONBAR_HEIGHT)
            }
            setWebViewFrame(webViewBounds)
        }
        else {
            toolbar.isHidden = true
            if locationbarVisible {
                // locationBar is on top of toolBar, hide toolBar
                // put locationBar at the bottom
                // webView take up whole height less locationBar height
                var webViewBounds: CGRect = view.bounds
                webViewBounds.size.height -= CGFloat(LOCATIONBAR_HEIGHT)
                setWebViewFrame(webViewBounds)
                // move locationBar down
                locationbarFrame.origin.y = webViewBounds.size.height
                addressLabel.frame = locationbarFrame
            }
            else {
                // no locationBar, expand webView to screen dimensions
                setWebViewFrame(view.bounds)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func viewDidUnload() {
//        webView?.loadHTMLString(nil, baseURL: nil)
//        CDVUserAgentUtil.releaseLock(userAgentLockToken)
//        super.viewDidUnload()
//    }
    
//    func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .default
//    }
//
//    func prefersStatusBarHidden() -> Bool {
//        return false
//    }
    
    @objc func close() {
        currentURL = nil
        if (navigationDelegate != nil) {
            navigationDelegate?.browserExit()
        }
//        if (navigationDelegate != nil) && navigationDelegate?.responds(to: #selector(self.browserExit)) {
//            navigationDelegate?.browserExit()
//        }
        weak var weakSelf = self// as? UIViewController
        // Run later to avoid the "took a long time" log message.
        
        DispatchQueue.main.async(execute: {() -> Void in
            if (weakSelf?.responds(to: #selector(getter: self.presentingViewController)))! {
                weakSelf?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                    self.tmpWindow?.windowLevel = 0.0
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                })
            }
            else {
                weakSelf?.parent?.dismiss(animated: true, completion: {() -> Void in
                    self.tmpWindow?.windowLevel = 0.0
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                })
            }
        })
    }
    
    func navigate(to url: URL) {
        let request = URLRequest(url: url)
        currentURL = url
        webView?.loadRequest(request)
//        if userAgentLockToken != 0 {
//            webView?.load(request, mimeType: <#String#>, textEncodingName: <#String#>, baseURL: <#URL#>)
//        }
//        else {
//            weak var weakSelf: CDVInAppBrowserViewController? = self
//            CDVUserAgentUtil.acquireLock({(_ lockToken: Int) -> Void in
//                userAgentLockToken = lockToken
//                CDVUserAgentUtil.setUserAgent(userAgent, lockToken: lockToken)
//                weakSelf?.webView?.load(request)
//            })
//        }
    }
    
    @objc func goBack(_ sender: Any) {
        webView?.goBack()
    }
    
    @objc func goForward(_ sender: Any) {
        webView?.goForward()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if IsAtLeastiOSVersion("7.0") {
            UIApplication.shared.statusBarStyle = preferredStatusBarStyle
        //}
        rePositionViews()
        super.viewWillAppear(animated)
    }
    
    //
    // On iOS 7 the status bar is part of the view's dimensions, therefore it's height has to be taken into account.
    // The height of it could be hardcoded as 20 pixels, but that would assume that the upcoming releases of iOS won't
    // change that value.
    //
    
    func getStatusBarOffset() -> Float {
        let statusBarFrame: CGRect = UIApplication.shared.statusBarFrame
        let statusBarOffset: Float = Float(min(statusBarFrame.size.width, statusBarFrame.size.height))//IsAtLeastiOSVersion("7.0") ? min(statusBarFrame.size.width, statusBarFrame.size.height) : 0.0
        return statusBarOffset
    }
    
    func rePositionViews() {
        if (browserOptions?.toolbarposition == kInAppBrowserToolbarBarPositionTop) {
            webView?.frame = CGRect(x: (webView?.frame.origin.x)!, y: CGFloat(TOOLBAR_HEIGHT), width: (webView?.frame.size.width)!, height: (webView?.frame.size.height)!)
            toolbar.frame = CGRect(x: toolbar.frame.origin.x, y: CGFloat(getStatusBarOffset()), width: toolbar.frame.size.width, height: toolbar.frame.size.height)
        }
    }
    
    // Helper function to convert hex color string to UIColor
    // Assumes input like "#00FF00" (#RRGGBB).
    // Taken from https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
    
    func color(fromHexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: fromHexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
    
    // MARK: UIWebViewDelegate
    
    func webViewDidStartLoad(_ theWebView: UIWebView) {
        // loading url, start spinner, update back/forward
        addressLabel.text = NSLocalizedString("Loading...", comment: "")
        backButton.isEnabled = theWebView.canGoBack
        forwardButton.isEnabled = theWebView.canGoForward
        print((browserOptions?.hidespinner)! ? "Yes" : "No")
        if !(browserOptions?.hidespinner)! {
            spinner.startAnimating()
        }
        return (navigationDelegate?.webViewDidStartLoad(theWebView))!
    }
    
//    func webView(_ theWebView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        let isTopLevelNavigation: Bool? = request.url == request.mainDocumentURL
//        if isTopLevelNavigation ?? false {
//            currentURL = request.url
//        }
//
//        return (navigationDelegate?.webView(theWebView, shouldStartLoadWith: request, navigationType: navigationType))!
//    }
    
    func webViewDidFinishLoad(_ theWebView: UIWebView) {
        // update url, stop spinner, update back/forward
        currentURL = theWebView.request?.url
        addressLabel.text = currentURL?.absoluteString
        backButton.isEnabled = theWebView.canGoBack
        forwardButton.isEnabled = theWebView.canGoForward
        spinner.stopAnimating()
        
        // Work around a bug where the first time a PDF is opened, all UIWebViews
        // reload their User-Agent from NSUserDefaults.
        // This work-around makes the following assumptions:
        // 1. The app has only a single Cordova Webview. If not, then the app should
        //    take it upon themselves to load a PDF in the background as a part of
        //    their start-up flow.
        // 2. That the PDF does not require any additional network requests. We change
        //    the user-agent here back to that of the CDVViewController, so requests
        //    from it must pass through its white-list. This *does* break PDFs that
        //    contain links to other remote PDF/websites.
        // More info at https://issues.apache.org/jira/browse/CB-2225
        let isPDF: Bool = "true" == theWebView.stringByEvaluatingJavaScript(from: "document.body==null")
        if isPDF {
            //CDVUserAgentUtil.setUserAgent(prevUserAgent, lockToken: userAgentLockToken)
        }
        navigationDelegate?.webViewDidFinishLoad(theWebView)
    }
    
    func webView(_ theWebView: UIWebView, didFailLoadWithError error: Error) {
        // log fail message, stop spinner, update back/forward
        print("webView:didFailLoadWithError - \(Int(error._code)): \(error.localizedDescription)")
        backButton.isEnabled = theWebView.canGoBack
        forwardButton.isEnabled = theWebView.canGoForward
        spinner.stopAnimating()
        addressLabel.text = NSLocalizedString("Load Error", comment: "")
        navigationDelegate?.webView(theWebView, didFailLoadWithError: error)
    }
    
    // MARK: CDVScreenOrientationDelegate
//    func shouldAutorotate() -> Bool {
//        if (orientationDelegate != nil) && (orientationDelegate?.responds(to: #selector(getter: self.shouldAutorotate)))! {
//            return orientationDelegate!.shouldAutorotate
//        }
//        return true
//    }
//    
//    func supportedInterfaceOrientations() -> Int {
//        if (orientationDelegate != nil) && (orientationDelegate?.responds(to: #selector(getter: self.supportedInterfaceOrientations)))! {
//            return Int(orientationDelegate!.supportedInterfaceOrientations.rawValue)
//        }
//        //return Int(1 << .portrait)
//        return 1
//    }
    
//    override func shouldAutorotate(to interfaceOrientation: UIInterfaceOrientation) -> Bool {
//        if (orientationDelegate != nil) && (orientationDelegate?.responds(to: #selector(self.shouldAutorotateToInterfaceOrientation)))! {
//            return orientationDelegate!.shouldAutorotate(to: interfaceOrientation)
//        }
//        return true
//    }

}

class CDVInAppBrowserNavigationController: UINavigationController {
    weak var orientationDelegate: AnyObject?
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    override func viewDidLoad() {
        var statusBarFrame: CGRect = invertFrameIfNeeded(UIApplication.shared.statusBarFrame)
        statusBarFrame.size.height = CGFloat(STATUSBAR_HEIGHT)
        // simplified from: http://stackoverflow.com/a/25669695/219684
        let bgToolbar = UIToolbar(frame: statusBarFrame)
        bgToolbar.barStyle = .default
        bgToolbar.autoresizingMask = .flexibleWidth
        view.addSubview(bgToolbar)
        super.viewDidLoad()
    }
    
    func invertFrameIfNeeded(_ rect: CGRect) -> CGRect {
        // We need to invert since on iOS 7 frames are always in Portrait context
//        if !IsAtLeastiOSVersion("8.0") {
//            if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
//                let temp: CGFloat = rect.size.width
//                rect.size.width = rect.size.height
//                rect.size.height = temp
//            }
//            rect.origin = CGPoint.zero
//        }
        return rect
    }
    
    // MARK: CDVScreenOrientationDelegate
    override var shouldAutorotate: Bool {
        if (orientationDelegate != nil) && (orientationDelegate?.responds(to: #selector(getter: self.shouldAutorotate)))! {
            return orientationDelegate!.shouldAutorotate
        }
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if (orientationDelegate != nil) && (orientationDelegate?.responds(to: #selector(getter: self.supportedInterfaceOrientations)))! {
            return orientationDelegate!.supportedInterfaceOrientations
        }
        //return Int(1 << .portrait)
        return UIInterfaceOrientationMask(rawValue: 1)
    }
    
//    override func shouldAutorotate(to interfaceOrientation: UIInterfaceOrientation) -> Bool {
//        if (orientationDelegate != nil) && (orientationDelegate?.responds(to: #selector(self.shouldAutorotateToInterfaceOrientation)))! {
//            return orientationDelegate!.shouldAutorotate(to: interfaceOrientation)
//        }
//        return true
//    }
}
