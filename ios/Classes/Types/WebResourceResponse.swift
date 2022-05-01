//
//  WebResourceResponse.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 01/05/22.
//

import Foundation

public class WebResourceResponse: NSObject {
    var contentType: String
    var contentEncoding: String
    var data: Data?
    var headers: [AnyHashable:Any]?
    var statusCode: Int?
    var reasonPhrase: String?
    
    public init(contentType: String, contentEncoding: String, data: Data?,
                headers: [AnyHashable:Any]?, statusCode: Int?, reasonPhrase: String?) {
        self.contentType = contentType
        self.contentEncoding = contentEncoding
        self.data = data
        self.headers = headers
        self.statusCode = statusCode
        self.reasonPhrase = reasonPhrase
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "contentType": contentType,
            "contentEncoding": contentEncoding,
            "data": data,
            "headers": headers,
            "statusCode": statusCode,
            "reasonPhrase": reasonPhrase
        ]
    }
}
