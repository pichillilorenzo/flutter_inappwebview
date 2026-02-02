//
//  JavaScriptHandlerFunctionData.swift
//  Pods
//
//  Created by Lorenzo Pichilli on 27/10/24.
//

import Foundation

public class JavaScriptHandlerFunctionData: NSObject {
    var args: String
    var isMainFrame: Bool
    var origin: String
    var requestUrl: String
    
    public init(args: String, isMainFrame: Bool, origin: String, requestUrl: String) {
        self.args = args
        self.isMainFrame = isMainFrame
        self.origin = origin
        self.requestUrl = requestUrl
    }
    
    public static func fromMap(map: [String:Any?]?) -> JavaScriptHandlerFunctionData? {
        guard let map = map else {
            return nil
        }
        
        return JavaScriptHandlerFunctionData(
            args: map["args"] as! String,
            isMainFrame: map["isMainFrame"] as! Bool,
            origin: map["origin"] as! String,
            requestUrl: map["requestUrl"] as! String
        )
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "args": args,
            "isMainFrame": isMainFrame,
            "origin": origin,
            "requestUrl": requestUrl
        ]
    }
}
