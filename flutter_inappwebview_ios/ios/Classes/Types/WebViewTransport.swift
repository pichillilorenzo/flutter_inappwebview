//
//  WebViewTransport.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class WebViewTransport: NSObject {
    weak var webView: InAppWebView?
    var request: URLRequest
    
    init(webView: InAppWebView, request: URLRequest) {
        self.webView = webView
        self.request = request
    }
}
