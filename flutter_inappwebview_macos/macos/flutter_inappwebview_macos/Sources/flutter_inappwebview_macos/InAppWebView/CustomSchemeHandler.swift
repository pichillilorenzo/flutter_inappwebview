//
//  CustomSchemeHandler.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 25/10/2019.
//

import FlutterMacOS
import Foundation
import WebKit

@available(macOS 10.13, *)
public class CustomSchemeHandler: NSObject, WKURLSchemeHandler {
    private final class SchemeTaskState {
        let task: WKURLSchemeTask
        let callbackID = UUID()

        init(task: WKURLSchemeTask) {
            self.task = task
        }
    }

    private var schemeHandlers: [ObjectIdentifier: SchemeTaskState] = [:]
    private let schemeHandlersLock = NSRecursiveLock()

    private func store(_ task: WKURLSchemeTask) -> (key: ObjectIdentifier, callbackID: UUID) {
        let key = ObjectIdentifier(task as AnyObject)
        let state = SchemeTaskState(task: task)
        schemeHandlersLock.lock()
        schemeHandlers[key] = state
        schemeHandlersLock.unlock()
        return (key, state.callbackID)
    }

    private func withPendingTask(
        for key: ObjectIdentifier,
        callbackID: UUID,
        perform action: (SchemeTaskState) -> Void
    ) {
        schemeHandlersLock.lock()
        defer { schemeHandlersLock.unlock() }
        guard let state = schemeHandlers[key], state.callbackID == callbackID else { return }
        action(state)
    }

    private func isPendingTask(for key: ObjectIdentifier, callbackID: UUID) -> Bool {
        schemeHandlersLock.lock()
        defer { schemeHandlersLock.unlock() }
        return schemeHandlers[key]?.callbackID == callbackID
    }

    private func removeTask(for key: ObjectIdentifier, ifMatching state: SchemeTaskState) {
        if schemeHandlers[key] === state {
            schemeHandlers.removeValue(forKey: key)
        }
    }

    private func performOnMainQueue(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    private func completeTask(
        for key: ObjectIdentifier,
        callbackID: UUID,
        response: CustomSchemeResponse,
        url: URL
    ) {
        performOnMainQueue { [weak self] in
            guard let self else { return }
            // Keep each WebKit call on the main queue and under the recursive lock. If stop is
            // reentered during a call, the next pending-task check prevents further delivery.
            self.withPendingTask(for: key, callbackID: callbackID) { state in
                state.task.didReceive(CustomSchemeHandler.urlResponse(for: response, url: url))
            }
            self.withPendingTask(for: key, callbackID: callbackID) { state in
                state.task.didReceive(response.data)
            }
            self.withPendingTask(for: key, callbackID: callbackID) { state in
                state.task.didFinish()
                self.removeTask(for: key, ifMatching: state)
            }
        }
    }

    private func failTask(for key: ObjectIdentifier, callbackID: UUID, error: Error) {
        performOnMainQueue { [weak self] in
            guard let self else { return }
            self.withPendingTask(for: key, callbackID: callbackID) { state in
                state.task.didFailWithError(error)
                self.removeTask(for: key, ifMatching: state)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let taskIdentity = store(urlSchemeTask)
        let inAppWebView = webView as! InAppWebView
        let request = WebResourceRequest.init(fromURLRequest: urlSchemeTask.request)
        let callback = WebViewChannelDelegate.LoadResourceWithCustomSchemeCallback()
        callback.nonNullSuccess = { [weak self] (response: CustomSchemeResponse) in
            self?.completeTask(
                for: taskIdentity.key,
                callbackID: taskIdentity.callbackID,
                response: response,
                url: request.url
            )
            return false
        }
        callback.defaultBehaviour = { [weak self] _ in
            self?.failTask(
                for: taskIdentity.key,
                callbackID: taskIdentity.callbackID,
                error: CustomSchemeHandler.taskError("No response was returned for the custom scheme request.")
            )
        }
        callback.error = { [weak self] (code: String, message: String?, details: Any?) in
            let description = [code, message].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ": ")
            self?.failTask(
                for: taskIdentity.key,
                callbackID: taskIdentity.callbackID,
                error: CustomSchemeHandler.taskError(description.isEmpty ? "The custom scheme request failed." : description)
            )
        }
        
        if let channelDelegate = inAppWebView.channelDelegate {
            performOnMainQueue { [weak self] in
                guard let self, self.isPendingTask(for: taskIdentity.key, callbackID: taskIdentity.callbackID) else { return }
                channelDelegate.onLoadResourceWithCustomScheme(request: request, callback: callback)
            }
        } else {
            callback.defaultBehaviour(nil)
        }
    }

    private static func taskError(_ description: String) -> NSError {
        NSError(domain: "CustomSchemeHandler", code: 1, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    /// An HTTP response when the response carries headers: a plain `URLResponse` has none, so a
    /// header such as `Content-Security-Policy` would never reach the page.
    static func urlResponse(for response: CustomSchemeResponse, url: URL) -> URLResponse {
        guard let headers = response.headers, !headers.isEmpty else {
            return URLResponse(url: url, mimeType: response.contentType, expectedContentLength: -1, textEncodingName: response.contentEncoding)
        }
        var headerFields = headers
        if !headerFields.keys.contains(where: { $0.caseInsensitiveCompare("Content-Type") == .orderedSame }) {
            headerFields["Content-Type"] = response.contentEncoding.isEmpty
                ? response.contentType
                : "\(response.contentType); charset=\(response.contentEncoding)"
        }
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headerFields)
            ?? URLResponse(url: url, mimeType: response.contentType, expectedContentLength: -1, textEncodingName: response.contentEncoding)
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        let key = ObjectIdentifier(urlSchemeTask as AnyObject)
        schemeHandlersLock.lock()
        schemeHandlers.removeValue(forKey: key)
        schemeHandlersLock.unlock()
    }
}
