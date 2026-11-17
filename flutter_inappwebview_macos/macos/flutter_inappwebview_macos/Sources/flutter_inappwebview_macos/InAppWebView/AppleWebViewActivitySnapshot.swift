import Foundation
import WebKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A read-only UI-process observation. No JavaScript, timers or policy writes.
/// Neither these flags nor the configured policy establish process liveness,
/// actual JavaScript suspension, or whether this view is rendering pixels.
// Keep production on the plugin's synchronous/GCD path at iOS 12/macOS 10.14.
// Only the newer-OS test applications use Swift async/await.
extension WKWebView {
    func getAppleWebViewActivitySnapshot() -> [String: Any] {
        precondition(Thread.isMainThread)
        let webView = self
        let window = webView.window
        var result: [String: Any] = [
            "schemaVersion": 1,
            "availability": "available",
            "capturedAtMillisecondsSinceEpoch": Int64(Date().timeIntervalSince1970 * 1000),
            "windowAttached": window != nil,
            "viewIsHidden": webView.isHidden
        ]
#if os(macOS)
        result["platform"] = "macos"
        result["viewOrAncestorIsHidden"] = webView.isHiddenOrHasHiddenAncestor
        result["applicationState"] = NSApplication.shared.isActive ? "active" : "inactive"
        result["applicationIsHidden"] = NSApplication.shared.isHidden
        if let window = window {
            result["windowIsVisible"] = window.isVisible
            result["windowIsMiniaturized"] = window.isMiniaturized
            result["windowIsOcclusionVisible"] = window.occlusionState.contains(.visible)
        }
#else
        result["platform"] = "ios"
        var ancestor: UIView? = webView
        var hidden = false
        while let view = ancestor {
            hidden = hidden || view.isHidden
            ancestor = view.superview
        }
        result["viewOrAncestorIsHidden"] = hidden
        switch UIApplication.shared.applicationState {
        case .active: result["applicationState"] = "active"
        case .inactive: result["applicationState"] = "inactive"
        case .background: result["applicationState"] = "background"
        @unknown default: result["applicationState"] = "unknown"
        }
        if let window = window {
            result["windowIsHidden"] = window.isHidden
            if #available(iOS 13.0, *), let scene = window.windowScene {
                switch scene.activationState {
                case .unattached: result["windowSceneState"] = "unattached"
                case .foregroundInactive: result["windowSceneState"] = "foregroundInactive"
                case .foregroundActive: result["windowSceneState"] = "foregroundActive"
                case .background: result["windowSceneState"] = "background"
                @unknown default: result["windowSceneState"] = "unknown"
                }
            }
        }
#endif
        if #available(iOS 17.0, macOS 14.0, *) {
            let policy = webView.configuration.preferences.inactiveSchedulingPolicy
            result["inactiveSchedulingPolicyIsSupported"] = true
            result["inactiveSchedulingPolicyRawValue"] = policy.rawValue
            switch policy {
            case .suspend: result["inactiveSchedulingPolicy"] = "suspend"
            case .throttle: result["inactiveSchedulingPolicy"] = "throttle"
            case .none: result["inactiveSchedulingPolicy"] = "none"
            @unknown default: result["inactiveSchedulingPolicy"] = "unknown"
            }
        } else {
            result["inactiveSchedulingPolicyIsSupported"] = false
        }
        return result
    }
}
