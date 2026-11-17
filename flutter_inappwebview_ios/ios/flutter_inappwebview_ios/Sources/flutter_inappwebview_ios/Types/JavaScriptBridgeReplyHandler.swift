import Foundation
import ObjectiveC
import WebKit

/// Stateless: a shared user-content controller must route using WebKit's
/// actual sender, never the view that happened to register the handler.
@available(iOS 14.0, *)
@MainActor
final class JavaScriptBridgeReplyHandler: NSObject, WKScriptMessageHandlerWithReply {
    static let name = "callHandlerWithReply"

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage,
                               replyHandler: @escaping @MainActor @Sendable (Any?, String?) -> Void) {
        let reply = JavaScriptBridgeReply { value, error in
            // WebKit and Flutter deliver these callbacks on the main thread.
            // Preserve WebKit's actor-isolated reply contract without adding
            // another asynchronous main-queue hop to the measured transport.
            MainActor.assumeIsolated { replyHandler(value, error) }
        }
        guard let webView = message.webView as? InAppWebView else {
            reply.fail("JavaScript bridge WebView is unavailable")
            return
        }
        webView.handleScriptMessage(userContentController, didReceive: message, reply: reply)
    }
}

@available(iOS 14.0, *)
private final class JavaScriptBridgeReplyControllerState {
    let owners = NSHashTable<InAppWebView>.weakObjects()
    var worlds = Set<WKContentWorld>()
}

extension WKUserContentController {
    private static var bridgeSecretKey: UInt8 = 0
    private static var bridgeReplyStateKey: UInt8 = 0

    // The secret belongs to the shared scripts, while permission settings
    // belong to the actual message.webView (including a popup).
    var javaScriptBridgeSecret: String? {
        get { objc_getAssociatedObject(self, &Self.bridgeSecretKey) as? String }
        set { objc_setAssociatedObject(self, &Self.bridgeSecretKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    @available(iOS 14.0, *)
    private var bridgeReplyState: JavaScriptBridgeReplyControllerState {
        if let state = objc_getAssociatedObject(self, &Self.bridgeReplyStateKey) as? JavaScriptBridgeReplyControllerState {
            return state
        }
        let state = JavaScriptBridgeReplyControllerState()
        objc_setAssociatedObject(self, &Self.bridgeReplyStateKey, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return state
    }

    @available(iOS 14.0, *)
    func registerJavaScriptBridgeReplyOwner(_ owner: InAppWebView) {
        bridgeReplyState.owners.add(owner)
        syncJavaScriptBridgeReplyHandler()
    }

    @available(iOS 14.0, *)
    func unregisterJavaScriptBridgeReplyOwner(_ owner: InAppWebView) {
        guard let state = objc_getAssociatedObject(self, &Self.bridgeReplyStateKey) as? JavaScriptBridgeReplyControllerState else { return }
        state.owners.remove(owner)
        if state.owners.allObjects.isEmpty {
            for world in state.worlds {
                removeScriptMessageHandler(forName: JavaScriptBridgeReplyHandler.name, contentWorld: world)
            }
            state.worlds.removeAll()
        }
    }

    @available(iOS 14.0, *)
    func syncJavaScriptBridgeReplyHandler() {
        guard let state = objc_getAssociatedObject(self, &Self.bridgeReplyStateKey) as? JavaScriptBridgeReplyControllerState else { return }
        // Default OFF: no native reply API, bootstrap probe, or extra traffic.
        guard !state.owners.allObjects.isEmpty else { return }
        for world in contentWorlds where !state.worlds.contains(world) {
            addScriptMessageHandler(JavaScriptBridgeReplyHandler(), contentWorld: world,
                                    name: JavaScriptBridgeReplyHandler.name)
            state.worlds.insert(world)
        }
    }

    @available(iOS 14.0, *)
    func removeJavaScriptBridgeReplyWorld(_ world: WKContentWorld) {
        (objc_getAssociatedObject(self, &Self.bridgeReplyStateKey) as? JavaScriptBridgeReplyControllerState)?.worlds.remove(world)
    }
}
