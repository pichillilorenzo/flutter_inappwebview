//
//  HttpAuthenticationChallenge.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 15/02/21.
//

import Foundation

class HttpAuthenticationChallenge: NSObject {
    var protectionSpace: URLProtectionSpace!
    var previousFailureCount: Int = 0
    var failureResponse: URLResponse?
    var error: Error?
    var proposedCredential: URLCredential?
    
    public init(fromChallenge: URLAuthenticationChallenge) {
        protectionSpace = fromChallenge.protectionSpace
        previousFailureCount = fromChallenge.previousFailureCount
        failureResponse = fromChallenge.failureResponse
        error = fromChallenge.error
        proposedCredential = fromChallenge.proposedCredential
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "protectionSpace": protectionSpace.toMap(),
            "previousFailureCount": previousFailureCount,
            "iosFailureResponse": failureResponse?.toMap(),
            "iosError": error?.localizedDescription,
            "proposedCredential": proposedCredential?.toMap()
        ]
    }
}
