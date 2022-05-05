//
//  URLRequest.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation

extension URLRequest {
    public init(fromPluginMap: [String:Any?]) {
        if let urlString = fromPluginMap["url"] as? String, let url = URL(string: urlString) {
            self.init(url: url)
        } else {
            self.init(url: URL(string: "about:blank")!)
        }
        
        if let method = fromPluginMap["method"] as? String {
            httpMethod = method
        }
        if let body = fromPluginMap["body"] as? FlutterStandardTypedData {
            httpBody = body.data
        }
        if let headers = fromPluginMap["headers"] as? [String:String] {
            for (key, value) in headers {
                setValue(value, forHTTPHeaderField: key)
            }
        }
        if let iosAllowsCellularAccess = fromPluginMap["iosAllowsCellularAccess"] as? Bool {
            allowsCellularAccess = iosAllowsCellularAccess
        }
        if #available(iOS 13.0, *), let iosAllowsConstrainedNetworkAccess = fromPluginMap["iosAllowsConstrainedNetworkAccess"] as? Bool {
            allowsConstrainedNetworkAccess = iosAllowsConstrainedNetworkAccess
        }
        if #available(iOS 13.0, *), let iosAllowsExpensiveNetworkAccess = fromPluginMap["iosAllowsExpensiveNetworkAccess"] as? Bool {
            allowsExpensiveNetworkAccess = iosAllowsExpensiveNetworkAccess
        }
        if let iosCachePolicy = fromPluginMap["iosCachePolicy"] as? Int {
            cachePolicy = CachePolicy.init(rawValue: UInt(iosCachePolicy)) ?? .useProtocolCachePolicy
        }
        if let iosHttpShouldHandleCookies = fromPluginMap["iosHttpShouldHandleCookies"] as? Bool {
            httpShouldHandleCookies = iosHttpShouldHandleCookies
        }
        if let iosHttpShouldUsePipelining = fromPluginMap["iosHttpShouldUsePipelining"] as? Bool {
            httpShouldUsePipelining = iosHttpShouldUsePipelining
        }
        if let iosNetworkServiceType = fromPluginMap["iosNetworkServiceType"] as? Int {
            networkServiceType = NetworkServiceType.init(rawValue: UInt(iosNetworkServiceType)) ?? .default
        }
        if let iosTimeoutInterval = fromPluginMap["iosTimeoutInterval"] as? Double {
            timeoutInterval = iosTimeoutInterval
        }
        if let iosMainDocumentURL = fromPluginMap["iosMainDocumentURL"] as? String {
            mainDocumentURL = URL(string: iosMainDocumentURL)!
        }
    }
    
    public func toMap () -> [String:Any?] {
        var iosAllowsConstrainedNetworkAccess: Bool? = nil
        var iosAllowsExpensiveNetworkAccess: Bool? = nil
        if #available(iOS 13.0, *) {
            iosAllowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
            iosAllowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        }
        return [
            "url": url?.absoluteString,
            "method": httpMethod,
            "headers": allHTTPHeaderFields,
            "body": httpBody.map(FlutterStandardTypedData.init(bytes:)),
            "iosAllowsCellularAccess": allowsCellularAccess,
            "iosAllowsConstrainedNetworkAccess": iosAllowsConstrainedNetworkAccess,
            "iosAllowsExpensiveNetworkAccess": iosAllowsExpensiveNetworkAccess,
            "iosCachePolicy": cachePolicy.rawValue,
            "iosHttpShouldHandleCookies": httpShouldHandleCookies,
            "iosHttpShouldUsePipelining": httpShouldUsePipelining,
            "iosNetworkServiceType": networkServiceType.rawValue,
            "iosTimeoutInterval": timeoutInterval,
            "iosMainDocumentURL": mainDocumentURL?.absoluteString
        ]
    }
}
