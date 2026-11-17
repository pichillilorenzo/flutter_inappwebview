import Foundation
import ObjectiveC
import WebKit

/// A shared controller must not retain the parent WebView, or route a popup's
/// one-way messages through a disposed parent. Both adapters use the same route.
final class JavaScriptBridgeMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        (message.webView as? InAppWebView)?.handleScriptMessage(userContentController,
                                                             didReceive: message, reply: nil)
    }
}

private final class JavaScriptBridgeOwners {
    let views = NSHashTable<InAppWebView>.weakObjects()
}

extension WKUserContentController {
    private static var bridgeOwnersKey: UInt8 = 0

    func registerJavaScriptBridgeOwner(_ owner: InAppWebView) {
        let owners: JavaScriptBridgeOwners
        if let existing = objc_getAssociatedObject(self, &Self.bridgeOwnersKey) as? JavaScriptBridgeOwners {
            owners = existing
        } else {
            owners = JavaScriptBridgeOwners()
            objc_setAssociatedObject(self, &Self.bridgeOwnersKey, owners, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        owners.views.add(owner)
    }

    /// Returns true only when shared scripts/handlers have no remaining owner.
    func unregisterJavaScriptBridgeOwner(_ owner: InAppWebView) -> Bool {
        guard let owners = objc_getAssociatedObject(self, &Self.bridgeOwnersKey) as? JavaScriptBridgeOwners else { return true }
        owners.views.remove(owner)
        return owners.views.allObjects.isEmpty
    }
}
