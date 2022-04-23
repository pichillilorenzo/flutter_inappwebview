//
//  InAppWebView.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 21/10/18.
//

import Flutter
import Foundation
import WebKit

public class InAppWebView: WKWebView, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate, PullToRefreshDelegate {

    var windowId: Int64?
    var windowCreated = false
    var inAppBrowserDelegate: InAppBrowserDelegate?
    var channel: FlutterMethodChannel?
    var options: InAppWebViewOptions?
    var pullToRefreshControl: PullToRefreshControl?
    var webMessageChannels: [String:WebMessageChannel] = [:]
    var webMessageListeners: [WebMessageListener] = []
    var currentOriginalUrl: URL?
    
    static var sslCertificatesMap: [String: SslCertificate] = [:] // [URL host name : SslCertificate]
    static var credentialsProposed: [URLCredential] = []
    
    var lastScrollX: CGFloat = 0
    var lastScrollY: CGFloat = 0
    
    // Used to manage pauseTimers() and resumeTimers()
    var isPausedTimers = false
    var isPausedTimersCompletionHandler: (() -> Void)?

    var contextMenu: [String: Any]?
    var initialUserScripts: [UserScript] = []
    
    // https://github.com/mozilla-mobile/firefox-ios/blob/50531a7e9e4d459fb11d4fcb7d4322e08103501f/Client/Frontend/Browser/ContextMenuHelper.swift
    fileprivate var nativeHighlightLongPressRecognizer: UILongPressGestureRecognizer?
    fileprivate var nativeLoupeGesture: UILongPressGestureRecognizer?
    var longPressRecognizer: UILongPressGestureRecognizer!
    var recognizerForDisablingContextMenuOnLinks: UILongPressGestureRecognizer!
    var lastLongPressTouchPoint: CGPoint?
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var lastTouchPoint: CGPoint?
    var lastTouchPointTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
    
    var contextMenuIsShowing = false
    // flag used for the workaround to trigger onCreateContextMenu event as the same on Android
    var onCreateContextMenuEventTriggeredWhenMenuDisabled = false
    
    var customIMPs: [IMP] = []
    
    static var windowWebViews: [Int64:WebViewTransport] = [:]
    static var windowAutoincrementId: Int64 = 0;
    
    var callAsyncJavaScriptBelowIOS14Results: [String:((Any?) -> Void)] = [:]
    
    var oldZoomScale = Float(1.0)
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, contextMenu: [String: Any]?, channel: FlutterMethodChannel?, userScripts: [UserScript] = []) {
        super.init(frame: frame, configuration: configuration)
        self.channel = channel
        self.contextMenu = contextMenu
        self.initialUserScripts = userScripts
        uiDelegate = self
        navigationDelegate = self
        scrollView.delegate = self
        longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.delegate = self
        longPressRecognizer.addTarget(self, action: #selector(longPressGestureDetected))
        recognizerForDisablingContextMenuOnLinks = UILongPressGestureRecognizer()
        recognizerForDisablingContextMenuOnLinks.delegate = self
        recognizerForDisablingContextMenuOnLinks.addTarget(self, action: #selector(longPressGestureDetected))
        recognizerForDisablingContextMenuOnLinks?.minimumPressDuration = 0.45
        panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(endDraggingDetected))
    }
    
    override public var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            
            self.scrollView.contentInset = UIEdgeInsets.zero;
            if #available(iOS 11, *) {
                // Above iOS 11, adjust contentInset to compensate the adjustedContentInset so the sum will
                // always be 0.
                if (scrollView.adjustedContentInset != UIEdgeInsets.zero) {
                    let insetToAdjust = self.scrollView.adjustedContentInset;
                    scrollView.contentInset = UIEdgeInsets(top: -insetToAdjust.top, left: -insetToAdjust.left,
                                                                bottom: -insetToAdjust.bottom, right: -insetToAdjust.right);
                }
            }
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // BVC KVO events for all changes on the webview will call this.
    // It is called frequently during a page load (particularly on progress changes and URL changes).
    // As of iOS 12, WKContentView gesture setup is async, but it has been called by the time
    // the webview is ready to load an URL. After this has happened, we can override the gesture.
    func replaceGestureHandlerIfNeeded() {
        DispatchQueue.main.async {
            if self.gestureRecognizerWithDescriptionFragment("InAppWebView") == nil {
                self.replaceWebViewLongPress()
            }
        }
    }
    
    private func replaceWebViewLongPress() {
        // WebKit installs gesture handlers async. If `replaceWebViewLongPress` is called after a wkwebview in most cases a small delay is sufficient
        // See also https://bugs.webkit.org/show_bug.cgi?id=193366
        nativeHighlightLongPressRecognizer = gestureRecognizerWithDescriptionFragment("action=_highlightLongPressRecognized:")
        nativeLoupeGesture = gestureRecognizerWithDescriptionFragment("action=loupeGesture:")

        if let nativeLongPressRecognizer = gestureRecognizerWithDescriptionFragment("action=_longPressRecognized:") {
            nativeLongPressRecognizer.removeTarget(nil, action: nil)
            nativeLongPressRecognizer.addTarget(self, action: #selector(self.longPressGestureDetected))
        }
    }
    
    private func gestureRecognizerWithDescriptionFragment(_ descriptionFragment: String) -> UILongPressGestureRecognizer? {
        let result = self.scrollView.subviews.compactMap({ $0.gestureRecognizers }).joined().first(where: {
            return (($0 as? UILongPressGestureRecognizer) != nil) && $0.description.contains(descriptionFragment)
        })
        return result as? UILongPressGestureRecognizer
    }
    
    @objc func longPressGestureDetected(_ sender: UIGestureRecognizer) {
        if sender.state == .cancelled {
            return
        }

        guard sender.state == .began else {
            return
        }
        
        if sender == recognizerForDisablingContextMenuOnLinks,
           let options = options, !options.disableLongPressContextMenuOnLinks {
            return
        }
        
        if sender == longPressRecognizer {
            // To prevent the tapped link from proceeding with navigation, "cancel" the native WKWebView
            // `_highlightLongPressRecognizer`. This preserves the original behavior as seen here:
            // https://github.com/WebKit/webkit/blob/d591647baf54b4b300ca5501c21a68455429e182/Source/WebKit/UIProcess/ios/WKContentViewInteraction.mm#L1600-L1614
            if let nativeHighlightLongPressRecognizer = nativeHighlightLongPressRecognizer,
                nativeHighlightLongPressRecognizer.isEnabled {
                nativeHighlightLongPressRecognizer.isEnabled = false
                nativeHighlightLongPressRecognizer.isEnabled = true
            }
        }

        //Finding actual touch location in webView
        var touchLocation = sender.location(in: self)
        touchLocation.x -= scrollView.contentInset.left
        touchLocation.y -= scrollView.contentInset.top
        touchLocation.x /= scrollView.zoomScale
        touchLocation.y /= scrollView.zoomScale

        lastLongPressTouchPoint = touchLocation

        evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._findElementsAtPoint(\(touchLocation.x),\(touchLocation.y))", completionHandler: {(value, error) in
            if error != nil {
                print("Long press gesture recognizer error: \(error?.localizedDescription ?? "")")
            } else if let value = value as? [String: Any?] {
                let hitTestResult = HitTestResult.fromMap(map: value)!
                self.nativeLoupeGesture = self.gestureRecognizerWithDescriptionFragment("action=loupeGesture:")
                
                if sender == self.recognizerForDisablingContextMenuOnLinks,
                   hitTestResult.type.rawValue > HitTestResultType.unknownType.rawValue,
                   hitTestResult.type.rawValue < HitTestResultType.editTextType.rawValue {
                    self.nativeLoupeGesture?.isEnabled = false
                    self.nativeLoupeGesture?.isEnabled = true
                } else {
                    self.onLongPressHitTestResult(hitTestResult: hitTestResult)
                }
            } else if sender == self.longPressRecognizer {
                self.onLongPressHitTestResult(hitTestResult: HitTestResult(type: .unknownType, extra: nil))
            }
        })
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        lastTouchPoint = point
        lastTouchPointTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
        SharedLastTouchPointTimestamp[self] = lastTouchPointTimestamp
        
        // re-build context menu items for the current webview
        UIMenuController.shared.menuItems = []
        if let menu = self.contextMenu {
            if let menuItems = menu["menuItems"] as? [[String : Any]] {
                for menuItem in menuItems {
                    let id = menuItem["iosId"] as! String
                    let title = menuItem["title"] as! String
                    let targetMethodName = "onContextMenuActionItemClicked-" + String(self.hash) + "-" + id
                    if !self.responds(to: Selector(targetMethodName)) {
                        let customAction: () -> Void = {
                            let arguments: [String: Any?] = [
                                "iosId": id,
                                "androidId": nil,
                                "title": title
                            ]
                            self.channel?.invokeMethod("onContextMenuActionItemClicked", arguments: arguments)
                        }
                        let castedCustomAction: AnyObject = unsafeBitCast(customAction as @convention(block) () -> Void, to: AnyObject.self)
                        let swizzledImplementation = imp_implementationWithBlock(castedCustomAction)
                        class_addMethod(InAppWebView.self, Selector(targetMethodName), swizzledImplementation, nil)
                        self.customIMPs.append(swizzledImplementation)
                    }
                    let item = UIMenuItem(title: title, action: Selector(targetMethodName))
                    UIMenuController.shared.menuItems!.append(item)
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let _ = sender as? UIMenuController {
            if self.options?.disableContextMenu == true {
                if !onCreateContextMenuEventTriggeredWhenMenuDisabled {
                    // workaround to trigger onCreateContextMenu event as the same on Android
                    self.onCreateContextMenu()
                    onCreateContextMenuEventTriggeredWhenMenuDisabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.onCreateContextMenuEventTriggeredWhenMenuDisabled = false
                    }
                }
                return false
            }
            
            if let menu = contextMenu {
                let contextMenuOptions = ContextMenuOptions()
                if let contextMenuOptionsMap = menu["options"] as? [String: Any?] {
                    let _ = contextMenuOptions.parse(options: contextMenuOptionsMap)
                    if !action.description.starts(with: "onContextMenuActionItemClicked-") && contextMenuOptions.hideDefaultSystemContextMenuItems {
                        return false
                    }
                }
            }
            
            if contextMenuIsShowing, !action.description.starts(with: "onContextMenuActionItemClicked-") {
                let id = action.description.compactMap({ $0.asciiValue?.description }).joined()
                let arguments: [String: Any?] = [
                    "iosId": id,
                    "androidId": nil,
                    "title": action.description
                ]
                self.channel?.invokeMethod("onContextMenuActionItemClicked", arguments: arguments)
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    // For some reasons, using the scrollViewDidEndDragging event, in some rare cases, could block
    // the scroll gesture
    @objc func endDraggingDetected() {
        // detect end dragging
        if panGestureRecognizer.state == .ended {
            // fix for pull-to-refresh jittering when the touch drag event is held
            if let pullToRefreshControl = pullToRefreshControl,
               pullToRefreshControl.shouldCallOnRefresh {
                pullToRefreshControl.onRefresh()
            }
        }
    }

    public func prepare() {
        scrollView.addGestureRecognizer(self.longPressRecognizer)
        scrollView.addGestureRecognizer(self.recognizerForDisablingContextMenuOnLinks)
        scrollView.addGestureRecognizer(self.panGestureRecognizer)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new, .old], context: nil)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.zoomScale), options: [.new, .old], context: nil)
        
        addObserver(self,
                    forKeyPath: #keyPath(WKWebView.estimatedProgress),
                    options: .new,
                    context: nil)
        
        addObserver(self,
                    forKeyPath: #keyPath(WKWebView.url),
                    options: [.new, .old],
                    context: nil)
        
        addObserver(self,
            forKeyPath: #keyPath(WKWebView.title),
            options: [.new, .old],
            context: nil)
        
        NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(onCreateContextMenu),
                        name: UIMenuController.willShowMenuNotification,
                        object: nil)
        
        NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(onHideContextMenu),
                        name: UIMenuController.didHideMenuNotification,
                        object: nil)
        
        // listen for videos playing in fullscreen
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onEnterFullscreen(_:)),
                                               name: UIWindow.didBecomeVisibleNotification,
                                               object: window)

        // listen for videos stopping to play in fullscreen
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onExitFullscreen(_:)),
                                               name: UIWindow.didBecomeHiddenNotification,
                                               object: window)
        
        if let options = options {
            if options.transparentBackground {
                isOpaque = false
                backgroundColor = UIColor.clear
                scrollView.backgroundColor = UIColor.clear
            }
            
            // prevent webView from bouncing
            if options.disallowOverScroll {
                if responds(to: #selector(getter: scrollView)) {
                    scrollView.bounces = false
                }
                else {
                    for subview: UIView in subviews {
                        if subview is UIScrollView {
                            (subview as! UIScrollView).bounces = false
                        }
                    }
                }
            }
            
            if #available(iOS 11.0, *) {
                accessibilityIgnoresInvertColors = options.accessibilityIgnoresInvertColors
                scrollView.contentInsetAdjustmentBehavior =
                    UIScrollView.ContentInsetAdjustmentBehavior.init(rawValue: options.contentInsetAdjustmentBehavior)!
            }
            
            allowsBackForwardNavigationGestures = options.allowsBackForwardNavigationGestures
            if #available(iOS 9.0, *) {
                allowsLinkPreview = options.allowsLinkPreview
                if !options.userAgent.isEmpty {
                    customUserAgent = options.userAgent
                }
            }
            
            if #available(iOS 13.0, *) {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = options.automaticallyAdjustsScrollIndicatorInsets
            }
            
            scrollView.showsVerticalScrollIndicator = !options.disableVerticalScroll
            scrollView.showsHorizontalScrollIndicator = !options.disableHorizontalScroll
            scrollView.showsVerticalScrollIndicator = options.verticalScrollBarEnabled
            scrollView.showsHorizontalScrollIndicator = options.horizontalScrollBarEnabled
            scrollView.isScrollEnabled = !(options.disableVerticalScroll && options.disableHorizontalScroll)
            scrollView.isDirectionalLockEnabled = options.isDirectionalLockEnabled

            scrollView.decelerationRate = Util.getDecelerationRate(type: options.decelerationRate)
            scrollView.alwaysBounceVertical = options.alwaysBounceVertical
            scrollView.alwaysBounceHorizontal = options.alwaysBounceHorizontal
            scrollView.scrollsToTop = options.scrollsToTop
            scrollView.isPagingEnabled = options.isPagingEnabled
            scrollView.maximumZoomScale = CGFloat(options.maximumZoomScale)
            scrollView.minimumZoomScale = CGFloat(options.minimumZoomScale)
            
            if #available(iOS 14.0, *) {
                mediaType = options.mediaType
                pageZoom = CGFloat(options.pageZoom)
            }
            
            // debugging is always enabled for iOS,
            // there isn't any option to set about it such as on Android.
            
            if options.clearCache {
                clearCache()
            }
        }
        
        prepareAndAddUserScripts()
        
        if windowId != nil {
            // The new created window webview has the same WKWebViewConfiguration variable reference.
            // So, we cannot set another WKWebViewConfiguration for it unfortunately!
            // This is a limitation of the official WebKit API.
            return
        }
        
        configuration.preferences = WKPreferences()
        if let options = options {
            if #available(iOS 9.0, *) {
                configuration.allowsAirPlayForMediaPlayback = options.allowsAirPlayForMediaPlayback
                configuration.allowsPictureInPictureMediaPlayback = options.allowsPictureInPictureMediaPlayback
            }
            
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = options.javaScriptCanOpenWindowsAutomatically
            configuration.preferences.minimumFontSize = CGFloat(options.minimumFontSize)
            
            if #available(iOS 13.0, *) {
                configuration.preferences.isFraudulentWebsiteWarningEnabled = options.isFraudulentWebsiteWarningEnabled
                configuration.defaultWebpagePreferences.preferredContentMode = WKWebpagePreferences.ContentMode(rawValue: options.preferredContentMode)!
            }
            
            configuration.preferences.javaScriptEnabled = options.javaScriptEnabled
            if #available(iOS 14.0, *) {
                configuration.defaultWebpagePreferences.allowsContentJavaScript = options.javaScriptEnabled
            }
        }
    }
    
    public func prepareAndAddUserScripts() -> Void {
        if windowId != nil {
            // The new created window webview has the same WKWebViewConfiguration variable reference.
            // So, we cannot set another WKWebViewConfiguration for it unfortunately!
            // This is a limitation of the official WebKit API.
            return
        }
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.initialize()
        
        if let applePayAPIEnabled = options?.applePayAPIEnabled, applePayAPIEnabled {
            return
        }
        
        configuration.userContentController.addPluginScript(PROMISE_POLYFILL_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(CONSOLE_LOG_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(PRINT_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(FIND_ELEMENTS_AT_POINT_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(LAST_TOUCHED_ANCHOR_OR_IMAGE_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(FIND_TEXT_HIGHLIGHT_JS_PLUGIN_SCRIPT)
        configuration.userContentController.addPluginScript(ORIGINAL_VIEWPORT_METATAG_CONTENT_JS_PLUGIN_SCRIPT)
        if let options = options {
            if options.useShouldInterceptAjaxRequest {
                configuration.userContentController.addPluginScript(INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT)
            }
            if options.useShouldInterceptFetchRequest {
                configuration.userContentController.addPluginScript(INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT)
            }
            if options.useOnLoadResource {
                configuration.userContentController.addPluginScript(ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT)
            }
            if !options.supportZoom {
                configuration.userContentController.addPluginScript(NOT_SUPPORT_ZOOM_JS_PLUGIN_SCRIPT)
            } else if options.enableViewportScale {
                configuration.userContentController.addPluginScript(ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT)
            }
        }
        configuration.userContentController.removeScriptMessageHandler(forName: "onCallAsyncJavaScriptResultBelowIOS14Received")
        configuration.userContentController.add(self, name: "onCallAsyncJavaScriptResultBelowIOS14Received")
        configuration.userContentController.removeScriptMessageHandler(forName: "onWebMessagePortMessageReceived")
        configuration.userContentController.add(self, name: "onWebMessagePortMessageReceived")
        configuration.userContentController.removeScriptMessageHandler(forName: "onWebMessageListenerPostMessageReceived")
        configuration.userContentController.add(self, name: "onWebMessageListenerPostMessageReceived")
        configuration.userContentController.addUserOnlyScripts(initialUserScripts)
        configuration.userContentController.sync(scriptMessageHandler: self)
    }
    
    public static func preWKWebViewConfiguration(options: InAppWebViewOptions?) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        configuration.processPool = WKProcessPoolManager.sharedProcessPool
        
        if let options = options {
            configuration.allowsInlineMediaPlayback = options.allowsInlineMediaPlayback
            configuration.suppressesIncrementalRendering = options.suppressesIncrementalRendering
            configuration.selectionGranularity = WKSelectionGranularity.init(rawValue: options.selectionGranularity)!
            
            if options.allowUniversalAccessFromFileURLs {
                configuration.setValue(options.allowUniversalAccessFromFileURLs, forKey: "allowUniversalAccessFromFileURLs")
            }
            
            if options.allowFileAccessFromFileURLs {
                configuration.preferences.setValue(options.allowFileAccessFromFileURLs, forKey: "allowFileAccessFromFileURLs")
            }
            
            if #available(iOS 9.0, *) {
                if options.incognito {
                    configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                } else if options.cacheEnabled {
                    configuration.websiteDataStore = WKWebsiteDataStore.default()
                }
                if !options.applicationNameForUserAgent.isEmpty {
                    if let applicationNameForUserAgent = configuration.applicationNameForUserAgent {
                        configuration.applicationNameForUserAgent = applicationNameForUserAgent + " " + options.applicationNameForUserAgent
                    }
                }
            }
            
            if #available(iOS 10.0, *) {
                configuration.ignoresViewportScaleLimits = options.ignoresViewportScaleLimits
                
                var dataDetectorTypes = WKDataDetectorTypes.init(rawValue: 0)
                for type in options.dataDetectorTypes {
                    let dataDetectorType = Util.getDataDetectorType(type: type)
                    dataDetectorTypes = WKDataDetectorTypes(rawValue: dataDetectorTypes.rawValue | dataDetectorType.rawValue)
                }
                configuration.dataDetectorTypes = dataDetectorTypes
                
                configuration.mediaTypesRequiringUserActionForPlayback = options.mediaPlaybackRequiresUserGesture ? .all : []
            } else {
                // Fallback on earlier versions
                configuration.mediaPlaybackRequiresUserAction = options.mediaPlaybackRequiresUserGesture
            }
            
            if #available(iOS 11.0, *) {
                for scheme in options.resourceCustomSchemes {
                    configuration.setURLSchemeHandler(CustomeSchemeHandler(), forURLScheme: scheme)
                }
                if options.sharedCookiesEnabled {
                    // More info to sending cookies with WKWebView
                    // https://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303
                    // Set Cookies in iOS 11 and above, initialize websiteDataStore before setting cookies
                    // See also https://forums.developer.apple.com/thread/97194
                    // check if websiteDataStore has not been initialized before
                    if(!options.incognito && !options.cacheEnabled) {
                        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                    }
                    for cookie in HTTPCookieStorage.shared.cookies ?? [] {
                        configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
                    }
                }
            }
            
            if #available(iOS 14.0, *) {
                configuration.limitsNavigationsToAppBoundDomains = options.limitsNavigationsToAppBoundDomains
            }
        }
        
        return configuration
    }
    
    @objc func onCreateContextMenu() {
        let mapSorted = SharedLastTouchPointTimestamp.sorted { $0.value > $1.value }
        if (mapSorted.first?.key != self) {
            return
        }
        
        contextMenuIsShowing = true
        
        if let lastLongPressTouhLocation = lastLongPressTouchPoint {
            if configuration.preferences.javaScriptEnabled {
                self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._findElementsAtPoint(\(lastLongPressTouhLocation.x),\(lastLongPressTouhLocation.y))", completionHandler: {(value, error) in
                    if error != nil {
                        print("Long press gesture recognizer error: \(error?.localizedDescription ?? "")")
                    } else if var value = value as? [String: Any?] {
                        value["type"] = value["type"] as? Int
                        self.channel?.invokeMethod("onCreateContextMenu", arguments: value)
                    } else {
                        self.channel?.invokeMethod("onCreateContextMenu", arguments: [:])
                    }
                })
            } else {
                channel?.invokeMethod("onCreateContextMenu", arguments: [:])
            }
        } else {
            channel?.invokeMethod("onCreateContextMenu", arguments: [:])
        }
    }
    
    @objc func onHideContextMenu() {
        if contextMenuIsShowing == false {
            return
        }
        
        contextMenuIsShowing = false
        
        let arguments: [String: Any] = [:]
        channel?.invokeMethod("onHideContextMenu", arguments: arguments)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            initializeWindowIdJS()
            let progress = Int(estimatedProgress * 100)
            onProgressChanged(progress: progress)
            inAppBrowserDelegate?.didChangeProgress(progress: estimatedProgress)
        } else if keyPath == #keyPath(WKWebView.url) && change?[NSKeyValueChangeKey.newKey] is URL {
            initializeWindowIdJS()
            let newUrl = change?[NSKeyValueChangeKey.newKey] as? URL
            onUpdateVisitedHistory(url: newUrl?.absoluteString)
            inAppBrowserDelegate?.didUpdateVisitedHistory(url: newUrl)
        } else if keyPath == #keyPath(WKWebView.title) && change?[NSKeyValueChangeKey.newKey] is String {
            let newTitle = change?[NSKeyValueChangeKey.newKey] as? String
            onTitleChanged(title: newTitle)
            inAppBrowserDelegate?.didChangeTitle(title: newTitle)
        } else if keyPath == #keyPath(UIScrollView.contentOffset) {
            let newContentOffset = change?[NSKeyValueChangeKey.newKey] as? CGPoint
            let oldContentOffset = change?[NSKeyValueChangeKey.oldKey] as? CGPoint
            let startedByUser = scrollView.isDragging || scrollView.isDecelerating
            if newContentOffset != oldContentOffset {
                DispatchQueue.main.async {
                    self.onScrollChanged(startedByUser: startedByUser, oldContentOffset: oldContentOffset)
                }
            }
        }
        replaceGestureHandlerIfNeeded()
    }
    
    public func initializeWindowIdJS() {
        if let windowId = windowId {
            if #available(iOS 14.0, *) {
                let contentWorlds = configuration.userContentController.getContentWorlds(with: windowId)
                for contentWorld in contentWorlds {
                    let source = WINDOW_ID_INITIALIZE_JS_SOURCE.replacingOccurrences(of: PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, with: String(windowId))
                    evaluateJavascript(source: source, contentWorld: contentWorld)
                }
            } else {
                let source = WINDOW_ID_INITIALIZE_JS_SOURCE.replacingOccurrences(of: PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, with: String(windowId))
                evaluateJavascript(source: source)
            }
        }
    }
    
    public func goBackOrForward(steps: Int) {
        if canGoBackOrForward(steps: steps) {
            if (steps > 0) {
                let index = steps - 1
                go(to: self.backForwardList.forwardList[index])
            }
            else if (steps < 0){
                let backListLength = self.backForwardList.backList.count
                let index = backListLength + steps
                go(to: self.backForwardList.backList[index])
            }
        }
    }
    
    public func canGoBackOrForward(steps: Int) -> Bool {
        let currentIndex = self.backForwardList.backList.count
        return (steps >= 0)
            ? steps <= self.backForwardList.forwardList.count
            : currentIndex + steps >= 0
    }
    
    @available(iOS 11.0, *)
    public func takeScreenshot (with: [String: Any?]?, completionHandler: @escaping (_ screenshot: Data?) -> Void) {
        var snapshotConfiguration: WKSnapshotConfiguration? = nil
        if let with = with {
            snapshotConfiguration = WKSnapshotConfiguration()
            if let rect = with["rect"] as? [String: Double] {
                snapshotConfiguration!.rect = CGRect(x: rect["x"]!, y: rect["y"]!, width: rect["width"]!, height: rect["height"]!)
            }
            if let snapshotWidth = with["snapshotWidth"] as? Double {
                snapshotConfiguration!.snapshotWidth = NSNumber(value: snapshotWidth)
            }
            if #available(iOS 13.0, *), let afterScreenUpdates = with["iosAfterScreenUpdates"] as? Bool {
                snapshotConfiguration!.afterScreenUpdates = afterScreenUpdates
            }
        }
        takeSnapshot(with: snapshotConfiguration, completionHandler: {(image, error) -> Void in
            var imageData: Data? = nil
            if let screenshot = image {
                if let with = with {
                    switch with["compressFormat"] as! String {
                    case "JPEG":
                        let quality = Float(with["quality"] as! Int) / 100
                        imageData = screenshot.jpegData(compressionQuality: CGFloat(quality))
                        break
                    case "PNG":
                        imageData = screenshot.pngData()
                        break
                    default:
                        imageData = screenshot.pngData()
                    }
                }
                else {
                    imageData = screenshot.pngData()
                }
            }
            completionHandler(imageData)
        })
    }
    
    @available(iOS 14.0, *)
    public func createPdf (configuration: [String: Any?]?, completionHandler: @escaping (_ pdf: Data?) -> Void) {
        let pdfConfiguration: WKPDFConfiguration = .init()
        if let configuration = configuration {
            if let rect = configuration["rect"] as? [String: Double] {
                pdfConfiguration.rect = CGRect(x: rect["x"]!, y: rect["y"]!, width: rect["width"]!, height: rect["height"]!)
            }
        }
        createPDF(configuration: pdfConfiguration) { (result) in
            switch (result) {
            case .success(let data):
                completionHandler(data)
                return
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(nil)
                return
            }
        }
    }
    
    @available(iOS 14.0, *)
    public func createWebArchiveData (dataCompletionHandler: @escaping (_ webArchiveData: Data?) -> Void) {
        createWebArchiveData(completionHandler: { (result) in
            switch (result) {
            case .success(let data):
                dataCompletionHandler(data)
                return
            case .failure(let error):
                print(error.localizedDescription)
                dataCompletionHandler(nil)
                return
            }
        })
    }
    
    @available(iOS 14.0, *)
    public func saveWebArchive (filePath: String, autoname: Bool, completionHandler: @escaping (_ path: String?) -> Void) {
        createWebArchiveData(dataCompletionHandler: { (webArchiveData) in
            if let webArchiveData = webArchiveData {
                var localUrl = URL(fileURLWithPath: filePath)
                if autoname {
                    if let url = self.url {
                        // tries to mimic Android saveWebArchive method
                        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
                                    .union(.newlines)
                                    .union(.illegalCharacters)
                                    .union(.controlCharacters)
                                
                        let currentPageUrlFileName = url.path
                            .components(separatedBy: invalidCharacters)
                            .joined(separator: "")
                        
                        let fullPath = filePath + "/" + currentPageUrlFileName + ".webarchive"
                        localUrl = URL(fileURLWithPath: fullPath)
                    } else {
                        completionHandler(nil)
                        return
                    }
                }
                do {
                    try webArchiveData.write(to: localUrl)
                    completionHandler(localUrl.path)
                } catch {
                    // Catch any errors
                    print(error.localizedDescription)
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        })
    }
    
    public func loadUrl(urlRequest: URLRequest, allowingReadAccessTo: URL?) {
        let url = urlRequest.url!
        
        if #available(iOS 9.0, *), let allowingReadAccessTo = allowingReadAccessTo, url.scheme == "file", allowingReadAccessTo.scheme == "file" {
            loadFileURL(url, allowingReadAccessTo: allowingReadAccessTo)
        } else {
            load(urlRequest)
        }
    }
    
    public func postUrl(url: URL, postData: Data) {
        var request = URLRequest(url: url)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        load(request)
    }
    
    public func loadData(data: String, mimeType: String, encoding: String, baseUrl: URL, allowingReadAccessTo: URL?) {
        if #available(iOS 9.0, *), let allowingReadAccessTo = allowingReadAccessTo, baseUrl.scheme == "file", allowingReadAccessTo.scheme == "file" {
            loadFileURL(baseUrl, allowingReadAccessTo: allowingReadAccessTo)
        }
        
        if #available(iOS 9.0, *) {
            load(data.data(using: .utf8)!, mimeType: mimeType, characterEncodingName: encoding, baseURL: baseUrl)
        } else {
            loadHTMLString(data, baseURL: baseUrl)
        }
    }
    
    public func loadFile(assetFilePath: String) throws {
        let assetURL = try Util.getUrlAsset(assetFilePath: assetFilePath)
        let urlRequest = URLRequest(url: assetURL)
        loadUrl(urlRequest: urlRequest, allowingReadAccessTo: nil)
    }
    
    func setOptions(newOptions: InAppWebViewOptions, newOptionsMap: [String: Any]) {
        
        // MUST be the first! In this way, all the options that uses evaluateJavaScript can be applied/blocked!
        if #available(iOS 13.0, *) {
            if newOptionsMap["applePayAPIEnabled"] != nil && options?.applePayAPIEnabled != newOptions.applePayAPIEnabled {
                if let options = options {
                    options.applePayAPIEnabled = newOptions.applePayAPIEnabled
                }
                if !newOptions.applePayAPIEnabled {
                    // re-add WKUserScripts for the next page load
                    prepareAndAddUserScripts()
                } else {
                    configuration.userContentController.removeAllUserScripts()
                }
            }
        }
        
        if newOptionsMap["transparentBackground"] != nil && options?.transparentBackground != newOptions.transparentBackground {
            if newOptions.transparentBackground {
                isOpaque = false
                backgroundColor = UIColor.clear
                scrollView.backgroundColor = UIColor.clear
            } else {
                isOpaque = true
                backgroundColor = nil
                scrollView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
        if newOptionsMap["disallowOverScroll"] != nil && options?.disallowOverScroll != newOptions.disallowOverScroll {
            if responds(to: #selector(getter: scrollView)) {
                scrollView.bounces = !newOptions.disallowOverScroll
            }
            else {
                for subview: UIView in subviews {
                    if subview is UIScrollView {
                        (subview as! UIScrollView).bounces = !newOptions.disallowOverScroll
                    }
                }
            }
        }
        
        if #available(iOS 9.0, *) {
            if (newOptionsMap["incognito"] != nil && options?.incognito != newOptions.incognito && newOptions.incognito) {
                configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            } else if (newOptionsMap["cacheEnabled"] != nil && options?.cacheEnabled != newOptions.cacheEnabled && newOptions.cacheEnabled) {
                configuration.websiteDataStore = WKWebsiteDataStore.default()
            }
        }
        
        if #available(iOS 11.0, *) {
            if (newOptionsMap["sharedCookiesEnabled"] != nil && options?.sharedCookiesEnabled != newOptions.sharedCookiesEnabled && newOptions.sharedCookiesEnabled) {
                if(!newOptions.incognito && !newOptions.cacheEnabled) {
                    configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                }
                for cookie in HTTPCookieStorage.shared.cookies ?? [] {
                    configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
                }
            }
            if newOptionsMap["accessibilityIgnoresInvertColors"] != nil && options?.accessibilityIgnoresInvertColors != newOptions.accessibilityIgnoresInvertColors {
                accessibilityIgnoresInvertColors = newOptions.accessibilityIgnoresInvertColors
            }
            if newOptionsMap["contentInsetAdjustmentBehavior"] != nil && options?.contentInsetAdjustmentBehavior != newOptions.contentInsetAdjustmentBehavior {
                scrollView.contentInsetAdjustmentBehavior =
                    UIScrollView.ContentInsetAdjustmentBehavior.init(rawValue: newOptions.contentInsetAdjustmentBehavior)!
            }
        }
        
        if newOptionsMap["enableViewportScale"] != nil && options?.enableViewportScale != newOptions.enableViewportScale {
            if !newOptions.enableViewportScale {
                if configuration.userContentController.userScripts.contains(ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT) {
                    configuration.userContentController.removePluginScript(ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT)
                    evaluateJavaScript(NOT_ENABLE_VIEWPORT_SCALE_JS_SOURCE)
                }
            } else {
                evaluateJavaScript(ENABLE_VIEWPORT_SCALE_JS_SOURCE)
                configuration.userContentController.addUserScript(ENABLE_VIEWPORT_SCALE_JS_PLUGIN_SCRIPT)
            }
        }
        
        if newOptionsMap["supportZoom"] != nil && options?.supportZoom != newOptions.supportZoom {
            if newOptions.supportZoom {
                if configuration.userContentController.userScripts.contains(NOT_SUPPORT_ZOOM_JS_PLUGIN_SCRIPT) {
                    configuration.userContentController.removePluginScript(NOT_SUPPORT_ZOOM_JS_PLUGIN_SCRIPT)
                    evaluateJavaScript(SUPPORT_ZOOM_JS_SOURCE)
                }
            } else {
                evaluateJavaScript(NOT_SUPPORT_ZOOM_JS_SOURCE)
                configuration.userContentController.addUserScript(NOT_SUPPORT_ZOOM_JS_PLUGIN_SCRIPT)
            }
        }
        
        if newOptionsMap["useOnLoadResource"] != nil && options?.useOnLoadResource != newOptions.useOnLoadResource {
            if let applePayAPIEnabled = options?.applePayAPIEnabled, !applePayAPIEnabled {
                enablePluginScriptAtRuntime(flagVariable: FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE,
                                            enable: newOptions.useOnLoadResource,
                                            pluginScript: ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT)
            } else {
                newOptions.useOnLoadResource = false
            }
        }
        
        if newOptionsMap["useShouldInterceptAjaxRequest"] != nil && options?.useShouldInterceptAjaxRequest != newOptions.useShouldInterceptAjaxRequest {
            if let applePayAPIEnabled = options?.applePayAPIEnabled, !applePayAPIEnabled {
                enablePluginScriptAtRuntime(flagVariable: FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE,
                                            enable: newOptions.useShouldInterceptAjaxRequest,
                                            pluginScript: INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT)
            } else {
                newOptions.useShouldInterceptFetchRequest = false
            }
        }
        
        if newOptionsMap["useShouldInterceptFetchRequest"] != nil && options?.useShouldInterceptFetchRequest != newOptions.useShouldInterceptFetchRequest {
            if let applePayAPIEnabled = options?.applePayAPIEnabled, !applePayAPIEnabled {
                enablePluginScriptAtRuntime(flagVariable: FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE,
                                            enable: newOptions.useShouldInterceptFetchRequest,
                                            pluginScript: INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT)
            } else {
                newOptions.useShouldInterceptFetchRequest = false
            }
        }
        
        if newOptionsMap["mediaPlaybackRequiresUserGesture"] != nil && options?.mediaPlaybackRequiresUserGesture != newOptions.mediaPlaybackRequiresUserGesture {
            if #available(iOS 10.0, *) {
                configuration.mediaTypesRequiringUserActionForPlayback = (newOptions.mediaPlaybackRequiresUserGesture) ? .all : []
            } else {
                // Fallback on earlier versions
                configuration.mediaPlaybackRequiresUserAction = newOptions.mediaPlaybackRequiresUserGesture
            }
        }
        
        if newOptionsMap["allowsInlineMediaPlayback"] != nil && options?.allowsInlineMediaPlayback != newOptions.allowsInlineMediaPlayback {
            configuration.allowsInlineMediaPlayback = newOptions.allowsInlineMediaPlayback
        }
        
        if newOptionsMap["suppressesIncrementalRendering"] != nil && options?.suppressesIncrementalRendering != newOptions.suppressesIncrementalRendering {
            configuration.suppressesIncrementalRendering = newOptions.suppressesIncrementalRendering
        }
        
        if newOptionsMap["allowsBackForwardNavigationGestures"] != nil && options?.allowsBackForwardNavigationGestures != newOptions.allowsBackForwardNavigationGestures {
            allowsBackForwardNavigationGestures = newOptions.allowsBackForwardNavigationGestures
        }
        
        if newOptionsMap["javaScriptCanOpenWindowsAutomatically"] != nil && options?.javaScriptCanOpenWindowsAutomatically != newOptions.javaScriptCanOpenWindowsAutomatically {
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = newOptions.javaScriptCanOpenWindowsAutomatically
        }
        
        if newOptionsMap["minimumFontSize"] != nil && options?.minimumFontSize != newOptions.minimumFontSize {
            configuration.preferences.minimumFontSize = CGFloat(newOptions.minimumFontSize)
        }
        
        if newOptionsMap["selectionGranularity"] != nil && options?.selectionGranularity != newOptions.selectionGranularity {
            configuration.selectionGranularity = WKSelectionGranularity.init(rawValue: newOptions.selectionGranularity)!
        }
        
        if #available(iOS 10.0, *) {
            if newOptionsMap["ignoresViewportScaleLimits"] != nil && options?.ignoresViewportScaleLimits != newOptions.ignoresViewportScaleLimits {
                configuration.ignoresViewportScaleLimits = newOptions.ignoresViewportScaleLimits
            }
            
            if newOptionsMap["dataDetectorTypes"] != nil && options?.dataDetectorTypes != newOptions.dataDetectorTypes {
                var dataDetectorTypes = WKDataDetectorTypes.init(rawValue: 0)
                for type in newOptions.dataDetectorTypes {
                    let dataDetectorType = Util.getDataDetectorType(type: type)
                    dataDetectorTypes = WKDataDetectorTypes(rawValue: dataDetectorTypes.rawValue | dataDetectorType.rawValue)
                }
                configuration.dataDetectorTypes = dataDetectorTypes
            }
        }
        
        if #available(iOS 13.0, *) {
            if newOptionsMap["isFraudulentWebsiteWarningEnabled"] != nil && options?.isFraudulentWebsiteWarningEnabled != newOptions.isFraudulentWebsiteWarningEnabled {
                configuration.preferences.isFraudulentWebsiteWarningEnabled = newOptions.isFraudulentWebsiteWarningEnabled
            }
            if newOptionsMap["preferredContentMode"] != nil && options?.preferredContentMode != newOptions.preferredContentMode {
                configuration.defaultWebpagePreferences.preferredContentMode = WKWebpagePreferences.ContentMode(rawValue: newOptions.preferredContentMode)!
            }
            if newOptionsMap["automaticallyAdjustsScrollIndicatorInsets"] != nil && options?.automaticallyAdjustsScrollIndicatorInsets != newOptions.automaticallyAdjustsScrollIndicatorInsets {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = newOptions.automaticallyAdjustsScrollIndicatorInsets
            }
        }
        
        if newOptionsMap["disableVerticalScroll"] != nil && options?.disableVerticalScroll != newOptions.disableVerticalScroll {
            scrollView.showsVerticalScrollIndicator = !newOptions.disableVerticalScroll
        }
        if newOptionsMap["disableHorizontalScroll"] != nil && options?.disableHorizontalScroll != newOptions.disableHorizontalScroll {
            scrollView.showsHorizontalScrollIndicator = !newOptions.disableHorizontalScroll
        }
        
        if newOptionsMap["verticalScrollBarEnabled"] != nil && options?.verticalScrollBarEnabled != newOptions.verticalScrollBarEnabled {
            scrollView.showsVerticalScrollIndicator = newOptions.verticalScrollBarEnabled
        }
        if newOptionsMap["horizontalScrollBarEnabled"] != nil && options?.horizontalScrollBarEnabled != newOptions.horizontalScrollBarEnabled {
            scrollView.showsHorizontalScrollIndicator = newOptions.horizontalScrollBarEnabled
        }
        
        if newOptionsMap["isDirectionalLockEnabled"] != nil && options?.isDirectionalLockEnabled != newOptions.isDirectionalLockEnabled {
            scrollView.isDirectionalLockEnabled = newOptions.isDirectionalLockEnabled
        }
        
        if newOptionsMap["decelerationRate"] != nil && options?.decelerationRate != newOptions.decelerationRate {
            scrollView.decelerationRate = Util.getDecelerationRate(type: newOptions.decelerationRate)
        }
        if newOptionsMap["alwaysBounceVertical"] != nil && options?.alwaysBounceVertical != newOptions.alwaysBounceVertical {
            scrollView.alwaysBounceVertical = newOptions.alwaysBounceVertical
        }
        if newOptionsMap["alwaysBounceHorizontal"] != nil && options?.alwaysBounceHorizontal != newOptions.alwaysBounceHorizontal {
            scrollView.alwaysBounceHorizontal = newOptions.alwaysBounceHorizontal
        }
        if newOptionsMap["scrollsToTop"] != nil && options?.scrollsToTop != newOptions.scrollsToTop {
            scrollView.scrollsToTop = newOptions.scrollsToTop
        }
        if newOptionsMap["isPagingEnabled"] != nil && options?.isPagingEnabled != newOptions.isPagingEnabled {
            scrollView.scrollsToTop = newOptions.isPagingEnabled
        }
        if newOptionsMap["maximumZoomScale"] != nil && options?.maximumZoomScale != newOptions.maximumZoomScale {
            scrollView.maximumZoomScale = CGFloat(newOptions.maximumZoomScale)
        }
        if newOptionsMap["minimumZoomScale"] != nil && options?.minimumZoomScale != newOptions.minimumZoomScale {
            scrollView.minimumZoomScale = CGFloat(newOptions.minimumZoomScale)
        }
        
        if #available(iOS 9.0, *) {
            if newOptionsMap["allowsLinkPreview"] != nil && options?.allowsLinkPreview != newOptions.allowsLinkPreview {
                allowsLinkPreview = newOptions.allowsLinkPreview
            }
            if newOptionsMap["allowsAirPlayForMediaPlayback"] != nil && options?.allowsAirPlayForMediaPlayback != newOptions.allowsAirPlayForMediaPlayback {
                configuration.allowsAirPlayForMediaPlayback = newOptions.allowsAirPlayForMediaPlayback
            }
            if newOptionsMap["allowsPictureInPictureMediaPlayback"] != nil && options?.allowsPictureInPictureMediaPlayback != newOptions.allowsPictureInPictureMediaPlayback {
                configuration.allowsPictureInPictureMediaPlayback = newOptions.allowsPictureInPictureMediaPlayback
            }
            if newOptionsMap["applicationNameForUserAgent"] != nil && options?.applicationNameForUserAgent != newOptions.applicationNameForUserAgent && newOptions.applicationNameForUserAgent != "" {
                configuration.applicationNameForUserAgent = newOptions.applicationNameForUserAgent
            }
            if newOptionsMap["userAgent"] != nil && options?.userAgent != newOptions.userAgent && newOptions.userAgent != "" {
                customUserAgent = newOptions.userAgent
            }
        }
        
        if newOptionsMap["allowUniversalAccessFromFileURLs"] != nil && options?.allowUniversalAccessFromFileURLs != newOptions.allowUniversalAccessFromFileURLs {
            configuration.setValue(newOptions.allowUniversalAccessFromFileURLs, forKey: "allowUniversalAccessFromFileURLs")
        }
        
        if newOptionsMap["allowFileAccessFromFileURLs"] != nil && options?.allowFileAccessFromFileURLs != newOptions.allowFileAccessFromFileURLs {
            configuration.preferences.setValue(newOptions.allowFileAccessFromFileURLs, forKey: "allowFileAccessFromFileURLs")
        }
        
        if newOptionsMap["clearCache"] != nil && newOptions.clearCache {
            clearCache()
        }
        
        if newOptionsMap["javaScriptEnabled"] != nil && options?.javaScriptEnabled != newOptions.javaScriptEnabled {
            configuration.preferences.javaScriptEnabled = newOptions.javaScriptEnabled
        }
        
        if #available(iOS 14.0, *) {
            if options?.mediaType != newOptions.mediaType {
                mediaType = newOptions.mediaType
            }
            
            if newOptionsMap["pageZoom"] != nil && options?.pageZoom != newOptions.pageZoom {
                pageZoom = CGFloat(newOptions.pageZoom)
            }
            
            if newOptionsMap["limitsNavigationsToAppBoundDomains"] != nil && options?.limitsNavigationsToAppBoundDomains != newOptions.limitsNavigationsToAppBoundDomains {
                configuration.limitsNavigationsToAppBoundDomains = newOptions.limitsNavigationsToAppBoundDomains
            }
            
            if newOptionsMap["javaScriptEnabled"] != nil && options?.javaScriptEnabled != newOptions.javaScriptEnabled {
                configuration.defaultWebpagePreferences.allowsContentJavaScript = newOptions.javaScriptEnabled
            }
        }
        
        if #available(iOS 11.0, *), newOptionsMap["contentBlockers"] != nil {
            configuration.userContentController.removeAllContentRuleLists()
            let contentBlockers = newOptions.contentBlockers
            if contentBlockers.count > 0 {
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
                            self.configuration.userContentController.add(contentRuleList!)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        scrollView.isScrollEnabled = !(newOptions.disableVerticalScroll && newOptions.disableHorizontalScroll)
        
        self.options = newOptions
    }
    
    func getOptions() -> [String: Any?]? {
        if (self.options == nil) {
            return nil
        }
        return self.options!.getRealOptions(obj: self)
    }
    
    public func enablePluginScriptAtRuntime(flagVariable: String, enable: Bool, pluginScript: PluginScript) {
        evaluateJavascript(source: flagVariable) { (alreadyLoaded) in
            if let alreadyLoaded = alreadyLoaded as? Bool, alreadyLoaded {
                let enableSource = "\(flagVariable) = \(enable);"
                if #available(iOS 14.0, *), pluginScript.requiredInAllContentWorlds {
                    for contentWorld in self.configuration.userContentController.contentWorlds {
                        self.evaluateJavaScript(enableSource, frame: nil, contentWorld: contentWorld, completionHandler: nil)
                    }
                } else {
                    self.evaluateJavaScript(enableSource, completionHandler: nil)
                }
                if !enable {
                    self.configuration.userContentController.removePluginScripts(with: pluginScript.groupName!)
                }
            }
            else if enable {
                if #available(iOS 14.0, *), pluginScript.requiredInAllContentWorlds {
                    for contentWorld in self.configuration.userContentController.contentWorlds {
                        self.evaluateJavaScript(pluginScript.source, frame: nil, contentWorld: contentWorld, completionHandler: nil)
                        self.configuration.userContentController.addPluginScript(pluginScript)
                    }
                } else {
                    self.evaluateJavaScript(pluginScript.source, completionHandler: nil)
                    self.configuration.userContentController.addPluginScript(pluginScript)
                }
                self.configuration.userContentController.sync(scriptMessageHandler: self)
            }
        }
    }
    
    public func clearCache() {
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
    
    public func injectDeferredObject(source: String, withWrapper jsWrapper: String?, completionHandler: ((Any?) -> Void)? = nil) {
        var jsToInject = source
        if let wrapper = jsWrapper {
            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
            let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
            let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.count ?? 0) - 2))
            jsToInject = String(format: wrapper, sourceString!)
        }
        
        evaluateJavaScript(jsToInject) { (value, error) in
            guard let completionHandler = completionHandler else {
                return
            }
            
            if let error = error {
                let userInfo = (error as NSError).userInfo
                let errorMessage = userInfo["WKJavaScriptExceptionMessage"] ??
                                   userInfo["NSLocalizedDescription"] as? String ??
                                   error.localizedDescription
                self.onConsoleMessage(message: String(describing: errorMessage), messageLevel: 3)
            }
            
            if value == nil {
                completionHandler(nil)
                return
            }
            
            completionHandler(value)
        }
    }
    
    @available(iOS 14.0, *)
    public func injectDeferredObject(source: String, contentWorld: WKContentWorld, withWrapper jsWrapper: String?, completionHandler: ((Any?) -> Void)? = nil) {
        var jsToInject = source
        if let wrapper = jsWrapper {
            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
            let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
            let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.count ?? 0) - 2))
            jsToInject = String(format: wrapper, sourceString!)
        }
        
        jsToInject = configuration.userContentController.generateCodeForScriptEvaluation(scriptMessageHandler: self, source: jsToInject, contentWorld: contentWorld)
        
        evaluateJavaScript(jsToInject, frame: nil, contentWorld: contentWorld) { (evalResult) in
            guard let completionHandler = completionHandler else {
                return
            }
            
            switch (evalResult) {
            case .success(let value):
                completionHandler(value)
                return
            case .failure(let error):
                let userInfo = (error as NSError).userInfo
                let errorMessage = userInfo["WKJavaScriptExceptionMessage"] ??
                                   userInfo["NSLocalizedDescription"] as? String ??
                                   error.localizedDescription
                self.onConsoleMessage(message: String(describing: errorMessage), messageLevel: 3)
                break
            }
            
            completionHandler(nil)
        }
    }
    
    public override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        if let applePayAPIEnabled = options?.applePayAPIEnabled, applePayAPIEnabled {
            if let completionHandler = completionHandler {
                completionHandler(nil, nil)
            }
            return
        }
        super.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
    
    @available(iOS 14.0, *)
    public func evaluateJavaScript(_ javaScript: String, frame: WKFrameInfo? = nil, contentWorld: WKContentWorld, completionHandler: ((Result<Any, Error>) -> Void)? = nil) {
        if let applePayAPIEnabled = options?.applePayAPIEnabled, applePayAPIEnabled {
            return
        }
        super.evaluateJavaScript(javaScript, in: frame, in: contentWorld, completionHandler: completionHandler)
    }
    
    public func evaluateJavascript(source: String, completionHandler: ((Any?) -> Void)? = nil) {
        injectDeferredObject(source: source, withWrapper: nil, completionHandler: completionHandler)
    }
    
    @available(iOS 14.0, *)
    public func evaluateJavascript(source: String, contentWorld: WKContentWorld, completionHandler: ((Any?) -> Void)? = nil) {
        injectDeferredObject(source: source, contentWorld: contentWorld, withWrapper: nil, completionHandler: completionHandler)
    }
    
    @available(iOS 14.0, *)
    public func callAsyncJavaScript(_ functionBody: String, arguments: [String : Any] = [:], frame: WKFrameInfo? = nil, contentWorld: WKContentWorld, completionHandler: ((Result<Any, Error>) -> Void)? = nil) {
        if let applePayAPIEnabled = options?.applePayAPIEnabled, applePayAPIEnabled {
            return
        }
        super.callAsyncJavaScript(functionBody, arguments: arguments, in: frame, in: contentWorld, completionHandler: completionHandler)
    }
    
    @available(iOS 14.0, *)
    public func callAsyncJavaScript(functionBody: String, arguments: [String:Any], contentWorld: WKContentWorld, completionHandler: ((Any?) -> Void)? = nil) {
        let jsToInject = configuration.userContentController.generateCodeForScriptEvaluation(scriptMessageHandler: self, source: functionBody, contentWorld: contentWorld)
        
        callAsyncJavaScript(jsToInject, arguments: arguments, frame: nil, contentWorld: contentWorld) { (evalResult) in
            guard let completionHandler = completionHandler else {
                return
            }
            
            var body: [String: Any?] = [
                "value": nil,
                "error": nil
            ]
            
            switch (evalResult) {
            case .success(let value):
                body["value"] = value
                break
            case .failure(let error):
                let userInfo = (error as NSError).userInfo
                body["error"] = userInfo["WKJavaScriptExceptionMessage"] ??
                                userInfo["NSLocalizedDescription"] as? String ??
                                error.localizedDescription
                self.onConsoleMessage(message: String(describing: body["error"]), messageLevel: 3)
                break
            }
            
            completionHandler(body)
        }
    }
    
    @available(iOS 10.3, *)
    public func callAsyncJavaScript(functionBody: String, arguments: [String:Any], completionHandler: ((Any?) -> Void)? = nil) {
        if let applePayAPIEnabled = options?.applePayAPIEnabled, applePayAPIEnabled {
            completionHandler?(nil)
        }
        
        var jsToInject = functionBody
        
        let resultUuid = NSUUID().uuidString
        if let completionHandler = completionHandler {
            callAsyncJavaScriptBelowIOS14Results[resultUuid] = completionHandler
        }
        
        var functionArgumentNamesList: [String] = []
        var functionArgumentValuesList: [String] = []
        let keys = arguments.keys
        keys.forEach { (key) in
            functionArgumentNamesList.append(key)
            functionArgumentValuesList.append("obj.\(key)")
        }
        
        let functionArgumentNames = functionArgumentNamesList.joined(separator: ", ")
        let functionArgumentValues = functionArgumentValuesList.joined(separator: ", ")
        
        jsToInject = CALL_ASYNC_JAVASCRIPT_BELOW_IOS_14_WRAPPER_JS
            .replacingOccurrences(of: PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES, with: functionArgumentNames)
            .replacingOccurrences(of: PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_VALUES, with: functionArgumentValues)
            .replacingOccurrences(of: PluginScriptsUtil.VAR_FUNCTION_ARGUMENTS_OBJ, with: Util.JSONStringify(value: arguments))
            .replacingOccurrences(of: PluginScriptsUtil.VAR_FUNCTION_BODY, with: jsToInject)
            .replacingOccurrences(of: PluginScriptsUtil.VAR_RESULT_UUID, with: resultUuid)
        
        evaluateJavaScript(jsToInject) { (value, error) in
            if let error = error {
                let userInfo = (error as NSError).userInfo
                let errorMessage = userInfo["WKJavaScriptExceptionMessage"] ??
                                   userInfo["NSLocalizedDescription"] as? String ??
                                   error.localizedDescription
                self.onConsoleMessage(message: String(describing: errorMessage), messageLevel: 3)
                completionHandler?(nil)
                self.callAsyncJavaScriptBelowIOS14Results.removeValue(forKey: resultUuid)
            }
        }
    }
    
    public func injectJavascriptFileFromUrl(urlFile: String, scriptHtmlTagAttributes: [String:Any?]?) {
        var scriptAttributes = ""
        if let scriptHtmlTagAttributes = scriptHtmlTagAttributes {
            if let typeAttr = scriptHtmlTagAttributes["type"] as? String {
                scriptAttributes += " script.type = '\(typeAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let idAttr = scriptHtmlTagAttributes["id"] as? String {
                let scriptIdEscaped = idAttr.replacingOccurrences(of: "\'", with: "\\'")
                scriptAttributes += " script.id = '\(scriptIdEscaped)'; "
                scriptAttributes += """
                script.onload = function() {
                    if (window.\(JAVASCRIPT_BRIDGE_NAME) != null) {
                        window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('onInjectedScriptLoaded', '\(scriptIdEscaped)');
                    }
                };
                """
                scriptAttributes += """
                script.onerror = function() {
                    if (window.\(JAVASCRIPT_BRIDGE_NAME) != null) {
                        window.\(JAVASCRIPT_BRIDGE_NAME).callHandler('onInjectedScriptError', '\(scriptIdEscaped)');
                    }
                };
                """
            }
            if let asyncAttr = scriptHtmlTagAttributes["async"] as? Bool, asyncAttr {
                scriptAttributes += " script.async = true; "
            }
            if let deferAttr = scriptHtmlTagAttributes["defer"] as? Bool, deferAttr {
                scriptAttributes += " script.defer = true; "
            }
            if let crossOriginAttr = scriptHtmlTagAttributes["crossOrigin"] as? String {
                scriptAttributes += " script.crossOrigin = '\(crossOriginAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let integrityAttr = scriptHtmlTagAttributes["integrity"] as? String {
                scriptAttributes += " script.integrity = '\(integrityAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let noModuleAttr = scriptHtmlTagAttributes["noModule"] as? Bool, noModuleAttr {
                scriptAttributes += " script.noModule = true; "
            }
            if let nonceAttr = scriptHtmlTagAttributes["nonce"] as? String {
                scriptAttributes += " script.nonce = '\(nonceAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let referrerPolicyAttr = scriptHtmlTagAttributes["referrerPolicy"] as? String {
                scriptAttributes += " script.referrerPolicy = '\(referrerPolicyAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
        }
        let jsWrapper = "(function(d) { var script = d.createElement('script'); \(scriptAttributes) script.src = %@; d.body.appendChild(script); })(document);"
        injectDeferredObject(source: urlFile, withWrapper: jsWrapper, completionHandler: nil)
    }
    
    public func injectCSSCode(source: String) {
        let jsWrapper = "(function(d) { var style = d.createElement('style'); style.innerHTML = %@; d.head.appendChild(style); })(document);"
        injectDeferredObject(source: source, withWrapper: jsWrapper, completionHandler: nil)
    }
    
    public func injectCSSFileFromUrl(urlFile: String, cssLinkHtmlTagAttributes: [String:Any?]?) {
        var cssLinkAttributes = ""
        var alternateStylesheet = ""
        if let cssLinkHtmlTagAttributes = cssLinkHtmlTagAttributes {
            if let idAttr = cssLinkHtmlTagAttributes["id"] as? String {
                cssLinkAttributes += " link.id = '\(idAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let mediaAttr = cssLinkHtmlTagAttributes["media"] as? String {
                cssLinkAttributes += " link.media = '\(mediaAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let crossOriginAttr = cssLinkHtmlTagAttributes["crossOrigin"] as? String {
                cssLinkAttributes += " link.crossOrigin = '\(crossOriginAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let integrityAttr = cssLinkHtmlTagAttributes["integrity"] as? String {
                cssLinkAttributes += " link.integrity = '\(integrityAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let referrerPolicyAttr = cssLinkHtmlTagAttributes["referrerPolicy"] as? String {
                cssLinkAttributes += " link.referrerPolicy = '\(referrerPolicyAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
            if let disabledAttr = cssLinkHtmlTagAttributes["disabled"] as? Bool, disabledAttr {
                cssLinkAttributes += " link.disabled = true; "
            }
            if let alternateAttr = cssLinkHtmlTagAttributes["alternate"] as? Bool, alternateAttr {
                alternateStylesheet = "alternate "
            }
            if let titleAttr = cssLinkHtmlTagAttributes["title"] as? String {
                cssLinkAttributes += " link.title = '\(titleAttr.replacingOccurrences(of: "\'", with: "\\'"))'; "
            }
        }
        let jsWrapper = "(function(d) { var link = d.createElement('link'); link.rel='\(alternateStylesheet)stylesheet', link.type='text/css'; \(cssLinkAttributes) link.href = %@; d.head.appendChild(link); })(document);"
        injectDeferredObject(source: urlFile, withWrapper: jsWrapper, completionHandler: nil)
    }
    
    public func getCopyBackForwardList() -> [String: Any] {
        let currentList = backForwardList
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
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 preferences: WKWebpagePreferences,
                 decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        self.webView(webView, decidePolicyFor: navigationAction, decisionHandler: {(navigationActionPolicy) -> Void in
            decisionHandler(navigationActionPolicy, preferences)
        })
    }
    
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if windowId != nil, !windowCreated {
            decisionHandler(.cancel)
            return
        }
        
        if navigationAction.request.url != nil {
            
            if let useShouldOverrideUrlLoading = options?.useShouldOverrideUrlLoading, useShouldOverrideUrlLoading {
                shouldOverrideUrlLoading(navigationAction: navigationAction, result: { (result) -> Void in
                    if result is FlutterError {
                        print((result as! FlutterError).message ?? "")
                        decisionHandler(.allow)
                        return
                    }
                    else if (result as? NSObject) == FlutterMethodNotImplemented {
                        decisionHandler(.allow)
                        return
                    }
                    else {
                        var response: [String: Any]
                        if let r = result {
                            response = r as! [String: Any]
                            let action = response["action"] as? Int
                            let navigationActionPolicy = WKNavigationActionPolicy.init(rawValue: action ?? WKNavigationActionPolicy.cancel.rawValue) ??
                                WKNavigationActionPolicy.cancel
                            decisionHandler(navigationActionPolicy)
                            return;
                        }
                        decisionHandler(.allow)
                    }
                })
                return
                
            }
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.isForMainFrame, let response = navigationResponse.response as? HTTPURLResponse {
            if response.statusCode >= 400 {
                onLoadHttpError(url: response.url?.absoluteString, statusCode: response.statusCode, description: "")
            }
        }
        
        let useOnNavigationResponse = options?.useOnNavigationResponse
        
        if useOnNavigationResponse != nil, useOnNavigationResponse! {
            onNavigationResponse(navigationResponse: navigationResponse, result: { (result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message ?? "")
                    decisionHandler(.allow)
                    return
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {
                    decisionHandler(.allow)
                    return
                }
                else {
                    var response: [String: Any]
                    if let r = result {
                        response = r as! [String: Any]
                        var action = response["action"] as? Int
                        action = action != nil ? action : 0;
                        switch action {
                            case 1:
                                decisionHandler(.allow)
                                break
                            default:
                                decisionHandler(.cancel)
                        }
                        return;
                    }
                    decisionHandler(.allow)
                }
            })
        }
        
        if let useOnDownloadStart = options?.useOnDownloadStart, useOnDownloadStart {
            let mimeType = navigationResponse.response.mimeType
            if let url = navigationResponse.response.url, navigationResponse.isForMainFrame {
                if url.scheme != "file", mimeType != nil, !mimeType!.starts(with: "text/") {
                    let downloadStartRequest = DownloadStartRequest(url: url.absoluteString,
                                                                    userAgent: nil,
                                                                    contentDisposition: nil,
                                                                    mimeType: mimeType,
                                                                    contentLength: navigationResponse.response.expectedContentLength,
                                                                    suggestedFilename: navigationResponse.response.suggestedFilename,
                                                                    textEncodingName: navigationResponse.response.textEncodingName)
                    onDownloadStartRequest(request: downloadStartRequest)
                    if useOnNavigationResponse == nil || !useOnNavigationResponse! {
                        decisionHandler(.cancel)
                    }
                    return
                }
            }
        }
        
        if useOnNavigationResponse == nil || !useOnNavigationResponse! {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        currentOriginalUrl = url
        lastTouchPoint = nil
        
        disposeWebMessageChannels()
        initializeWindowIdJS()
        
        if #available(iOS 14.0, *) {
            configuration.userContentController.resetContentWorlds(windowId: windowId)
        }
        
        onLoadStart(url: url?.absoluteString)
        
        inAppBrowserDelegate?.didStartNavigation(url: url)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        initializeWindowIdJS()
        
        InAppWebView.credentialsProposed = []
        evaluateJavaScript(PLATFORM_READY_JS_SOURCE, completionHandler: nil)
        
        // sometimes scrollView.contentSize doesn't fit all the frame.size available
        // so, we call setNeedsLayout to redraw the layout
        let webViewFrameSize = frame.size
        let scrollViewSize = scrollView.contentSize
        if (scrollViewSize.width < webViewFrameSize.width || scrollViewSize.height < webViewFrameSize.height) {
            setNeedsLayout()
        }

        onLoadStop(url: url?.absoluteString)
        
        inAppBrowserDelegate?.didFinishNavigation(url: url)
    }
    
    public func webView(_ view: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        webView(view, didFail: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        InAppWebView.credentialsProposed = []
        
        var urlError = url?.absoluteString
        if let info = error._userInfo as? [String: Any] {
            if let failingUrl = info[NSURLErrorFailingURLErrorKey] as? URL {
                urlError = failingUrl.absoluteString
            }
            if let failingUrlString = info[NSURLErrorFailingURLStringErrorKey] as? String {
                urlError = failingUrlString
            }
        }
        
        onLoadError(url: urlError, error: error)
        
        inAppBrowserDelegate?.didFailNavigation(url: url, error: error)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if windowId != nil, !windowCreated {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic ||
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodDefault ||
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest ||
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNegotiate ||
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM {
            let host = challenge.protectionSpace.host
            let prot = challenge.protectionSpace.protocol
            let realm = challenge.protectionSpace.realm
            let port = challenge.protectionSpace.port
            onReceivedHttpAuthRequest(challenge: challenge, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message ?? "")
                    completionHandler(.performDefaultHandling, nil)
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {
                    completionHandler(.performDefaultHandling, nil)
                }
                else {
                    var response: [String: Any]
                    if let r = result {
                        response = r as! [String: Any]
                        var action = response["action"] as? Int
                        action = action != nil ? action : 0;
                        switch action {
                            case 0:
                                InAppWebView.credentialsProposed = []
                                // used .performDefaultHandling to mantain consistency with Android
                                // because .cancelAuthenticationChallenge will call webView(_:didFail:withError:)
                                completionHandler(.performDefaultHandling, nil)
                                //completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            case 1:
                                let username = response["username"] as! String
                                let password = response["password"] as! String
                                let permanentPersistence = response["permanentPersistence"] as? Bool ?? false
                                let persistence = (permanentPersistence) ? URLCredential.Persistence.permanent : URLCredential.Persistence.forSession
                                let credential = URLCredential(user: username, password: password, persistence: persistence)
                                completionHandler(.useCredential, credential)
                                break
                            case 2:
                                if InAppWebView.credentialsProposed.count == 0, let credentialStore = CredentialDatabase.credentialStore {
                                    for (protectionSpace, credentials) in credentialStore.allCredentials {
                                        if protectionSpace.host == host && protectionSpace.realm == realm &&
                                        protectionSpace.protocol == prot && protectionSpace.port == port {
                                            for credential in credentials {
                                                InAppWebView.credentialsProposed.append(credential.value)
                                            }
                                            break
                                        }
                                    }
                                }
                                if InAppWebView.credentialsProposed.count == 0, let credential = challenge.proposedCredential {
                                    InAppWebView.credentialsProposed.append(credential)
                                }
                                
                                if let credential = InAppWebView.credentialsProposed.popLast() {
                                    completionHandler(.useCredential, credential)
                                }
                                else {
                                    completionHandler(.performDefaultHandling, nil)
                                }
                                break
                            default:
                                InAppWebView.credentialsProposed = []
                                completionHandler(.performDefaultHandling, nil)
                        }
                        return;
                    }
                    completionHandler(.performDefaultHandling, nil)
                }
            })
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {

            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            onReceivedServerTrustAuthRequest(challenge: challenge, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message ?? "")
                    completionHandler(.performDefaultHandling, nil)
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {
                    completionHandler(.performDefaultHandling, nil)
                }
                else {
                    var response: [String: Any]
                    if let r = result {
                        response = r as! [String: Any]
                        var action = response["action"] as? Int
                        action = action != nil ? action : 0;
                        switch action {
                            case 0:
                                InAppWebView.credentialsProposed = []
                                completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            case 1:
                                let exceptions = SecTrustCopyExceptions(serverTrust)
                                SecTrustSetExceptions(serverTrust, exceptions)
                                let credential = URLCredential(trust: serverTrust)
                                completionHandler(.useCredential, credential)
                                break
                            default:
                                InAppWebView.credentialsProposed = []
                                completionHandler(.performDefaultHandling, nil)
                        }
                        return;
                    }
                    completionHandler(.performDefaultHandling, nil)
                }
            })
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            onReceivedClientCertRequest(challenge: challenge, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message ?? "")
                    completionHandler(.performDefaultHandling, nil)
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {
                    completionHandler(.performDefaultHandling, nil)
                }
                else {
                    var response: [String: Any]
                    if let r = result {
                        response = r as! [String: Any]
                        var action = response["action"] as? Int
                        action = action != nil ? action : 0;
                        switch action {
                            case 0:
                                completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            case 1:
                                let certificatePath = response["certificatePath"] as! String;
                                let certificatePassword = response["certificatePassword"] as? String ?? "";
                                
                                do {
                                    let path = try Util.getAbsPathAsset(assetFilePath: certificatePath)
                                    let PKCS12Data = NSData(contentsOfFile: path)!
                                    
                                    if let identityAndTrust: IdentityAndTrust = self.extractIdentity(PKCS12Data: PKCS12Data, password: certificatePassword) {
                                        let urlCredential: URLCredential = URLCredential(
                                            identity: identityAndTrust.identityRef,
                                            certificates: identityAndTrust.certArray as? [AnyObject],
                                            persistence: URLCredential.Persistence.forSession);
                                        completionHandler(.useCredential, urlCredential)
                                    } else {
                                        completionHandler(.performDefaultHandling, nil)
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                    completionHandler(.performDefaultHandling, nil)
                                }
                                
                                break
                            case 2:
                                completionHandler(.cancelAuthenticationChallenge, nil)
                                break
                            default:
                                completionHandler(.performDefaultHandling, nil)
                        }
                        return;
                    }
                    completionHandler(.performDefaultHandling, nil)
                }
            })
        }
        else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    struct IdentityAndTrust {

        var identityRef:SecIdentity
        var trust:SecTrust
        var certArray:AnyObject
    }

    func extractIdentity(PKCS12Data:NSData, password: String) -> IdentityAndTrust? {
        var identityAndTrust:IdentityAndTrust?
        var securityError:OSStatus = errSecSuccess

        var importResult: CFArray? = nil
        securityError = SecPKCS12Import(
            PKCS12Data as NSData,
            [kSecImportExportPassphrase as String: password] as NSDictionary,
            &importResult
        )

        if securityError == errSecSuccess {
            let certItems:CFArray = importResult! as CFArray;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = (identityPointer as! SecIdentity?)!;
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrust = trustPointer as! SecTrust;
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"];
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
            }
        } else {
            print("Security Error: " + securityError.description)
            if #available(iOS 11.3, *) {
                print(SecCopyErrorMessageString(securityError,nil) ?? "")
            }
        }
        return identityAndTrust;
    }
    
    func createAlertDialog(message: String?, responseMessage: String?, confirmButtonTitle: String?, completionHandler: @escaping () -> Void) {
        let title = responseMessage != nil && !responseMessage!.isEmpty ? responseMessage : message
        let okButton = confirmButtonTitle != nil && !confirmButtonTitle!.isEmpty ? confirmButtonTitle : NSLocalizedString("Ok", comment: "")
        let alertController = UIAlertController(title: title, message: nil,
                                                preferredStyle: UIAlertController.Style.alert);
        
        alertController.addAction(UIAlertAction(title: okButton, style: UIAlertAction.Style.default) {
            _ in completionHandler()}
        );
        
        guard let presentingViewController = inAppBrowserDelegate != nil ? inAppBrowserDelegate as? InAppBrowserWebViewController : window?.rootViewController else {
            completionHandler()
            return
        }
        presentingViewController.present(alertController, animated: true, completion: {})
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        if (isPausedTimers) {
            isPausedTimersCompletionHandler = completionHandler
            return
        }
        
        onJsAlert(frame: frame, message: message, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
                completionHandler()
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                self.createAlertDialog(message: message, responseMessage: nil, confirmButtonTitle: nil, completionHandler: completionHandler)
            }
            else {
                let response: [String: Any]
                var responseMessage: String?;
                var confirmButtonTitle: String?;
                
                if let r = result {
                    response = r as! [String: Any]
                    responseMessage = response["message"] as? String
                    confirmButtonTitle = response["confirmButtonTitle"] as? String
                    let handledByClient = response["handledByClient"] as? Bool
                    if handledByClient != nil, handledByClient! {
                        var action = response["action"] as? Int
                        action = action != nil ? action : 1;
                        switch action {
                            case 0:
                                completionHandler()
                                break
                            default:
                                completionHandler()
                        }
                        return;
                    }
                }
                
                self.createAlertDialog(message: message, responseMessage: responseMessage, confirmButtonTitle: confirmButtonTitle, completionHandler: completionHandler)
            }
        })
    }
    
    func createConfirmDialog(message: String?, responseMessage: String?, confirmButtonTitle: String?, cancelButtonTitle: String?, completionHandler: @escaping (Bool) -> Void) {
        let dialogMessage = responseMessage != nil && !responseMessage!.isEmpty ? responseMessage : message
        let okButton = confirmButtonTitle != nil && !confirmButtonTitle!.isEmpty ? confirmButtonTitle : NSLocalizedString("Ok", comment: "")
        let cancelButton = cancelButtonTitle != nil && !cancelButtonTitle!.isEmpty ? cancelButtonTitle : NSLocalizedString("Cancel", comment: "")
        
        let confirmController = UIAlertController(title: nil, message: dialogMessage, preferredStyle: .alert)
        
        confirmController.addAction(UIAlertAction(title: okButton, style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        confirmController.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        
        guard let presentingViewController = inAppBrowserDelegate != nil ? inAppBrowserDelegate as? InAppBrowserWebViewController : window?.rootViewController else {
            completionHandler(false)
            return
        }
        presentingViewController.present(confirmController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {

        onJsConfirm(frame: frame, message: message, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
                completionHandler(false)
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                self.createConfirmDialog(message: message, responseMessage: nil, confirmButtonTitle: nil, cancelButtonTitle: nil, completionHandler: completionHandler)
            }
            else {
                let response: [String: Any]
                var responseMessage: String?;
                var confirmButtonTitle: String?;
                var cancelButtonTitle: String?;
                
                if let r = result {
                    response = r as! [String: Any]
                    responseMessage = response["message"] as? String
                    confirmButtonTitle = response["confirmButtonTitle"] as? String
                    cancelButtonTitle = response["cancelButtonTitle"] as? String
                    let handledByClient = response["handledByClient"] as? Bool
                    if handledByClient != nil, handledByClient! {
                        var action = response["action"] as? Int
                        action = action != nil ? action : 1;
                        switch action {
                            case 0:
                                completionHandler(true)
                                break
                            case 1:
                                completionHandler(false)
                                break
                            default:
                                completionHandler(false)
                        }
                        return;
                    }
                }
                self.createConfirmDialog(message: message, responseMessage: responseMessage, confirmButtonTitle: confirmButtonTitle, cancelButtonTitle: cancelButtonTitle, completionHandler: completionHandler)
            }
        })
    }

    func createPromptDialog(message: String, defaultValue: String?, responseMessage: String?, confirmButtonTitle: String?, cancelButtonTitle: String?, value: String?, completionHandler: @escaping (String?) -> Void) {
        let dialogMessage = responseMessage != nil && !responseMessage!.isEmpty ? responseMessage : message
        let okButton = confirmButtonTitle != nil && !confirmButtonTitle!.isEmpty ? confirmButtonTitle : NSLocalizedString("Ok", comment: "")
        let cancelButton = cancelButtonTitle != nil && !cancelButtonTitle!.isEmpty ? cancelButtonTitle : NSLocalizedString("Cancel", comment: "")
        
        let promptController = UIAlertController(title: nil, message: dialogMessage, preferredStyle: .alert)
        
        promptController.addTextField { (textField) in
            textField.text = defaultValue
        }
        
        promptController.addAction(UIAlertAction(title: okButton, style: .default, handler: { (action) in
            if let v = value {
                completionHandler(v)
            }
            else if let text = promptController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler("")
            }
        }))
        
        promptController.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: { (action) in
            completionHandler(nil)
        }))
        
        guard let presentingViewController = inAppBrowserDelegate != nil ? inAppBrowserDelegate as? InAppBrowserWebViewController : window?.rootViewController else {
            completionHandler(nil)
            return
        }
        presentingViewController.present(promptController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt message: String, defaultText defaultValue: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        onJsPrompt(frame: frame, message: message, defaultValue: defaultValue, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
                completionHandler(nil)
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                self.createPromptDialog(message: message, defaultValue: defaultValue, responseMessage: nil, confirmButtonTitle: nil, cancelButtonTitle: nil, value: nil, completionHandler: completionHandler)
            }
            else {
                let response: [String: Any]
                var responseMessage: String?;
                var confirmButtonTitle: String?;
                var cancelButtonTitle: String?;
                var value: String?;
                
                if let r = result {
                    response = r as! [String: Any]
                    responseMessage = response["message"] as? String
                    confirmButtonTitle = response["confirmButtonTitle"] as? String
                    cancelButtonTitle = response["cancelButtonTitle"] as? String
                    let handledByClient = response["handledByClient"] as? Bool
                    value = response["value"] as? String;
                    if handledByClient != nil, handledByClient! {
                        var action = response["action"] as? Int
                        action = action != nil ? action : 1;
                        switch action {
                            case 0:
                                completionHandler(value)
                                break
                            case 1:
                                completionHandler(nil)
                                break
                            default:
                                completionHandler(nil)
                        }
                        return;
                    }
                }
                
                self.createPromptDialog(message: message, defaultValue: defaultValue, responseMessage: responseMessage, confirmButtonTitle: confirmButtonTitle, cancelButtonTitle: cancelButtonTitle, value: value, completionHandler: completionHandler)
            }
        })
    }
    
    /// UIScrollViewDelegate is somehow bugged:
    /// if InAppWebView implements the UIScrollViewDelegate protocol and implement the scrollViewDidScroll event,
    /// then, when the user scrolls the content, the webview content is not rendered (just white space).
    /// Calling setNeedsLayout() resolves this problem, but, for some reason, the bounce effect is canceled.
    ///
    /// So, to track the same event, without implementing the scrollViewDidScroll event, we create
    /// an observer that observes the scrollView.contentOffset property.
    /// This way, we don't need to call setNeedsLayout() and all works fine.
    public func onScrollChanged(startedByUser: Bool, oldContentOffset: CGPoint?) {
        let disableVerticalScroll = options?.disableVerticalScroll ?? false
        let disableHorizontalScroll = options?.disableHorizontalScroll ?? false
        if startedByUser {
            if disableVerticalScroll && disableHorizontalScroll {
                scrollView.contentOffset = CGPoint(x: lastScrollX, y: lastScrollY);
            }
            else if disableVerticalScroll {
                if scrollView.contentOffset.y >= 0 || scrollView.contentOffset.y < 0 {
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: lastScrollY);
                }
            }
            else if disableHorizontalScroll {
                if scrollView.contentOffset.x >= 0 || scrollView.contentOffset.x < 0 {
                    scrollView.contentOffset = CGPoint(x: lastScrollX, y: scrollView.contentOffset.y);
                }
            }
        }
        if (!disableVerticalScroll && !disableHorizontalScroll) ||
            (disableVerticalScroll && scrollView.contentOffset.x != oldContentOffset?.x) ||
            (disableHorizontalScroll && scrollView.contentOffset.y != oldContentOffset?.y) {
            let x = Int(scrollView.contentOffset.x / scrollView.contentScaleFactor)
            let y = Int(scrollView.contentOffset.y / scrollView.contentScaleFactor)
            onScrollChanged(x: x, y: y)
        }
        lastScrollX = scrollView.contentOffset.x
        lastScrollY = scrollView.contentOffset.y
        
        let overScrolledHorizontally = lastScrollX < 0 || lastScrollX > (scrollView.contentSize.width - scrollView.frame.size.width)
        let overScrolledVertically = lastScrollY < 0 || lastScrollY > (scrollView.contentSize.height - scrollView.frame.size.height)
        if overScrolledHorizontally || overScrolledVertically {
            let x = Int(lastScrollX / scrollView.contentScaleFactor)
            let y = Int(lastScrollY / scrollView.contentScaleFactor)
            self.onOverScrolled(x: x, y: y,
                           clampedX: overScrolledHorizontally,
                           clampedY: overScrolledVertically)
        }
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let newScale = Float(scrollView.zoomScale)
        if newScale != oldZoomScale {
            self.onZoomScaleChanged(newScale: newScale, oldScale: oldZoomScale)
            oldZoomScale = newScale
        }
    }
    
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                  for navigationAction: WKNavigationAction,
                  windowFeatures: WKWindowFeatures) -> WKWebView? {
        InAppWebView.windowAutoincrementId += 1
        let windowId = InAppWebView.windowAutoincrementId
        
        let windowWebView = InAppWebView(frame: CGRect.zero, configuration: configuration, contextMenu: nil, channel: nil)
        windowWebView.windowId = windowId
        
        let webViewTransport = WebViewTransport(
            webView: windowWebView,
            request: navigationAction.request
        )

        InAppWebView.windowWebViews[windowId] = webViewTransport
        windowWebView.stopLoading()
        
        var arguments: [String: Any?] = navigationAction.toMap()
        arguments["windowId"] = windowId
        arguments["iosWindowFeatures"] = windowFeatures.toMap()

        channel?.invokeMethod("onCreateWindow", arguments: arguments, result: { (result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
                if InAppWebView.windowWebViews[windowId] != nil {
                    InAppWebView.windowWebViews.removeValue(forKey: windowId)
                }
                return
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                if InAppWebView.windowWebViews[windowId] != nil {
                    InAppWebView.windowWebViews.removeValue(forKey: windowId)
                }
                return
            }
            else {
                var handledByClient = false
                if result != nil, result is Bool {
                    handledByClient = result as! Bool
                }
                if !handledByClient, InAppWebView.windowWebViews[windowId] != nil {
                    InAppWebView.windowWebViews.removeValue(forKey: windowId)
                    self.loadUrl(urlRequest: navigationAction.request, allowingReadAccessTo: nil)
                }
            }
        })
        
        return windowWebView
    }
    
    public func webView(_ webView: WKWebView,
                        authenticationChallenge challenge: URLAuthenticationChallenge,
                        shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        if windowId != nil, !windowCreated {
            decisionHandler(false)
            return
        }
        
        shouldAllowDeprecatedTLS(challenge: challenge, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
                decisionHandler(false)
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {
                decisionHandler(false)
            }
            else {
                var response: [String: Any]
                if let r = result {
                    response = r as! [String: Any]
                    var action = response["action"] as? Int
                    action = action != nil ? action : 0;
                    switch action {
                        case 0:
                            decisionHandler(false)
                            break
                        case 1:
                            decisionHandler(true)
                            break
                        default:
                            decisionHandler(false)
                    }
                    return;
                }
                decisionHandler(false)
            }
        })
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onCloseWindow", arguments: arguments)
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        onWebContentProcessDidTerminate()
    }
    
    public func webView(_ webView: WKWebView,
                        didCommit navigation: WKNavigation!) {
        onPageCommitVisible(url: url?.absoluteString)
    }
    
    public func webView(_ webView: WKWebView,
                        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        onDidReceiveServerRedirectForProvisionalNavigation()
    }
    
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo,
//                        completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
//        print("contextMenuConfigurationForElement")
//        let actionProvider: UIContextMenuActionProvider = { _ in
//            let editMenu = UIMenu(title: "Edit...", children: [
//                UIAction(title: "Copy") { action in
//
//                },
//                UIAction(title: "Duplicate") { action in
//
//                }
//            ])
//            return UIMenu(title: "Title", children: [
//                UIAction(title: "Share") { action in
//
//                },
//                editMenu
//            ])
//        }
//        let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
//        //completionHandler(contextMenuConfiguration)
//        completionHandler(nil)
////        onContextMenuConfigurationForElement(linkURL: elementInfo.linkURL?.absoluteString, result: nil/*{(result) -> Void in
////            if result is FlutterError {
////                print((result as! FlutterError).message ?? "")
////            }
////            else if (result as? NSObject) == FlutterMethodNotImplemented {
////                completionHandler(nil)
////            }
////            else {
////                var response: [String: Any]
////                if let r = result {
////                    response = r as! [String: Any]
////                    var action = response["action"] as? Int
////                    action = action != nil ? action : 0;
////                    switch action {
////                        case 0:
////                            break
////                        case 1:
////                            break
////                        default:
////                            completionHandler(nil)
////                    }
////                    return;
////                }
////                completionHandler(nil)
////            }
////        }*/)
//    }
////
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
//        print("contextMenuDidEndForElement")
//        print(elementInfo)
//        //onContextMenuDidEndForElement(linkURL: elementInfo.linkURL?.absoluteString)
//    }
//
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuForElement elementInfo: WKContextMenuElementInfo,
//                        willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
//        print("willCommitWithAnimator")
//        print(elementInfo)
////        onWillCommitWithAnimator(linkURL: elementInfo.linkURL?.absoluteString, result: nil/*{(result) -> Void in
////            if result is FlutterError {
////                print((result as! FlutterError).message ?? "")
////            }
////            else if (result as? NSObject) == FlutterMethodNotImplemented {
////
////            }
////            else {
////                var response: [String: Any]
////                if let r = result {
////                    response = r as! [String: Any]
////                    var action = response["action"] as? Int
////                    action = action != nil ? action : 0;
//////                    switch action {
//////                        case 0:
//////                            break
//////                        case 1:
//////                            break
//////                        default:
//////
//////                    }
////                    return;
////                }
////
////            }
////        }*/)
//    }
//
//    @available(iOS 13.0, *)
//    public func webView(_ webView: WKWebView,
//                        contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
//        print("contextMenuWillPresentForElement")
//        print(elementInfo.linkURL)
//        //onContextMenuWillPresentForElement(linkURL: elementInfo.linkURL?.absoluteString)
//    }
    
    public func onLoadStart(url: String?) {
        let arguments: [String: Any?] = ["url": url]
        channel?.invokeMethod("onLoadStart", arguments: arguments)
    }
    
    public func onLoadStop(url: String?) {
        let arguments: [String: Any?] = ["url": url]
        channel?.invokeMethod("onLoadStop", arguments: arguments)
    }
    
    public func onLoadError(url: String?, error: Error) {
        let arguments: [String: Any?] = ["url": url, "code": error._code, "message": error.localizedDescription]
        channel?.invokeMethod("onLoadError", arguments: arguments)
    }
    
    public func onLoadHttpError(url: String?, statusCode: Int, description: String) {
        let arguments: [String: Any?] = ["url": url, "statusCode": statusCode, "description": description]
        channel?.invokeMethod("onLoadHttpError", arguments: arguments)
    }
    
    public func onProgressChanged(progress: Int) {
        let arguments: [String: Any] = ["progress": progress]
        channel?.invokeMethod("onProgressChanged", arguments: arguments)
    }
    
    public func onFindResultReceived(activeMatchOrdinal: Int, numberOfMatches: Int, isDoneCounting: Bool) {
        let arguments: [String : Any] = [
            "activeMatchOrdinal": activeMatchOrdinal,
            "numberOfMatches": numberOfMatches,
            "isDoneCounting": isDoneCounting
        ]
        channel?.invokeMethod("onFindResultReceived", arguments: arguments)
    }
    
    public func onScrollChanged(x: Int, y: Int) {
        let arguments: [String: Any] = ["x": x, "y": y]
        channel?.invokeMethod("onScrollChanged", arguments: arguments)
    }
    
    public func onZoomScaleChanged(newScale: Float, oldScale: Float) {
        let arguments: [String: Any] = ["newScale": newScale, "oldScale": oldScale]
        channel?.invokeMethod("onZoomScaleChanged", arguments: arguments)
    }
    
    public func onOverScrolled(x: Int, y: Int, clampedX: Bool, clampedY: Bool) {
        let arguments: [String: Any] = ["x": x, "y": y, "clampedX": clampedX, "clampedY": clampedY]
        channel?.invokeMethod("onOverScrolled", arguments: arguments)
    }
    
    public func onDownloadStartRequest(request: DownloadStartRequest) {
        channel?.invokeMethod("onDownloadStartRequest", arguments: request.toMap())
    }
    
    public func onLoadResourceCustomScheme(url: String, result: FlutterResult?) {
        let arguments: [String: Any] = ["url": url]
        channel?.invokeMethod("onLoadResourceCustomScheme", arguments: arguments, result: result)
    }
    
    public func shouldOverrideUrlLoading(navigationAction: WKNavigationAction, result: FlutterResult?) {
        channel?.invokeMethod("shouldOverrideUrlLoading", arguments: navigationAction.toMap(), result: result)
    }
    
    public func onNavigationResponse(navigationResponse: WKNavigationResponse, result: FlutterResult?) {
        channel?.invokeMethod("onNavigationResponse", arguments: navigationResponse.toMap(), result: result)
    }
    
    public func onReceivedHttpAuthRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        channel?.invokeMethod("onReceivedHttpAuthRequest",
                              arguments: HttpAuthenticationChallenge(fromChallenge: challenge).toMap(), result: result)
    }
    
    public func onReceivedServerTrustAuthRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        if let scheme = challenge.protectionSpace.protocol, scheme == "https",
           let sslCertificate = challenge.protectionSpace.sslCertificate {
            InAppWebView.sslCertificatesMap[challenge.protectionSpace.host] = sslCertificate
        }
        channel?.invokeMethod("onReceivedServerTrustAuthRequest",
                              arguments: ServerTrustChallenge(fromChallenge: challenge).toMap(), result: result)
    }
    
    public func onReceivedClientCertRequest(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        channel?.invokeMethod("onReceivedClientCertRequest",
                              arguments: ClientCertChallenge(fromChallenge: challenge).toMap(), result: result)
    }
    
    public func shouldAllowDeprecatedTLS(challenge: URLAuthenticationChallenge, result: FlutterResult?) {
        channel?.invokeMethod("shouldAllowDeprecatedTLS", arguments: challenge.toMap(), result: result)
    }
    
    public func onJsAlert(frame: WKFrameInfo, message: String, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "url": frame.request.url?.absoluteString,
            "message": message,
            "iosIsMainFrame": frame.isMainFrame
        ]
        channel?.invokeMethod("onJsAlert", arguments: arguments, result: result)
    }
    
    public func onJsConfirm(frame: WKFrameInfo, message: String, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "url": frame.request.url?.absoluteString,
            "message": message,
            "iosIsMainFrame": frame.isMainFrame
        ]
        channel?.invokeMethod("onJsConfirm", arguments: arguments, result: result)
    }
    
    public func onJsPrompt(frame: WKFrameInfo, message: String, defaultValue: String?, result: FlutterResult?) {
        let arguments: [String: Any?] = [
            "url": frame.request.url?.absoluteString,
            "message": message,
            "defaultValue": defaultValue as Any,
            "iosIsMainFrame": frame.isMainFrame
        ]
        channel?.invokeMethod("onJsPrompt", arguments: arguments, result: result)
    }
    
    public func onConsoleMessage(message: String, messageLevel: Int) {
        let arguments: [String: Any] = ["message": message, "messageLevel": messageLevel]
        channel?.invokeMethod("onConsoleMessage", arguments: arguments)
    }
    
    public func onUpdateVisitedHistory(url: String?) {
        let arguments: [String: Any?] = [
            "url": url,
            "androidIsReload": nil
        ]
        channel?.invokeMethod("onUpdateVisitedHistory", arguments: arguments)
    }
    
    public func onTitleChanged(title: String?) {
        let arguments: [String: Any?] = [
            "title": title
        ]
        channel?.invokeMethod("onTitleChanged", arguments: arguments)
    }
    
    public func onLongPressHitTestResult(hitTestResult: HitTestResult) {
        channel?.invokeMethod("onLongPressHitTestResult", arguments: hitTestResult.toMap())
    }
    
    public func onCallJsHandler(handlerName: String, _callHandlerID: Int64, args: String) {
        let arguments: [String: Any] = ["handlerName": handlerName, "args": args]
        
        // invoke flutter javascript handler and send back flutter data as a JSON Object to javascript
        channel?.invokeMethod("onCallJsHandler", arguments: arguments, result: {(result) -> Void in
            if result is FlutterError {
                print((result as! FlutterError).message ?? "")
            }
            else if (result as? NSObject) == FlutterMethodNotImplemented {}
            else {
                var json = "null"
                if let r = result {
                    json = r as! String
                }
                
                self.evaluateJavaScript("""
if(window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)] != null) {
    window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)](\(json));
    delete window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)];
}
""", completionHandler: nil)
            }
        })
    }
    
    public func onWebContentProcessDidTerminate() {
        channel?.invokeMethod("onWebContentProcessDidTerminate", arguments: [])
    }
    
    public func onPageCommitVisible(url: String?) {
        let arguments: [String: Any?] = [
            "url": url
        ]
        channel?.invokeMethod("onPageCommitVisible", arguments: arguments)
    }
    
    public func onDidReceiveServerRedirectForProvisionalNavigation() {
        channel?.invokeMethod("onDidReceiveServerRedirectForProvisionalNavigation", arguments: [])
    }
    
    // https://stackoverflow.com/a/42840541/4637638
    public func isVideoPlayerWindow(_ notificationObject: AnyObject?) -> Bool {
        let nonVideoClasses = ["_UIAlertControllerShimPresenterWindow",
                               "UITextEffectsWindow",
                               "UIRemoteKeyboardWindow"]
        var isVideo = true
        if let obj = notificationObject {
            for nonVideoClass in nonVideoClasses {
                if let clazz = NSClassFromString(nonVideoClass) {
                    isVideo = isVideo && !(obj.isKind(of: clazz))
                }
            }
        }
        return isVideo
    }
    
    @objc func onEnterFullscreen(_ notification: Notification) {
        if (isVideoPlayerWindow(notification.object as AnyObject?)) {
            channel?.invokeMethod("onEnterFullscreen", arguments: [])
        }
    }
    
    @objc func onExitFullscreen(_ notification: Notification) {
        if (isVideoPlayerWindow(notification.object as AnyObject?)) {
            channel?.invokeMethod("onExitFullscreen", arguments: [])
        }
    }
    
//    public func onContextMenuConfigurationForElement(linkURL: String?, result: FlutterResult?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onContextMenuConfigurationForElement", arguments: arguments, result: result)
//    }
//
//    public func onContextMenuDidEndForElement(linkURL: String?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onContextMenuDidEndForElement", arguments: arguments)
//    }
//
//    public func onWillCommitWithAnimator(linkURL: String?, result: FlutterResult?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onWillCommitWithAnimator", arguments: arguments, result: result)
//    }
//
//    public func onContextMenuWillPresentForElement(linkURL: String?) {
//        let arguments: [String: Any?] = ["linkURL": linkURL]
//        channel?.invokeMethod("onContextMenuWillPresentForElement", arguments: arguments)
//    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name.starts(with: "console") {
            var messageLevel = 1
            switch (message.name) {
                case "consoleLog":
                    messageLevel = 1
                    break;
                case "consoleDebug":
                    // on Android, console.debug is TIP
                    messageLevel = 0
                    break;
                case "consoleError":
                    messageLevel = 3
                    break;
                case "consoleInfo":
                    // on Android, console.info is LOG
                    messageLevel = 1
                    break;
                case "consoleWarn":
                    messageLevel = 2
                    break;
                default:
                    messageLevel = 1
                    break;
            }
            let body = message.body as! [String: Any?]
            let consoleMessage = body["message"] as! String
            
            let _windowId = body["_windowId"] as? Int64
            var webView = self
            if let wId = _windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                webView = webViewTransport.webView
            }
            webView.onConsoleMessage(message: consoleMessage, messageLevel: messageLevel)
        } else if message.name == "callHandler" {
            let body = message.body as! [String: Any?]
            let handlerName = body["handlerName"] as! String
            if handlerName == "onPrint" {
                printCurrentPage(printCompletionHandler: nil)
            }
            let _callHandlerID = body["_callHandlerID"] as! Int64
            let args = body["args"] as! String
            
            let _windowId = body["_windowId"] as? Int64
            var webView = self
            if let wId = _windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                webView = webViewTransport.webView
            }
            webView.onCallJsHandler(handlerName: handlerName, _callHandlerID: _callHandlerID, args: args)
        } else if message.name == "onFindResultReceived" {
            let body = message.body as! [String: Any?]
            let findResult = body["findResult"] as! [String: Any]
            let activeMatchOrdinal = findResult["activeMatchOrdinal"] as! Int
            let numberOfMatches = findResult["numberOfMatches"] as! Int
            let isDoneCounting = findResult["isDoneCounting"] as! Bool
            
            let _windowId = body["_windowId"] as? Int64
            var webView = self
            if let wId = _windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
                webView = webViewTransport.webView
            }
            webView.onFindResultReceived(activeMatchOrdinal: activeMatchOrdinal, numberOfMatches: numberOfMatches, isDoneCounting: isDoneCounting)
        } else if message.name == "onCallAsyncJavaScriptResultBelowIOS14Received" {
            let body = message.body as! [String: Any?]
            let resultUuid = body["resultUuid"] as! String
            if let result = callAsyncJavaScriptBelowIOS14Results[resultUuid] {
                result([
                        "value": body["value"],
                        "error": body["error"]
                ])
                callAsyncJavaScriptBelowIOS14Results.removeValue(forKey: resultUuid)
            }
        } else if message.name == "onWebMessagePortMessageReceived" {
            let body = message.body as! [String: Any?]
            let webMessageChannelId = body["webMessageChannelId"] as! String
            let index = body["index"] as! Int64
            let webMessage = body["message"] as? String
            if let webMessageChannel = webMessageChannels[webMessageChannelId] {
                webMessageChannel.onMessage(index: index, message: webMessage)
            }
        } else if message.name == "onWebMessageListenerPostMessageReceived" {
            let body = message.body as! [String: Any?]
            let jsObjectName = body["jsObjectName"] as! String
            let messageData = body["message"] as? String
            if let webMessageListener = webMessageListeners.first(where: ({($0.jsObjectName == jsObjectName)})) {
                let isMainFrame = message.frameInfo.isMainFrame
                
                var scheme: String? = nil
                var host: String? = nil
                var port: Int? = nil
                if #available(iOS 9.0, *) {
                    let sourceOrigin = message.frameInfo.securityOrigin
                    scheme = sourceOrigin.protocol
                    host = sourceOrigin.host
                    port = sourceOrigin.port
                } else if let url = message.frameInfo.request.url {
                    scheme = url.scheme
                    host = url.host
                    port = url.port
                }
                
                if !webMessageListener.isOriginAllowed(scheme: scheme, host: host, port: port) {
                    return
                }
                
                var sourceOrigin: URL? = nil
                if let scheme = scheme, !scheme.isEmpty, let host = host, !host.isEmpty {
                    sourceOrigin = URL(string: "\(scheme)://\(host)\(port != nil && port != 0 ? ":" + String(port!) : "")")
                }
                webMessageListener.onPostMessage(message: messageData, sourceOrigin: sourceOrigin, isMainFrame: isMainFrame)
            }
        }
    }
    
    public func findAllAsync(find: String?, completionHandler: ((Any?, Error?) -> Void)?) {
        let startSearch = "window.\(JAVASCRIPT_BRIDGE_NAME)._findAllAsync('\(find ?? "")');"
        evaluateJavaScript(startSearch, completionHandler: completionHandler)
    }

    public func findNext(forward: Bool, completionHandler: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._findNext(\(forward ? "true" : "false"));", completionHandler: completionHandler)
    }

    public func clearMatches(completionHandler: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._clearMatches();", completionHandler: completionHandler)
    }
    
    public func scrollTo(x: Int, y: Int, animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
    public func scrollBy(x: Int, y: Int, animated: Bool) {
        let newX = CGFloat(x) + scrollView.contentOffset.x
        let newY = CGFloat(y) + scrollView.contentOffset.y
        scrollView.setContentOffset(CGPoint(x: newX, y: newY), animated: animated)
    }
    
    
    public func pauseTimers() {
        if !isPausedTimers {
            isPausedTimers = true
            let script = "alert();";
            self.evaluateJavaScript(script, completionHandler: nil)
        }
    }
    
    public func resumeTimers() {
        if isPausedTimers {
            if let completionHandler = isPausedTimersCompletionHandler {
                self.isPausedTimersCompletionHandler = nil
                completionHandler()
            }
            isPausedTimers = false
        }
    }
    
    public func printCurrentPage(printCompletionHandler: ((_ completed: Bool, _ error: Error?) -> Void)?) {
        let printController = UIPrintInteractionController.shared
        let printFormatter = self.viewPrintFormatter()
        printController.printFormatter = printFormatter
        
        let completionHandler: UIPrintInteractionController.CompletionHandler = { (printController, completed, error) in
            if !completed {
                if let e = error {
                    print("[PRINT] Failed: \(e.localizedDescription)")
                } else {
                    print("[PRINT] Canceled")
                }
            }
            if let callback = printCompletionHandler {
                callback(completed, error)
            }
        }
        
        printController.present(animated: true, completionHandler: completionHandler)
    }
    
    public func getContentHeight() -> Int64 {
        return Int64(scrollView.contentSize.height)
    }
    
    public func zoomBy(zoomFactor: Float, animated: Bool) {
        let currentZoomScale = scrollView.zoomScale
        scrollView.setZoomScale(currentZoomScale * CGFloat(zoomFactor), animated: animated)
    }
    
    public func getOriginalUrl() -> URL? {
        return currentOriginalUrl
    }
    
    public func getZoomScale() -> Float {
        return Float(scrollView.zoomScale)
    }
    
    public func getSelectedText(completionHandler: @escaping (Any?, Error?) -> Void) {
        if configuration.preferences.javaScriptEnabled {
            evaluateJavaScript(PluginScriptsUtil.GET_SELECTED_TEXT_JS_SOURCE, completionHandler: completionHandler)
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func getHitTestResult(completionHandler: @escaping (HitTestResult) -> Void) {
        if configuration.preferences.javaScriptEnabled, let lastTouchLocation = lastTouchPoint {
            self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._findElementsAtPoint(\(lastTouchLocation.x),\(lastTouchLocation.y))", completionHandler: {(value, error) in
                if error != nil {
                    print("getHitTestResult error: \(error?.localizedDescription ?? "")")
                    completionHandler(HitTestResult(type: .unknownType, extra: nil))
                } else if let value = value as? [String: Any?] {
                    let hitTestResult = HitTestResult.fromMap(map: value)!
                    completionHandler(hitTestResult)
                } else {
                    completionHandler(HitTestResult(type: .unknownType, extra: nil))
                }
            })
        } else {
            completionHandler(HitTestResult(type: .unknownType, extra: nil))
        }
    }
    
    public func requestFocusNodeHref(completionHandler: @escaping ([String: Any?]?, Error?) -> Void) {
        if configuration.preferences.javaScriptEnabled {
            // add some delay to make it sure _lastAnchorOrImageTouched is updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._lastAnchorOrImageTouched", completionHandler: {(value, error) in
                    let lastAnchorOrImageTouched = value as? [String: Any?]
                    completionHandler(lastAnchorOrImageTouched, error)
                })
            }
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func requestImageRef(completionHandler: @escaping ([String: Any?]?, Error?) -> Void) {
        if configuration.preferences.javaScriptEnabled {
            // add some delay to make it sure _lastImageTouched is updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)._lastImageTouched", completionHandler: {(value, error) in
                    let lastImageTouched = value as? [String: Any?]
                    completionHandler(lastImageTouched, error)
                })
            }
        } else {
            completionHandler(nil, nil)
        }
    }
    
    public func clearFocus() {
        self.scrollView.subviews.first?.resignFirstResponder()
    }
    
    public func getCertificate() -> SslCertificate? {
        guard let scheme = url?.scheme,
              scheme == "https",
              let host = url?.host,
              let sslCertificate = InAppWebView.sslCertificatesMap[host] else {
            return nil
        }
        return sslCertificate
    }
    
    public func isSecureContext(completionHandler: @escaping (_ isSecureContext: Bool) -> Void) {
        evaluateJavascript(source: "window.isSecureContext") { (isSecureContext) in
            if let isSecureContext = isSecureContext {
                completionHandler(isSecureContext as? Bool ?? false)
                return
            }
            completionHandler(false)
        }
    }
    
    public func canScrollVertically() -> Bool {
        return scrollView.contentSize.height > self.frame.height
    }
    
    public func canScrollHorizontally() -> Bool {
        return scrollView.contentSize.width > self.frame.width
    }
    
    public func enablePullToRefresh() {
        if let pullToRefreshControl = pullToRefreshControl {
            if #available(iOS 10.0, *) {
                scrollView.refreshControl = pullToRefreshControl
            } else {
                scrollView.addSubview(pullToRefreshControl)
            }
        }
    }
    
    public func disablePullToRefresh() {
        pullToRefreshControl?.removeFromSuperview()
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = nil
        }
    }
    
    public func createWebMessageChannel(completionHandler: ((WebMessageChannel) -> Void)? = nil) -> WebMessageChannel {
        let id = NSUUID().uuidString
        let webMessageChannel = WebMessageChannel(id: id)
        webMessageChannel.initJsInstance(webView: self, completionHandler: completionHandler)
        webMessageChannels[id] = webMessageChannel
        
        return webMessageChannel
    }
    
    public func postWebMessage(message: WebMessage, targetOrigin: String, completionHandler: ((Any?) -> Void)? = nil) throws {
        var portsString = "null"
        if let ports = message.ports {
            var portArrayString: [String] = []
            for port in ports {
                if port.isStarted {
                    throw NSError(domain: "Port is already started", code: 0)
                }
                if port.isClosed || port.isTransferred {
                    throw NSError(domain: "Port is already closed or transferred", code: 0)
                }
                port.isTransferred = true
                portArrayString.append("\(WEB_MESSAGE_CHANNELS_VARIABLE_NAME)['\(port.webMessageChannel!.id)'].\(port.name)")
            }
            portsString = "[" + portArrayString.joined(separator: ", ") + "]"
        }
        let data = message.data?.replacingOccurrences(of: "\'", with: "\\'") ?? "null"
        let url = URL(string: targetOrigin)?.absoluteString ?? "*"
        let source = """
        (function() {
            window.postMessage('\(data)', '\(url)', \(portsString));
        })();
        """
        evaluateJavascript(source: source, completionHandler: completionHandler)
        message.dispose()
    }
    
    public func addWebMessageListener(webMessageListener: WebMessageListener) throws {
        if webMessageListeners.map({ ($0.jsObjectName) }).contains(webMessageListener.jsObjectName) {
            throw NSError(domain: "jsObjectName \(webMessageListener.jsObjectName) was already added.", code: 0)
        }
        try webMessageListener.assertOriginRulesValid()
        webMessageListener.initJsInstance(webView: self)
        webMessageListeners.append(webMessageListener)
    }
    
    public func disposeWebMessageChannels() {
        for webMessageChannel in webMessageChannels.values {
            webMessageChannel.dispose()
        }
        webMessageChannels.removeAll()
    }
    
    public func dispose() {
        channel = nil
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.zoomScale))
        resumeTimers()
        stopLoading()
        disposeWebMessageChannels()
        for webMessageListener in webMessageListeners {
            webMessageListener.dispose()
        }
        webMessageListeners.removeAll()
        if windowId == nil {
            configuration.userContentController.removeAllPluginScriptMessageHandlers()
            configuration.userContentController.removeScriptMessageHandler(forName: "onCallAsyncJavaScriptResultBelowIOS14Received")
            configuration.userContentController.removeScriptMessageHandler(forName: "onWebMessagePortMessageReceived")
            configuration.userContentController.removeScriptMessageHandler(forName: "onWebMessageListenerPostMessageReceived")
            configuration.userContentController.removeAllUserScripts()
            if #available(iOS 11.0, *) {
                configuration.userContentController.removeAllContentRuleLists()
            }
        } else if let wId = windowId, InAppWebView.windowWebViews[wId] != nil {
            InAppWebView.windowWebViews.removeValue(forKey: wId)
        }
        configuration.userContentController.dispose(windowId: windowId)
        NotificationCenter.default.removeObserver(self)
        for imp in customIMPs {
            imp_removeBlock(imp)
        }
        longPressRecognizer.removeTarget(self, action: #selector(longPressGestureDetected))
        longPressRecognizer.delegate = nil
        scrollView.removeGestureRecognizer(longPressRecognizer)
        recognizerForDisablingContextMenuOnLinks.removeTarget(self, action: #selector(longPressGestureDetected))
        recognizerForDisablingContextMenuOnLinks.delegate = nil
        scrollView.removeGestureRecognizer(recognizerForDisablingContextMenuOnLinks)
        panGestureRecognizer.removeTarget(self, action: #selector(endDraggingDetected))
        panGestureRecognizer.delegate = nil
        scrollView.removeGestureRecognizer(panGestureRecognizer)
        disablePullToRefresh()
        pullToRefreshControl?.dispose()
        pullToRefreshControl = nil
        uiDelegate = nil
        navigationDelegate = nil
        scrollView.delegate = nil
        isPausedTimersCompletionHandler = nil
        SharedLastTouchPointTimestamp.removeValue(forKey: self)
        callAsyncJavaScriptBelowIOS14Results.removeAll()
        super.removeFromSuperview()
    }
    
    deinit {
        print("InAppWebView - dealloc")
    }
    
    // https://stackoverflow.com/a/58001395/4637638
    public override var inputAccessoryView: UIView? {
        return options?.disableInputAccessoryView ?? false ? nil : super.inputAccessoryView
    }
}
