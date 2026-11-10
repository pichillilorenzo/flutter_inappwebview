//
//  URLProtectionSpace.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 19/02/21.
//

import Foundation

extension URLProtectionSpace {
    
    var x509Certificate: Data? {
        guard let serverTrust = serverTrust else {
            return nil
        }
        
        _ = SecTrustEvaluateWithError(serverTrust, nil)
        
        let serverCertificate: SecCertificate?
        if #available(macOS 12.0, *) {
            serverCertificate = (SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate])?.first
        } else {
            serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        }
        return serverCertificate?.data
    }
    
    var sslCertificate: SslCertificate? {
        var sslCertificate: SslCertificate? = nil
        if let x509Certificate = x509Certificate {
            sslCertificate = SslCertificate(x509Certificate: x509Certificate)
        }
        return sslCertificate
    }
    
    var sslError: SslError? {
        guard let serverTrust = serverTrust else {
            return nil
        }
        
        _ = SecTrustEvaluateWithError(serverTrust, nil)
        var secResult = SecTrustResultType.invalid
        SecTrustGetTrustResult(serverTrust, &secResult)
        
        guard let sslErrorType = secResult != SecTrustResultType.proceed ? secResult : nil else {
            return nil
        }
        
        return SslError(errorType: sslErrorType)
    }
    
    public func toMap () -> [String:Any?] {
        return [
            "host": host,
            "protocol": self.protocol,
            "realm": realm,
            "port": port,
            "sslCertificate": sslCertificate?.toMap(),
            "sslError": sslError?.toMap(),
            "authenticationMethod": authenticationMethod,
            "distinguishedNames": distinguishedNames,
            "receivesCredentialSecurely": receivesCredentialSecurely,
            "proxyType": proxyType
        ]
    }
}
