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
    var initHeaders: [String: String]?
    
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
        
        loadUrl(url: self.currentURL!, headers: self.initHeaders)
    }
    
    // Prevent crashes on closing windows
    deinit {
        webView?.uiDelegate = nil
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func prepareWebView() {
        
        self.webView.configuration.userContentController = WKUserContentController()
        self.webView.configuration.preferences = WKPreferences()
        
        if (browserOptions?.hideUrlBar)! {
            self.urlField.isHidden = true
            self.urlField.isEnabled = false
        }
        
        if (browserOptions?.toolbarTop)! {
            if browserOptions?.toolbarTopBackgroundColor != "" {
                self.toolbarTop.backgroundColor = color(fromHexString: (browserOptions?.toolbarTopBackgroundColor)!)
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
            if browserOptions?.toolbarBottomBackgroundColor != "" {
                self.toolbarBottom.backgroundColor = color(fromHexString: (browserOptions?.toolbarBottomBackgroundColor)!)
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
        
        if (browserOptions?.enableViewportScale)! {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            self.webView.configuration.userContentController.addUserScript(userScript)
        }
        
        // Prevents long press on links that cause WKWebView exit
        let jscriptWebkitTouchCallout = WKUserScript(source: "document.body.style.webkitTouchCallout='none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.webView.configuration.userContentController.addUserScript(jscriptWebkitTouchCallout)
        
        if (browserOptions?.mediaTypesRequiringUserActionForPlayback)! != "" {
            if #available(iOS 10.0, *) {
                switch (browserOptions?.mediaTypesRequiringUserActionForPlayback)! {
                    case "all":
                        self.webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
                        break
                    case "audio":
                        self.webView.configuration.mediaTypesRequiringUserActionForPlayback = .audio
                        break
                    case "video":
                        self.webView.configuration.mediaTypesRequiringUserActionForPlayback = .video
                        break
                    default:
                        self.webView.configuration.mediaTypesRequiringUserActionForPlayback = []
                        break
                }
                
            } else {
                // Fallback on earlier versions
                self.webView.configuration.mediaPlaybackRequiresUserAction = true
            }
        }
        
        self.webView.configuration.allowsInlineMediaPlayback = (browserOptions?.allowsInlineMediaPlayback)!
        self.webView.keyboardDisplayRequiresUserAction = browserOptions?.keyboardDisplayRequiresUserAction
        self.webView.configuration.suppressesIncrementalRendering = (browserOptions?.suppressesIncrementalRendering)!
        self.webView.allowsBackForwardNavigationGestures = (browserOptions?.allowsBackForwardNavigationGestures)!
        if #available(iOS 9.0, *) {
            self.webView.allowsLinkPreview = (browserOptions?.allowsLinkPreview)!
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            self.webView.configuration.ignoresViewportScaleLimits = (browserOptions?.ignoresViewportScaleLimits)!
        } else {
            // Fallback on earlier versions
        }
        self.webView.configuration.allowsInlineMediaPlayback = (browserOptions?.allowsInlineMediaPlayback)!
        if #available(iOS 9.0, *) {
            self.webView.configuration.allowsPictureInPictureMediaPlayback = (browserOptions?.allowsPictureInPictureMediaPlayback)!
        } else {
            // Fallback on earlier versions
        }
        self.webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = (browserOptions?.javaScriptCanOpenWindowsAutomatically)!
        self.webView.configuration.preferences.javaScriptEnabled = (browserOptions?.javaScriptEnabled)!
        
        if ((browserOptions?.userAgent)! != "") {
            if #available(iOS 9.0, *) {
                self.webView.customUserAgent = (browserOptions?.userAgent)!
            } else {
                // Fallback on earlier versions
            }
        }
        
        if (browserOptions?.clearCache)! {
            clearCache()
        }
        
    }
    
    func loadUrl(url: URL, headers: [String: String]?) {
        var request = URLRequest(url: url)
        currentURL = url
        updateUrlTextField(url: (currentURL?.absoluteString)!)
        
        if headers != nil {
            for (key, value) in headers! {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        webView.load(request)
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
    
    func setWebViewFrame(_ frame: CGRect) {
        print("Setting the WebView's frame to \(NSStringFromCGRect(frame))")
        webView.frame = frame
    }
    
    func clearCache() {
        if #available(iOS 9.0, *) {
            //let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: date as Date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("can't clear cache")
            }
            URLCache.shared.removeAllCachedResponses()
        }
    }
    
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
    
    func canGoBack() -> Bool {
        return webView.canGoBack
    }
    
    @objc func goBack() {
        if canGoBack() {
            webView.goBack()
            updateUrlTextField(url: (webView?.url?.absoluteString)!)
        }
    }
    
    func canGoForward() -> Bool {
        return webView.canGoForward
    }
    
    @objc func goForward() {
        if canGoForward() {
            webView.goForward()
            updateUrlTextField(url: (webView?.url?.absoluteString)!)
        }
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
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url
        
        if url != nil && (navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .backForward) {
            currentURL = url
            updateUrlTextField(url: (url?.absoluteString)!)
        }
        
        decisionHandler(.allow)
    }
    
//    func webView(_ webView: WKWebView,
//                 decidePolicyFor navigationResponse: WKNavigationResponse,
//                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//        let mimeType = navigationResponse.response.mimeType
//        if mimeType != nil && !mimeType!.starts(with: "text/") {
//            download(url: webView.url)
//            decisionHandler(.cancel)
//            return
//        }
//        decisionHandler(.allow)
//    }
//
//    func download (url: URL?) {
//        let filename = url?.lastPathComponent
//
//        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let fileURL = documentsURL.appendingPathComponent(filename!)
//
//            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//        }
//
//        Alamofire.download((url?.absoluteString)!, to: destination).downloadProgress { progress in
//            print("Download Progress: \(progress.fractionCompleted)")
//            }.response { response in
//                if response.error == nil, let path = response.destinationURL?.path {
//                    UIAlertView(title: nil, message: "File saved to " + path, delegate: nil, cancelButtonTitle: nil).show()
//                }
//                else {
//                   UIAlertView(title: nil, message: "Cannot save " + filename!, delegate: nil, cancelButtonTitle: nil).show()
//                }
//            }
//    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // loading url, start spinner, update back/forward
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward

        if (browserOptions?.spinner)! {
            spinner.startAnimating()
        }
        
        return (navigationDelegate?.webViewDidStartLoad(webView))!
    }
    
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
