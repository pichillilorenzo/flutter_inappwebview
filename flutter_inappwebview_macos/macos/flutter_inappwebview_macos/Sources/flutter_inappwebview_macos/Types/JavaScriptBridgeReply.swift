import Foundation

/// Owns a WebKit reply until one terminal result. All bridge callbacks run on
/// the main thread, including cancellation before navigation or disposal.
final class JavaScriptBridgeReply {
    typealias Handler = (Any?, String?) -> Void
    let id = UUID()
    private var handler: Handler?
    var onSettled: (() -> Void)?

    init(_ handler: @escaping Handler) {
        self.handler = handler
    }

    func succeed(_ json: String?) {
        finish(json as NSString?, error: nil)
    }

    func fail(_ error: String) {
        finish(nil, error: error)
    }

    private func finish(_ value: Any?, error: String?) {
        precondition(Thread.isMainThread)
        guard let handler = handler else { return }
        self.handler = nil
        let onSettled = self.onSettled
        self.onSettled = nil
        onSettled?()
        handler(value, error)
    }

    deinit {
        // Also settle if an owner is released without an explicit dispose.
        handler?(nil, "JavaScript bridge reply owner was released")
    }
}

final class JavaScriptBridgeReplyRegistry {
    private var pending: [UUID: (reply: JavaScriptBridgeReply, documentId: String?)] = [:]
    var count: Int { pending.count }

    func track(_ reply: JavaScriptBridgeReply, documentId: String?) {
        precondition(Thread.isMainThread)
        pending[reply.id] = (reply, documentId)
        let id = reply.id
        reply.onSettled = { [weak self] in self?.pending.removeValue(forKey: id) }
    }

    func cancel(documentId: String? = nil, error: String) {
        precondition(Thread.isMainThread)
        let replies = pending.values.filter { documentId == nil || $0.documentId == documentId }
        for entry in replies {
            entry.reply.fail(error)
        }
    }

    deinit {
        for entry in pending.values {
            entry.reply.onSettled = nil
            entry.reply.fail("JavaScript bridge reply owner was released")
        }
    }
}
