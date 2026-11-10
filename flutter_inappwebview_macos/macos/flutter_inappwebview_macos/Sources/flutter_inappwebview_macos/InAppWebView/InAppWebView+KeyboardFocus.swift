//
//  InAppWebView+KeyboardFocus.swift
//  flutter_inappwebview
//
//  Keyboard and VoiceOver focus going into and out of the page.
//
//  The web view is a Flutter platform view. Flutter's focus can stand on it, but
//  nothing made the web view AppKit's first responder, so Tab stopped on it
//  without getting into the page, and VoiceOver, which follows the first
//  responder and finds only an empty group for the view in the Flutter
//  semantics tree, could not read the page. Once the web view is first responder
//  VoiceOver reads the page as in any other app.
//  The Dart side (MacOSInAppWebViewWidget) says when.
//

import AppKit
import WebKit

extension InAppWebView {
    /// The Flutter view hosting the web view. It is the first responder whenever Flutter has the keyboard.
    var flutterHostView: NSView? {
        var view = superview
        while let v = view {
            if String(describing: type(of: v)).contains("FlutterView") {
                return v
            }
            view = v.superview
        }
        return nil
    }

    private var hasKeyboardFocus: Bool {
        guard let responder = window?.firstResponder as? NSView else { return false }
        return responder === self || responder.isDescendant(of: self)
    }

    /// Gives the page the keyboard focus. `"next"` starts at its first focusable element
    /// (Tab came forward into it), `"previous"` at its last one (Shift+Tab), anything else
    /// at the page itself (for example, VoiceOver moved onto it).
    ///
    /// The first and last element are chosen by WebKit itself: a web view that becomes first
    /// responder through the window's key view loop sets its initial focus by the direction of
    /// the loop. The loop is pointed through the web view only for the moment of the move.
    func focusPage(direction: String?) {
        guard let window = window, !hasKeyboardFocus else { return }
        if let host = flutterHostView {
            if direction == "next" {
                let saved = host.nextKeyView
                host.nextKeyView = self
                window.selectKeyView(following: host)
                host.nextKeyView = saved
            } else if direction == "previous" {
                let saved = nextKeyView
                nextKeyView = host
                window.selectKeyView(preceding: host)
                nextKeyView = saved
            }
        }
        if !hasKeyboardFocus {
            window.makeFirstResponder(self)
        }
    }

    /// Flutter's focus left the web view: the keyboard goes back to Flutter.
    func releasePage() {
        guard let window = window, hasKeyboardFocus, let host = flutterHostView else { return }
        window.makeFirstResponder(host)
    }

    /// WKUIDelegate (private): Tab went past the last focusable element of the page
    /// (Shift+Tab before the first one). Without this, WebKit walks the window's key view
    /// loop, which does not lead back into Flutter's focus order.
    /// `direction` is `_WKFocusDirection` (0 backward, 1 forward).
    @objc(_webView:takeFocus:)
    func webView(_ webView: WKWebView, takeFocus direction: Int) {
        if let host = flutterHostView {
            window?.makeFirstResponder(host)
        }
        channelDelegate?.channel?.invokeMethod("_onTakeFocus", arguments: ["forward": direction == 1])
    }
}
