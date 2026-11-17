//
//  UnhandledScrollGestureForwarder.swift
//  flutter_inappwebview
//

import AppKit
import WebKit

/// Hands horizontal trackpad gestures that the page did not use to the host view.
///
/// WKWebView never passes an unused wheel event up the responder chain, so a host
/// such as Flutter cannot react to a horizontal swipe over a page. WebKit reports
/// every unused event asynchronously and in order through
/// `_webView:didNotHandleWheelEvent:`, after scrolling (including frames and shadow
/// trees), rubber-banding and `preventDefault()` have all had their say.
///
/// Ownership is decided once per gesture, from the first report: the host receives
/// the whole gesture, in order and from its first event, only when one of the
/// first moving events was unused and the movement so far is mostly horizontal.
/// A gesture the page used, or one without a timely report, stays with the page.
/// A gesture that began outside the web view (e.g. over Flutter content that then
/// slid the web view under the pointer) already belongs to the host.
public final class UnhandledScrollGestureForwarder {
    /// Moving events after which a first report no longer hands the gesture over.
    static let decisionWindow = 4
    /// Events kept while the owner is undecided.
    static let maxPendingEvents = 64
    /// A report this long after the gesture ended could interrupt the user's next gesture.
    static let lateReportAfterEnd: TimeInterval = 0.25

    private enum Owner {
        case undecided
        case page
        case host
    }

    private let forward: (NSEvent) -> Void
    private var tracking = false
    private var owner = Owner.page
    private var pending: [NSEvent] = []
    private var endedAt: TimeInterval?

    public init(forward: @escaping (NSEvent) -> Void) {
        self.forward = forward
    }

    /// Records an event that is about to be sent to WebKit.
    public func observe(_ event: NSEvent) {
        guard UnhandledScrollGestureForwarder.isTrackpadGestureEvent(event) else {
            return
        }
        let phase = event.phase
        if phase.contains(.mayBegin) || (phase.contains(.began) && !continuesMayBegin()) {
            tracking = true
            owner = .undecided
            pending = []
            endedAt = nil
        }
        guard tracking else {
            if phase.contains(.changed) || phase.contains(.ended) || phase.contains(.cancelled) {
                forward(event)
            }
            return
        }
        if phase.contains(.ended) || phase.contains(.cancelled) {
            tracking = false
            endedAt = ProcessInfo.processInfo.systemUptime
        }
        switch owner {
        case .host:
            forward(event)
        case .page:
            break
        case .undecided:
            if pending.count >= UnhandledScrollGestureForwarder.maxPendingEvents {
                giveToPage()
            } else {
                pending.append(event)
            }
        }
    }

    /// Handles WebKit's report that it did not use [event].
    public func didNotHandle(_ event: NSEvent) {
        if let endedAt = endedAt,
           ProcessInfo.processInfo.systemUptime - endedAt > UnhandledScrollGestureForwarder.lateReportAfterEnd {
            giveToPage()
        }
        guard owner == .undecided,
              let index = pending.firstIndex(where: { UnhandledScrollGestureForwarder.isSame($0, event) }),
              UnhandledScrollGestureForwarder.isMoving(pending[index]) else {
            return
        }
        let moving = pending[...index].filter(UnhandledScrollGestureForwarder.isMoving)
        let dx = moving.reduce(CGFloat(0)) { $0 + $1.scrollingDeltaX }
        let dy = moving.reduce(CGFloat(0)) { $0 + $1.scrollingDeltaY }
        guard moving.count <= UnhandledScrollGestureForwarder.decisionWindow, abs(dx) > abs(dy) else {
            giveToPage()
            return
        }
        owner = .host
        let events = pending
        pending = []
        events.forEach(forward)
    }

    /// Keeps a page that cannot scroll sideways from bouncing sideways: WebKit counts
    /// that bounce as using the event, so no horizontal swipe would ever be unused.
    /// `_rubberBandingEnabled` is WebKit SPI (macOS 10.13.4); without it nothing changes.
    public static func stopHorizontalRubberBanding(_ webView: WKWebView) {
        let key = "rubberBandingEnabled"
        guard webView.responds(to: NSSelectorFromString("_setRubberBandingEnabled:")),
              let edges = webView.value(forKey: key) as? UInt else {
            return
        }
        let horizontal: UInt = (1 << CGRectEdge.minXEdge.rawValue) | (1 << CGRectEdge.maxXEdge.rawValue)
        webView.setValue(edges & ~horizontal, forKey: key)
    }

    /// Forgets the current gesture, e.g. when the web view is disposed.
    public func reset() {
        tracking = false
        giveToPage()
    }

    private func giveToPage() {
        owner = .page
        pending = []
    }

    /// A `began` that follows a lone `mayBegin` belongs to the same touch.
    private func continuesMayBegin() -> Bool {
        return tracking && owner == .undecided && pending.count == 1
            && pending[0].phase.contains(.mayBegin)
    }

    static func isTrackpadGestureEvent(_ event: NSEvent) -> Bool {
        return event.type == .scrollWheel && event.hasPreciseScrollingDeltas
            && !event.phase.isEmpty && event.momentumPhase.isEmpty
    }

    static func isMoving(_ event: NSEvent) -> Bool {
        return event.phase.contains(.changed)
            && (event.scrollingDeltaX != 0 || event.scrollingDeltaY != 0)
    }

    /// WebKit reports the NSEvent it was given; a coalesced batch reports its last event.
    static func isSame(_ a: NSEvent, _ b: NSEvent) -> Bool {
        return a === b || (a.timestamp == b.timestamp && a.phase == b.phase
            && a.scrollingDeltaX == b.scrollingDeltaX && a.scrollingDeltaY == b.scrollingDeltaY)
    }
}
