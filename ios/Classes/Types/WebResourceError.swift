//
//  WebResourceError.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 01/05/22.
//

import Foundation

public class WebResourceError: NSObject {
    var errorCode: Int
    var errorDescription: String
    
    public init(errorCode: Int, errorDescription: String) {
        self.errorCode = errorCode
        self.errorDescription = errorDescription
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "errorCode": errorCode,
            "description": errorDescription
        ]
    }
}
