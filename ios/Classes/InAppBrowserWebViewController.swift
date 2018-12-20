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

// the message needs to be concatenated with '' in order to have the same behavior like on Android
let consoleLogJS = """
(function() {
    var oldLogs = {
        'consoleLog': console.log,
        'consoleDebug': console.debug,
        'consoleError': console.error,
        'consoleInfo': console.info,
        'consoleWarn': console.warn
    };

    for (var k in oldLogs) {
        (function(oldLog) {
            console[oldLog.replace('console', '').toLowerCase()] = function() {
                var message = '';
                for (var i in arguments) {
                    if (message == '') {
                        message += arguments[i];
                    }
                    else {
                        message += ' ' + arguments[i];
                    }
                }
                window.webkit.messageHandlers[oldLog].postMessage(message);
            }
        })(k);
    }
})();
"""

let resourceObserverJS = """
(function() {
    var observer = new PerformanceObserver(function(list) {
        list.getEntries().forEach(function(entry) {
            window.webkit.messageHandlers['resourceLoaded'].postMessage(JSON.stringify(entry));
        });
    });
    observer.observe({entryTypes: ['resource', 'mark', 'measure']});
})();
"""

let JAVASCRIPT_BRIDGE_NAME = "flutter_inappbrowser"

let javaScriptBridgeJS = """
window.\(JAVASCRIPT_BRIDGE_NAME) = {};
window.\(JAVASCRIPT_BRIDGE_NAME).callHandler = function(handlerName, ...args) {
    window.webkit.messageHandlers['callHandler'].postMessage( {'handlerName': handlerName, 'args': JSON.stringify(args)} );
}
"""

func currentTimeInMilliSeconds() -> Int64 {
    let currentDate = Date()
    let since1970 = currentDate.timeIntervalSince1970
    return Int64(since1970 * 1000)
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

//extension WKWebView{
//
//    var keyboardDisplayRequiresUserAction: Bool? {
//        get {
//            return self.keyboardDisplayRequiresUserAction
//        }
//        set {
//            self.setKeyboardRequiresUserInteraction(newValue ?? true)
//        }
//    }
//
//    func setKeyboardRequiresUserInteraction( _ value: Bool) {
//
//        guard
//            let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
//                print("Cannot find the WKContentView class")
//                return
//        }
//
//        let olderSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
//        let newerSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
//
//        if let method = class_getInstanceMethod(WKContentViewClass, olderSelector) {
//
//            let originalImp: IMP = method_getImplementation(method)
//            let original: OlderClosureType = unsafeBitCast(originalImp, to: OlderClosureType.self)
//            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3) in
//                original(me, olderSelector, arg0, !value, arg2, arg3)
//            }
//            let imp: IMP = imp_implementationWithBlock(block)
//            method_setImplementation(method, imp)
//        }
//
//        if let method = class_getInstanceMethod(WKContentViewClass, newerSelector) {
//
//            let originalImp: IMP = method_getImplementation(method)
//            let original: NewerClosureType = unsafeBitCast(originalImp, to: NewerClosureType.self)
//            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3, arg4) in
//                original(me, newerSelector, arg0, !value, arg2, arg3, arg4)
//            }
//            let imp: IMP = imp_implementationWithBlock(block)
//            method_setImplementation(method, imp)
//        }
//
//    }
//
//}

class InAppWebView_IBWrapper: InAppWebView {
    required convenience init(coder: NSCoder) {
        let config = WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config, IABController: nil, IAWController: nil)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

class InAppBrowserWebViewController: UIViewController, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate, UITextFieldDelegate, WKScriptMessageHandler {
    
    @IBOutlet var webView: InAppWebView_IBWrapper!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var reloadButton: UIBarButtonItem!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var toolbarTop: UIView!
    @IBOutlet var toolbarBottom: UIToolbar!
    @IBOutlet var urlField: UITextField!
    
    @IBOutlet var toolbarTop_BottomToWebViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var toolbarBottom_TopToWebViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var webView_BottomFullScreenConstraint: NSLayoutConstraint!
    @IBOutlet var webView_TopFullScreenConstraint: NSLayoutConstraint!
    
    weak var navigationDelegate: SwiftFlutterPlugin?
    var currentURL: URL?
    var tmpWindow: UIWindow?
    var browserOptions: InAppBrowserOptions?
    var webViewOptions: InAppWebViewOptions?
    var initHeaders: [String: String]?
    var initData: String?
    var initMimeType: String?
    var initEncoding: String?
    var initBaseUrl: String?
    var isHidden = false
    var uuid: String = ""
    var WKNavigationMap: [String: [String: Any]] = [:]
    var startPageTime: Int64 = 0
    var viewPrepared = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.webView.IABController = self
        if !viewPrepared {
            prepareConstraints()
            prepareWebView()
        }
        viewPrepared = true
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
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
        
        if self.initData == nil {
            loadUrl(url: self.currentURL!, headers: self.initHeaders)
        }
        else {
            loadData(data: initData!, mimeType: initMimeType!, encoding: initEncoding!, baseUrl: initBaseUrl!)
        }
        
        navigationDelegate?.onBrowserCreated(uuid: uuid, webView: webView)
    }
    
    // Prevent crashes on closing windows
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.uiDelegate = nil
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func prepareConstraints () {
        webView_BottomFullScreenConstraint = NSLayoutConstraint(item: self.webView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        webView_TopFullScreenConstraint = NSLayoutConstraint(item: self.webView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
    }
    
    func prepareWebView() {
        //UIApplication.shared.statusBarStyle = preferredStatusBarStyle
        
        self.webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
        
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
            self.toolbarTop.isHidden = true
            self.toolbarTop_BottomToWebViewTopConstraint.isActive = false
            self.webView_TopFullScreenConstraint.isActive = true
        }
        
        if (browserOptions?.toolbarBottom)! {
            if browserOptions?.toolbarBottomBackgroundColor != "" {
                self.toolbarBottom.backgroundColor = color(fromHexString: (browserOptions?.toolbarBottomBackgroundColor)!)
            }
            self.toolbarBottom.isTranslucent = (browserOptions?.toolbarBottomTranslucent)!
        }
        else {
            self.toolbarBottom.isHidden = true
            self.toolbarBottom_TopToWebViewBottomConstraint.isActive = false
            self.webView_BottomFullScreenConstraint.isActive = true
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
        if (webViewOptions?.disallowOverScroll)! {
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
        
        if (webViewOptions?.enableViewportScale)! {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            self.webView.configuration.userContentController.addUserScript(userScript)
        }
        
        // Prevents long press on links that cause WKWebView exit
        let jscriptWebkitTouchCallout = WKUserScript(source: "document.body.style.webkitTouchCallout='none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.webView.configuration.userContentController.addUserScript(jscriptWebkitTouchCallout)
        
        
        let consoleLogJSScript = WKUserScript(source: consoleLogJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webView.configuration.userContentController.addUserScript(consoleLogJSScript)
        self.webView.configuration.userContentController.add(self, name: "consoleLog")
        self.webView.configuration.userContentController.add(self, name: "consoleDebug")
        self.webView.configuration.userContentController.add(self, name: "consoleError")
        self.webView.configuration.userContentController.add(self, name: "consoleInfo")
        self.webView.configuration.userContentController.add(self, name: "consoleWarn")
        
        let javaScriptBridgeJSScript = WKUserScript(source: javaScriptBridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webView.configuration.userContentController.addUserScript(javaScriptBridgeJSScript)
        self.webView.configuration.userContentController.add(self, name: "callHandler")
        
        let resourceObserverJSScript = WKUserScript(source: resourceObserverJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webView.configuration.userContentController.addUserScript(resourceObserverJSScript)
        self.webView.configuration.userContentController.add(self, name: "resourceLoaded")
        
        if #available(iOS 10.0, *) {
            self.webView.configuration.mediaTypesRequiringUserActionForPlayback = ((webViewOptions?.mediaPlaybackRequiresUserGesture)!) ? .all : []
        } else {
            // Fallback on earlier versions
            self.webView.configuration.mediaPlaybackRequiresUserAction = (webViewOptions?.mediaPlaybackRequiresUserGesture)!
        }
        
        
        self.webView.configuration.allowsInlineMediaPlayback = (webViewOptions?.allowsInlineMediaPlayback)!
        
        //self.webView.keyboardDisplayRequiresUserAction = browserOptions?.keyboardDisplayRequiresUserAction
        
        self.webView.configuration.suppressesIncrementalRendering = (webViewOptions?.suppressesIncrementalRendering)!
        self.webView.allowsBackForwardNavigationGestures = (webViewOptions?.allowsBackForwardNavigationGestures)!
        if #available(iOS 9.0, *) {
            self.webView.allowsLinkPreview = (webViewOptions?.allowsLinkPreview)!
        }
        
        if #available(iOS 10.0, *) {
            self.webView.configuration.ignoresViewportScaleLimits = (webViewOptions?.ignoresViewportScaleLimits)!
        }
        
        self.webView.configuration.allowsInlineMediaPlayback = (webViewOptions?.allowsInlineMediaPlayback)!
        
        if #available(iOS 9.0, *) {
            self.webView.configuration.allowsPictureInPictureMediaPlayback = (webViewOptions?.allowsPictureInPictureMediaPlayback)!
        }
        
        self.webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = (webViewOptions?.javaScriptCanOpenWindowsAutomatically)!
        
        self.webView.configuration.preferences.javaScriptEnabled = (webViewOptions?.javaScriptEnabled)!
        
        if ((webViewOptions?.userAgent)! != "") {
            if #available(iOS 9.0, *) {
                self.webView.customUserAgent = (webViewOptions?.userAgent)!
            }
        }
        
        if (webViewOptions?.clearCache)! {
            clearCache()
        }
        
    }
    
    func loadUrl(url: URL, headers: [String: String]?) {
        var request = URLRequest(url: url)
        currentURL = url
        updateUrlTextField(url: (currentURL?.absoluteString)!)
        
        if let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            for (key, value) in headers! {
                mutableRequest.setValue(value, forHTTPHeaderField: key)
            }
            request = mutableRequest as URLRequest
        }
        
        webView.load(request)
    }
    
    func loadData(data: String, mimeType: String, encoding: String, baseUrl: String) {
        let url = URL(string: baseUrl)!
        currentURL = url
        if #available(iOS 9.0, *) {
            webView.load(data.data(using: .utf8)!, mimeType: mimeType, characterEncodingName: encoding, baseURL: url)
        } else {
            webView.loadHTMLString(data, baseURL: url)
        }
    }
    
    func postUrl(url: URL, postData: Data, result: @escaping FlutterResult) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
            var returnString = ""
            if data != nil {
                returnString = String(data: data!, encoding: .utf8) ?? ""
            }
            DispatchQueue.main.async(execute: {() -> Void in
                self.webView.loadHTMLString(returnString, baseURL: url)
                result(true)
            })
        }
        task.resume()
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
        //currentURL = nil
        
        weak var weakSelf = self
        
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            if (weakSelf?.responds(to: #selector(getter: self.presentingViewController)))! {
                weakSelf?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                    self.tmpWindow?.windowLevel = 0.0
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                    if (self.navigationDelegate != nil) {
                        self.navigationDelegate?.browserExit(uuid: self.uuid)
                    }
                })
            }
            else {
                weakSelf?.parent?.dismiss(animated: true, completion: {() -> Void in
                    self.tmpWindow?.windowLevel = 0.0
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                    if (self.navigationDelegate != nil) {
                        self.navigationDelegate?.browserExit(uuid: self.uuid)
                    }
                })
            }
        })
    }
    
    @objc func goBack() {
        if canGoBack() {
            webView.goBack()
            updateUrlTextField(url: (webView?.url?.absoluteString)!)
        }
    }
    
    func canGoBack() -> Bool {
        return webView.canGoBack
    }
    
    @objc func goForward() {
        if canGoForward() {
            webView.goForward()
            updateUrlTextField(url: (webView?.url?.absoluteString)!)
        }
    }
    
    func canGoForward() -> Bool {
        return webView.canGoForward
    }
    
    @objc func goBackOrForward(steps: Int) {
        webView.goBackOrForward(steps: steps)
        updateUrlTextField(url: (webView?.url?.absoluteString)!)
    }
    
    func canGoBackOrForward(steps: Int) -> Bool {
        return webView.canGoBackOrForward(steps: steps)
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
        
        if let url = navigationAction.request.url {
            
            if url.absoluteString != self.currentURL?.absoluteString && (webViewOptions?.useOnLoadResource)! {
                WKNavigationMap[url.absoluteString] = [
                    "startTime": currentTimeInMilliSeconds(),
                    "request": navigationAction.request
                ]
            }
            
            if navigationAction.navigationType == .linkActivated && (webViewOptions?.useShouldOverrideUrlLoading)! {
                if navigationDelegate != nil {
                    navigationDelegate?.shouldOverrideUrlLoading(uuid: self.uuid, webView: webView, url: url)
                }
                decisionHandler(.cancel)
                return
            }
            
            if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .backForward {
                currentURL = url
                updateUrlTextField(url: (url.absoluteString))
            }
            
        }
        
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if (webViewOptions?.useOnLoadResource)! {
            if let url = navigationResponse.response.url {
                if WKNavigationMap[url.absoluteString] != nil {
                    let startResourceTime: Int64 = (WKNavigationMap[url.absoluteString]!["startTime"] as! Int64)
                    let startTime: Int64 = startResourceTime - startPageTime;
                    let duration: Int64 = currentTimeInMilliSeconds() - startResourceTime;
                    self.didReceiveResourceResponse(navigationResponse.response, fromRequest: WKNavigationMap[url.absoluteString]!["request"] as? URLRequest, withData: Data(), startTime: startTime, duration: duration)
                }
            }
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
        
        self.startPageTime = currentTimeInMilliSeconds()
        
        // loading url, start spinner, update back/forward
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward

        if (browserOptions?.spinner)! {
            spinner.startAnimating()
        }
        
        if navigationDelegate != nil {
            navigationDelegate?.onLoadStart(uuid: self.uuid, webView: webView)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.WKNavigationMap = [:]
        // update url, stop spinner, update back/forward
        currentURL = webView.url
        updateUrlTextField(url: (currentURL?.absoluteString)!)
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        spinner.stopAnimating()
        
        if navigationDelegate != nil {
            navigationDelegate?.onLoadStop(uuid: self.uuid, webView: webView)
        }
    }
    
    func webView(_ view: WKWebView,
                      didFailProvisionalNavigation navigation: WKNavigation!,
                      withError error: Error) {
        webView(view, didFail: navigation, withError: error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        spinner.stopAnimating()
        
        if navigationDelegate != nil {
            navigationDelegate?.onLoadError(uuid: self.uuid, webView: webView, error: error)
        }
    }
    
    func didReceiveResourceResponse(_ response: URLResponse, fromRequest request: URLRequest?, withData data: Data, startTime: Int64, duration: Int64) {
        if navigationDelegate != nil {
            navigationDelegate?.onLoadResource(uuid: self.uuid, webView: webView, response: response, fromRequest: request, withData: data, startTime: startTime, duration: duration)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if navigationDelegate != nil {
            let x = Int(scrollView.contentOffset.x / scrollView.contentScaleFactor)
            let y = Int(scrollView.contentOffset.y / scrollView.contentScaleFactor)
            navigationDelegate?.onScrollChanged(uuid: self.uuid, webView: webView, x: x, y: y)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name.starts(with: "console") {
            var messageLevel = "LOG"
            switch (message.name) {
                case "consoleLog":
                    messageLevel = "LOG"
                    break;
                case "consoleDebug":
                    // on Android, console.debug is TIP
                    messageLevel = "TIP"
                    break;
                case "consoleError":
                    messageLevel = "ERROR"
                    break;
                case "consoleInfo":
                    // on Android, console.info is LOG
                    messageLevel = "LOG"
                    break;
                case "consoleWarn":
                    messageLevel = "WARNING"
                    break;
                default:
                    messageLevel = "LOG"
                    break;
            }
            if navigationDelegate != nil {
                navigationDelegate?.onConsoleMessage(uuid: self.uuid, sourceURL: "", lineNumber: 1, message: message.body as! String, messageLevel: messageLevel)
            }
        }
        else if message.name == "resourceLoaded" && (webViewOptions?.useOnLoadResource)! {
            if let resource = convertToDictionary(text: message.body as! String) {
                let url = URL(string: resource["name"] as! String)!
                if !UIApplication.shared.canOpenURL(url) {
                    return
                }
                let startTime = Int64(resource["startTime"] as! Double)
                let duration = Int64(resource["duration"] as! Double)
                var urlRequest = URLRequest(url: url)
                urlRequest.allHTTPHeaderFields = [:]
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.dataTask(with: urlRequest) { (data, response, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    var withData = data
                    if withData == nil {
                        withData = Data()
                    }
                    self.didReceiveResourceResponse(response!, fromRequest: urlRequest, withData: withData!, startTime: startTime, duration: duration)
                }
                task.resume()
            }
        }
        else if message.name == "callHandler" {
            let body = message.body as! [String: Any]
            let handlerName = body["handlerName"] as! String
            let args = body["args"] as! String
            if navigationDelegate != nil {
                self.navigationDelegate?.onCallJsHandler(uuid: self.uuid, webView: webView, handlerName: handlerName, args: args)
            }
        }
    }
    
    func takeScreenshot (completionHandler: @escaping (_ screenshot: Data?) -> Void) {
        if #available(iOS 11.0, *) {
            self.webView.takeSnapshot(with: nil, completionHandler: {(image, error) -> Void in
                var imageData: Data? = nil
                if let screenshot = image {
                    imageData = UIImagePNGRepresentation(screenshot)!
                }
                completionHandler(imageData)
            })
        } else {
            completionHandler(nil)
        }
    }

    func setOptions(newOptions: InAppBrowserOptions, newOptionsMap: [String: Any]) {
        
        let newInAppWebViewOptions = InAppWebViewOptions()
        newInAppWebViewOptions.parse(options: newOptionsMap)
        
        if newOptionsMap["hidden"] != nil && browserOptions?.hidden != newOptions.hidden {
            if newOptions.hidden {
                self.navigationDelegate?.hide(uuid: self.uuid)
            }
            else {
                self.navigationDelegate?.show(uuid: self.uuid)
            }
        }

        if newOptionsMap["hideUrlBar"] != nil && browserOptions?.hideUrlBar != newOptions.hideUrlBar {
            self.urlField.isHidden = newOptions.hideUrlBar
            self.urlField.isEnabled = !newOptions.hideUrlBar
        }
        
        if newOptionsMap["toolbarTop"] != nil && browserOptions?.toolbarTop != newOptions.toolbarTop {
            self.webView_TopFullScreenConstraint.isActive = !newOptions.toolbarTop
            self.toolbarTop.isHidden = !newOptions.toolbarTop
            self.toolbarTop_BottomToWebViewTopConstraint.isActive = newOptions.toolbarTop
        }
        
        if newOptionsMap["toolbarTopBackgroundColor"] != nil && browserOptions?.toolbarTopBackgroundColor != newOptions.toolbarTopBackgroundColor && newOptions.toolbarTopBackgroundColor != "" {
            self.toolbarTop.backgroundColor = color(fromHexString: newOptions.toolbarTopBackgroundColor)
        }
        
        if newOptionsMap["toolbarBottom"] != nil && browserOptions?.toolbarBottom != newOptions.toolbarBottom {
            self.webView_BottomFullScreenConstraint.isActive = !newOptions.toolbarBottom
            self.toolbarBottom.isHidden = !newOptions.toolbarBottom
            self.toolbarBottom_TopToWebViewBottomConstraint.isActive = newOptions.toolbarBottom
        }
        
        if newOptionsMap["toolbarBottomBackgroundColor"] != nil && browserOptions?.toolbarBottomBackgroundColor != newOptions.toolbarBottomBackgroundColor && newOptions.toolbarBottomBackgroundColor != "" {
            self.toolbarBottom.backgroundColor = color(fromHexString: newOptions.toolbarBottomBackgroundColor)
        }
        
        if newOptionsMap["toolbarBottomTranslucent"] != nil && browserOptions?.toolbarBottomTranslucent != newOptions.toolbarBottomTranslucent {
            self.toolbarBottom.isTranslucent = newOptions.toolbarBottomTranslucent
        }
        
        if newOptionsMap["closeButtonCaption"] != nil && browserOptions?.closeButtonCaption != newOptions.closeButtonCaption && newOptions.closeButtonCaption != "" {
            closeButton.setTitle(newOptions.closeButtonCaption, for: .normal)
        }
        
        if newOptionsMap["closeButtonColor"] != nil && browserOptions?.closeButtonColor != newOptions.closeButtonColor && newOptions.closeButtonColor != "" {
            closeButton.tintColor = color(fromHexString: newOptions.closeButtonColor)
        }
        
        if newOptionsMap["presentationStyle"] != nil && browserOptions?.presentationStyle != newOptions.presentationStyle {
            self.modalPresentationStyle = UIModalPresentationStyle(rawValue: newOptions.presentationStyle)!
        }
        
        if newOptionsMap["transitionStyle"] != nil && browserOptions?.transitionStyle != newOptions.transitionStyle {
            self.modalTransitionStyle = UIModalTransitionStyle(rawValue: newOptions.transitionStyle)!
        }

        if newOptionsMap["disallowOverScroll"] != nil && webViewOptions?.disallowOverScroll != newInAppWebViewOptions.disallowOverScroll {
            if self.webView.responds(to: #selector(getter: self.webView.scrollView)) {
                self.webView.scrollView.bounces = !newInAppWebViewOptions.disallowOverScroll
            }
            else {
                for subview: UIView in self.webView.subviews {
                    if subview is UIScrollView {
                        (subview as! UIScrollView).bounces = !newInAppWebViewOptions.disallowOverScroll
                    }
                }
            }
        }

        if newOptionsMap["enableViewportScale"] != nil && webViewOptions?.enableViewportScale != newInAppWebViewOptions.enableViewportScale && newInAppWebViewOptions.enableViewportScale {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            self.webView.evaluateJavaScript(jscript, completionHandler: nil)
        }
        
        if newOptionsMap["mediaPlaybackRequiresUserGesture"] != nil && webViewOptions?.mediaPlaybackRequiresUserGesture != newInAppWebViewOptions.mediaPlaybackRequiresUserGesture {
            if #available(iOS 10.0, *) {
                self.webView.configuration.mediaTypesRequiringUserActionForPlayback = (newInAppWebViewOptions.mediaPlaybackRequiresUserGesture) ? .all : []
            } else {
                // Fallback on earlier versions
                self.webView.configuration.mediaPlaybackRequiresUserAction = newInAppWebViewOptions.mediaPlaybackRequiresUserGesture
            }
        }

        if newOptionsMap["allowsInlineMediaPlayback"] != nil && webViewOptions?.allowsInlineMediaPlayback != newInAppWebViewOptions.allowsInlineMediaPlayback {
            self.webView.configuration.allowsInlineMediaPlayback = newInAppWebViewOptions.allowsInlineMediaPlayback
        }
        
//        if newOptionsMap["keyboardDisplayRequiresUserAction"] != nil && browserOptions?.keyboardDisplayRequiresUserAction != newOptions.keyboardDisplayRequiresUserAction {
//            self.webView.keyboardDisplayRequiresUserAction = newOptions.keyboardDisplayRequiresUserAction
//        }
        
        if newOptionsMap["suppressesIncrementalRendering"] != nil && webViewOptions?.suppressesIncrementalRendering != newInAppWebViewOptions.suppressesIncrementalRendering {
            self.webView.configuration.suppressesIncrementalRendering = newInAppWebViewOptions.suppressesIncrementalRendering
        }
        
        if newOptionsMap["allowsBackForwardNavigationGestures"] != nil && webViewOptions?.allowsBackForwardNavigationGestures != newInAppWebViewOptions.allowsBackForwardNavigationGestures {
            self.webView.allowsBackForwardNavigationGestures = newInAppWebViewOptions.allowsBackForwardNavigationGestures
        }
        
        if newOptionsMap["allowsLinkPreview"] != nil && webViewOptions?.allowsLinkPreview != newInAppWebViewOptions.allowsLinkPreview {
            if #available(iOS 9.0, *) {
                self.webView.allowsLinkPreview = newInAppWebViewOptions.allowsLinkPreview
            }
        }
        
        if newOptionsMap["ignoresViewportScaleLimits"] != nil && webViewOptions?.ignoresViewportScaleLimits != newInAppWebViewOptions.ignoresViewportScaleLimits {
            if #available(iOS 10.0, *) {
                self.webView.configuration.ignoresViewportScaleLimits = newInAppWebViewOptions.ignoresViewportScaleLimits
            }
        }
        
        if newOptionsMap["allowsInlineMediaPlayback"] != nil && webViewOptions?.allowsInlineMediaPlayback != newInAppWebViewOptions.allowsInlineMediaPlayback {
            self.webView.configuration.allowsInlineMediaPlayback = newInAppWebViewOptions.allowsInlineMediaPlayback
        }
        
        if newOptionsMap["allowsPictureInPictureMediaPlayback"] != nil && webViewOptions?.allowsPictureInPictureMediaPlayback != newInAppWebViewOptions.allowsPictureInPictureMediaPlayback {
            if #available(iOS 9.0, *) {
                self.webView.configuration.allowsPictureInPictureMediaPlayback = newInAppWebViewOptions.allowsPictureInPictureMediaPlayback
            }
        }
        
        if newOptionsMap["javaScriptCanOpenWindowsAutomatically"] != nil && webViewOptions?.javaScriptCanOpenWindowsAutomatically != newInAppWebViewOptions.javaScriptCanOpenWindowsAutomatically {
            self.webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = newInAppWebViewOptions.javaScriptCanOpenWindowsAutomatically
        }
        
        if newOptionsMap["javaScriptEnabled"] != nil && webViewOptions?.javaScriptEnabled != newInAppWebViewOptions.javaScriptEnabled {
            self.webView.configuration.preferences.javaScriptEnabled = newInAppWebViewOptions.javaScriptEnabled
        }

        if newOptionsMap["userAgent"] != nil && webViewOptions?.userAgent != newInAppWebViewOptions.userAgent && (newInAppWebViewOptions.userAgent != "") {
            if #available(iOS 9.0, *) {
                self.webView.customUserAgent = newInAppWebViewOptions.userAgent
            }
        }

        if newOptionsMap["clearCache"] != nil && newInAppWebViewOptions.clearCache {
            clearCache()
        }
        
        self.browserOptions = newOptions
        self.webViewOptions = newInAppWebViewOptions
    }
    
    func getOptions() -> [String: Any]? {
        if (self.browserOptions == nil || self.webViewOptions == nil) {
            return nil
        }
        var optionsMap = self.browserOptions!.getHashMap()
        optionsMap.merge(self.webViewOptions!.getHashMap(), uniquingKeysWith: { (current, _) in current })
        return optionsMap
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Int(webView.estimatedProgress * 100)
            self.navigationDelegate?.onProgressChanged(uuid: self.uuid, webView: self.webView, progress: progress)
        }
    }
    
    func getCopyBackForwardList() -> [String: Any] {
        let currentList = self.webView.backForwardList
        let currentIndex = currentList.backList.count
        var completeList = currentList.backList
        if currentList.currentItem != nil {
            completeList.append(currentList.currentItem!)
        }
        completeList.append(contentsOf: currentList.forwardList)
        
        var history: [[String: String]] = []
        
        for historyItem in completeList {
            var historyItemMap: [String: String] = [:]
            historyItemMap["originalUrl"] = historyItem.initialURL.absoluteString
            historyItemMap["title"] = historyItem.title
            historyItemMap["url"] = historyItem.url.absoluteString
            history.append(historyItemMap)
        }
        
        var result: [String: Any] = [:]
        result["history"] = history
        result["currentIndex"] = currentIndex
        
        return result;
    }

}
