// Template: the runner inserts production Swift methods at the markers.
import AppKit
import WebKit

struct PluginScriptsUtil {
    // PRODUCTION_CONSTANTS
}
struct Util {
    // PRODUCTION_JSON_STRINGIFY
}
struct JavaScriptBridgeJS {
    static func get_JAVASCRIPT_BRIDGE_NAME() -> String { "flutter_inappwebview" }
}
final class Channel {
    func onConsoleMessage(message: String, messageLevel: Int) {}
    func onPageCommitVisible(url: String?) {}
    func onWebContentProcessDidTerminate() {}
    func dispose() {}
}
final class OtherBridgeReplies {
    func cancel(error: String) {}
}

@MainActor
final class InAppWebView: WKWebView, WKNavigationDelegate, WKScriptMessageHandler {
    private let pendingLegacyJavaScriptCallbacks = PendingLegacyJavaScriptCallbacks()
    let javaScriptBridgeReplies = OtherBridgeReplies()
    var javaScriptBridgeDisposed = false
    var channelDelegate: Channel? = Channel()
    var finishedLoads = 0
    var receivedReplies = 0

    init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController.addUserScript(WKUserScript(source: """
            window.flutter_inappwebview = { callHandler: function(name, result) {
                window.webkit.messageHandlers.legacy.postMessage({
                    name: name, args: JSON.stringify([result])
                });
            }};
            """, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 300), configuration: configuration)
        configuration.userContentController.add(self, name: "legacy")
        navigationDelegate = self
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func initializeWindowIdJS() {}
    func updateScrollChangedListener() {}
    func setConsoleMessageListener(_ enabled: Bool) {}
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { finishedLoads += 1 }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let name = body["name"] as? String else {
            fatalError("Unexpected legacy bridge payload")
        }
        receivedReplies += 1
        let webView = self
        switch name {
            // PRODUCTION_REPLY
        default: fatalError("Unexpected legacy bridge handler: \(name)")
        }
    }
    // PRODUCTION_LEGACY_CALL
    // PRODUCTION_COMMIT
    // PRODUCTION_TERMINATION
    // PRODUCTION_DISPOSAL

    func releaseFixture() {
        configuration.userContentController.removeScriptMessageHandler(forName: "legacy")
        navigationDelegate = nil
        removeFromSuperview()
    }
}

final class Answer {
    var results: [[String: Any]] = []
    func receive(_ value: Any?) {
        guard let value = value as? [String: Any] else { fatalError("Expected legacy result map") }
        results.append(value)
    }
}

@MainActor
func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() { fatalError(message) }
}

@MainActor
func waitUntil(_ message: String, _ condition: () -> Bool) {
    let deadline = Date().addingTimeInterval(15)
    while !condition() {
        require(Date() < deadline, "Timed out: " + message)
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
    }
}

@MainActor
@discardableResult
func evaluate(_ view: WKWebView, _ script: String) -> Any? {
    var finished = false
    var value: Any?
    view.evaluateJavaScript(script) { result, error in
        require(error == nil, "Fixture JavaScript failed: \(String(describing: error))")
        value = result
        finished = true
    }
    waitUntil(script) { finished }
    return value
}

@MainActor
func call(_ view: InAppWebView, _ body: String, _ arguments: [String: Any] = [:]) -> Answer {
    let answer = Answer()
    view.callAsyncJavaScript(functionBody: body, arguments: arguments, completionHandler: answer.receive)
    return answer
}

@MainActor
func pending(_ view: InAppWebView) -> Answer {
    let answer = call(view, "return await new Promise(resolve => { window.releaseLegacy = resolve; });")
    // WebKit evaluates requests in order, so this observes registration of the
    // promise resolver without a timing-dependent sleep.
    require(evaluate(view, "typeof window.releaseLegacy") as? String == "function", "Promise must be pending")
    require(answer.results.isEmpty, "Unresolved promise completed early")
    return answer
}

@MainActor
func requireCancelled(_ answer: Answer, _ reason: String) {
    require(answer.results.count == 1, "Cancellation must complete once")
    require(answer.results[0]["value"] is NSNull, "Cancellation must return a null value")
    require(answer.results[0]["error"] as? String == reason, "Incorrect cancellation reason")
}

@main
struct LegacyJavaScriptWebKitTests {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.finishLaunching()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                              styleMask: [.titled], backing: .buffered, defer: false)
        let view = InAppWebView()
        let peer = InAppWebView()
        peer.setFrameOrigin(NSPoint(x: 400, y: 0))
        for webView in [view, peer] {
            window.contentView!.addSubview(webView)
            webView.loadHTMLString("<html><body>legacy probe</body></html>", baseURL: URL(string: "https://legacy.test/"))
        }
        window.makeKeyAndOrderFront(nil)
        waitUntil("initial documents") { view.finishedLoads == 1 && peer.finishedLoads == 1 }

        let normal = call(view, "return await Promise.resolve(42);")
        waitUntil("normal completion") { !normal.results.isEmpty }
        require(normal.results.count == 1 && normal.results[0]["value"] as? Int == 42, "Normal result changed")
        require(normal.results[0]["error"] is NSNull, "Normal result must have no error")

        let text = "עברית 😀 \"quotes\" \\ newline\n"
        let arguments = call(view, "return {text, count: items.length};", ["text": text, "items": [1, 2, 3]])
        waitUntil("argument result") { !arguments.results.isEmpty }
        let argumentValue = arguments.results[0]["value"] as! [String: Any]
        require(argumentValue["text"] as? String == text && argumentValue["count"] as? Int == 3, "Arguments changed")

        let rejected = call(view, "throw new Error('expected rejection');")
        waitUntil("rejection") { !rejected.results.isEmpty }
        require(rejected.results.count == 1 && rejected.results[0]["value"] is NSNull, "Rejection shape changed")
        require((rejected.results[0]["error"] as? String)?.contains("expected rejection") == true, "Rejection lost")

        let invalid = call(view, "return };")
        waitUntil("native evaluation error") { !invalid.results.isEmpty }
        require(invalid.results.count == 1 && invalid.results[0]["value"] is NSNull, "Native error shape changed")
        require(invalid.results[0]["error"] is String, "Native evaluation failure must settle")

        let sameDocument = pending(view)
        evaluate(view, "window.location.hash = 'same-document'; null;")
        evaluate(view, "window.releaseLegacy(7); null;")
        waitUntil("same-document result") { !sameDocument.results.isEmpty }
        require(sameDocument.results.count == 1 && sameDocument.results[0]["value"] as? Int == 7, "Hash navigation cancelled work")

        let replaced = pending(view)
        view.loadHTMLString("<html><body>replacement document</body></html>", baseURL: URL(string: "https://legacy.test/replacement"))
        waitUntil("document replacement") { view.finishedLoads == 2 }
        requireCancelled(replaced, "JavaScript document replaced")

        let terminated = pending(view)
        let surviving = pending(peer)
        let repliesBeforeTermination = view.receivedReplies
        // Deliver the real delegate entry point, without private crash APIs.
        view.webViewWebContentProcessDidTerminate(view)
        requireCancelled(terminated, "Web content process terminated")
        evaluate(view, "window.releaseLegacy(8); null;")
        waitUntil("late terminated reply") { view.receivedReplies > repliesBeforeTermination }
        requireCancelled(terminated, "Web content process terminated")
        require(surviving.results.isEmpty, "Terminating a sibling cancelled peer work")
        let recovered = call(view, "return 9;")
        waitUntil("request after termination notification") { !recovered.results.isEmpty }
        require(recovered.results[0]["value"] as? Int == 9, "New requests cannot recover")

        let disposed = pending(view)
        let repliesBeforeDisposal = view.receivedReplies
        view.dispose()
        view.dispose()
        requireCancelled(disposed, "WebView disposed")
        evaluate(view, "window.releaseLegacy(10); null;")
        waitUntil("late disposed reply") { view.receivedReplies > repliesBeforeDisposal }
        requireCancelled(disposed, "WebView disposed")
        evaluate(peer, "window.releaseLegacy(11); null;")
        waitUntil("surviving peer") { !surviving.results.isEmpty }
        require(surviving.results.count == 1 && surviving.results[0]["value"] as? Int == 11, "Peer result changed")
        for webView in [view, peer] { webView.releaseFixture() }
        print("PASS: live WKWebView legacy execution, errors, navigation, cancellation, late replies and peer isolation")
    }
}
