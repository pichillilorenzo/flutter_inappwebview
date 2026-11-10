import Foundation

@main
struct PendingLegacyJavaScriptCallbacksTests {
    static func main() {
        let callbacks = PendingLegacyJavaScriptCallbacks()
        var successes: [String] = []
        callbacks.register({ result in
            successes.append(result as? String ?? "unexpected")
        }, for: "normal")
        callbacks.complete("normal", with: "ok")
        callbacks.complete("normal", with: "late")
        assert(successes == ["ok"], "a completed request must resolve once")

        var canceled: [[String: Any]] = []
        callbacks.register({ result in
            if let json = result as? [String: Any] { canceled.append(json) }
        }, for: "pending")
        callbacks.cancelAll(reason: "WebView disposed")
        callbacks.complete("pending", with: "late")
        callbacks.cancelAll(reason: "again")
        assert(canceled.count == 1, "cancellation must resolve exactly once")
        assert(canceled[0]["value"] is NSNull)
        assert(canceled[0]["error"] as? String == "WebView disposed")

        let survivor = PendingLegacyJavaScriptCallbacks()
        var peerResults: [String] = []
        survivor.register({ _ in peerResults.append("peer") }, for: "same")
        callbacks.register({ _ in peerResults.append("closing") }, for: "same")
        callbacks.cancelAll(reason: "closing")
        survivor.complete("same", with: nil)
        assert(peerResults == ["closing", "peer"], "another view must remain live")

        var reentrant: [String] = []
        callbacks.register({ _ in
            callbacks.register({ _ in reentrant.append("replacement") }, for: "new")
        }, for: "old")
        callbacks.cancelAll(reason: "replace")
        callbacks.complete("new", with: nil)
        assert(reentrant == ["replacement"], "callbacks added during cancellation must survive")
        print("PASS: pending legacy JavaScript callbacks")
    }
}
