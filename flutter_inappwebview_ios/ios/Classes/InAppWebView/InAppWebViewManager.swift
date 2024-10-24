//
//  InAppWebViewManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/12/2019.
//

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scroll Optimization</title>
    <style>
        /* Ensuring smooth scrolling on iOS */
        .scrollable-container {
            overflow-y: auto;
            height: 100vh;  /* Fixed height for scrolling */
            -webkit-overflow-scrolling: touch; /* Smoother scrolling on iOS */
        }
    </style>
</head>
<body>
    <div class="scrollable-container">
        <!-- Content that causes scrolling -->
        <div style="height: 2000px;">
            <h1>Scroll down to test the height issue</h1>
            <p>Long content...</p>
        </div>
    </div>

    <script>
        // Function to debounce scroll events
        function debounce(func, wait) {
            let timeout;
            return function (...args) {
                const later = () => {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        }

        // Function to throttle resize events
        function throttle(func, limit) {
            let inThrottle;
            return function(...args) {
                if (!inThrottle) {
                    func(...args);
                    inThrottle = true;
                    setTimeout(() => (inThrottle = false), limit);
                }
            };
        }

        // Use requestAnimationFrame for height calculation during scrolling
        let ticking = false;
        const scrollableContainer = document.querySelector('.scrollable-container');

        function handleScroll() {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    // Here you can handle height adjustments if needed
                    console.log('Handling height adjustments on scroll');
                    // Example: adjust container height or perform other calculations
                    const containerHeight = scrollableContainer.scrollHeight;
                    console.log('Container height:', containerHeight);
                    ticking = false;
                });
                ticking = true;
            }
        }

        // Debounce scroll handling for smoother performance
        window.addEventListener('scroll', debounce(handleScroll, 200));

        // Throttle resize events to avoid multiple renders
        window.addEventListener('resize', throttle(() => {
            console.log('Resize event handled');
        }, 300));

        // iOS-specific fix detection
        const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        if (isIOS) {
            console.log('Running on iOS');
            // Apply any iOS-specific logic here if needed
        }
    </script>
</body>
</html>

import Foundation
import WebKit

public class InAppWebViewManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_manager"
    var plugin: SwiftFlutterPlugin?
    var webViewForUserAgent: WKWebView?
    var defaultUserAgent: String?
    
    var keepAliveWebViews: [String:FlutterWebViewController?] = [:]
    var windowWebViews: [Int64:WebViewTransport] = [:]
    var windowAutoincrementId: Int64 = 0
    
    init(plugin: SwiftFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: InAppWebViewManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar!.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
            case "getDefaultUserAgent":
                getDefaultUserAgent(completionHandler: { (value) in
                    result(value)
                })
                break
            case "handlesURLScheme":
                let urlScheme = arguments!["urlScheme"] as! String
                if #available(iOS 11.0, *) {
                    result(WKWebView.handlesURLScheme(urlScheme))
                } else {
                    result(false)
                }
                break
            case "disposeKeepAlive":
                let keepAliveId = arguments!["keepAliveId"] as! String
                disposeKeepAlive(keepAliveId: keepAliveId)
                result(true)
                break
            case "clearAllCache":
                let includeDiskFiles = arguments!["includeDiskFiles"] as! Bool
                clearAllCache(includeDiskFiles: includeDiskFiles, completionHandler: {
                    result(true)
                })
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func getDefaultUserAgent(completionHandler: @escaping (_ value: String?) -> Void) {
        if defaultUserAgent == nil {
            webViewForUserAgent = WKWebView()
            webViewForUserAgent?.evaluateJavaScript("navigator.userAgent") { (value, error) in

                if error != nil {
                    print("Error occurred to get userAgent")
                    self.webViewForUserAgent = nil
                    completionHandler(nil)
                    return
                }

                if let unwrappedUserAgent = value as? String {
                    self.defaultUserAgent = unwrappedUserAgent
                    completionHandler(self.defaultUserAgent)
                } else {
                    print("Failed to get userAgent")
                }
                self.webViewForUserAgent = nil
            }
        } else {
            completionHandler(defaultUserAgent)
        }
    }
    
    public func disposeKeepAlive(keepAliveId: String) {
        if let flutterWebView = keepAliveWebViews[keepAliveId] as? FlutterWebViewController {
            flutterWebView.keepAliveId = nil
            flutterWebView.dispose(removeFromSuperview: true)
            keepAliveWebViews[keepAliveId] = nil
        }
    }
    
    public func clearAllCache(includeDiskFiles: Bool, completionHandler: @escaping () -> Void) {
        if #available(iOS 9.0, *) {
            var websiteDataTypes = Set([WKWebsiteDataTypeMemoryCache])
            if includeDiskFiles {
                websiteDataTypes.insert(WKWebsiteDataTypeDiskCache)
                if #available(iOS 11.3, *) {
                    websiteDataTypes.insert(WKWebsiteDataTypeFetchCache)
                }
                websiteDataTypes.insert(WKWebsiteDataTypeOfflineWebApplicationCache)
            }
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date as Date, completionHandler: completionHandler)
        } else {
            URLCache.shared.removeAllCachedResponses()
            completionHandler()
        }
    }
    
    public override func dispose() {
        super.dispose()
        let keepAliveWebViewValues = keepAliveWebViews.values
        keepAliveWebViewValues.forEach {(keepAliveWebView: FlutterWebViewController?) in
            if let keepAliveId = keepAliveWebView?.keepAliveId {
                disposeKeepAlive(keepAliveId: keepAliveId)
            }
        }
        keepAliveWebViews.removeAll()
        windowWebViews.removeAll()
        webViewForUserAgent = nil
        defaultUserAgent = nil
        plugin = nil
    }
    
    deinit {
        dispose()
    }
}
