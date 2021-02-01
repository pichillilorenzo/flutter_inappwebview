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
        
        var channelName = ""
        if let id = viewId as? Int64 {
            channelName = "com.pichillilorenzo/flutter_inappwebview_" + String(id)
        } else if let id = viewId as? String {
            channelName = "com.pichillilorenzo/flutter_inappwebview_" + id
        }
        channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        
        myView = UIView(frame: frame)
        
        let initialUrl = args["initialUrl"] as? String
        let initialFile = args["initialFile"] as? String
        let initialData = args["initialData"] as? [String: String]
        let initialHeaders = args["initialHeaders"] as? [String: String]
        let initialOptions = args["initialOptions"] as! [String: Any?]
        let contextMenu = args["contextMenu"] as? [String: Any]
        let windowId = args["windowId"] as? Int64
        let initialUserScripts = args["initialUserScripts"] as? [[String: Any]]

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
        
        methodCallDelegate = InAppWebViewMethodHandler(webView: webView!)
        channel!.setMethodCallHandler(LeakAvoider(delegate: methodCallDelegate!).handle)

        webView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myView!.autoresizesSubviews = true
        myView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myView!.addSubview(webView!)

        webView!.options = options
        if let userScripts = initialUserScripts {
            webView!.appendUserScripts(userScripts: userScripts)
        }
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
        methodCallDelegate?.webView = nil
        methodCallDelegate = nil
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
}
