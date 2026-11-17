import Foundation

/// Resolves callbacks at most once, including on WebView teardown or process loss.
/// All accesses occur on the main WebKit callback thread.
final class PendingLegacyJavaScriptCallbacks {
    private var callbacks: [String: (Any?) -> Void] = [:]

    func register(_ completion: @escaping (Any?) -> Void, for id: String) {
        callbacks[id] = completion
    }

    func complete(_ id: String, with result: Any?) {
        let completion = callbacks.removeValue(forKey: id)
        completion?(result)
    }

    func cancelAll(reason: String) {
        let pending = callbacks
        callbacks.removeAll()
        let cancellation: [String: Any] = ["value": NSNull(), "error": reason]
        for completion in pending.values {
            completion(cancellation)
        }
    }
}
