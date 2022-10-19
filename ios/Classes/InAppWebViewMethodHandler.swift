//
//  WebViewMethodHandler.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 01/02/21.
//

import Foundation
import WebKit

public class InAppWebViewMethodHandler: FlutterMethodCallDelegate {
    var webView: InAppWebView?
    
    init(webView: InAppWebView) {
        super.init()
        self.webView = webView
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
            case "getUrl":
                result(webView?.url?.absoluteString)
                break
            case "getTitle":
                result(webView?.title)
                break
            case "getProgress":
                result( (webView != nil) ? Int(webView!.estimatedProgress * 100) : nil )
                break
            case "loadUrl":
                let urlRequest = arguments!["urlRequest"] as! [String:Any?]
                let allowingReadAccessTo = arguments!["allowingReadAccessTo"] as? String
                var allowingReadAccessToURL: URL? = nil
                if let allowingReadAccessTo = allowingReadAccessTo {
                    allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                }
                webView?.loadUrl(urlRequest: URLRequest.init(fromPluginMap: urlRequest), allowingReadAccessTo: allowingReadAccessToURL)
                result(true)
                break
            case "postUrl":
                if let webView = webView {
                    let url = arguments!["url"] as! String
                    let postData = arguments!["postData"] as! FlutterStandardTypedData
                    webView.postUrl(url: URL(string: url)!, postData: postData.data)
                }
                result(true)
                break
            case "loadData":
                let data = arguments!["data"] as! String
                let mimeType = arguments!["mimeType"] as! String
                let encoding = arguments!["encoding"] as! String
                let baseUrl = URL(string: arguments!["baseUrl"] as! String)!
                let allowingReadAccessTo = arguments!["allowingReadAccessTo"] as? String
                var allowingReadAccessToURL: URL? = nil
                if let allowingReadAccessTo = allowingReadAccessTo {
                    allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                }
                webView?.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl, allowingReadAccessTo: allowingReadAccessToURL)
                result(true)
                break
            case "loadFile":
                let assetFilePath = arguments!["assetFilePath"] as! String
                
                do {
                    try webView?.loadFile(assetFilePath: assetFilePath)
                }
                catch let error as NSError {
                    result(FlutterError(code: "InAppWebViewMethodHandler", message: error.domain, details: nil))
                    return
                }
                result(true)
                break
            case "evaluateJavascript":
                if let webView = webView {
                    let source = arguments!["source"] as! String
                    let contentWorldMap = arguments!["contentWorld"] as? [String:Any?]
                    if #available(iOS 14.0, *), let contentWorldMap = contentWorldMap {
                        let contentWorld = WKContentWorld.fromMap(map: contentWorldMap, windowId: webView.windowId)!
                        webView.evaluateJavascript(source: source, contentWorld: contentWorld) { (value) in
                            result(value)
                        }
                    } else {
                        webView.evaluateJavascript(source: source) { (value) in
                            result(value)
                        }
                    }
                }
                else {
                    result(nil)
                }
                break
            case "injectJavascriptFileFromUrl":
                let urlFile = arguments!["urlFile"] as! String
                let scriptHtmlTagAttributes = arguments!["scriptHtmlTagAttributes"] as? [String:Any?]
                webView?.injectJavascriptFileFromUrl(urlFile: urlFile, scriptHtmlTagAttributes: scriptHtmlTagAttributes)
                result(true)
                break
            case "injectCSSCode":
                let source = arguments!["source"] as! String
                webView?.injectCSSCode(source: source)
                result(true)
                break
            case "injectCSSFileFromUrl":
                let urlFile = arguments!["urlFile"] as! String
                let cssLinkHtmlTagAttributes = arguments!["cssLinkHtmlTagAttributes"] as? [String:Any?]
                webView?.injectCSSFileFromUrl(urlFile: urlFile, cssLinkHtmlTagAttributes: cssLinkHtmlTagAttributes)
                result(true)
                break
            case "reload":
                webView?.reload()
                result(true)
                break
            case "goBack":
                webView?.goBack()
                result(true)
                break
            case "canGoBack":
                result(webView?.canGoBack ?? false)
                break
            case "goForward":
                webView?.goForward()
                result(true)
                break
            case "canGoForward":
                result(webView?.canGoForward ?? false)
                break
            case "goBackOrForward":
                let steps = arguments!["steps"] as! Int
                webView?.goBackOrForward(steps: steps)
                result(true)
                break
            case "canGoBackOrForward":
                let steps = arguments!["steps"] as! Int
                result(webView?.canGoBackOrForward(steps: steps) ?? false)
                break
            case "stopLoading":
                webView?.stopLoading()
                result(true)
                break
            case "isLoading":
                result(webView?.isLoading ?? false)
                break
            case "takeScreenshot":
                if let webView = webView, #available(iOS 11.0, *) {
                    let screenshotConfiguration = arguments!["screenshotConfiguration"] as? [String: Any?]
                    webView.takeScreenshot(with: screenshotConfiguration, completionHandler: { (screenshot) -> Void in
                        result(screenshot)
                    })
                }
                else {
                    result(nil)
                }
                break
            case "setOptions":
                if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                    let inAppBrowserOptions = InAppBrowserOptions()
                    let inAppBrowserOptionsMap = arguments!["options"] as! [String: Any]
                    let _ = inAppBrowserOptions.parse(options: inAppBrowserOptionsMap)
                    iabController.setOptions(newOptions: inAppBrowserOptions, newOptionsMap: inAppBrowserOptionsMap)
                } else {
                    let inAppWebViewOptions = InAppWebViewOptions()
                    let inAppWebViewOptionsMap = arguments!["options"] as! [String: Any]
                    let _ = inAppWebViewOptions.parse(options: inAppWebViewOptionsMap)
                    webView?.setOptions(newOptions: inAppWebViewOptions, newOptionsMap: inAppWebViewOptionsMap)
                }
                result(true)
                break
            case "getOptions":
                if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                    result(iabController.getOptions())
                } else {
                    result(webView?.getOptions())
                }
                break
            case "close":
                if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                    iabController.close {
                        result(true)
                    }
                } else {
                    result(FlutterMethodNotImplemented)
                }
                break
            case "show":
                if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                    iabController.show {
                        result(true)
                    }
                } else {
                    result(FlutterMethodNotImplemented)
                }
                break
            case "hide":
                if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                    iabController.hide {
                        result(true)
                    }
                } else {
                    result(FlutterMethodNotImplemented)
                }
                break
            case "isHidden":
                if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                    result(iabController.isHidden)
                } else {
                    result(FlutterMethodNotImplemented)
                }
                break
            case "getCopyBackForwardList":
                result(webView?.getCopyBackForwardList())
                break
            case "findAllAsync":
                if let webView = webView {
                    let find = arguments!["find"] as! String
                    webView.findAllAsync(find: find, completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "InAppWebViewMethodHandler", message: error?.localizedDescription, details: nil))
                        return
                    }
                    result(true)
                })
                } else {
                    result(false)
                }
                break
            case "findNext":
                if let webView = webView {
                    let forward = arguments!["forward"] as! Bool
                    webView.findNext(forward: forward, completionHandler: {(value, error) in
                        if error != nil {
                            result(FlutterError(code: "InAppWebViewMethodHandler", message: error?.localizedDescription, details: nil))
                            return
                        }
                        result(true)
                    })
                } else {
                    result(false)
                }
                break
            case "clearMatches":
                if let webView = webView {
                    webView.clearMatches(completionHandler: {(value, error) in
                        if error != nil {
                            result(FlutterError(code: "InAppWebViewMethodHandler", message: error?.localizedDescription, details: nil))
                            return
                        }
                        result(true)
                    })
                } else {
                    result(false)
                }
                break
            case "clearCache":
                webView?.clearCache()
                result(true)
                break
            case "scrollTo":
                let x = arguments!["x"] as! Int
                let y = arguments!["y"] as! Int
                let animated = arguments!["animated"] as! Bool
                webView?.scrollTo(x: x, y: y, animated: animated)
                result(true)
                break
            case "scrollBy":
                let x = arguments!["x"] as! Int
                let y = arguments!["y"] as! Int
                let animated = arguments!["animated"] as! Bool
                webView?.scrollBy(x: x, y: y, animated: animated)
                result(true)
                break
            case "pauseTimers":
                webView?.pauseTimers()
                result(true)
                break
            case "resumeTimers":
                webView?.resumeTimers()
                result(true)
                break
            case "printCurrentPage":
                if let webView = webView {
                    webView.printCurrentPage(printCompletionHandler: {(completed, error) in
                        if !completed, let err = error {
                            print(err.localizedDescription)
                            result(false)
                            return
                        }
                        result(true)
                    })
                } else {
                    result(false)
                }
                break
            case "getContentHeight":
                result(webView?.getContentHeight())
                break
            case "zoomBy":
                let zoomFactor = (arguments!["zoomFactor"] as! NSNumber).floatValue
                let animated = arguments!["animated"] as! Bool
                webView?.zoomBy(zoomFactor: zoomFactor, animated: animated)
                result(true)
                break
            case "reloadFromOrigin":
                webView?.reloadFromOrigin()
                result(true)
                break
            case "getOriginalUrl":
                result(webView?.getOriginalUrl()?.absoluteString)
                break
            case "getZoomScale":
                result(webView?.getZoomScale())
                break
            case "hasOnlySecureContent":
                result(webView?.hasOnlySecureContent ?? false)
                break
            case "getSelectedText":
                if let webView = webView {
                    webView.getSelectedText { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            result("")
                            return
                        }
                        result(value)
                    }
                }
                else {
                    result(nil)
                }
                break
            case "getHitTestResult":
                if let webView = webView {
                    webView.getHitTestResult { (hitTestResult) in
                        result(hitTestResult.toMap())
                    }
                }
                else {
                    result(nil)
                }
                break
            case "clearFocus":
                webView?.clearFocus()
                result(true)
                break
            case "setContextMenu":
                if let webView = webView {
                    let contextMenu = arguments!["contextMenu"] as? [String: Any]
                    webView.contextMenu = contextMenu
                    result(true)
                } else {
                    result(false)
                }
                break
            case "requestFocusNodeHref":
                if let webView = webView {
                    webView.requestFocusNodeHref { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            result(nil)
                            return
                        }
                        result(value)
                    }
                } else {
                    result(nil)
                }
                break
            case "requestImageRef":
                if let webView = webView {
                    webView.requestImageRef { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            result(nil)
                            return
                        }
                        result(value)
                    }
                } else {
                    result(nil)
                }
                break
            case "getScrollX":
                if let webView = webView {
                    result(Int(webView.scrollView.contentOffset.x))
                } else {
                    result(nil)
                }
                break
            case "getScrollY":
                if let webView = webView {
                    result(Int(webView.scrollView.contentOffset.y))
                } else {
                    result(nil)
                }
                break
            case "getCertificate":
                result(webView?.getCertificate()?.toMap())
                break
            case "addUserScript":
                if let webView = webView {
                    let userScriptMap = arguments!["userScript"] as! [String: Any?]
                    let userScript = UserScript.fromMap(map: userScriptMap, windowId: webView.windowId)!
                    webView.configuration.userContentController.addUserOnlyScript(userScript)
                    webView.configuration.userContentController.sync(scriptMessageHandler: webView)
                }
                result(true)
                break
            case "removeUserScript":
                let index = arguments!["index"] as! Int
                let userScriptMap = arguments!["userScript"] as! [String: Any?]
                let userScript = UserScript.fromMap(map: userScriptMap, windowId: webView?.windowId)!
                webView?.configuration.userContentController.removeUserOnlyScript(at: index, injectionTime: userScript.injectionTime)
                result(true)
                break
            case "removeUserScriptsByGroupName":
                let groupName = arguments!["groupName"] as! String
                webView?.configuration.userContentController.removeUserOnlyScripts(with: groupName)
                result(true)
                break
            case "removeAllUserScripts":
                webView?.configuration.userContentController.removeAllUserOnlyScripts()
                result(true)
                break
            case "callAsyncJavaScript":
                if let webView = webView, #available(iOS 10.3, *) {
                    if #available(iOS 14.3, *) { // on iOS 14.0, for some reason, it crashes
                        let functionBody = arguments!["functionBody"] as! String
                        let functionArguments = arguments!["arguments"] as! [String:Any]
                        var contentWorld = WKContentWorld.page
                        if let contentWorldMap = arguments!["contentWorld"] as? [String:Any?] {
                            contentWorld = WKContentWorld.fromMap(map: contentWorldMap, windowId: webView.windowId)!
                        }
                        webView.callAsyncJavaScript(functionBody: functionBody, arguments: functionArguments, contentWorld: contentWorld) { (value) in
                            result(value)
                        }
                    } else {
                        let functionBody = arguments!["functionBody"] as! String
                        let functionArguments = arguments!["arguments"] as! [String:Any]
                        webView.callAsyncJavaScript(functionBody: functionBody, arguments: functionArguments) { (value) in
                            result(value)
                        }
                    }
                }
                else {
                    result(nil)
                }
                break
            case "createPdf":
                if let webView = webView, #available(iOS 14.0, *) {
                    let configuration = arguments!["iosWKPdfConfiguration"] as? [String: Any?]
                    webView.createPdf(configuration: configuration, completionHandler: { (pdf) -> Void in
                        result(pdf)
                    })
                }
                else {
                    result(nil)
                }
                break
            case "createWebArchiveData":
                if let webView = webView, #available(iOS 14.0, *) {
                    webView.createWebArchiveData(dataCompletionHandler: { (webArchiveData) -> Void in
                        result(webArchiveData)
                    })
                }
                else {
                    result(nil)
                }
                break
            case "saveWebArchive":
                if let webView = webView, #available(iOS 14.0, *) {
                    let filePath = arguments!["filePath"] as! String
                    let autoname = arguments!["autoname"] as! Bool
                    webView.saveWebArchive(filePath: filePath, autoname: autoname, completionHandler: { (path) -> Void in
                        result(path)
                    })
                }
                else {
                    result(nil)
                }
                break
            case "isSecureContext":
                if let webView = webView {
                    webView.isSecureContext(completionHandler: { (isSecureContext) in
                        result(isSecureContext)
                    })
                }
                else {
                    result(false)
                }
                break
            case "createWebMessageChannel":
                if let webView = webView {
                    let _ = webView.createWebMessageChannel { (webMessageChannel) in
                        result(webMessageChannel.toMap())
                    }
                } else {
                    result(nil)
                }
                break
            case "postWebMessage":
                if let webView = webView {
                    let message = arguments!["message"] as! [String: Any?]
                    let targetOrigin = arguments!["targetOrigin"] as! String
                    
                    var ports: [WebMessagePort] = []
                    let portsMap = message["ports"] as? [[String: Any?]]
                    if let portsMap = portsMap {
                        for portMap in portsMap {
                            let webMessageChannelId = portMap["webMessageChannelId"] as! String
                            let index = portMap["index"] as! Int
                            if let webMessageChannel = webView.webMessageChannels[webMessageChannelId] {
                                ports.append(webMessageChannel.ports[index])
                            }
                        }
                    }
                    let webMessage = WebMessage(data: message["data"] as? String, ports: ports)
                    do {
                        try webView.postWebMessage(message: webMessage, targetOrigin: targetOrigin) { (_) in
                            result(true)
                        }
                    } catch let error as NSError {
                        result(FlutterError(code: "InAppWebViewMethodHandler", message: error.domain, details: nil))
                    }
                } else {
                    result(false)
                }
                break
            case "addWebMessageListener":
                if let webView = webView {
                    let webMessageListenerMap = arguments!["webMessageListener"] as! [String: Any?]
                    let webMessageListener = WebMessageListener.fromMap(map: webMessageListenerMap)!
                    do {
                        try webView.addWebMessageListener(webMessageListener: webMessageListener)
                        result(false)
                    } catch let error as NSError {
                        result(FlutterError(code: "InAppWebViewMethodHandler", message: error.domain, details: nil))
                    }
                } else {
                    result(false)
                }
                break
            case "canScrollVertically":
                if let webView = webView {
                    result(webView.canScrollVertically())
                } else {
                    result(false)
                }
                break
            case "canScrollHorizontally":
                if let webView = webView {
                    result(webView.canScrollHorizontally())
                } else {
                    result(false)
                }
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func dispose() {
        webView = nil
    }
    
    deinit {
        print("InAppWebViewMethodHandler - dealloc")
        dispose()
    }
}
