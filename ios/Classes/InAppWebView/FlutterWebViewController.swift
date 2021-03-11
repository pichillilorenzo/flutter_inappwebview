//
//  FlutterWebViewController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 13/11/18.
//

import Foundation
import WebKit

public class FlutterWebViewController: NSObject, FlutterPlatformView {
    
    private weak var registrar: FlutterPluginRegistrar?
    var webView: InAppWebView?
    var viewId: Any = 0
    var channel: FlutterMethodChannel?
    var myView: UIView?
    var methodCallDelegate: InAppWebViewMethodHandler?

    init(registrar: FlutterPluginRegistrar, withFrame frame: CGRect, viewIdentifier viewId: Any, arguments args: NSDictionary) {
        super.init()
        
        self.registrar = registrar
        self.viewId = viewId
        
        channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappwebview_" + String(describing: viewId),
                                       binaryMessenger: registrar.messenger())
        
        myView = UIView(frame: frame)
        myView!.clipsToBounds = true
        
        let initialUrlRequest = args["initialUrlRequest"] as? [String: Any?]
        let initialFile = args["initialFile"] as? String
        let initialData = args["initialData"] as? [String: String]
        let initialOptions = args["initialOptions"] as! [String: Any?]
        let contextMenu = args["contextMenu"] as? [String: Any]
        let windowId = args["windowId"] as? Int64
        let initialUserScripts = args["initialUserScripts"] as? [[String: Any]]
        let pullToRefreshInitialOptions = args["pullToRefreshOptions"] as! [String: Any?]
        
        var userScripts: [UserScript] = []
        if let initialUserScripts = initialUserScripts {
            for intialUserScript in initialUserScripts {
                userScripts.append(UserScript.fromMap(map: intialUserScript, windowId: windowId)!)
            }
        }
        
        let options = InAppWebViewOptions()
        let _ = options.parse(options: initialOptions)
        let preWebviewConfiguration = InAppWebView.preWKWebViewConfiguration(options: options)
        
        if let wId = windowId, let webViewTransport = InAppWebView.windowWebViews[wId] {
            webView = webViewTransport.webView
            webView!.frame = myView!.bounds
            webView!.contextMenu = contextMenu
            webView!.channel = channel!
            webView!.initialUserScripts = userScripts
        } else {
            webView = InAppWebView(frame: myView!.bounds,
                                   configuration: preWebviewConfiguration,
                                   contextMenu: contextMenu,
                                   channel: channel!,
                                   userScripts: userScripts)
        }
        
        methodCallDelegate = InAppWebViewMethodHandler(webView: webView!)
        channel!.setMethodCallHandler(LeakAvoider(delegate: methodCallDelegate!).handle)
        
        let pullToRefreshLayoutChannel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_" + String(describing: viewId),
                                                              binaryMessenger: registrar.messenger())
        let pullToRefreshOptions = PullToRefreshOptions()
        let _ = pullToRefreshOptions.parse(options: pullToRefreshInitialOptions)
        let pullToRefreshControl = PullToRefreshControl(channel: pullToRefreshLayoutChannel, options: pullToRefreshOptions)
        webView!.pullToRefreshControl = pullToRefreshControl
        pullToRefreshControl.delegate = webView!
        pullToRefreshControl.prepare()

        webView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myView!.autoresizesSubviews = true
        myView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myView!.addSubview(webView!)

        webView!.options = options
        webView!.prepare()
        webView!.windowCreated = true
        
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

                                self.load(initialUrlRequest: initialUrlRequest, initialFile: initialFile, initialData: initialData)
                        }
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            load(initialUrlRequest: initialUrlRequest, initialFile: initialFile, initialData: initialData)
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

            let arguments: [String: Any] = ["id": viewId]
            channel!.invokeMethod("onHeadlessWebViewCreated", arguments: arguments)
        }
    }
    
    deinit {
        print("FlutterWebViewController - dealloc")
        channel?.setMethodCallHandler(nil)
        methodCallDelegate?.webView = nil
        methodCallDelegate = nil
        webView?.dispose()
        webView = nil
        myView = nil
    }
    
    public func view() -> UIView {
        return myView!
    }
    
    public func load(initialUrlRequest: [String:Any?]?, initialFile: String?, initialData: [String: String]?) {
        if let initialFile = initialFile {
            do {
                try webView?.loadFile(assetFilePath: initialFile)
            }
            catch let error as NSError {
                dump(error)
            }
        }
        else if let initialData = initialData {
            let data = initialData["data"]!
            let mimeType = initialData["mimeType"]!
            let encoding = initialData["encoding"]!
            let baseUrl = initialData["baseUrl"]!
            webView?.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl)
        }
        else if let initialUrlRequest = initialUrlRequest {
            let urlRequest = URLRequest.init(fromPluginMap: initialUrlRequest)
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = webView?.options?.allowingReadAccessTo, let url = urlRequest.url, url.scheme == "file" {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
                if allowingReadAccessToURL?.scheme != "file" {
                    allowingReadAccessToURL = nil
                }
            }
            webView?.loadUrl(urlRequest: urlRequest, allowingReadAccessTo: allowingReadAccessToURL)
        }
    }
}
