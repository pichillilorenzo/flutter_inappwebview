//
//  URLRequest.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation

extension URLRequest {
    public init(fromPluginMap: [String:Any?]) {
        let url = fromPluginMap["url"] as! String
        self.init(url: URL(string: url)!)
        
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
        if let iosAllowsCellularAccess = fromPluginMap["allowsCellularAccess"] as? Bool {
            allowsCellularAccess = iosAllowsCellularAccess
        }
        if #available(iOS 13.0, *), let iosAllowsConstrainedNetworkAccess = fromPluginMap["allowsConstrainedNetworkAccess"] as? Bool {
            allowsConstrainedNetworkAccess = iosAllowsConstrainedNetworkAccess
        }
        if #available(iOS 13.0, *), let iosAllowsExpensiveNetworkAccess = fromPluginMap["allowsExpensiveNetworkAccess"] as? Bool {
            allowsExpensiveNetworkAccess = iosAllowsExpensiveNetworkAccess
        }
        if let iosCachePolicy = fromPluginMap["cachePolicy"] as? Int {
            cachePolicy = CachePolicy.init(rawValue: UInt(iosCachePolicy)) ?? .useProtocolCachePolicy
        }
        if let iosHttpShouldHandleCookies = fromPluginMap["httpShouldHandleCookies"] as? Bool {
            httpShouldHandleCookies = iosHttpShouldHandleCookies
        }
        if let iosHttpShouldUsePipelining = fromPluginMap["httpShouldUsePipelining"] as? Bool {
            httpShouldUsePipelining = iosHttpShouldUsePipelining
        }
        if let iosNetworkServiceType = fromPluginMap["networkServiceType"] as? Int {
            networkServiceType = NetworkServiceType.init(rawValue: UInt(iosNetworkServiceType)) ?? .default
        }
        if let iosTimeoutInterval = fromPluginMap["timeoutInterval"] as? Double {
            timeoutInterval = iosTimeoutInterval
        }
        if let iosMainDocumentURL = fromPluginMap["mainDocumentURL"] as? String {
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
            "allowsCellularAccess": allowsCellularAccess,
            "allowsConstrainedNetworkAccess": iosAllowsConstrainedNetworkAccess,
            "allowsExpensiveNetworkAccess": iosAllowsExpensiveNetworkAccess,
            "cachePolicy": cachePolicy.rawValue,
            "httpShouldHandleCookies": httpShouldHandleCookies,
            "httpShouldUsePipelining": httpShouldUsePipelining,
            "networkServiceType": networkServiceType.rawValue,
            "timeoutInterval": timeoutInterval,
            "mainDocumentURL": mainDocumentURL?.absoluteString
        ]
    }
}
