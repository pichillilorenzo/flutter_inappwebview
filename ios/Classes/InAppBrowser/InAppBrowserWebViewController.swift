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

public class InAppBrowserWebViewController: UIViewController, InAppBrowserDelegate, UIScrollViewDelegate, WKUIDelegate, UISearchBarDelegate {
    
    var closeButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    var progressBar: UIProgressView!
    
    var tmpWindow: UIWindow?
    var id: String = ""
    var windowId: Int64?
    var webView: InAppWebView!
    var channel: FlutterMethodChannel?
    var initialUrlRequest: URLRequest?
    var initialFile: String?
    var contextMenu: [String: Any]?
    var browserOptions: InAppBrowserOptions?
    var webViewOptions: InAppWebViewOptions?
    var initialData: String?
    var initialMimeType: String?
    var initialEncoding: String?
    var initialBaseUrl: String?
    var previousStatusBarStyle = -1
    var initialUserScripts: [[String: Any]] = []
    var pullToRefreshInitialOptions: [String: Any?] = [:]
    var methodCallDelegate: InAppWebViewMethodHandler?
    var isHidden = false

    public override func loadView() {
        channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser_" + id, binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        
        var userScripts: [UserScript] = []
        for intialUserScript in initialUserScripts {
            userScripts.append(UserScript.fromMap(map: intialUserScript, windowId: windowId)!)
        }
        
        let preWebviewConfiguration = InAppWebView.preWKWebViewConfiguration(options: webViewOptions)
        if let wId = windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
            webView = webViewTransport.webView
            webView.contextMenu = contextMenu
            webView.channel = channel!
            webView.initialUserScripts = userScripts
        } else {
            webView = InAppWebView(frame: .zero,
                                        configuration: preWebviewConfiguration,
                                        contextMenu: contextMenu,
                                        channel: channel!,
                                        userScripts: userScripts)
        }
        webView.inAppBrowserDelegate = self
        
        methodCallDelegate = InAppWebViewMethodHandler(webView: webView!)
        channel!.setMethodCallHandler(LeakAvoider(delegate: methodCallDelegate!).handle)
        
        let pullToRefreshLayoutChannel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_" + id,
                                                              binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger())
        let pullToRefreshOptions = PullToRefreshOptions()
        let _ = pullToRefreshOptions.parse(options: pullToRefreshInitialOptions)
        let pullToRefreshControl = PullToRefreshControl(channel: pullToRefreshLayoutChannel, options: pullToRefreshOptions)
        webView.pullToRefreshControl = pullToRefreshControl
        pullToRefreshControl.delegate = webView
        pullToRefreshControl.prepare()
        
        prepareWebView()
        webView.windowCreated = true
        
        progressBar = UIProgressView(progressViewStyle: .bar)
        
        view = UIView()
        view.addSubview(webView)
        view.insertSubview(progressBar, aboveSubview: webView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true

            progressBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
            progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
            progressBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        } else {
            view.addConstraints([
                NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: webView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: webView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
            ])
            
            view.addConstraints([
                NSLayoutConstraint(item: progressBar!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: progressBar!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: progressBar!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
            ])
        }
        
        if let wId = windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
            webView.load(webViewTransport.request)
            onBrowserCreated()
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

                                self.initLoad()
                        }
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            initLoad()
        }
    }
    
    public func initLoad() {
        if let initialFile = initialFile {
            do {
                try webView?.loadFile(assetFilePath: initialFile)
            }
            catch let error as NSError {
                dump(error)
            }
        }
        else if let initialData = initialData {
            let baseUrl = URL(string: initialBaseUrl!)!
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = webView?.options?.allowingReadAccessTo, baseUrl.scheme == "file" {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                if allowingReadAccessToURL?.scheme != "file" {
                    allowingReadAccessToURL = nil
                }
            }
            webView.loadData(data: initialData, mimeType: initialMimeType!, encoding: initialEncoding!, baseUrl: baseUrl, allowingReadAccessTo: allowingReadAccessToURL)
        }
        else if let initialUrlRequest = initialUrlRequest {
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = webView.options?.allowingReadAccessTo, let url = initialUrlRequest.url, url.scheme == "file" {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                if allowingReadAccessToURL?.scheme != "file" {
                    allowingReadAccessToURL = nil
                }
            }
            webView.loadUrl(urlRequest: initialUrlRequest, allowingReadAccessTo: allowingReadAccessToURL)
        }
        onBrowserCreated()
    }
    
    deinit {
        print("InAppBrowserWebViewController - dealloc")
        dispose()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        dispose()
        super.viewDidDisappear(animated)
    }
    
    public override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func prepareNavigationControllerBeforeViewWillAppear() {
        if let browserOptions = browserOptions {
            navigationController?.modalPresentationStyle = UIModalPresentationStyle(rawValue: browserOptions.presentationStyle)!
            navigationController?.modalTransitionStyle = UIModalTransitionStyle(rawValue: browserOptions.transitionStyle)!
        }
    }
    
    public func prepareWebView() {
        webView.options = webViewOptions
        webView.prepare()
              
        searchBar = UISearchBar()
        searchBar.keyboardType = .URL
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        forwardButton = UIBarButtonItem(title: "\u{203A}", style: .plain, target: self, action: #selector(goForward))
        forwardButton.isEnabled = false
        backButton = UIBarButtonItem(title: "\u{2039}", style: .plain, target: self, action: #selector(goBack))
        backButton.isEnabled = false
        
        for state: UIControl.State in [.normal, .disabled, .highlighted, .selected] {
            forwardButton.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 50.0),
                NSAttributedString.Key.baselineOffset: 2.5
            ], for: state)
            backButton.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 50.0),
                NSAttributedString.Key.baselineOffset: 2.5
            ], for: state)
        }
        
        toolbarItems = [backButton, spacer, forwardButton, spacer, shareButton, spacer, reloadButton]
        
        if let browserOptions = browserOptions {
            if !browserOptions.hideToolbarTop {
                navigationController?.navigationBar.isHidden = false
                if browserOptions.hideUrlBar {
                    searchBar.isHidden = true
                }
                if let bgColor = browserOptions.toolbarTopBackgroundColor, !bgColor.isEmpty {
                    navigationController?.navigationBar.backgroundColor = UIColor(hexString: bgColor)
                }
                if let barTintColor = browserOptions.toolbarTopBarTintColor, !barTintColor.isEmpty {
                    navigationController?.navigationBar.barTintColor = UIColor(hexString: barTintColor)
                }
                if let tintColor = browserOptions.toolbarTopTintColor, !tintColor.isEmpty {
                    navigationController?.navigationBar.tintColor = UIColor(hexString: tintColor)
                }
                navigationController?.navigationBar.isTranslucent = browserOptions.toolbarTopTranslucent
            }
            else {
                navigationController?.navigationBar.isHidden = true
            }
            
            if !browserOptions.hideToolbarBottom {
                navigationController?.isToolbarHidden = false
                if let bgColor = browserOptions.toolbarBottomBackgroundColor, !bgColor.isEmpty {
                    navigationController?.toolbar.barTintColor = UIColor(hexString: bgColor)
                }
                if let tintColor = browserOptions.toolbarBottomTintColor, !tintColor.isEmpty {
                    navigationController?.toolbar.tintColor = UIColor(hexString: tintColor)
                }
                navigationController?.toolbar.isTranslucent = false
            }
            else {
                navigationController?.isToolbarHidden = true
            }
            
            if let closeButtonCaption = browserOptions.closeButtonCaption, !closeButtonCaption.isEmpty {
                closeButton = UIBarButtonItem(title: closeButtonCaption, style: .plain, target: self, action: #selector(close))
            } else {
                setDefaultCloseButton()
            }
            
            if let closeButtonColor = browserOptions.closeButtonColor, !closeButtonColor.isEmpty {
                closeButton.tintColor = UIColor(hexString: closeButtonColor)
            }
            
            if browserOptions.hideProgressBar {
                progressBar.isHidden = true
            }
        }
        
        navigationItem.rightBarButtonItem = closeButton
    }
    
    func setDefaultCloseButton() {
        if closeButton != nil {
            closeButton.target = nil
            closeButton.action = nil
        }
        if #available(iOS 13.0, *) {
            closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        } else {
            closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
    }
    
    public func didChangeTitle(title: String?) {
        guard let _ = title else {
            return
        }
    }
    
    public func didStartNavigation(url: URL?) {
        forwardButton.isEnabled = webView.canGoForward
        backButton.isEnabled = webView.canGoBack
        progressBar.setProgress(0.0, animated: false)
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didUpdateVisitedHistory(url: URL?) {
        forwardButton.isEnabled = webView.canGoForward
        backButton.isEnabled = webView.canGoBack
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didFinishNavigation(url: URL?) {
        forwardButton.isEnabled = webView.canGoForward
        backButton.isEnabled = webView.canGoBack
        progressBar.setProgress(0.0, animated: false)
        guard let url = url else {
            return
        }
        searchBar.text = url.absoluteString
    }
    
    public func didFailNavigation(url: URL?, error: Error) {
        forwardButton.isEnabled = webView.canGoForward
        backButton.isEnabled = webView.canGoBack
        progressBar.setProgress(0.0, animated: false)
    }
    
    public func didChangeProgress(progress: Double) {
        progressBar.setProgress(Float(progress), animated: true)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              let urlEncoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlEncoded) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    public func show(completion: (() -> Void)? = nil) {
        if let navController = navigationController as? InAppBrowserNavigationController, let window = navController.tmpWindow {
            isHidden = false
            window.alpha = 0.0
            window.isHidden = false
            window.makeKeyAndVisible()
            UIView.animate(withDuration: 0.2) {
                window.alpha = 1.0
                completion?()
            }
        }
    }

    public func hide(completion: (() -> Void)? = nil) {
        if let navController = navigationController as? InAppBrowserNavigationController, let window = navController.tmpWindow {
            isHidden = true
            window.alpha = 1.0
            UIView.animate(withDuration: 0.2) {
                window.alpha = 0.0
            } completion: { (finished) in
                if finished {
                    window.isHidden = true
                    UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                    completion?()
                }
            }
        }
    }
    
    @objc public func reload() {
        webView.reload()
        didUpdateVisitedHistory(url: webView.url)
    }
    
    @objc public func share() {
        let vc = UIActivityViewController(activityItems: [webView.url?.absoluteString ?? ""], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    public func close(completion: (() -> Void)? = nil) {
        if (navigationController?.responds(to: #selector(getter: navigationController?.presentingViewController)))! {
            navigationController?.presentingViewController?.dismiss(animated: true, completion: {() -> Void in
                completion?()
            })
        }
        else {
            navigationController?.parent?.dismiss(animated: true, completion: {() -> Void in
                completion?()
            })
        }
    }
    
    @objc public func close() {
        if (navigationController?.responds(to: #selector(getter: navigationController?.presentingViewController)))! {
            navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            navigationController?.parent?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc public func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc public func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc public func goBackOrForward(steps: Int) {
        webView.goBackOrForward(steps: steps)
    }

    public func setOptions(newOptions: InAppBrowserOptions, newOptionsMap: [String: Any]) {
        
        let newInAppWebViewOptions = InAppWebViewOptions()
        let _ = newInAppWebViewOptions.parse(options: newOptionsMap)
        self.webView.setOptions(newOptions: newInAppWebViewOptions, newOptionsMap: newOptionsMap)
        
        if newOptionsMap["hidden"] != nil, browserOptions?.hidden != newOptions.hidden {
            if newOptions.hidden {
                hide()
            }
            else {
                show()
            }
        }

        if newOptionsMap["hideUrlBar"] != nil, browserOptions?.hideUrlBar != newOptions.hideUrlBar {
            searchBar.isHidden = newOptions.hideUrlBar
        }

        if newOptionsMap["hideToolbarTop"] != nil, browserOptions?.hideToolbarTop != newOptions.hideToolbarTop {
            navigationController?.navigationBar.isHidden = newOptions.hideToolbarTop
        }

        if newOptionsMap["toolbarTopBackgroundColor"] != nil, browserOptions?.toolbarTopBackgroundColor != newOptions.toolbarTopBackgroundColor {
            if let bgColor = newOptions.toolbarTopBackgroundColor, !bgColor.isEmpty {
                navigationController?.navigationBar.backgroundColor = UIColor(hexString: bgColor)
            } else {
                navigationController?.navigationBar.backgroundColor = nil
            }
        }
        
        if newOptionsMap["toolbarTopBarTintColor"] != nil, browserOptions?.toolbarTopBarTintColor != newOptions.toolbarTopBarTintColor {
            if let barTintColor = newOptions.toolbarTopBarTintColor, !barTintColor.isEmpty {
                navigationController?.navigationBar.barTintColor = UIColor(hexString: barTintColor)
            } else {
                navigationController?.navigationBar.barTintColor = nil
            }
        }
        
        if newOptionsMap["toolbarTopTintColor"] != nil, browserOptions?.toolbarTopTintColor != newOptions.toolbarTopTintColor {
            if let tintColor = newOptions.toolbarTopTintColor, !tintColor.isEmpty {
                navigationController?.navigationBar.tintColor = UIColor(hexString: tintColor)
            } else {
                navigationController?.navigationBar.tintColor = nil
            }
        }

        if newOptionsMap["hideToolbarBottom"] != nil, browserOptions?.hideToolbarBottom != newOptions.hideToolbarBottom {
            navigationController?.isToolbarHidden = !newOptions.hideToolbarBottom
        }

        if newOptionsMap["toolbarBottomBackgroundColor"] != nil, browserOptions?.toolbarBottomBackgroundColor != newOptions.toolbarBottomBackgroundColor {
            if let bgColor = newOptions.toolbarBottomBackgroundColor, !bgColor.isEmpty {
                navigationController?.toolbar.barTintColor = UIColor(hexString: bgColor)
            } else {
                navigationController?.toolbar.barTintColor = nil
            }
        }
        
        if newOptionsMap["toolbarBottomTintColor"] != nil, browserOptions?.toolbarBottomTintColor != newOptions.toolbarBottomTintColor {
            if let tintColor = newOptions.toolbarBottomTintColor, !tintColor.isEmpty {
                navigationController?.toolbar.tintColor = UIColor(hexString: tintColor)
            } else {
                navigationController?.toolbar.tintColor = nil
            }
        }

        if newOptionsMap["toolbarTopTranslucent"] != nil, browserOptions?.toolbarTopTranslucent != newOptions.toolbarTopTranslucent {
            navigationController?.navigationBar.isTranslucent = newOptions.toolbarTopTranslucent
        }
        
        if newOptionsMap["toolbarBottomTranslucent"] != nil, browserOptions?.toolbarBottomTranslucent != newOptions.toolbarBottomTranslucent {
            navigationController?.toolbar.isTranslucent = newOptions.toolbarBottomTranslucent
        }

        if newOptionsMap["closeButtonCaption"] != nil, browserOptions?.closeButtonCaption != newOptions.closeButtonCaption {
            if let closeButtonCaption = newOptions.closeButtonCaption, !closeButtonCaption.isEmpty {
                if let oldTitle = closeButton.title, !oldTitle.isEmpty {
                    closeButton.title = closeButtonCaption
                } else {
                    closeButton.target = nil
                    closeButton.action = nil
                    closeButton = UIBarButtonItem(title: closeButtonCaption, style: .plain, target: self, action: #selector(close))
                }
            } else {
                setDefaultCloseButton()
            }
        }

        if newOptionsMap["closeButtonColor"] != nil, browserOptions?.closeButtonColor != newOptions.closeButtonColor {
            if let tintColor = newOptions.closeButtonColor, !tintColor.isEmpty {
                closeButton.tintColor = UIColor(hexString: tintColor)
            } else {
                closeButton.tintColor = nil
            }
        }
        
        if newOptionsMap["presentationStyle"] != nil, browserOptions?.presentationStyle != newOptions.presentationStyle {
            navigationController?.modalPresentationStyle = UIModalPresentationStyle(rawValue: newOptions.presentationStyle)!
        }
        
        if newOptionsMap["transitionStyle"] != nil, browserOptions?.transitionStyle != newOptions.transitionStyle {
            navigationController?.modalTransitionStyle = UIModalTransitionStyle(rawValue: newOptions.transitionStyle)!
        }
        
        if newOptionsMap["hideProgressBar"] != nil, browserOptions?.hideProgressBar != newOptions.hideProgressBar {
            progressBar.isHidden = newOptions.hideProgressBar
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
        onExit()
        channel?.setMethodCallHandler(nil)
        channel = nil
        webView?.dispose()
        webView = nil
        view = nil
        if previousStatusBarStyle != -1 {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle(rawValue: previousStatusBarStyle)!
        }
        transitioningDelegate = nil
        searchBar.delegate = nil
        closeButton.target = nil
        forwardButton.target = nil
        backButton.target = nil
        reloadButton.target = nil
        shareButton.target = nil
        methodCallDelegate?.webView = nil
        methodCallDelegate = nil
    }
    
    public func onBrowserCreated() {
        channel?.invokeMethod("onBrowserCreated", arguments: [])
    }
    
    public func onExit() {
        channel?.invokeMethod("onExit", arguments: [])
    }
}
