import AppKit
import WebKit

@MainActor
final class ProbeApplication: NSObject, NSApplicationDelegate {
    let recorder = ActivityProbeRecorder()
    var window: NSWindow!
    let output: URL

    init(output: URL) { self.output = output }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            do {
                try await runCases()
                recorder.finish(output)
                window.close()
                exit(0)
            } catch {
                recorder.finish(output, error: error)
                exit(1)
            }
        }
    }

    func runCases() async throws {
        window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 640, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = "Apple activity getter CI fixture"
        window.isReleasedWhenClosed = false
        let parent = NSView(frame: window.contentView!.bounds)
        window.contentView = parent
        let view = WKWebView(frame: parent.bounds)
        parent.addSubview(view)
        view.loadHTMLString("<meta charset=utf-8><p>Native activity getter fixture</p>", baseURL: nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        try await waitFor("visible window") { self.window.isVisible && !self.window.isMiniaturized }
        try await recorder.observe(view, "visible", expected: ["windowAttached": true,
            "viewIsHidden": false, "viewOrAncestorIsHidden": false, "windowIsVisible": true])

        view.isHidden = true
        try await recorder.observe(view, "view-hidden", expected: ["windowAttached": true,
            "viewIsHidden": true, "viewOrAncestorIsHidden": true])
        view.isHidden = false
        parent.isHidden = true
        try await recorder.observe(view, "ancestor-hidden", expected: ["windowAttached": true,
            "viewIsHidden": false, "viewOrAncestorIsHidden": true])
        parent.isHidden = false
        try await recorder.observe(view, "ancestor-restored", expected: ["windowAttached": true,
            "viewOrAncestorIsHidden": false])

        view.removeFromSuperview()
        try await recorder.observe(view, "detached", expected: ["windowAttached": false])
        parent.addSubview(view)
        try await recorder.observe(view, "reattached", expected: ["windowAttached": true])

        window.orderOut(nil)
        try await waitFor("ordered-out window") { !self.window.isVisible }
        try await recorder.observe(view, "window-ordered-out", expected: ["windowAttached": true,
            "windowIsVisible": false, "windowIsMiniaturized": false])
        window.makeKeyAndOrderFront(nil)
        try await waitFor("restored window") { self.window.isVisible }
        try await recorder.observe(view, "window-restored", expected: ["windowAttached": true,
            "windowIsVisible": true])

        window.miniaturize(nil)
        try await waitFor("minimized window") { self.window.isMiniaturized }
        try await recorder.observe(view, "window-minimized", expected: ["windowAttached": true,
            "windowIsMiniaturized": true])
        window.deminiaturize(nil)
        try await waitFor("deminimized window") { !self.window.isMiniaturized && self.window.isVisible }
        try await recorder.observe(view, "window-deminimized", expected: ["windowAttached": true,
            "windowIsMiniaturized": false])

        NSApp.hide(nil)
        try await waitFor("hidden application") { NSApp.isHidden }
        try await recorder.observe(view, "application-hidden", expected: ["windowAttached": true,
            "applicationIsHidden": true])
        NSApp.unhide(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        try await waitFor("unhidden application") { !NSApp.isHidden && self.window.isVisible }
        try await recorder.observe(view, "application-unhidden", expected: ["windowAttached": true,
            "applicationIsHidden": false])

        let neverAttached = WKWebView(frame: .zero)
        try await recorder.observe(neverAttached, "never-attached", expected: ["windowAttached": false,
            "viewIsHidden": false, "viewOrAncestorIsHidden": false])
        try await recorder.observe(view, "owner-after-other-capture", expected: ["windowAttached": true])
        try await recorder.checkLifecycle(view)
        try await recorder.checkPolicies()
        try await recorder.checkCallbackBoundary(view)
    }
}

@main
struct ActivityProbeMain {
    @MainActor static func main() {
        guard CommandLine.arguments.count == 2 else { exit(2) }
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)
        let delegate = ProbeApplication(output: URL(fileURLWithPath: CommandLine.arguments[1]))
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
        // A successful test writes its result and exits in the delegate.
        exit(2)
    }
}
