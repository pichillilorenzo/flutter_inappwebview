//
//  WebViewMethodHandler.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 01/02/21.
//

import Foundation
import WebKit

class InAppWebViewMethodHandler: FlutterMethodCallDelegate {
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
                let url = arguments!["url"] as! String
                let headers = arguments!["headers"] as! [String: String]
                webView?.loadUrl(url: URL(string: url)!, headers: headers)
                result(true)
                break
            case "postUrl":
                if webView != nil {
                    let url = arguments!["url"] as! String
                    let postData = arguments!["postData"] as! FlutterStandardTypedData
                    webView!.postUrl(url: URL(string: url)!, postData: postData.data, completionHandler: { () -> Void in
                        result(true)
                    })
                }
                else {
                    result(false)
                }
                break
            case "loadData":
                let data = arguments!["data"] as! String
                let mimeType = arguments!["mimeType"] as! String
                let encoding = arguments!["encoding"] as! String
                let baseUrl = arguments!["baseUrl"] as! String
                webView?.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
                result(true)
                break
            case "loadFile":
                let url = arguments!["url"] as! String
                let headers = arguments!["headers"] as! [String: String]
                
                do {
                    try webView?.loadFile(url: url, headers: headers)
                }
                catch let error as NSError {
                    result(FlutterError(code: "InAppWebViewMethodHandler", message: error.domain, details: nil))
                    return
                }
                result(true)
                break
            case "evaluateJavascript":
                if webView != nil {
                    let source = arguments!["source"] as! String
                    let contentWorldName = arguments!["contentWorld"] as? String
                    webView!.evaluateJavascript(source: source, contentWorldName: contentWorldName, result: result)
                }
                else {
                    result(nil)
                }
                break
            case "injectJavascriptFileFromUrl":
                let urlFile = arguments!["urlFile"] as! String
                webView?.injectJavascriptFileFromUrl(urlFile: urlFile)
                result(true)
                break
            case "injectCSSCode":
                let source = arguments!["source"] as! String
                webView?.injectCSSCode(source: source)
                result(true)
                break
            case "injectCSSFileFromUrl":
                let urlFile = arguments!["urlFile"] as! String
                webView?.injectCSSFileFromUrl(urlFile: urlFile)
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
                if webView != nil {
                    webView!.takeScreenshot(completionHandler: { (screenshot) -> Void in
                        result(screenshot)
                    })
                }
                else {
                    result(nil)
                }
                break
            case "setOptions":
                if let iabController = webView?.IABController {
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
                if let iabController = webView?.IABController {
                    result(iabController.getOptions())
                } else {
                    result(webView?.getOptions())
                }
                break
            case "close":
                if let iabController = webView?.IABController {
                    iabController.close()
                    result(true)
                } else {
                    result(FlutterMethodNotImplemented)
                }
                break
            case "show":
                if let iabController = webView?.IABController {
                    iabController.show()
                    result(true)
                } else {
                    result(FlutterMethodNotImplemented)
                }
                break
            case "hide":
                if let iabController = webView?.IABController {
                    iabController.hide()
                    result(true)
                } else {
                    result(FlutterMethodNotImplemented)
                }
                break
            case "getCopyBackForwardList":
                result(webView?.getCopyBackForwardList())
                break
            case "findAllAsync":
                if webView != nil {
                    let find = arguments!["find"] as! String
                    webView!.findAllAsync(find: find, completionHandler: {(value, error) in
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
                if webView != nil {
                    let forward = arguments!["forward"] as! Bool
                    webView!.findNext(forward: forward, completionHandler: {(value, error) in
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
                if webView != nil {
                    webView!.clearMatches(completionHandler: {(value, error) in
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
                if webView != nil {
                    webView!.printCurrentPage(printCompletionHandler: {(completed, error) in
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
            case "reloadFromOrigin":
                webView?.reloadFromOrigin()
                result(true)
                break
            case "getScale":
                result(webView?.getScale())
                break
            case "hasOnlySecureContent":
                result(webView?.hasOnlySecureContent)
                break
            case "getSelectedText":
                if webView != nil {
                    webView!.getSelectedText { (value, error) in
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
                if webView != nil {
                    webView!.getHitTestResult { (value, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            result(nil)
                            return
                        }
                        result(value)
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
                    result(nil)
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
                    result(nil)
                }
                break
            case "getScrollX":
                if webView != nil {
                    result(Int(webView!.scrollView.contentOffset.x))
                } else {
                    result(nil)
                }
                break
            case "getScrollY":
                if webView != nil {
                    result(Int(webView!.scrollView.contentOffset.y))
                } else {
                    result(nil)
                }
                break
            case "getCertificate":
                result(webView?.getCertificateMap())
                break
            case "addUserScript":
                let userScript = arguments!["userScript"] as! [String: Any]
                let wkUserScript = WKUserScript(source: userScript["source"] as! String,
                                                injectionTime: WKUserScriptInjectionTime.init(rawValue: userScript["injectionTime"] as! Int) ?? .atDocumentStart,
                                                forMainFrameOnly: userScript["iosForMainFrameOnly"] as! Bool)
                webView?.addUserScript(wkUserScript: wkUserScript)
                result(true)
                break
            case "removeUserScript":
                let index = arguments!["index"] as! Int
                webView?.removeUserScript(at: index)
                result(true)
                break
            case "removeAllUserScripts":
                webView?.removeAllUserScripts()
                result(true)
                break
            case "callAsyncJavaScript":
                if webView != nil, #available(iOS 10.3, *) {
                    let functionBody = arguments!["functionBody"] as! String
                    let functionArguments = arguments!["arguments"] as! [String:Any]
                    let contentWorldName = arguments!["contentWorld"] as? String
                    webView!.callAsyncJavaScript(functionBody: functionBody, arguments: functionArguments, contentWorldName: contentWorldName, result: result)
                }
                else {
                    result(nil)
                }
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    deinit {
        print("InAppWebViewMethodHandler - dealloc")
        webView = nil
    }
}
