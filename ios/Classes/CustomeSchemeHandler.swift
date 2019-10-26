//
//  CustomeSchemeHandler.swift
//  flutter_downloader
//
//  Created by Lorenzo Pichilli on 25/10/2019.
//

import Flutter
import Foundation
import WebKit

@available(iOS 11.0, *)
class CustomeSchemeHandler : NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let inAppWebView = webView as! InAppWebView
        if let url = urlSchemeTask.request.url, let scheme = url.scheme {
            inAppWebView.onLoadResourceCustomScheme(scheme: scheme, url: url.absoluteString, result: {(result) -> Void in
                if result is FlutterError {
                    print((result as! FlutterError).message)
                }
                else if (result as? NSObject) == FlutterMethodNotImplemented {}
                else {
                    let json: [String: String]
                    if let r = result {
                        json = r as! [String: String]
                        let urlResponse = URLResponse(url: url, mimeType: json["content-type"], expectedContentLength: -1, textEncodingName: json["content-encoding"])
                        let data = Data(base64Encoded: json["base64data"]!, options: .ignoreUnknownCharacters)
                        urlSchemeTask.didReceive(urlResponse)
                        urlSchemeTask.didReceive(data!)
                        urlSchemeTask.didFinish()
                    }
                }
            })
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
}
