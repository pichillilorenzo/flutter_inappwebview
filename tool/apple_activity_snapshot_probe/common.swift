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
    var comparisonControls: [[String: Any]] = []

    private let booleanFields = ["viewIsHidden", "viewOrAncestorIsHidden", "windowAttached",
        "applicationIsHidden", "windowIsVisible", "windowIsMiniaturized",
        "windowIsOcclusionVisible", "windowIsHidden", "inactiveSchedulingPolicyIsSupported"]

    // Read framework properties independently of the production helper, inside
    // its synchronous result callback. Never reread them after an await to judge
    // an earlier snapshot: app/window/scene state may have changed by then.
    private func readReference(_ view: WKWebView) -> [String: Any] {
        precondition(Thread.isMainThread)
        let window = view.window
        var reference: [String: Any] = ["windowAttached": window != nil,
            "viewIsHidden": view.isHidden]
#if os(macOS)
        reference["platform"] = "macos"
        reference["viewOrAncestorIsHidden"] = view.isHiddenOrHasHiddenAncestor
        reference["applicationState"] = NSApp.isActive ? "active" : "inactive"
        reference["applicationIsHidden"] = NSApp.isHidden
        if let window = window {
            reference["windowIsVisible"] = window.isVisible
            reference["windowIsMiniaturized"] = window.isMiniaturized
            reference["windowIsOcclusionVisible"] = window.occlusionState.contains(.visible)
        }
#else
        reference["platform"] = "ios"
        var ancestor: UIView? = view
        var hidden = false
        while let current = ancestor {
            hidden = hidden || current.isHidden
            ancestor = current.superview
        }
        reference["viewOrAncestorIsHidden"] = hidden
        switch UIApplication.shared.applicationState {
        case .active: reference["applicationState"] = "active"
        case .inactive: reference["applicationState"] = "inactive"
        case .background: reference["applicationState"] = "background"
        @unknown default: reference["applicationState"] = "unknown"
        }
        if let window = window {
            reference["windowIsHidden"] = window.isHidden
            if #available(iOS 13.0, *), let scene = window.windowScene {
                switch scene.activationState {
                case .unattached: reference["windowSceneState"] = "unattached"
                case .foregroundActive: reference["windowSceneState"] = "foregroundActive"
                case .foregroundInactive: reference["windowSceneState"] = "foregroundInactive"
                case .background: reference["windowSceneState"] = "background"
                @unknown default: reference["windowSceneState"] = "unknown"
                }
            }
        }
#endif
        if #available(iOS 17.0, macOS 14.0, *) {
            reference["inactiveSchedulingPolicyIsSupported"] = true
            reference["inactiveSchedulingPolicyRawValue"] =
                view.configuration.preferences.inactiveSchedulingPolicy.rawValue
        } else {
            reference["inactiveSchedulingPolicyIsSupported"] = false
        }
        return reference
    }

    private func captureObservation(_ view: WKWebView, _ label: String,
                                    expected: [String: Bool],
                                    afterReference: (() -> Void)? = nil) async -> [String: Any] {
        let delegate = ActivityProbeDelegate(webView: view)
        let wallBefore = Int64(Date().timeIntervalSince1970 * 1000)
        let uptimeBefore = ProcessInfo.processInfo.systemUptime
        var observation: [String: Any] = await withCheckedContinuation { continuation in
            delegate.handle { value in
                let onMain = Thread.isMainThread
                // The production route calls result synchronously after capture.
                // Save its unmodified value and our reference before resuming.
                var captured = value as? [String: Any] ?? [:]
                captured["nativeResult"] = value ?? NSNull()
                captured["callbackReference"] = onMain ? self.readReference(view) : [:]
                captured["case"] = label
                captured["expected"] = expected
                captured["callbackOnMain"] = onMain
                captured["referenceBoundary"] = "native-result-callback-before-resume"
                captured["wallBefore"] = wallBefore
                captured["callbackAt"] = Int64(Date().timeIntervalSince1970 * 1000)
                captured["callbackElapsedSeconds"] = ProcessInfo.processInfo.systemUptime - uptimeBefore
                // Test-only hook: deterministic state change after callback-side
                // capture, before the awaiting caller can resume. No production hook.
                afterReference?()
                continuation.resume(returning: captured)
            }
        }
        // The fixture is the delegate's owner; keep it alive across the queued
        // read. Production still captures its delegate weakly, unchanged.
        withExtendedLifetime(delegate) {}
        observation["wallAfter"] = Int64(Date().timeIntervalSince1970 * 1000)
        observation["requestElapsedSeconds"] = ProcessInfo.processInfo.systemUptime - uptimeBefore
        return observation
    }

    // Pure comparison of saved values. No AppKit/UIKit/WebKit reads here.
    private func validateObservation(_ observation: [String: Any]) throws {
        guard let result = observation["nativeResult"] as? [String: Any],
              let reference = observation["callbackReference"] as? [String: Any],
              let expected = observation["expected"] as? [String: Bool],
              let label = observation["case"] as? String,
              let before = observation["wallBefore"] as? Int64,
              let callback = observation["callbackAt"] as? Int64,
              let after = observation["wallAfter"] as? Int64 else {
            throw ProbeFailure(description: "missing observation evidence")
        }
        try require(result["availability"] as? String == "available", label + ": unavailable")
        try require(observation["callbackOnMain"] as? Bool == true, label + ": callback not on main")
        let capturedAt = result["capturedAtMillisecondsSinceEpoch"] as? Int64
        try require(capturedAt != nil && capturedAt! >= before && capturedAt! <= callback && callback <= after,
                    label + ": invalid native wall-clock capture time")
        for (key, value) in expected {
            try require(result[key] as? Bool == value, label + ": unexpected " + key)
        }
        for key in booleanFields {
            if let value = reference[key] as? Bool {
                try require(result[key] as? Bool == value, label + ": reference mismatch: " + key)
            } else {
                try require(result[key] == nil, label + ": unavailable reference field: " + key)
            }
        }
        for key in ["platform", "applicationState", "windowSceneState"] {
            if let value = reference[key] as? String {
                try require(result[key] as? String == value, label + ": reference mismatch: " + key)
            } else {
                try require(result[key] == nil, label + ": unavailable reference field: " + key)
            }
        }
        if reference["inactiveSchedulingPolicyIsSupported"] as? Bool == true {
            guard let policy = reference["inactiveSchedulingPolicyRawValue"] as? Int else {
                throw ProbeFailure(description: label + ": missing policy reference")
            }
            try require(result["inactiveSchedulingPolicyRawValue"] as? Int == policy,
                        label + ": wrong policy value")
        } else {
            try require(result["inactiveSchedulingPolicy"] == nil &&
                result["inactiveSchedulingPolicyRawValue"] == nil, label + ": invented old-OS policy")
        }
    }

    func observe(_ view: WKWebView, _ label: String,
                 expected: [String: Bool]) async throws {
        try recordObservation(await captureObservation(view, label, expected: expected))
    }

    private func recordObservation(_ captured: [String: Any]) throws {
        var observation = captured
        observation["validationStatus"] = "pending"
        let index = observations.count
        // Retain raw result, reference, phase expectation and timing even when
        // the first assertion fails. finish(error:) will write this failed row.
        observations.append(observation)
        do {
            try validateObservation(observation)
            observations[index]["validationStatus"] = "passed"
        } catch {
            observations[index]["validationStatus"] = "failed"
            observations[index]["validationError"] = String(describing: error)
            throw error
        }
    }

    private func rejectedComparison(_ observation: [String: Any], field: String) throws -> [String: Any] {
        // Exercise the same record-before-validation path on a separate recorder
        // so intentionally failed controls do not replace ordinary observations.
        let recorder = ActivityProbeRecorder()
        do {
            try recorder.recordObservation(observation)
        } catch let failure as ProbeFailure {
            try require(failure.description.contains(field), "negative control failed for an unrelated field")
            try require(recorder.observations.count == 1, "failed comparison lost its observation")
            let failed = recorder.observations[0]
            try require(failed["validationStatus"] as? String == "failed" &&
                failed["validationError"] as? String == failure.description,
                "failed comparison lost its validation result")
            var retained = failed
            retained.removeValue(forKey: "validationStatus")
            retained.removeValue(forKey: "validationError")
            try require(NSDictionary(dictionary: retained).isEqual(NSDictionary(dictionary: observation)),
                        "failed comparison changed its raw result/reference/timing")
            return failed
        }
        throw ProbeFailure(description: "comparison accepted a wrong value for " + field)
    }

    func checkCallbackBoundary(_ view: WKWebView) async throws {
        let originalHidden = view.isHidden
        defer { view.isHidden = originalHidden }
        view.isHidden = false
        let captured = await captureObservation(view, "callback-state-change", expected: [:],
                                               afterReference: { view.isHidden = true })
        let index = comparisonControls.count
        comparisonControls.append(["case": "callback-state-change", "observation": captured,
            "viewIsHiddenAfterResume": view.isHidden, "validationStatus": "pending"])
        do {
            try require(view.isHidden && captured["viewIsHidden"] as? Bool == false,
                        "control did not change view state between callback capture and resumption")
            try validateObservation(captured)
            var lateReference = captured
            lateReference["callbackReference"] = readReference(view)
            comparisonControls[index]["lateReference"] = lateReference["callbackReference"]
            let lateFailure = try rejectedComparison(lateReference, field: "viewIsHidden")
            comparisonControls[index]["lateReferenceRejected"] = lateFailure["validationError"]
            comparisonControls[index]["lateReferenceFailure"] = lateFailure
            var rejections: [[String: Any]] = []
            for field in booleanFields {
                var wrong = captured
                var raw = captured["nativeResult"] as! [String: Any]
                // Also reject invented false values for platform-unavailable flags.
                let incorrect = !(raw[field] as? Bool ?? true)
                raw[field] = incorrect
                wrong["nativeResult"] = raw
                wrong[field] = incorrect
                let failure = try rejectedComparison(wrong, field: field)
                rejections.append(["field": field, "value": incorrect,
                    "error": failure["validationError"]!, "failedObservation": failure])
            }
            comparisonControls[index]["wrongNativeValuesRejected"] = rejections
            comparisonControls[index]["validationStatus"] = "passed"
        } catch {
            comparisonControls[index]["validationStatus"] = "failed"
            comparisonControls[index]["validationError"] = String(describing: error)
            throw error
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
            "lifecycleCases": lifecycleCases,
            "comparisonControls": comparisonControls
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
