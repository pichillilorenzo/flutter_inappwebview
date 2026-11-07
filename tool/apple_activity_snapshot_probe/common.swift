import Foundation
import WebKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ProbeFailure: Error, CustomStringConvertible {
    let description: String
}

@MainActor
func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() { throw ProbeFailure(description: message) }
}

@MainActor
func waitFor(_ label: String, _ predicate: () -> Bool) async throws {
    let deadline = ProcessInfo.processInfo.systemUptime + 8
    while !predicate() {
        if ProcessInfo.processInfo.systemUptime > deadline {
            throw ProbeFailure(description: "Timed out waiting for " + label)
        }
        try await Task.sleep(nanoseconds: 20_000_000)
    }
}

@MainActor
final class ActivityProbeRecorder {
    var observations: [[String: Any]] = []
    var lifecycleCases: [String] = []

    func observe(_ view: WKWebView, _ label: String,
                 expected: [String: Bool]) async throws {
        let delegate = ActivityProbeDelegate(webView: view)
        let wallBefore = Int64(Date().timeIntervalSince1970 * 1000)
        let uptimeBefore = ProcessInfo.processInfo.systemUptime
        let result = await request(delegate)
        let wallAfter = Int64(Date().timeIntervalSince1970 * 1000)
        let uptimeAfter = ProcessInfo.processInfo.systemUptime
        try require(result["availability"] as? String == "available", label + ": unavailable")
        try require(result["callbackOnMain"] as? Bool == true, label + ": callback not on main")
        let capturedAt = result["capturedAtMillisecondsSinceEpoch"] as? Int64
        try require(capturedAt != nil && capturedAt! >= wallBefore && capturedAt! <= wallAfter,
                    label + ": invalid native wall-clock capture time")
        for (key, value) in expected {
            try require(result[key] as? Bool == value, label + ": unexpected " + key)
        }
#if os(macOS)
        try require(result["platform"] as? String == "macos", "wrong native platform")
        try require(result["applicationState"] as? String ==
            (NSApp.isActive ? "active" : "inactive"), "wrong application state")
        try require(result["applicationIsHidden"] as? Bool == NSApp.isHidden,
                    "wrong application hidden state")
        try require(result["windowIsHidden"] == nil && result["windowSceneState"] == nil,
                    "macOS must not invent UIKit fields")
        if let window = view.window {
            try require(result["windowIsOcclusionVisible"] as? Bool ==
                window.occlusionState.contains(.visible), "wrong native window occlusion flag")
        }
#else
        try require(result["platform"] as? String == "ios", "wrong native platform")
        let expectedApplication: String
        switch UIApplication.shared.applicationState {
        case .active: expectedApplication = "active"
        case .inactive: expectedApplication = "inactive"
        case .background: expectedApplication = "background"
        @unknown default: expectedApplication = "unknown"
        }
        try require(result["applicationState"] as? String == expectedApplication,
                    "wrong application state")
        try require(result["applicationIsHidden"] == nil && result["windowIsVisible"] == nil &&
            result["windowIsMiniaturized"] == nil && result["windowIsOcclusionVisible"] == nil,
            "iOS must not infer AppKit visibility/occlusion")
        if #available(iOS 13.0, *), let scene = view.window?.windowScene {
            let expectedScene: String
            switch scene.activationState {
            case .unattached: expectedScene = "unattached"
            case .foregroundActive: expectedScene = "foregroundActive"
            case .foregroundInactive: expectedScene = "foregroundInactive"
            case .background: expectedScene = "background"
            @unknown default: expectedScene = "unknown"
            }
            try require(result["windowSceneState"] as? String == expectedScene,
                        "wrong owning scene state")
        } else {
            try require(result["windowSceneState"] == nil, "scene state without an owning scene")
        }
#endif
        if view.window == nil {
            for key in ["windowIsVisible", "windowIsMiniaturized", "windowIsOcclusionVisible",
                        "windowIsHidden", "windowSceneState"] {
                try require(result[key] == nil, label + ": stale window field " + key)
            }
        }
        if #available(iOS 17.0, macOS 14.0, *) {
            let actual = view.configuration.preferences.inactiveSchedulingPolicy
            try require(result["inactiveSchedulingPolicyIsSupported"] as? Bool == true,
                        "available policy marked unsupported")
            try require(result["inactiveSchedulingPolicyRawValue"] as? Int == actual.rawValue,
                        "wrong policy value")
        } else {
            try require(result["inactiveSchedulingPolicyIsSupported"] as? Bool == false,
                        "old OS policy marked available")
            try require(result["inactiveSchedulingPolicy"] == nil &&
                result["inactiveSchedulingPolicyRawValue"] == nil, "invented old-OS policy")
        }
        var observation = result
        observation["case"] = label
        observation["wallBefore"] = wallBefore
        observation["wallAfter"] = wallAfter
        observation["requestElapsedSeconds"] = uptimeAfter - uptimeBefore
        observations.append(observation)
    }

    func request(_ delegate: ActivityProbeDelegate) async -> [String: Any] {
        await withCheckedContinuation { continuation in
            delegate.handle { value in
                var result = value as? [String: Any] ?? [:]
                result["callbackOnMain"] = Thread.isMainThread
                continuation.resume(returning: result)
            }
        }
    }

    func checkLifecycle(_ view: WKWebView) async throws {
        let delegate = ActivityProbeDelegate(webView: view)
        let afterDispose: [String: Any] = await withCheckedContinuation { continuation in
            delegate.handle { value in
                continuation.resume(returning: value as? [String: Any] ?? [:])
            }
            delegate.dispose()
        }
        try require(afterDispose["availability"] as? String == "noNativeView" &&
            afterDispose.count == 1, "queued request returned data after native disposal")
        lifecycleCases.append("dispose-before-main-queue-capture")

        var releasedDelegate: ActivityProbeDelegate? = ActivityProbeDelegate(webView: view)
        weak var weakDelegate = releasedDelegate
        let afterRelease: [String: Any] = await withCheckedContinuation { continuation in
            releasedDelegate!.handle { value in
                continuation.resume(returning: value as? [String: Any] ?? [:])
            }
            releasedDelegate = nil
        }
        try require(weakDelegate == nil, "queued request retained its delegate")
        try require(afterRelease["availability"] as? String == "noNativeView" &&
            afterRelease.count == 1, "queued request returned data after delegate release")
        lifecycleCases.append("release-before-main-queue-capture")

        let backgroundDelegate = ActivityProbeDelegate(webView: view)
        let fromBackground: [String: Any] = await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                backgroundDelegate.handle { value in
                    var result = value as? [String: Any] ?? [:]
                    result["callbackOnMain"] = Thread.isMainThread
                    continuation.resume(returning: result)
                }
            }
        }
        try require(fromBackground["availability"] as? String == "available" &&
            fromBackground["callbackOnMain"] as? Bool == true,
            "background request did not capture and complete on main")
        lifecycleCases.append("background-request-main-thread-capture")
    }

    func checkPolicies() async throws {
        if #available(iOS 17.0, macOS 14.0, *) {
            // Test-owned views only. The production capture never changes policy.
            for (policy, name) in [(WKPreferences.InactiveSchedulingPolicy.suspend, "suspend"),
                                   (.throttle, "throttle"), (.none, "none")] {
                let configuration = WKWebViewConfiguration()
                configuration.preferences.inactiveSchedulingPolicy = policy
                let view = WKWebView(frame: .zero, configuration: configuration)
                try await observe(view, "policy-" + name, expected: ["windowAttached": false])
                try require(observations.last?["inactiveSchedulingPolicy"] as? String == name,
                            "wrong policy name")
                try require(view.configuration.preferences.inactiveSchedulingPolicy == policy,
                            "capture changed the configured policy")
            }
        }
    }

    func finish(_ output: URL, error: Error? = nil) {
#if os(macOS)
        let sandbox = "Direct macOS app without App Sandbox entitlements; not the Flutter app sandbox"
#else
        let sandbox = "Ad-hoc-signed iOS Simulator app in its application container; not a physical device"
#endif
        let errorMessage: Any
        if let error = error { errorMessage = String(describing: error) }
        else { errorMessage = NSNull() }
        let report: [String: Any] = [
            "schemaVersion": 1,
            "probe": "apple-native-activity-getter",
            "status": error == nil ? "passed" : "failed",
            "error": errorMessage,
            "os": ProcessInfo.processInfo.operatingSystemVersionString,
            "webKitVersion": Bundle(for: WKWebView.self).object(forInfoDictionaryKey: "CFBundleVersion") ?? NSNull(),
            "hostProcessId": ProcessInfo.processInfo.processIdentifier,
            "scope": "Direct WKWebView with production capture and extracted method route; no Flutter platform view or Offstage test",
            "sandbox": sandbox,
            "javaScriptEvaluationApiCallsInFixture": 0,
            "cpuMeasurement": NSNull(),
            "webContentProcessLiveness": NSNull(),
            "observations": observations,
            "lifecycleCases": lifecycleCases
        ]
        do {
            try FileManager.default.createDirectory(at: output.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            let data = try JSONSerialization.data(withJSONObject: report,
                options: [.prettyPrinted, .sortedKeys])
            try data.write(to: output, options: .atomic)
            print("ACTIVITY_PROBE " + (error == nil ? "PASS" : "FAIL") + " " + output.path)
        } catch {
            fputs("Failed to write native activity result: \(error)\n", stderr)
            exit(2)
        }
    }
}
