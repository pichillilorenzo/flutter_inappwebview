//
//  InAppBrowserWebViewController.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 17/09/18.
//

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation

typealias OlderClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Any?) -> Void
typealias NewerClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void

extension WKWebView{
    
    var keyboardDisplayRequiresUserAction: Bool? {
        get {
            return self.keyboardDisplayRequiresUserAction
        }
        set {
            self.setKeyboardRequiresUserInteraction(newValue ?? true)
        }
    }
    
    func setKeyboardRequiresUserInteraction( _ value: Bool) {
        
        guard
            let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
                print("Cannot find the WKContentView class")
                return
        }
        
        let olderSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
        let newerSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        
        if let method = class_getInstanceMethod(WKContentViewClass, olderSelector) {
            
            let originalImp: IMP = method_getImplementation(method)
            let original: OlderClosureType = unsafeBitCast(originalImp, to: OlderClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3) in
                original(me, olderSelector, arg0, !value, arg2, arg3)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
        
        if let method = class_getInstanceMethod(WKContentViewClass, newerSelector) {
            
            let originalImp: IMP = method_getImplementation(method)
            let original: NewerClosureType = unsafeBitCast(originalImp, to: NewerClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3, arg4) in
                original(me, newerSelector, arg0, !value, arg2, arg3, arg4)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
        
    }
    
}

class InAppBrowserWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UITextFieldDelegate {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var reloadButton: UIBarButtonItem!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var toolbarTop: UIView!
    @IBOutlet var toolbarBottom: UIToolbar!
    @IBOutlet var urlField: UITextField!
    
    weak var navigationDelegate: SwiftFlutterPlugin?
    var currentURL: URL?
    var tmpWindow: UIWindow?
    var browserOptions: InAppBrowserOptions?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = preferredStatusBarStyle
        super.viewWillAppear(animated)
        prepareWebView()
    }
    
    override func viewDidLoad() {
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        urlField.delegate = self
        urlField.text = self.currentURL?.absoluteString
        
        closeButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        
        forwardButton.target = self
        forwardButton.action = #selector(self.goForward)
        
        forwardButton.target = self
        forwardButton.action = #selector(self.goForward)
        
        backButton.target = self
        backButton.action = #selector(self.goBack)
        
        reloadButton.target = self
        reloadButton.action = #selector(self.reload)
        
        shareButton.target = self
        shareButton.action = #selector(self.share)
        
        spinner.hidesWhenStopped = true
        spinner.isHidden = false
        spinner.stopAnimating()
        
        navigate(to: self.currentURL!)
    }
    
    // Prevent crashes on closing windows
    deinit {
        webView?.uiDelegate = nil
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func prepareWebView() {
        
        if (browserOptions?.hideUrlBar)! {
            self.urlField.isHidden = true
            self.urlField.isEnabled = false
        }
        
        if (browserOptions?.toolbarTop)! {
            if browserOptions?.toolbarTopColor != "" {
                self.toolbarTop.backgroundColor = color(fromHexString: (browserOptions?.toolbarTopColor)!)
            }
        }
        else {
            self.toolbarTop.removeFromSuperview()
            self.webView.bounds.size.height += self.toolbarTop.bounds.height
            
            if #available(iOS 9.0, *) {
                let topConstraint = webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(getStatusBarOffset()))
                NSLayoutConstraint.activate([topConstraint])
            }
        }
        
        if (browserOptions?.toolbarBottom)! {
            if browserOptions?.toolbarBottomColor != "" {
                self.toolbarBottom.backgroundColor = color(fromHexString: (browserOptions?.toolbarBottomColor)!)
            }
            self.toolbarBottom.isTranslucent = (browserOptions?.toolbarBottomTranslucent)!
        }
        else {
            self.toolbarBottom.removeFromSuperview()
            self.webView.bounds.size.height += self.toolbarBottom.bounds.height
            
            if #available(iOS 9.0, *) {
                let bottomConstraint = webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                NSLayoutConstraint.activate([bottomConstraint])
            }
        }
        
        if browserOptions?.closeButtonCaption != "" {
            closeButton.setTitle(browserOptions?.closeButtonCaption, for: .normal)
        }
        if browserOptions?.closeButtonColor != "" {
            closeButton.tintColor = color(fromHexString: (browserOptions?.closeButtonColor)!)
        }
        
        self.modalPresentationStyle = UIModalPresentationStyle(rawValue: (browserOptions?.presentationStyle)!)!
        self.modalTransitionStyle = UIModalTransitionStyle(rawValue: (browserOptions?.transitionStyle)!)!
        
        // prevent webView from bouncing
        if (browserOptions?.disallowOverScroll)! {
            if self.webView.responds(to: #selector(getter: self.webView.scrollView)) {
                self.webView.scrollView.bounces = false
            }
            else {
                for subview: UIView in self.webView.subviews {
                    if subview is UIScrollView {
                        (subview as! UIScrollView).bounces = false
                    }
                }
            }
        }
        
        let wkUController = WKUserContentController()
        self.webView.configuration.userContentController = wkUController
        
        if (browserOptions?.enableViewportScale)! {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            self.webView.configuration.userContentController.addUserScript(userScript)
        }
        
        // Prevents long press on links that cause WKWebView exit
        let jscriptWebkitTouchCallout = WKUserScript(source: "document.body.style.webkitTouchCallout='none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.webView.configuration.userContentController.addUserScript(jscriptWebkitTouchCallout)
        
        if (browserOptions?.mediaPlaybackRequiresUserAction)! {
            if #available(iOS 10.0, *) {
                self.webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
            } else {
                // Fallback on earlier versions
            }
        }
        
        self.webView.configuration.allowsInlineMediaPlayback = (browserOptions?.allowInlineMediaPlayback)!
        
        self.webView.keyboardDisplayRequiresUserAction = browserOptions?.keyboardDisplayRequiresUserAction
        self.webView.configuration.suppressesIncrementalRendering = (browserOptions?.suppressesIncrementalRendering)!
    }
    
    // Load user requested url
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil && textField.text != "" {
            let url = textField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let request = URLRequest(url: URL(string: url!)!)
            webView.load(request)
        }
        else {
            updateUrlTextField(url: (currentURL?.absoluteString)!)
        }
        //var list : WKBackForwardList = self.webView.backForwardList
        return false
    }
    
    //    func createViews() {
    //        // We create the views in code for primarily for ease of upgrades and not requiring an external .xib to be included
    ////        let screenSize: CGRect = view.bounds
    ////        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-44-CGFloat((browserOptions?.location)! ? FOOTER_HEIGHT : TOOLBAR_HEIGHT)))
    ////
    //
    ////
    ////        let webViewFrame = CGRect(x: 0, y: urlField.frame.height, width: screenSize.width, height: screenSize.height-44-CGFloat((browserOptions?.location)! ? FOOTER_HEIGHT : TOOLBAR_HEIGHT))
    ////
    ////        let webConfiguration = WKWebViewConfiguration()
    ////        webView = WKWebView(frame: webViewFrame, configuration: webConfiguration)
    ////        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    //
    //        let toolbarIsAtBottom: Bool = browserOptions!.toolbarposition == kInAppBrowserToolbarBarPositionBottom
    //
    //        var webViewBounds: CGRect = view.bounds
    //        webViewBounds.origin.y += (toolbarIsAtBottom) ? 0 : CGFloat(TOOLBAR_HEIGHT+getStatusBarOffset())
    //        webViewBounds.size.height -= (browserOptions?.location)! ? CGFloat(TOOLBAR_HEIGHT+getStatusBarOffset()) : 0
    //        let webConfiguration = WKWebViewConfiguration()
    //        webView = WKWebView(frame: webViewBounds, configuration: webConfiguration)
    //        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    //        view.addSubview(webView!)
    //        //view.sendSubview(toBack: webView!)
    //
    //        webView?.uiDelegate = self
    //        webView?.navigationDelegate = self
    //        webView?.backgroundColor = UIColor.white
    //        webView?.clearsContextBeforeDrawing = true
    //        webView?.clipsToBounds = true
    //        webView?.contentMode = .scaleToFill
    //        webView?.isMultipleTouchEnabled = true
    //        webView?.isOpaque = true
    //        //webView?.scalesPageToFit = false
    //        webView?.isUserInteractionEnabled = true
    //
    //        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    //        spinner.alpha = 1.000
    //        spinner.autoresizesSubviews = true
    //        spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
    //        spinner.clearsContextBeforeDrawing = false
    //        spinner.clipsToBounds = false
    //        spinner.contentMode = .scaleToFill
    //        spinner.frame = CGRect(x: (webView?.frame.midX)!, y: (webView?.frame.midY)!, width: 20.0, height: 20.0)
    //        spinner.isHidden = false
    //        spinner.hidesWhenStopped = true
    //        spinner.isMultipleTouchEnabled = false
    //        spinner.isOpaque = false
    //        spinner.isUserInteractionEnabled = false
    //        spinner.stopAnimating()
    //
    //        closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))
    //        closeButton.isEnabled = true
    //        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    //        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    //        fixedSpaceButton.width = 20
    //
    //
    //        let toolbarY: Float = toolbarIsAtBottom ? Float(view.bounds.size.height) - TOOLBAR_HEIGHT : 0.0
    //        let toolbarFrame = CGRect(x: 0.0, y: CGFloat(toolbarY), width: view.bounds.size.width, height: CGFloat(TOOLBAR_HEIGHT))
    //
    //        toolbar = UIToolbar(frame: toolbarFrame)
    //        toolbar.alpha = 1.000
    //        toolbar.autoresizesSubviews = true
    //        toolbar.autoresizingMask = toolbarIsAtBottom ? ([.flexibleWidth, .flexibleTopMargin]) : .flexibleWidth
    //        toolbar.barStyle = .blackOpaque
    //        toolbar.clearsContextBeforeDrawing = false
    //        toolbar.clipsToBounds = false
    //        toolbar.contentMode = .scaleToFill
    //        toolbar.isHidden = false
    //        toolbar.isMultipleTouchEnabled = false
    //        toolbar.isOpaque = false
    //        toolbar.isUserInteractionEnabled = true
    //        if browserOptions?.toolbarcolor != nil {
    //            // Set toolbar color if user sets it in options
    //            toolbar.barTintColor = color(fromHexString: (browserOptions?.toolbarcolor)!)
    //        }
    //        if !(browserOptions?.toolbartranslucent)! {
    //            // Set toolbar translucent to no if user sets it in options
    //            toolbar.isTranslucent = false
    //        }
    //        let labelInset: CGFloat = 5.0
    //        let locationBarY: Float = toolbarIsAtBottom ? Float(view.bounds.size.height) - FOOTER_HEIGHT : Float(view.bounds.size.height) - LOCATIONBAR_HEIGHT
    //
    //
    //        let frontArrowString = NSLocalizedString("►", comment: "")
    //        // create arrow from Unicode char
    //        forwardButton = UIBarButtonItem(title: frontArrowString, style: .plain, target: self, action: #selector(self.goForward))
    //
    //        //forwardButton = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(self.goForward))
    //        forwardButton.isEnabled = true
    //        forwardButton.imageInsets = UIEdgeInsets.zero as? UIEdgeInsets ?? UIEdgeInsets()
    //        if browserOptions?.navigationbuttoncolor != nil {
    //            // Set button color if user sets it in options
    //            forwardButton.tintColor = color(fromHexString: (browserOptions?.navigationbuttoncolor)!)
    //        }
    //
    //        let backArrowString = NSLocalizedString("◄", comment: "")
    //        // create arrow from Unicode char
    //        backButton = UIBarButtonItem(title: backArrowString, style: .plain, target: self, action: #selector(self.goBack))
    //        backButton.isEnabled = true
    //        backButton.imageInsets = UIEdgeInsets.zero as? UIEdgeInsets ?? UIEdgeInsets()
    //        if browserOptions?.navigationbuttoncolor != nil {
    //            // Set button color if user sets it in options
    //            backButton.tintColor = color(fromHexString: (browserOptions?.navigationbuttoncolor)!)
    //        }
    //
    //        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reload))
    //        reloadButton.isEnabled = true
    //        reloadButton.imageInsets = UIEdgeInsetsMake(0, 0, 0, 15)
    //
    //        urlField = UITextField()
    //        urlField.bounds.size.width = toolbar.bounds.width - 150
    //        urlField.bounds.size.height = CGFloat(TOOLBAR_HEIGHT-15)
    //        urlField.backgroundColor = color(fromHexString: "#ECECED")
    //        urlField.center.y = toolbar.center.y
    //        urlField.autoresizesSubviews = true
    //        urlField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    //        urlField.text = currentURL?.absoluteString
    //        urlField.textAlignment = NSTextAlignment.center
    //        urlField.font = UIFont.systemFont(ofSize: 15)
    //        urlField.borderStyle = UITextBorderStyle.roundedRect
    //        urlField.autocorrectionType = UITextAutocorrectionType.no
    //        urlField.keyboardType = UIKeyboardType.default
    //        urlField.returnKeyType = UIReturnKeyType.done
    //        urlField.clearButtonMode = UITextFieldViewMode.whileEditing;
    //        urlField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
    //        urlField.delegate = self
    //        urlFieldBarButton = UIBarButtonItem.init(customView: urlField)
    //
    //        // Filter out Navigation Buttons if user requests so
    //        if (browserOptions?.hidenavigationbuttons)! {
    //            toolbar.items = [closeButton, flexibleSpaceButton, urlFieldBarButton]
    //        }
    //        else {
    //            //toolbar.items = [urlFieldBarButton, closeButton, flexibleSpaceButton, backButton, fixedSpaceButton, forwardButton]
    //            toolbar.items = [urlFieldBarButton, flexibleSpaceButton, reloadButton, closeButton]
    //        }
    //
    //        view.backgroundColor = UIColor.gray
    //        view.addSubview(toolbar)
    //        view.addSubview(spinner)
    //    }
    
    func setWebViewFrame(_ frame: CGRect) {
        print("Setting the WebView's frame to \(NSStringFromCGRect(frame))")
        webView.frame = frame
    }
    
    //    func showToolBar(_ show: Bool, toolbarPosition: String) {
    //        var toolbarFrame: CGRect = toolbar.frame
    //        // prevent double show/hide
    //        if show == !toolbar.isHidden {
    //            return
    //        }
    //        if show {
    //            toolbar.isHidden = false
    //            var webViewBounds: CGRect = view.bounds
    //
    //            webViewBounds.size.height -= CGFloat(TOOLBAR_HEIGHT)
    //            toolbar.frame = toolbarFrame
    //
    //            if (toolbarPosition == kInAppBrowserToolbarBarPositionTop) {
    //                toolbarFrame.origin.y = 0
    //                webViewBounds.origin.y += toolbarFrame.size.height
    //                setWebViewFrame(webViewBounds)
    //            }
    //            else {
    //                toolbarFrame.origin.y = webViewBounds.size.height + CGFloat(LOCATIONBAR_HEIGHT)
    //            }
    //            setWebViewFrame(webViewBounds)
    //        }
    //        else {
    //            toolbar.isHidden = true
    //            setWebViewFrame(view.bounds)
    //        }
    //    }
    
    //    override func viewDidUnload() {
    //        webView?.loadHTMLString(nil, baseURL: nil)
    //        CDVUserAgentUtil.releaseLock(userAgentLockToken)
    //        super.viewDidUnload()
    //    }
    
    @objc func reload () {
        webView.reload()
    }
    
    @objc func share () {
        let vc = UIActivityViewController(activityItems: [currentURL ?? ""], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    @objc func close() {
        currentURL = nil
        
        if (navigationDelegate != nil) {
            navigationDelegate?.browserExit()
        }
        //        if (navigationDelegate != nil) && navigationDelegate?.responds(to: #selector(self.browserExit)) {
        //            navigationDelegate?.browserExit()
        //        }
        weak var weakSelf = self
        
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
        updateUrlTextField(url: (currentURL?.absoluteString)!)
        webView.load(request)
    }
    
    @objc func goBack(_ sender: Any) {
        webView.goBack()
        updateUrlTextField(url: (webView?.url?.absoluteString)!)
    }
    
    @objc func goForward(_ sender: Any) {
        webView.goForward()
        updateUrlTextField(url: (webView?.url?.absoluteString)!)
    }
    
    func updateUrlTextField(url: String) {
        urlField.text = url
    }
    
    //
    // On iOS 7 the status bar is part of the view's dimensions, therefore it's height has to be taken into account.
    // The height of it could be hardcoded as 20 pixels, but that would assume that the upcoming releases of iOS won't
    // change that value.
    //
    
    func getStatusBarOffset() -> Float {
        let statusBarFrame: CGRect = UIApplication.shared.statusBarFrame
        let statusBarOffset: Float = Float(min(statusBarFrame.size.width, statusBarFrame.size.height))
        return statusBarOffset
    }
    
    //    func rePositionViews() {
    //        if (browserOptions?.toolbarposition == kInAppBrowserToolbarBarPositionTop) {
    //            webView?.frame = CGRect(x: (webView?.frame.origin.x)!, y: CGFloat(TOOLBAR_HEIGHT+getStatusBarOffset()), width: (webView?.frame.size.width)!, height: (webView?.frame.size.height)!)
    //            toolbar.frame = CGRect(x: toolbar.frame.origin.x, y: CGFloat(getStatusBarOffset()), width: toolbar.frame.size.width, height: toolbar.frame.size.height)
    //        }
    //    }
    
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // loading url, start spinner, update back/forward
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        
        if (browserOptions?.spinner)! {
            spinner.startAnimating()
        }
        
        return (navigationDelegate?.webViewDidStartLoad(webView))!
    }
    
    //    func webView(_ theWebView: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    //        let isTopLevelNavigation: Bool? = request.url == request.mainDocumentURL
    //        if isTopLevelNavigation ?? false {
    //            currentURL = request.url
    //        }
    //
    //        return (navigationDelegate?.webView(theWebView, shouldStartLoadWith: request, navigationType: navigationType))!
    //    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //func webViewDidFinishLoad(_ theWebView: WKWebView) {
        // update url, stop spinner, update back/forward
        currentURL = webView.url
        updateUrlTextField(url: (currentURL?.absoluteString)!)
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        spinner.stopAnimating()
        navigationDelegate?.webViewDidFinishLoad(webView)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //func webView(_ theWebView: WKWebView, didFailLoadWithError error: Error) {
        // log fail message, stop spinner, update back/forward
        print("webView:didFailLoadWithError - \(Int(error._code)): \(error.localizedDescription)")
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        spinner.stopAnimating()
        navigationDelegate?.webView(webView, didFailLoadWithError: error)
    }
}
