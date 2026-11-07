import UIKit
import WebKit

@MainActor
final class ProbeApplication: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting session: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Activity Probe", sessionRole: session.role)
        configuration.delegateClass = ProbeSceneDelegate.self
        return configuration
    }
}

@MainActor
final class ProbeSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let recorder = ActivityProbeRecorder()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        self.window = window
        Task { @MainActor in
            let output = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("apple-activity.json")
            do {
                try await waitFor("active simulator scene") {
                    UIApplication.shared.applicationState == .active &&
                        windowScene.activationState == .foregroundActive
                }
                try await runCases()
                recorder.finish(output)
            } catch {
                recorder.finish(output, error: error)
            }
        }
    }

    func runCases() async throws {
        let parent = window!.rootViewController!.view!
        let view = WKWebView(frame: parent.bounds)
        parent.addSubview(view)
        view.loadHTMLString("<meta charset=utf-8><p>Native activity getter fixture</p>", baseURL: nil)
        try await recorder.observe(view, "visible", expected: ["windowAttached": true,
            "viewIsHidden": false, "viewOrAncestorIsHidden": false, "windowIsHidden": false])
        try require(recorder.observations.last?["windowSceneState"] as? String == "foregroundActive",
                    "attached view did not report its owning scene")
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
        window!.isHidden = true
        try await recorder.observe(view, "window-hidden", expected: ["windowAttached": true,
            "viewOrAncestorIsHidden": true, "windowIsHidden": true])
        window!.isHidden = false
        try await recorder.observe(view, "window-restored", expected: ["windowAttached": true,
            "windowIsHidden": false])
        let neverAttached = WKWebView(frame: .zero)
        try await recorder.observe(neverAttached, "never-attached", expected: ["windowAttached": false,
            "viewIsHidden": false, "viewOrAncestorIsHidden": false])
        try await recorder.observe(view, "owner-after-other-capture", expected: ["windowAttached": true])
        // An attached view in a never-shown, scene-less UIWindow has no scene
        // metadata even while the application's real scene is active elsewhere.
        let legacyWindow = UIWindow(frame: .zero)
        let legacyView = WKWebView(frame: .zero)
        legacyWindow.addSubview(legacyView)
        try await recorder.observe(legacyView, "window-without-scene", expected: ["windowAttached": true])
        try require(recorder.observations.last?["windowSceneState"] == nil,
                    "invented scene state on a scene-less window")
        legacyView.removeFromSuperview()
        try await recorder.checkLifecycle(view)
        try await recorder.checkPolicies()
        try await recorder.checkCallbackBoundary(view)
    }
}

@main
struct ActivityProbeMain {
    @MainActor static func main() {
        UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil,
            NSStringFromClass(ProbeApplication.self))
    }
}
