//
//  InAppBrowserWebViewController.swift
//  flutter_inappwebview
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

public class InAppWebView_IBWrapper: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

public class InAppBrowserWebViewController: UIViewController, FlutterPlugin, UIScrollViewDelegate, WKUIDelegate, UITextFieldDelegate {
    
    @IBOutlet var containerWebView: InAppWebView_IBWrapper!
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
    @IBOutlet var containerWebView_BottomFullScreenConstraint: NSLayoutConstraint!
    @IBOutlet var containerWebView_TopFullScreenConstraint: NSLayoutConstraint!
    @IBOutlet var webView_BottomFullScreenConstraint: NSLayoutConstraint!
    @IBOutlet var webView_TopFullScreenConstraint: NSLayoutConstraint!
    
    var uuid: String = ""
    var windowId: Int64?
    var webView: InAppWebView!
    var channel: FlutterMethodChannel?
    var initURL: URL?
    var contextMenu: [String: Any]?
    var tmpWindow: UIWindow?
    var browserOptions: InAppBrowserOptions?
    var webViewOptions: InAppWebViewOptions?
    var initHeaders: [String: String]?
    var initData: String?
    var initMimeType: String?
    var initEncoding: String?
    var initBaseUrl: String?
    var isHidden = false
    var viewPrepared = false
    var previousStatusBarStyle = -1
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    public func prepareMethodChannel() {
        channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser_" + uuid, binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        SwiftFlutterPlugin.instance!.registrar!.addMethodCallDelegate(self, channel: channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary

        switch call.method {
            case "getUrl":
                result(webView.url?.absoluteString)
                break
            case "getTitle":
                result(webView.title)
                break
            case "getProgress":
                let progress = Int(webView.estimatedProgress * 100)
                result(progress)
                break
            case "loadUrl":
                 let url = arguments!["url"] as! String
               let headers = arguments!["headers"] as? [String: String]
               let absoluteUrl = URL(string: url)!.absoluteURL
               webView.loadUrl(url: absoluteUrl, headers: headers)
                result(true)
                break
            case "loadData":
                let data = arguments!["data"] as! String
                let mimeType = arguments!["mimeType"] as! String
                let encoding = arguments!["encoding"] as! String
                let baseUrl = arguments!["baseUrl"] as! String
                webView.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
                result(true)
                break
            case "postUrl":
                let url = arguments!["url"] as! String
                let postData = arguments!["postData"] as! FlutterStandardTypedData
                let absoluteUrl = URL(string: url)!.absoluteURL
                webView.postUrl(url: absoluteUrl, postData: postData.data, completionHandler: { () -> Void in
                    result(true)
                })
                break
            case "loadFile":
                let url = arguments!["url"] as! String
                let headers = arguments!["headers"] as? [String: String]
                do {
                    try webView.loadFile(url: url, headers: headers)
                    result(true)
                }
                catch let error as NSError {
                    dump(error)
                    result(FlutterError(code: "InAppBrowserWebViewController", message: error.localizedDescription, details: nil))
                }
                break
            case "close":
                close()
                result(true)
                break
            case "show":
                show()
                result(true)
                break
            case "hide":
                hide()
                result(true)
                break
            case "reload":
                webView.reload()
                result(true)
                break
            case "goBack":
                webView.goBack()
                result(true)
                break
            case "canGoBack":
                result(webView.canGoBack)
                break
            case "goForward":
                webView.goForward()
                result(true)
                break
            case "canGoForward":
                result(webView.canGoForward)
                break
            case "goBackOrForward":
                let steps = arguments!["steps"] as! Int
                webView.goBackOrForward(steps: steps)
                result(true)
                break
            case "canGoBackOrForward":
                let steps = arguments!["steps"] as! Int
                result(webView.canGoBackOrForward(steps: steps))
                break
            case "isLoading":
                result(webView.isLoading == true)
                break
            case "stopLoading":
                webView.stopLoading()
                result(true)
                break
            case "isHidden":
                result(isHidden == true)
                break
            case "evaluateJavascript":
                let source = arguments!["source"] as! String
                webView.evaluateJavascript(source: source, result: result)
                break
            case "injectJavascriptFileFromUrl":
                let urlFile = arguments!["urlFile"] as! String
                webView.injectJavascriptFileFromUrl(urlFile: urlFile)
                result(true)
                break
            case "injectCSSCode":
                let source = arguments!["source"] as! String
                webView.injectCSSCode(source: source)
                result(true)
                break
            case "injectCSSFileFromUrl":
                let urlFile = arguments!["urlFile"] as! String
                webView.injectCSSFileFromUrl(urlFile: urlFile)
                result(true)
                break
            case "takeScreenshot":
                webView.takeScreenshot(completionHandler: { (screenshot) -> Void in
                    result(screenshot)
                })
                break
            case "setOptions":
                let inAppBrowserOptions = InAppBrowserOptions()
                let inAppBrowserOptionsMap = arguments!["options"] as! [String: Any]
                let _ = inAppBrowserOptions.parse(options: inAppBrowserOptionsMap)
                self.setOptions(newOptions: inAppBrowserOptions, newOptionsMap: inAppBrowserOptionsMap)
                result(true)
                break
            case "getOptions":
                result(getOptions())
                break
            case "getCopyBackForwardList":
                result(webView.getCopyBackForwardList())
                break
            case "findAllAsync":
                let find = arguments!["find"] as! String
                webView.findAllAsync(find: find, completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "InAppBrowserWebViewController", message: error?.localizedDescription, details: nil))
                        return
                    }
                    result(true)
                })
                break
            case "findNext":
                let forward = arguments!["forward"] as! Bool
                webView.findNext(forward: forward, completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "InAppBrowserWebViewController", message: error?.localizedDescription, details: nil))
                        return
                    }
                    result(true)
                })
                break
            case "clearMatches":
                webView.clearMatches(completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "InAppBrowserWebViewController", message: error?.localizedDescription, details: nil))
                        return
                    }
                    result(true)
                })
                break
            case "clearCache":
                webView.clearCache()
                result(true)
                break
            case "scrollTo":
                let x = arguments!["x"] as! Int
                let y = arguments!["y"] as! Int
                let animated = arguments!["animated"] as! Bool
                webView.scrollTo(x: x, y: y, animated: animated)
                result(true)
                break
            case "scrollBy":
                let x = arguments!["x"] as! Int
                let y = arguments!["y"] as! Int
                let animated = arguments!["animated"] as! Bool
                webView.scrollTo(x: x, y: y, animated: animated)
                result(true)
                break
            case "pauseTimers":
               webView.pauseTimers()
               result(true)
               break
            case "resumeTimers":
                webView.resumeTimers()
                result(true)
                break
            case "printCurrentPage":
                webView.printCurrentPage(printCompletionHandler: {(completed, error) in
                    if !completed, let _ = error {
                        result(false)
                        return
                    }
                    result(true)
                })
                break
            case "getContentHeight":
                result(webView.getContentHeight())
                break
            case "reloadFromOrigin":
                webView.reloadFromOrigin()
                result(true)
                break
            case "getScale":
                result(webView.getScale())
                break
            case "hasOnlySecureContent":
                result(webView.hasOnlySecureContent)
                break
            case "getSelectedText":
                if webView != nil {
                    webView!.getSelectedText { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                        }
                        result(value)
                    }
                }
                else {
                    result(nil)
                }
                break
            case "getHitTestResult":
                if webView != nil {
                    webView!.getHitTestResult { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                        }
                        result(value)
                    }
                }
                else {
                    result(nil)
                }
                break
            case "clearFocus":
                if webView != nil {
                    webView!.clearFocus()
                    result(true)
                } else {
                    result(false)
                }
                
                break
            case "setContextMenu":
                if webView != nil {
                    let contextMenu = arguments!["contextMenu"] as? [String: Any]
                    webView!.contextMenu = contextMenu
                    result(true)
                } else {
                    result(false)
                }
                break
            case "requestFocusNodeHref":
                if webView != nil {
                    webView!.requestFocusNodeHref { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            result(nil)
                            return
                        }
                        result(value)
                    }
                } else {
                    result(false)
                }
                break
            case "requestImageRef":
                if webView != nil {
                    webView!.requestImageRef { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            result(nil)
                            return
                        }
                        result(value)
                    }
                } else {
                    result(false)
                }
                break
            case "getScrollX":
                if webView != nil {
                    result(Int(webView!.scrollView.contentOffset.x))
                } else {
                    result(false)
                }
                break
            case "getScrollY":
                if webView != nil {
                    result(Int(webView!.scrollView.contentOffset.y))
                } else {
                    result(false)
                }
                break
            case "getCertificate":
                if webView != nil {
                    result(webView!.getCertificateMap())
                } else {
                    result(false)
                }
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if !viewPrepared {
            print(containerWebView)
            let preWebviewConfiguration = InAppWebView.preWKWebViewConfiguration(options: webViewOptions)
            if let wId = windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                self.webView = webViewTransport.webView
                self.webView.IABController = self
                self.webView.contextMenu = contextMenu
                self.webView.channel = channel!
            } else {
                self.webView = InAppWebView(frame: .zero,
                                            configuration: preWebviewConfiguration,
                                            IABController: self,
                                            contextMenu: contextMenu,
                                            channel: channel!)
            }
            self.containerWebView.addSubview(self.webView)
            prepareConstraints()
            prepareWebView()
            
            if let wId = windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                self.webView.load(webViewTransport.request)
            } else {
                if #available(iOS 11.0, *) {
                    if let contentBlockers = webView.options?.contentBlockers, contentBlockers.count > 0 {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: contentBlockers, options: [])
                            let blockRules = String(data: jsonData, encoding: String.Encoding.utf8)
                            WKContentRuleListStore.default().compileContentRuleList(
                                forIdentifier: "ContentBlockingRules",
                                encodedContentRuleList: blockRules) { (contentRuleList, error) in

                                    if let error = error {
                                        print(error.localizedDescription)
                                        return
                                    }

                                    let configuration = self.webView!.configuration
                                    configuration.userContentController.add(contentRuleList!)

                                    self.initLoad(initURL: self.initURL, initData: self.initData, initMimeType: self.initMimeType, initEncoding: self.initEncoding, initBaseUrl: self.initBaseUrl, initHeaders: self.initHeaders)

                                    self.onBrowserCreated()
                            }
                            return
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
                initLoad(initURL: initURL, initData: initData, initMimeType: initMimeType, initEncoding: initEncoding, initBaseUrl: initBaseUrl, initHeaders: initHeaders)
            }
            
            onBrowserCreated()
        }
        viewPrepared = true
        super.viewWillAppear(animated)
    }
    
    public func initLoad(initURL: URL?, initData: String?, initMimeType: String?, initEncoding: String?, initBaseUrl: String?, initHeaders: [String: String]?) {
        if self.initData == nil {
            loadUrl(url: self.initURL!, headers: self.initHeaders)
        }
        else {
            webView.loadData(data: initData!, mimeType: initMimeType!, encoding: initEncoding!, baseUrl: initBaseUrl!)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        urlField.delegate = self
        urlField.text = self.initURL?.absoluteString
        
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
    }
    
    // Prevent crashes on closing windows
    deinit {
        print("InAppBrowserWebViewController - dealloc")
    }
    
    public override func viewWillDisappear (_ animated: Bool) {
        dispose()
        super.viewWillDisappear(animated)
    }
    
    public func prepareConstraints () {
        containerWebView_BottomFullScreenConstraint = NSLayoutConstraint(item: self.containerWebView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        containerWebView_TopFullScreenConstraint = NSLayoutConstraint(item: self.containerWebView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: self.webView!, attribute: .height, relatedBy: .equal, toItem: containerWebView, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: self.webView!, attribute: .width, relatedBy: .equal, toItem: containerWebView, attribute: .width, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.webView!, attribute: .leftMargin, relatedBy: .equal, toItem: containerWebView, attribute: .leftMargin, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.webView!, attribute: .rightMargin, relatedBy: .equal, toItem: containerWebView, attribute: .rightMargin, multiplier: 1, constant: 0)
        let bottomContraint = NSLayoutConstraint(item: self.webView!, attribute: .bottomMargin, relatedBy: .equal, toItem: containerWebView, attribute: .bottomMargin, multiplier: 1, constant: 0)
        containerWebView.addConstraints([height, width, leftConstraint, rightConstraint, bottomContraint])
        
        webView_BottomFullScreenConstraint = NSLayoutConstraint(item: webView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.containerWebView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        webView_TopFullScreenConstraint = NSLayoutConstraint(item: webView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.containerWebView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
    }
    
    public func prepareWebView() {
        self.webView.options = webViewOptions
        self.webView.prepare()
        
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
            self.containerWebView_TopFullScreenConstraint.isActive = true
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
            self.containerWebView_BottomFullScreenConstraint.isActive = true
            self.webView_BottomFullScreenConstraint.isActive = true
        }
        
        if browserOptions?.closeButtonCaption != "" {
            closeButton.setTitle(browserOptions?.closeButtonCaption, for: .normal)
        }
        if browserOptions?.closeButtonColor != "" {
            closeButton.tintColor = color(fromHexString: (browserOptions?.closeButtonColor)!)
        }
    }
    
    public func prepareBeforeViewWillAppear() {
        self.modalPresentationStyle = UIModalPresentationStyle(rawValue: (browserOptions?.presentationStyle)!)!
        self.modalTransitionStyle = UIModalTransitionStyle(rawValue: (browserOptions?.transitionStyle)!)!
    }
    
    public func loadUrl(url: URL, headers: [String: String]?) {
        webView.loadUrl(url: url, headers: headers)
        updateUrlTextField(url: (webView.currentURL?.absoluteString)!)
    }
    
    // Load user requested url
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil && textField.text != "" {
            let url = textField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let request = URLRequest(url: URL(string: url!)!)
            webView.load(request)
        }
        else {
            updateUrlTextField(url: (webView.currentURL?.absoluteString)!)
        }
        return false
    }
    
    func setWebViewFrame(_ frame: CGRect) {
        print("Setting the WebView's frame to \(NSCoder.string(for: frame))")
        webView.frame = frame
    }
    
    public func show() {
        isHidden = false
        view.isHidden = false
        
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            let baseWindowLevel = UIApplication.shared.keyWindow?.windowLevel
            self.tmpWindow?.windowLevel = UIWindow.Level(baseWindowLevel!.rawValue + 1.0)
            self.tmpWindow?.makeKeyAndVisible()
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            self.tmpWindow?.rootViewController?.present(self, animated: true, completion: nil)
        })
    }

    public func hide() {
        isHidden = true
        
        // Run later to avoid the "took a long time" log message.
        DispatchQueue.main.async(execute: {() -> Void in
            self.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                self.tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                if self.previousStatusBarStyle != -1 {
                    UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: self.previousStatusBarStyle)!
                }
            })
        })
    }
    
    @objc public func reload () {
        webView.reload()
    }
    
    @objc public func share () {
        let vc = UIActivityViewController(activityItems: [webView.currentURL ?? ""], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    @objc public func close() {
        weak var weakSelf = self
        
        if (weakSelf?.responds(to: #selector(getter: self.presentingViewController)))! {
            weakSelf?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                
            })
        }
        else {
            weakSelf?.parent?.dismiss(animated: true, completion: {() -> Void in
                
            })
        }
    }
    
    @objc public func goBack() {
        if canGoBack() {
            webView.goBack()
            updateUrlTextField(url: (webView?.url?.absoluteString)!)
        }
    }
    
    public func canGoBack() -> Bool {
        return webView.canGoBack
    }
    
    @objc public func goForward() {
        if canGoForward() {
            webView.goForward()
            updateUrlTextField(url: (webView?.url?.absoluteString)!)
        }
    }
    
    public func canGoForward() -> Bool {
        return webView.canGoForward
    }
    
    @objc public func goBackOrForward(steps: Int) {
        webView.goBackOrForward(steps: steps)
        updateUrlTextField(url: (webView?.url?.absoluteString)!)
    }
    
    public func canGoBackOrForward(steps: Int) -> Bool {
        return webView.canGoBackOrForward(steps: steps)
    }
    
    public func updateUrlTextField(url: String) {
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

    public func setOptions(newOptions: InAppBrowserOptions, newOptionsMap: [String: Any]) {
        
        let newInAppWebViewOptions = InAppWebViewOptions()
        let _ = newInAppWebViewOptions.parse(options: newOptionsMap)
        self.webView.setOptions(newOptions: newInAppWebViewOptions, newOptionsMap: newOptionsMap)
        
        if newOptionsMap["hidden"] != nil && browserOptions?.hidden != newOptions.hidden {
            if newOptions.hidden {
                hide()
            }
            else {
                show()
            }
        }

        if newOptionsMap["hideUrlBar"] != nil && browserOptions?.hideUrlBar != newOptions.hideUrlBar {
            self.urlField.isHidden = newOptions.hideUrlBar
            self.urlField.isEnabled = !newOptions.hideUrlBar
        }
        
        if newOptionsMap["toolbarTop"] != nil && browserOptions?.toolbarTop != newOptions.toolbarTop {
            self.containerWebView_TopFullScreenConstraint.isActive = !newOptions.toolbarTop
            self.webView_TopFullScreenConstraint.isActive = !newOptions.toolbarTop
            self.toolbarTop.isHidden = !newOptions.toolbarTop
            self.toolbarTop_BottomToWebViewTopConstraint.isActive = newOptions.toolbarTop
        }
        
        if newOptionsMap["toolbarTopBackgroundColor"] != nil && browserOptions?.toolbarTopBackgroundColor != newOptions.toolbarTopBackgroundColor && newOptions.toolbarTopBackgroundColor != "" {
            self.toolbarTop.backgroundColor = color(fromHexString: newOptions.toolbarTopBackgroundColor)
        }
        
        if newOptionsMap["toolbarBottom"] != nil && browserOptions?.toolbarBottom != newOptions.toolbarBottom {
            self.containerWebView_BottomFullScreenConstraint.isActive = !newOptions.toolbarBottom
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
        
        self.browserOptions = newOptions
        self.webViewOptions = newInAppWebViewOptions
    }
    
    public func getOptions() -> [String: Any?]? {
        let webViewOptionsMap = self.webView.getOptions()
        if (self.browserOptions == nil || webViewOptionsMap == nil) {
            return nil
        }
        var optionsMap = self.browserOptions!.getRealOptions(obj: self)
        optionsMap.merge(webViewOptionsMap!, uniquingKeysWith: { (current, _) in current })
        return optionsMap
    }
    
    public func dispose() {
        webView.dispose()
        if previousStatusBarStyle != -1 {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: previousStatusBarStyle)!
        }
        transitioningDelegate = nil
        urlField.delegate = nil
        closeButton.removeTarget(self, action: #selector(self.close), for: .touchUpInside)
        forwardButton.target = nil
        forwardButton.target = nil
        backButton.target = nil
        reloadButton.target = nil
        shareButton.target = nil
        tmpWindow?.windowLevel = UIWindow.Level(rawValue: 0.0)
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
        onExit()
        channel?.setMethodCallHandler(nil)
        channel = nil
    }
    
    public func onBrowserCreated() {
        channel!.invokeMethod("onBrowserCreated", arguments: [])
    }
    
    public func onExit() {
        channel!.invokeMethod("onExit", arguments: [])
    }
}
