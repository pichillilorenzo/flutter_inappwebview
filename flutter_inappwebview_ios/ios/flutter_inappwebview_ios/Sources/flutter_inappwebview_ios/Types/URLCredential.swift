//
//  URLCredential.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation

extension URLCredential {
    public func toMap () -> [String:Any?] {
        let x509Certificates = certificates.map { ($0 as! SecCertificate).data }
        return [
            "password": password,
            "username": user,
            "certificates": x509Certificates,
            "persistence": persistence.rawValue
        ]
    }
}
