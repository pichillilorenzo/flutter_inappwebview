//
//  MyURLProtocol.swift
//  Pods
//
//  Created by Lorenzo on 12/10/18.
//

import Foundation
import WebKit


func currentTimeInMilliSeconds() -> Int {
    let currentDate = Date()
    let since1970 = currentDate.timeIntervalSince1970
    return Int(since1970 * 1000)
}

class MyURLProtocol: URLProtocol {
    
//    struct Constants {
//        static let RequestHandledKey = "URLProtocolRequestHandled"
//    }
    
    var wkWebViewUuid: String?
    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    var response: URLResponse?
    var data: Data?
    static var wkWebViewDelegateMap: [String: MyURLProtocolDelegate] = [:]
    var loadingTime: Int = 0
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        self.wkWebViewUuid = MyURLProtocol.getUuid(request)
        
        if session == nil && self.wkWebViewUuid != nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {

        if getUuid(request) == nil {
            return false
        }
//        if MyURLProtocol.property(forKey: Constants.RequestHandledKey, in: request) != nil {
//            return false
//        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let newRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
        loadingTime = currentTimeInMilliSeconds()
        //MyURLProtocol.setProperty(true, forKey: Constants.RequestHandledKey, in: newRequest)
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
    }
    
    override func stopLoading() {
        if let uuid = self.wkWebViewUuid {
            if MyURLProtocol.wkWebViewDelegateMap[uuid] != nil && self.response != nil {
                loadingTime = currentTimeInMilliSeconds() - loadingTime
                if self.data == nil {
                    self.data = Data()
                }
                MyURLProtocol.wkWebViewDelegateMap[uuid]!.didReceiveResponse(self.response!, fromRequest: request, withData: self.data!, loadingTime: loadingTime)
            }
        }
        
        sessionTask?.cancel()
    }
    
    class func getUuid(_ request: URLRequest?) -> String? {
        let userAgent: String? = request?.allHTTPHeaderFields?["User-Agent"]
        var uuid: String? = nil
        if userAgent != nil {
            if userAgent!.contains("WKWebView/") {
                let userAgentSplitted = userAgent!.split(separator: " ")
                uuid = String(userAgentSplitted[userAgentSplitted.count-1]).replacingOccurrences(of: "WKWebView/", with: "")
            }
        }
        return uuid
    }
}

extension MyURLProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.data == nil {
            self.data = data
        }
        else {
            self.data!.append(data)
        }
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        self.response = response
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        let sender = challenge.sender
        
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
                return
            }
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}

protocol MyURLProtocolDelegate {
    func didReceiveResponse(_ response: URLResponse, fromRequest request: URLRequest?, withData data: Data, loadingTime time: Int)
}
