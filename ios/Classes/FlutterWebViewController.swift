//
//  FlutterWebViewController.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 13/11/18.
//

import Foundation
import WebKit

public class FlutterWebViewController: NSObject, FlutterPlatformView {
    
    private weak var registrar: FlutterPluginRegistrar?
    var webView: InAppWebView?
    var viewId: Int64 = 0
    var channel: FlutterMethodChannel?
    
    init(registrar: FlutterPluginRegistrar, withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: NSDictionary) {
        super.init()
        self.registrar = registrar
        self.viewId = viewId
        
        let initialUrl = (args["initialUrl"] as? String)!
        let initialFile = args["initialFile"] as? String
        let initialData = args["initialData"] as? [String: String]
        let initialHeaders = (args["initialHeaders"] as? [String: String])!
        let initialOptions = (args["initialOptions"] as? [String: Any])!
        
        let options = InAppWebViewOptions()
        options.parse(options: initialOptions)
        let preWebviewConfiguration = InAppWebView.preWKWebViewConfiguration(options: options, webViewProcessPool: SwiftFlutterPlugin.webViewProcessPool)
        
        webView = InAppWebView(frame: frame, configuration: preWebviewConfiguration, IABController: nil, IAWController: self)
        let channelName = "com.pichillilorenzo/flutter_inappwebview_" + String(viewId)
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        self.channel?.setMethodCallHandler(self.handle)
        
        webView!.options = options
        webView!.prepare()
        
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
            let data = (initialData!["data"] as? String)!
            let mimeType = (initialData!["mimeType"] as? String)!
            let encoding = (initialData!["encoding"] as? String)!
            let baseUrl = (initialData!["baseUrl"] as? String)!
            webView!.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
        }
        else {
            webView!.loadUrl(url: URL(string: initialUrl)!, headers: initialHeaders)
        }
    }
    
    public func view() -> UIView {
        return webView!
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
            case "injectScriptCode":
                if webView != nil {
                    let source = (arguments!["source"] as? String)!
                    webView!.injectScriptCode(source: source, result: result)
                }
                else {
                    result("")
                }
                break
            case "injectScriptFile":
                if webView != nil {
                    let urlFile = (arguments!["urlFile"] as? String)!
                    webView!.injectScriptFile(urlFile: urlFile)
                }
                result(true)
                break
            case "injectStyleCode":
                if webView != nil {
                    let source = (arguments!["source"] as? String)!
                    webView!.injectStyleCode(source: source)
                }
                result(true)
                break
            case "injectStyleFile":
                if webView != nil {
                    let urlFile = (arguments!["urlFile"] as? String)!
                    webView!.injectStyleFile(urlFile: urlFile)
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
                    inAppWebViewOptions.parse(options: inAppWebViewOptionsMap)
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
            case "dispose":
                dispose()
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func dispose() {
        if webView != nil {
            webView!.IABController = nil
            webView!.IAWController = nil
            webView!.uiDelegate = nil
            webView!.navigationDelegate = nil
            webView!.scrollView.delegate = nil
            webView!.stopLoading()
            webView = nil
        }
    }
}
