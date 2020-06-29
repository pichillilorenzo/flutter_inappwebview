//
//  FlutterWebViewController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 13/11/18.
//

import Foundation
import WebKit

public class FlutterWebViewController: FlutterMethodCallDelegate, FlutterPlatformView {
    
    private weak var registrar: FlutterPluginRegistrar?
    var webView: InAppWebView?
    var viewId: Any = 0
    var channel: FlutterMethodChannel?
    var myView: UIView?

    init(registrar: FlutterPluginRegistrar, withFrame frame: CGRect, viewIdentifier viewId: Any, arguments args: NSDictionary) {
        super.init()
        
        self.registrar = registrar
        self.viewId = viewId
        
        var channelName = ""
        if let id = viewId as? Int64 {
            channelName = "com.pichillilorenzo/flutter_inappwebview_" + String(id)
        } else if let id = viewId as? String {
            channelName = "com.pichillilorenzo/flutter_inappwebview_" + id
        }
        channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        channel!.setMethodCallHandler(LeakAvoider(delegate: self).handle)
        
        myView = UIView(frame: frame)
        
        let initialUrl = args["initialUrl"] as? String
        let initialFile = args["initialFile"] as? String
        let initialData = args["initialData"] as? [String: String]
        let initialHeaders = args["initialHeaders"] as? [String: String]
        let initialOptions = args["initialOptions"] as! [String: Any?]
        let contextMenu = args["contextMenu"] as? [String: Any]
        let windowId = args["windowId"] as? Int64

        let options = InAppWebViewOptions()
        let _ = options.parse(options: initialOptions)
        let preWebviewConfiguration = InAppWebView.preWKWebViewConfiguration(options: options)
        
        if let wId = windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
            webView = webViewTransport.webView
            webView!.frame = myView!.bounds
            webView!.IABController = nil
            webView!.contextMenu = contextMenu
            webView!.channel = channel!
        } else {
            webView = InAppWebView(frame: myView!.bounds, configuration: preWebviewConfiguration, IABController: nil, contextMenu: contextMenu, channel: channel!)
        }

        webView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myView!.autoresizesSubviews = true
        myView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myView!.addSubview(webView!)

        webView!.options = options
        webView!.prepare()
        
        if windowId == nil {
            if #available(iOS 11.0, *) {
                self.webView!.configuration.userContentController.removeAllContentRuleLists()
                if let contentBlockers = webView!.options?.contentBlockers, contentBlockers.count > 0 {
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

                                self.load(initialUrl: initialUrl, initialFile: initialFile, initialData: initialData, initialHeaders: initialHeaders)
                        }
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            load(initialUrl: initialUrl, initialFile: initialFile, initialData: initialData, initialHeaders: initialHeaders)
        }
        else if let wId = windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
            webView!.load(webViewTransport.request)
        }
        
        if (frame.isEmpty && viewId is String) {
            /// Note: The WKWebView behaves very unreliable when rendering offscreen
            /// on a device. This is especially true with JavaScript, which simply
            /// won't be executed sometimes.
            /// Therefore, I decided to add this very ugly hack where the rendering
            /// webview will be added to the view hierarchy (between the
            /// rootViewController's view and the key window).
            self.myView!.alpha = 0.01
            UIApplication.shared.keyWindow!.insertSubview(self.myView!, at: 0)

            let arguments: [String: Any] = ["uuid": viewId]
            channel!.invokeMethod("onHeadlessWebViewCreated", arguments: arguments)
        }
    }
    
    deinit {
        print("FlutterWebViewController - dealloc")
        channel?.setMethodCallHandler(nil)
        webView?.dispose()
        webView = nil
        myView = nil
    }
    
    public func view() -> UIView {
        return myView!
    }
    
    public func load(initialUrl: String?, initialFile: String?, initialData: [String: String]?, initialHeaders: [String: String]?) {
        if initialFile != nil {
            do {
                try webView!.loadFile(url: initialFile!, headers: initialHeaders)
            }
            catch let error as NSError {
                dump(error)
            }
            return
        }
        
        if initialData != nil {
            let data = initialData!["data"]!
            let mimeType = initialData!["mimeType"]!
            let encoding = initialData!["encoding"]!
            let baseUrl = initialData!["baseUrl"]!
            webView!.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
        }
        else if let url = URL(string: initialUrl!) {
            webView!.loadUrl(url: url, headers: initialHeaders)
        }
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "getUrl":
                result( (webView != nil) ? webView!.url?.absoluteString : nil )
                break
            case "getTitle":
                result( (webView != nil) ? webView!.title : nil )
                break
            case "getProgress":
                result( (webView != nil) ? Int(webView!.estimatedProgress * 100) : nil )
                break
            case "loadUrl":
                if webView != nil {
                    let url = (arguments!["url"] as? String)!
                    let headers = (arguments!["headers"] as? [String: String])!
                    webView!.loadUrl(url: URL(string: url)!, headers: headers)
                    result(true)
                }
                else {
                    result(false)
                }
                break
            case "postUrl":
                if webView != nil {
                    let url = (arguments!["url"] as? String)!
                    let postData = (arguments!["postData"] as? FlutterStandardTypedData)!
                    webView!.postUrl(url: URL(string: url)!, postData: postData.data, completionHandler: { () -> Void in
                        result(true)
                    })
                }
                else {
                    result(false)
                }
                break
            case "loadData":
                if webView != nil {
                    let data = (arguments!["data"] as? String)!
                    let mimeType = (arguments!["mimeType"] as? String)!
                    let encoding = (arguments!["encoding"] as? String)!
                    let baseUrl = (arguments!["baseUrl"] as? String)!
                    webView!.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
                    result(true)
                }
                else {
                    result(false)
                }
                break
            case "loadFile":
                if webView != nil {
                    let url = (arguments!["url"] as? String)!
                    let headers = (arguments!["headers"] as? [String: String])!
                    
                    do {
                        try webView!.loadFile(url: url, headers: headers)
                        result(true)
                    }
                    catch let error as NSError {
                        result(FlutterError(code: "InAppBrowserFlutterPlugin", message: error.domain, details: nil))
                        return
                    }
                }
                else {
                    result(false)
                }
                break
            case "evaluateJavascript":
                if webView != nil {
                    let source = (arguments!["source"] as? String)!
                    webView!.evaluateJavascript(source: source, result: result)
                }
                else {
                    result(nil)
                }
                break
            case "injectJavascriptFileFromUrl":
                if webView != nil {
                    let urlFile = (arguments!["urlFile"] as? String)!
                    webView!.injectJavascriptFileFromUrl(urlFile: urlFile)
                }
                result(true)
                break
            case "injectCSSCode":
                if webView != nil {
                    let source = (arguments!["source"] as? String)!
                    webView!.injectCSSCode(source: source)
                }
                result(true)
                break
            case "injectCSSFileFromUrl":
                if webView != nil {
                    let urlFile = (arguments!["urlFile"] as? String)!
                    webView!.injectCSSFileFromUrl(urlFile: urlFile)
                }
                result(true)
                break
            case "reload":
                if webView != nil {
                    webView!.reload()
                }
                result(true)
                break
            case "goBack":
                if webView != nil {
                    webView!.goBack()
                }
                result(true)
                break
            case "canGoBack":
                result((webView != nil) && webView!.canGoBack)
                break
            case "goForward":
                if webView != nil {
                    webView!.goForward()
                }
                result(true)
                break
            case "canGoForward":
                result((webView != nil) && webView!.canGoForward)
                break
            case "goBackOrForward":
                if webView != nil {
                    let steps = (arguments!["steps"] as? Int)!
                    webView!.goBackOrForward(steps: steps)
                }
                result(true)
                break
            case "canGoBackOrForward":
                let steps = (arguments!["steps"] as? Int)!
                result((webView != nil) && webView!.canGoBackOrForward(steps: steps))
                break
            case "stopLoading":
                if webView != nil {
                    webView!.stopLoading()
                }
                result(true)
                break
            case "isLoading":
                result((webView != nil) && webView!.isLoading)
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
                if webView != nil {
                    let inAppWebViewOptions = InAppWebViewOptions()
                    let inAppWebViewOptionsMap = arguments!["options"] as! [String: Any]
                    let _ = inAppWebViewOptions.parse(options: inAppWebViewOptionsMap)
                    webView!.setOptions(newOptions: inAppWebViewOptions, newOptionsMap: inAppWebViewOptionsMap)
                }
                result(true)
                break
            case "getOptions":
                result((webView != nil) ? webView!.getOptions() : nil)
                break
            case "getCopyBackForwardList":
                result((webView != nil) ? webView!.getCopyBackForwardList() : nil)
                break
            case "findAllAsync":
                if webView != nil {
                    let find = arguments!["find"] as! String
                    webView!.findAllAsync(find: find, completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "FlutterWebViewController", message: error?.localizedDescription, details: nil))
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
                            result(FlutterError(code: "FlutterWebViewController", message: error?.localizedDescription, details: nil))
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
                            result(FlutterError(code: "FlutterWebViewController", message: error?.localizedDescription, details: nil))
                            return
                        }
                        result(true)
                    })
                } else {
                    result(false)
                }
                break
            case "clearCache":
                if webView != nil {
                    webView!.clearCache()
                }
                result(true)
                break
            case "scrollTo":
                if webView != nil {
                    let x = arguments!["x"] as! Int
                    let y = arguments!["y"] as! Int
                    let animated = arguments!["animated"] as! Bool
                    webView!.scrollTo(x: x, y: y, animated: animated)
                }
                result(true)
                break
            case "scrollBy":
                if webView != nil {
                    let x = arguments!["x"] as! Int
                    let y = arguments!["y"] as! Int
                    let animated = arguments!["animated"] as! Bool
                    webView!.scrollBy(x: x, y: y, animated: animated)
                }
                result(true)
                break
            case "pauseTimers":
               if webView != nil {
                   webView!.pauseTimers()
               }
               result(true)
               break
            case "resumeTimers":
                if webView != nil {
                    webView!.resumeTimers()
                }
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
                result( (webView != nil) ? webView!.getContentHeight() : nil )
                break
            case "reloadFromOrigin":
                if webView != nil {
                    webView!.reloadFromOrigin()
                }
                result(true)
                break
            case "getScale":
                result( (webView != nil) ? webView!.getScale() : nil )
                break
            case "hasOnlySecureContent":
                result( (webView != nil) ? webView!.hasOnlySecureContent : nil )
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
}
