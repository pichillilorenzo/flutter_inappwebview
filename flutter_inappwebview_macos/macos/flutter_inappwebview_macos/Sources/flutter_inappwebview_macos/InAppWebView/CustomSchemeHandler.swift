//
//  CustomSchemeHandler.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 25/10/2019.
//

import FlutterMacOS
import Foundation
import WebKit

@available(macOS 10.13, *)
public class CustomSchemeHandler: NSObject, WKURLSchemeHandler {
    var schemeHandlers: [Int: WKURLSchemeTask] = [:]
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        schemeHandlers[urlSchemeTask.hash] = urlSchemeTask
        let inAppWebView = webView as! InAppWebView
        let request = WebResourceRequest.init(fromURLRequest: urlSchemeTask.request)
        let callback = WebViewChannelDelegate.LoadResourceWithCustomSchemeCallback()
        callback.nonNullSuccess = { (response: CustomSchemeResponse) in
            if (self.schemeHandlers[urlSchemeTask.hash] != nil) {
                urlSchemeTask.didReceive(CustomSchemeHandler.urlResponse(for: response, url: request.url))
                urlSchemeTask.didReceive(response.data)
                urlSchemeTask.didFinish()
                self.schemeHandlers.removeValue(forKey: urlSchemeTask.hash)
            }
            return false
        }
        callback.error = { (code: String, message: String?, details: Any?) in
            print(code + ", " + (message ?? ""))
        }
        
        if let channelDelegate = inAppWebView.channelDelegate {
            channelDelegate.onLoadResourceWithCustomScheme(request: request, callback: callback)
        } else {
            callback.defaultBehaviour(nil)
        }
    }
    
    /// An HTTP response when the response carries headers: a plain `URLResponse` has none, so a
    /// header such as `Content-Security-Policy` would never reach the page.
    static func urlResponse(for response: CustomSchemeResponse, url: URL) -> URLResponse {
        guard let headers = response.headers, !headers.isEmpty else {
            return URLResponse(url: url, mimeType: response.contentType, expectedContentLength: -1, textEncodingName: response.contentEncoding)
        }
        var headerFields = headers
        if !headerFields.keys.contains(where: { $0.caseInsensitiveCompare("Content-Type") == .orderedSame }) {
            headerFields["Content-Type"] = response.contentEncoding.isEmpty
                ? response.contentType
                : "\(response.contentType); charset=\(response.contentEncoding)"
        }
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headerFields)
            ?? URLResponse(url: url, mimeType: response.contentType, expectedContentLength: -1, textEncodingName: response.contentEncoding)
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        schemeHandlers.removeValue(forKey: urlSchemeTask.hash)
    }
}
