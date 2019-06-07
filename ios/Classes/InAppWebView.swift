//
//  InAppWebView.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 21/10/18.
//

import Flutter
import Foundation
import WebKit

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
window.\(JAVASCRIPT_BRIDGE_NAME).callHandler = function() {
    var _callHandlerID = setTimeout(function(){});
    window.webkit.messageHandlers['callHandler'].postMessage( {'handlerName': arguments[0], '_callHandlerID': _callHandlerID, 'args': JSON.stringify(Array.prototype.slice.call(arguments, 1))} );
    return new Promise(function(resolve, reject) {
        window.\(JAVASCRIPT_BRIDGE_NAME)[_callHandlerID] = resolve;
    });
}
"""

let platformReadyJS = "window.dispatchEvent(new Event('flutterInAppBrowserPlatformReady'));";

public class InAppWebView: WKWebView, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    var IABController: InAppBrowserWebViewController?
    var IAWController: FlutterWebViewController?
    var options: InAppWebViewOptions?
    var currentURL: URL?
    var WKNavigationMap: [String: [String: Any]] = [:]
    var startPageTime: Int64 = 0
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, IABController: InAppBrowserWebViewController?, IAWController: FlutterWebViewController?) {
        super.init(frame: frame, configuration: configuration)
        self.IABController = IABController
        self.IAWController = IAWController
        uiDelegate = self
        navigationDelegate = self
        scrollView.delegate = self
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public func prepare() {
        addObserver(self,
                    forKeyPath: #keyPath(WKWebView.estimatedProgress),
                    options: .new,
                    context: nil)
        
        configuration.userContentController = WKUserContentController()
        configuration.preferences = WKPreferences()
        
        if (options?.transparentBackground)! {
            isOpaque = false
            backgroundColor = UIColor.clear
            scrollView.backgroundColor = UIColor.clear
        }
        
        // prevent webView from bouncing
        if (options?.disallowOverScroll)! {
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
        
        if (options?.enableViewportScale)! {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            configuration.userContentController.addUserScript(userScript)
        }
        
        // Prevents long press on links that cause WKWebView exit
        let jscriptWebkitTouchCallout = WKUserScript(source: "document.body.style.webkitTouchCallout='none';", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(jscriptWebkitTouchCallout)
        
        
        let consoleLogJSScript = WKUserScript(source: consoleLogJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(consoleLogJSScript)
        configuration.userContentController.add(self, name: "consoleLog")
        configuration.userContentController.add(self, name: "consoleDebug")
        configuration.userContentController.add(self, name: "consoleError")
        configuration.userContentController.add(self, name: "consoleInfo")
        configuration.userContentController.add(self, name: "consoleWarn")
        
        let javaScriptBridgeJSScript = WKUserScript(source: javaScriptBridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(javaScriptBridgeJSScript)
        configuration.userContentController.add(self, name: "callHandler")
        
        let resourceObserverJSScript = WKUserScript(source: resourceObserverJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(resourceObserverJSScript)
        configuration.userContentController.add(self, name: "resourceLoaded")
        
        //keyboardDisplayRequiresUserAction = browserOptions?.keyboardDisplayRequiresUserAction
        
        configuration.suppressesIncrementalRendering = (options?.suppressesIncrementalRendering)!
        allowsBackForwardNavigationGestures = (options?.allowsBackForwardNavigationGestures)!
        if #available(iOS 9.0, *) {
            allowsLinkPreview = (options?.allowsLinkPreview)!
        }
        
        if #available(iOS 10.0, *) {
            configuration.ignoresViewportScaleLimits = (options?.ignoresViewportScaleLimits)!
        }
        
        if #available(iOS 9.0, *) {
            configuration.allowsPictureInPictureMediaPlayback = (options?.allowsPictureInPictureMediaPlayback)!
        }
        
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = (options?.javaScriptCanOpenWindowsAutomatically)!
        
        configuration.preferences.javaScriptEnabled = (options?.javaScriptEnabled)!
        
        if ((options?.userAgent)! != "") {
            if #available(iOS 9.0, *) {
                customUserAgent = (options?.userAgent)!
            }
        }
        
        if (options?.clearCache)! {
            clearCache()
        }
    }
    
    public static func preWKWebViewConfiguration(options: InAppWebViewOptions?) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = ((options?.mediaPlaybackRequiresUserGesture)!) ? .all : []
        } else {
            // Fallback on earlier versions
            configuration.mediaPlaybackRequiresUserAction = (options?.mediaPlaybackRequiresUserGesture)!
        }
        
        configuration.allowsInlineMediaPlayback = (options?.allowsInlineMediaPlayback)!
        
        return configuration
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Int(estimatedProgress * 100)
            onProgressChanged(progress: progress)
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
    
    public func takeScreenshot (completionHandler: @escaping (_ screenshot: Data?) -> Void) {
        if #available(iOS 11.0, *) {
            takeSnapshot(with: nil, completionHandler: {(image, error) -> Void in
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
    
    public func loadUrl(url: URL, headers: [String: String]?) {
        var request = URLRequest(url: url)
        currentURL = url
        if headers != nil {
            if let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
                for (key, value) in headers! {
                    mutableRequest.setValue(value, forHTTPHeaderField: key)
                }
                request = mutableRequest as URLRequest
            }
        }
        load(request)
    }
    
    public func postUrl(url: URL, postData: Data, completionHandler: @escaping () -> Void) {
        var request = URLRequest(url: url)
        currentURL = url
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
            var returnString = ""
            if data != nil {
                returnString = String(data: data!, encoding: .utf8) ?? ""
            }
            DispatchQueue.main.async(execute: {() -> Void in
                self.loadHTMLString(returnString, baseURL: url)
                completionHandler()
            })
        }
        task.resume()
    }
    
    public func loadData(data: String, mimeType: String, encoding: String, baseUrl: String) {
        let url = URL(string: baseUrl)!
        currentURL = url
        if #available(iOS 9.0, *) {
            load(data.data(using: .utf8)!, mimeType: mimeType, characterEncodingName: encoding, baseURL: url)
        } else {
            loadHTMLString(data, baseURL: url)
        }
    }
    
    public func loadFile(url: String, headers: [String: String]?) throws {
        let key = SwiftFlutterPlugin.registrar!.lookupKey(forAsset: url)
        let assetURL = Bundle.main.url(forResource: key, withExtension: nil)
        if assetURL == nil {
            throw NSError(domain: url + " asset file cannot be found!", code: 0)
        }
        loadUrl(url: assetURL!, headers: headers)
    }
    
    func setOptions(newOptions: InAppWebViewOptions, newOptionsMap: [String: Any]) {
        
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
        
        if newOptionsMap["enableViewportScale"] != nil && options?.enableViewportScale != newOptions.enableViewportScale && newOptions.enableViewportScale {
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            evaluateJavaScript(jscript, completionHandler: nil)
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
        
        //        if newOptionsMap["keyboardDisplayRequiresUserAction"] != nil && browserOptions?.keyboardDisplayRequiresUserAction != newOptions.keyboardDisplayRequiresUserAction {
        //            self.webView.keyboardDisplayRequiresUserAction = newOptions.keyboardDisplayRequiresUserAction
        //        }
        
        if newOptionsMap["suppressesIncrementalRendering"] != nil && options?.suppressesIncrementalRendering != newOptions.suppressesIncrementalRendering {
            configuration.suppressesIncrementalRendering = newOptions.suppressesIncrementalRendering
        }
        
        if newOptionsMap["allowsBackForwardNavigationGestures"] != nil && options?.allowsBackForwardNavigationGestures != newOptions.allowsBackForwardNavigationGestures {
            allowsBackForwardNavigationGestures = newOptions.allowsBackForwardNavigationGestures
        }
        
        if newOptionsMap["allowsLinkPreview"] != nil && options?.allowsLinkPreview != newOptions.allowsLinkPreview {
            if #available(iOS 9.0, *) {
                allowsLinkPreview = newOptions.allowsLinkPreview
            }
        }
        
        if newOptionsMap["ignoresViewportScaleLimits"] != nil && options?.ignoresViewportScaleLimits != newOptions.ignoresViewportScaleLimits {
            if #available(iOS 10.0, *) {
                configuration.ignoresViewportScaleLimits = newOptions.ignoresViewportScaleLimits
            }
        }
        
        if newOptionsMap["allowsInlineMediaPlayback"] != nil && options?.allowsInlineMediaPlayback != newOptions.allowsInlineMediaPlayback {
            configuration.allowsInlineMediaPlayback = newOptions.allowsInlineMediaPlayback
        }
        
        if newOptionsMap["allowsPictureInPictureMediaPlayback"] != nil && options?.allowsPictureInPictureMediaPlayback != newOptions.allowsPictureInPictureMediaPlayback {
            if #available(iOS 9.0, *) {
                configuration.allowsPictureInPictureMediaPlayback = newOptions.allowsPictureInPictureMediaPlayback
            }
        }
        
        if newOptionsMap["javaScriptCanOpenWindowsAutomatically"] != nil && options?.javaScriptCanOpenWindowsAutomatically != newOptions.javaScriptCanOpenWindowsAutomatically {
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = newOptions.javaScriptCanOpenWindowsAutomatically
        }
        
        if newOptionsMap["javaScriptEnabled"] != nil && options?.javaScriptEnabled != newOptions.javaScriptEnabled {
            configuration.preferences.javaScriptEnabled = newOptions.javaScriptEnabled
        }
        
        if newOptionsMap["userAgent"] != nil && options?.userAgent != newOptions.userAgent && (newOptions.userAgent != "") {
            if #available(iOS 9.0, *) {
                customUserAgent = newOptions.userAgent
            }
        }
        
        if newOptionsMap["clearCache"] != nil && newOptions.clearCache {
            clearCache()
        }
        
        self.options = newOptions
    }
    
    func getOptions() -> [String: Any]? {
        if (self.options == nil) {
            return nil
        }
        return self.options!.getHashMap()
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
    
    public func injectDeferredObject(source: String, withWrapper jsWrapper: String, result: FlutterResult?) {
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: [source], options: [])
        let sourceArrayString = String(data: jsonData!, encoding: String.Encoding.utf8)
        if sourceArrayString != nil {
            let sourceString: String? = (sourceArrayString! as NSString).substring(with: NSRange(location: 1, length: (sourceArrayString?.count ?? 0) - 2))
            let jsToInject = String(format: jsWrapper, sourceString!)
            
            evaluateJavaScript(jsToInject, completionHandler: {(value, error) in
                if result == nil {
                    return
                }
                
                if error != nil {
                    let userInfo = (error! as NSError).userInfo
                    self.onConsoleMessage(sourceURL: (userInfo["WKJavaScriptExceptionSourceURL"] as? URL)?.absoluteString ?? "", lineNumber: userInfo["WKJavaScriptExceptionLineNumber"] as! Int, message: userInfo["WKJavaScriptExceptionMessage"] as! String, messageLevel: "ERROR")
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
    
    public func injectScriptCode(source: String, result: FlutterResult?) {
        let jsWrapper = "(function(){return JSON.stringify(eval(%@));})();"
        injectDeferredObject(source: source, withWrapper: jsWrapper, result: result)
    }
    
    public func injectScriptFile(urlFile: String) {
        let jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(source: urlFile, withWrapper: jsWrapper, result: nil)
    }
    
    public func injectStyleCode(source: String) {
        let jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(source: source, withWrapper: jsWrapper, result: nil)
    }
    
    public func injectStyleFile(urlFile: String) {
        let jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet', c.type='text/css'; c.href = %@; d.body.appendChild(c); })(document);"
        injectDeferredObject(source: urlFile, withWrapper: jsWrapper, result: nil)
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
    
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            
            if url.absoluteString != url.absoluteString && (options?.useOnLoadResource)! {
                WKNavigationMap[url.absoluteString] = [
                    "startTime": currentTimeInMilliSeconds(),
                    "request": navigationAction.request
                ]
            }
            
            if navigationAction.navigationType == .linkActivated && (options?.useShouldOverrideUrlLoading)! {
                shouldOverrideUrlLoading(url: url)
                decisionHandler(.cancel)
                return
            }
            
            if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .backForward {
                currentURL = url
                if IABController != nil {
                    IABController!.updateUrlTextField(url: (currentURL?.absoluteString)!)
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if (options?.useOnLoadResource)! {
            if let url = navigationResponse.response.url {
                if WKNavigationMap[url.absoluteString] != nil {
                    let startResourceTime: Int64 = (WKNavigationMap[url.absoluteString]!["startTime"] as! Int64)
                    let startTime: Int64 = startResourceTime - startPageTime;
                    let duration: Int64 = currentTimeInMilliSeconds() - startResourceTime;
                    onLoadResource(response: navigationResponse.response, fromRequest: WKNavigationMap[url.absoluteString]!["request"] as? URLRequest, withData: Data(), startTime: startTime, duration: duration)
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
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.startPageTime = currentTimeInMilliSeconds()
        onLoadStart(url: (currentURL?.absoluteString)!)
        
        if IABController != nil {
            // loading url, start spinner, update back/forward
            IABController!.backButton.isEnabled = canGoBack
            IABController!.forwardButton.isEnabled = canGoForward
            
            if (IABController!.browserOptions?.spinner)! {
                IABController!.spinner.startAnimating()
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.WKNavigationMap = [:]
        currentURL = url
        onLoadStop(url: (currentURL?.absoluteString)!)
        evaluateJavaScript(platformReadyJS, completionHandler: nil)
        
        if IABController != nil {
            IABController!.updateUrlTextField(url: (currentURL?.absoluteString)!)
            IABController!.backButton.isEnabled = canGoBack
            IABController!.forwardButton.isEnabled = canGoForward
            IABController!.spinner.stopAnimating()
        }
    }
    
    public func webView(_ view: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        webView(view, didFail: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadError(url: (currentURL?.absoluteString)!, error: error)
        
        if IABController != nil {
            IABController!.backButton.isEnabled = canGoBack
            IABController!.forwardButton.isEnabled = canGoForward
            IABController!.spinner.stopAnimating()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if navigationDelegate != nil {
            let x = Int(scrollView.contentOffset.x / scrollView.contentScaleFactor)
            let y = Int(scrollView.contentOffset.y / scrollView.contentScaleFactor)
            onScrollChanged(x: x, y: y)
        }
        setNeedsLayout()
    }
    
    public func onLoadStart(url: String) {
        var arguments: [String: Any] = ["url": url]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadStart", arguments: arguments)
        }
    }
    
    public func onLoadStop(url: String) {
        var arguments: [String: Any] = ["url": url]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadStop", arguments: arguments)
        }
    }
    
    public func onLoadError(url: String, error: Error) {
        var arguments: [String: Any] = ["url": url, "code": error._code, "message": error.localizedDescription]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadError", arguments: arguments)
        }
    }
    
    public func onProgressChanged(progress: Int) {
        var arguments: [String: Any] = ["progress": progress]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onProgressChanged", arguments: arguments)
        }
    }
    
    public func onLoadResource(response: URLResponse, fromRequest request: URLRequest?, withData data: Data, startTime: Int64, duration: Int64) {
        var headersResponse = (response as! HTTPURLResponse).allHeaderFields as! [String: String]
        headersResponse.lowercaseKeys()
        
        var headersRequest = request!.allHTTPHeaderFields! as [String: String]
        headersRequest.lowercaseKeys()
        
        var arguments: [String : Any] = [
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
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onLoadResource", arguments: arguments)
        }
    }
    
    public func onScrollChanged(x: Int, y: Int) {
        var arguments: [String: Any] = ["x": x, "y": y]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onScrollChanged", arguments: arguments)
        }
    }
    
    public func shouldOverrideUrlLoading(url: URL) {
        var arguments: [String: Any] = ["url": url.absoluteString]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("shouldOverrideUrlLoading", arguments: arguments)
        }
    }
    
    public func onConsoleMessage(sourceURL: String, lineNumber: Int, message: String, messageLevel: String) {
        var arguments: [String: Any] = ["sourceURL": sourceURL, "lineNumber": lineNumber, "message": message, "messageLevel": messageLevel]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        if let channel = getChannel() {
            channel.invokeMethod("onConsoleMessage", arguments: arguments)
        }
    }
    
    public func onCallJsHandler(handlerName: String, _callHandlerID: Int64, args: String) {
        var arguments: [String: Any] = ["handlerName": handlerName, "args": args]
        if IABController != nil {
            arguments["uuid"] = IABController!.uuid
        }
        
        if let channel = getChannel() {
            channel.invokeMethod("onCallJsHandler", arguments: arguments, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message)
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {}
                else {
                    var json = "null"
                    if let r = result {
                        json = r as! String
                    }
                    self.evaluateJavaScript("window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)](\(json)); delete window.\(JAVASCRIPT_BRIDGE_NAME)[\(_callHandlerID)];", completionHandler: nil)
                }
            })
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
            onConsoleMessage(sourceURL: "", lineNumber: 1, message: message.body as! String, messageLevel: messageLevel)
        }
        else if message.name == "resourceLoaded" && (options?.useOnLoadResource)! {
            if let resource = convertToDictionary(text: message.body as! String) {
                // escape special chars
                let resourceName = (resource["name"] as! String).addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
                
                let url = URL(string: resourceName!)!
                if !UIApplication.shared.canOpenURL(url) {
                    return
                }
                let startTime: Int64 = Int64(resource["startTime"] as! Double)
                let duration: Int64 = Int64(resource["duration"] as! Double)
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
                    self.onLoadResource(response: response!, fromRequest: urlRequest, withData: withData!, startTime: startTime, duration: duration)
                }
                task.resume()
            }
        }
        else if message.name == "callHandler" {
            let body = message.body as! [String: Any]
            let handlerName = body["handlerName"] as! String
            let _callHandlerID = body["_callHandlerID"] as! Int64
            let args = body["args"] as! String
            onCallJsHandler(handlerName: handlerName, _callHandlerID: _callHandlerID, args: args)
        }
    }
    
    private func getChannel() -> FlutterMethodChannel? {
        return (IABController != nil) ? SwiftFlutterPlugin.channel! : ((IAWController != nil) ? IAWController!.channel! : nil);
    }
}
