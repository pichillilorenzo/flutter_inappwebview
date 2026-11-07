#!/usr/bin/env python3
"""Check native activity metadata without JavaScript or a Flutter engine.

The capture helper is compiled byte-for-byte. The actual channel switch branch
is compiled in a small delegate with a weak WKWebView, not a fake WKWebView.
The source mode does not compile Swift. macOS and iOS Simulator probes are
separate from Flutter platform-view/Offstage and physical-device acceptance.
"""

import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import plistlib
import shutil
import subprocess
import sys
import time
import uuid

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tool/apple_activity_snapshot_probe"
BASE_CASES = ["visible", "view-hidden", "ancestor-hidden", "ancestor-restored",
              "detached", "reattached", "window-restored", "never-attached",
              "owner-after-other-capture"]
LIFECYCLE_CASES = ["dispose-before-main-queue-capture",
                   "release-before-main-queue-capture",
                   "background-request-main-thread-capture"]
REFERENCE_BOOLEAN_FIELDS = ["viewIsHidden", "viewOrAncestorIsHidden", "windowAttached",
    "applicationIsHidden", "windowIsVisible", "windowIsMiniaturized",
    "windowIsOcclusionVisible", "windowIsHidden", "inactiveSchedulingPolicyIsSupported"]
REFERENCE_FIELDS = REFERENCE_BOOLEAN_FIELDS + ["platform", "applicationState", "windowSceneState",
                                               "inactiveSchedulingPolicyRawValue"]


def source_dir(apple_platform):
    package = f"flutter_inappwebview_{apple_platform}"
    return ROOT / package / apple_platform / package / "Sources" / package / "InAppWebView"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read_sources():
    sources = {}
    for apple_platform in ("ios", "macos"):
        directory = source_dir(apple_platform)
        helper = (directory / "AppleWebViewActivitySnapshot.swift").read_bytes()
        delegate = (directory / "WebViewChannelDelegate.swift").read_text()
        start = "        case .getAppleWebViewActivitySnapshot:\n"
        end = "        case .getUrl:\n"
        if delegate.count(start) != 1 or delegate.count(end) != 1:
            raise AssertionError("Activity route boundaries are not unique")
        route = start + delegate.split(start, 1)[1].split(end, 1)[0]
        if not route.rstrip().endswith("break"):
            raise AssertionError("Incomplete activity channel branch")
        for forbidden in ("evaluateJavaScript(", "evaluateJavascript(", "Timer(",
                          "inactiveSchedulingPolicy =", "performSelector", "value(forKey:",
                          "systemUptime"):
            if forbidden in helper.decode() or forbidden in route:
                raise AssertionError("Activity capture must remain read-only: " + forbidden)
        assert "precondition(Thread.isMainThread)" in helper.decode()
        assert 'if #available(iOS 17.0, macOS 14.0, *)' in helper.decode()
        assert route.index("DispatchQueue.main.async { [weak self]") < route.index("self?.webView")
        assert route.count("webView.getAppleWebViewActivitySnapshot()") == 1
        assert 'result(["availability": "noNativeView"])' in route
        assert 'case getAppleWebViewActivitySnapshot' in (
            directory / "WebViewChannelDelegateMethods.swift").read_text()
        sources[apple_platform] = (helper, route)
    assert sources["ios"] == sources["macos"], "Platform source copies drifted"
    return sources


def emit_sources(output):
    sources = read_sources()
    manifest = {}
    for apple_platform, (helper, route) in sources.items():
        directory = output / apple_platform
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "Capture.swift").write_bytes(helper)
        delegate = """import Foundation
import WebKit

// Fixture surrounding the byte-for-byte production channel switch branch.
// FlutterResult has the same (Any?) -> Void signature used here.
final class ActivityProbeDelegate {
    private weak var webView: WKWebView?
    init(webView: WKWebView) { self.webView = webView }
    func dispose() { webView = nil }
    enum Method { case getAppleWebViewActivitySnapshot }
    func handle(result: @escaping (Any?) -> Void) {
        let method = Method.getAppleWebViewActivitySnapshot
        switch method {
""" + route + """        }
    }
}
"""
        (directory / "Delegate.swift").write_text(delegate)
        manifest[apple_platform] = {
            "captureSha256": sha(helper), "routeSha256": sha(route.encode()),
            "delegateFixtureSha256": sha(delegate.encode()),
            "captureByteIdenticalToProduction": True,
            "routeByteIdenticalToProduction": True,
        }
    (output / "source-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return manifest


def validate_capture_evidence(row, apple_platform):
    """Recheck saved callback data, never compare with a later framework state."""
    def require(condition, reason):
        if not condition:
            raise AssertionError(reason)
    native = row.get("nativeResult")
    reference = row.get("callbackReference")
    expected = row.get("expected")
    require(isinstance(native, dict) and isinstance(reference, dict) and isinstance(expected, dict),
            "Missing native result/reference/phase evidence")
    require(native.get("availability") == "available" and native.get("platform") == apple_platform,
            "Unobserved callback data")
    require(type(native.get("schemaVersion")) is int and native["schemaVersion"] == 1,
            "Invalid callback observation schema")
    require(row.get("callbackOnMain") is True and
            row.get("referenceBoundary") == "native-result-callback-before-resume",
            "Reference was not captured at the main-thread native callback")
    for key, value in native.items():
        require(type(row.get(key)) is type(value) and row.get(key) == value,
                "Displayed observation differs from raw native result: " + key)
    for key in ("wallBefore", "callbackAt", "wallAfter"):
        require(type(row.get(key)) is int, "Missing callback boundary: " + key)
    captured = native.get("capturedAtMillisecondsSinceEpoch")
    require(type(captured) is int and
            row["wallBefore"] <= captured <= row["callbackAt"] <= row["wallAfter"],
            "Capture outside native callback boundary")
    callback_elapsed = row.get("callbackElapsedSeconds")
    elapsed = row.get("requestElapsedSeconds")
    require(all(type(value) in (int, float) and math.isfinite(value)
                for value in (callback_elapsed, elapsed)) and 0 <= callback_elapsed <= elapsed,
            "Invalid callback/resumption interval")
    for key, value in expected.items():
        require(type(value) is bool and type(native.get(key)) is bool and native[key] == value,
                "Unexpected phase value: " + key)
    for key in REFERENCE_FIELDS:
        actual, wanted = native.get(key), reference.get(key)
        require(type(actual) is type(wanted) and actual == wanted,
                "Callback reference mismatch: " + key)


def validate_comparison_controls(controls, apple_platform):
    def require(condition, reason):
        if not condition:
            raise AssertionError(reason)
    require(isinstance(controls, list) and len(controls) == 1, "Missing callback comparison control")
    control = controls[0]
    require(control.get("case") == "callback-state-change" and
            control.get("validationStatus") == "passed" and control.get("validationError") is None,
            "Callback comparison control failed")
    captured = control.get("observation")
    require(isinstance(captured, dict), "Missing control observation")
    validate_capture_evidence(captured, apple_platform)
    require(captured["nativeResult"].get("viewIsHidden") is False and
            control.get("viewIsHiddenAfterResume") is True,
            "Control did not change state after callback capture")
    late_reference = control.get("lateReference")
    require(isinstance(late_reference, dict) and late_reference.get("viewIsHidden") is True,
            "Missing changed reference after resumption")

    def require_rejected(changed, field, recorded_error, failed):
        require(isinstance(recorded_error, str) and field in recorded_error,
                "Missing native rejection evidence: " + field)
        require(isinstance(failed, dict) and failed.get("validationStatus") == "failed" and
                failed.get("validationError") == recorded_error, "Missing retained failure: " + field)
        retained = {key: value for key, value in failed.items()
                    if key not in ("validationStatus", "validationError")}
        require(json.dumps(retained, sort_keys=True) == json.dumps(changed, sort_keys=True),
                "Failed comparison changed or lost raw evidence: " + field)
        try:
            validate_capture_evidence(changed, apple_platform)
        except AssertionError as error:
            require(field in str(error), "Control failed for an unrelated field")
        else:
            raise AssertionError("Comparison accepted a wrong value for " + field)

    later = dict(captured, callbackReference=late_reference)
    require_rejected(later, "viewIsHidden", control.get("lateReferenceRejected"),
                     control.get("lateReferenceFailure"))
    rejections = control.get("wrongNativeValuesRejected")
    require(isinstance(rejections, list) and
            [item.get("field") for item in rejections] == REFERENCE_BOOLEAN_FIELDS,
            "Incomplete wrong-native-value controls")
    for rejection in rejections:
        field, value = rejection["field"], rejection.get("value")
        require(type(value) is bool, "Missing incorrect native flag")
        wrong = dict(captured)
        wrong["nativeResult"] = dict(captured["nativeResult"], **{field: value})
        wrong[field] = value
        require_rejected(wrong, field, rejection.get("error"), rejection.get("failedObservation"))


def validate_report(report, apple_platform):
    def require(condition, reason):
        if not condition:
            raise AssertionError(reason)
    require(type(report.get("schemaVersion")) is int and report["schemaVersion"] == 1,
            "Invalid report schema")
    require(report.get("status") == "passed" and report.get("error") is None,
            "Native probe failed or did not finish")
    require(report.get("probe") == "apple-native-activity-getter", "Wrong probe")
    require(report.get("javaScriptEvaluationApiCallsInFixture") == 0, "JS evaluation in probe")
    require(report.get("cpuMeasurement") is None and
            report.get("webContentProcessLiveness") is None, "Invented measurements")
    require(type(report.get("hostProcessId")) is int and report["hostProcessId"] > 0,
            "Missing host PID")
    require(isinstance(report.get("os"), str) and report["os"], "Missing OS metadata")
    require(report.get("lifecycleCases") == LIFECYCLE_CASES, "Incomplete lifecycle cases")
    validate_comparison_controls(report.get("comparisonControls"), apple_platform)
    rows = report.get("observations", [])
    require(isinstance(rows, list) and rows, "No observations")
    labels = [row.get("case") for row in rows]
    require(len(labels) == len(set(labels)), "Duplicate observation case")
    expected = BASE_CASES + (["window-ordered-out", "window-minimized",
        "window-deminimized", "application-hidden", "application-unhidden"]
        if apple_platform == "macos" else ["window-hidden", "window-without-scene"])
    policy_supported = rows[0].get("inactiveSchedulingPolicyIsSupported")
    require(type(policy_supported) is bool, "Policy support is not observed")
    if policy_supported:
        expected += ["policy-suspend", "policy-throttle", "policy-none"]
    require(set(labels) == set(expected), "Incomplete or unexpected native phase set")
    for row in rows:
        require(row.get("validationStatus") == "passed" and row.get("validationError") is None,
                "Observation was not validated successfully")
        validate_capture_evidence(row, apple_platform)
        require(row.get("availability") == "available" and row.get("platform") == apple_platform,
                "Unobserved or wrong-platform snapshot")
        require(type(row.get("schemaVersion")) is int and row["schemaVersion"] == 1,
                "Invalid observation schema")
        require(row.get("callbackOnMain") is True, "Callback did not run on main")
        require(row.get("inactiveSchedulingPolicyIsSupported") is policy_supported,
                "Inconsistent policy API support")
        for key in ("windowAttached", "viewIsHidden", "viewOrAncestorIsHidden"):
            require(type(row.get(key)) is bool, "Missing native flag: " + key)
        for key in ("wallBefore", "capturedAtMillisecondsSinceEpoch", "wallAfter"):
            require(type(row.get(key)) is int, "Missing native timestamp: " + key)
        require(row["wallBefore"] <= row["capturedAtMillisecondsSinceEpoch"] <= row["wallAfter"],
                "Capture wall time outside request")
        elapsed = row.get("requestElapsedSeconds")
        require(type(elapsed) in (int, float) and math.isfinite(elapsed) and elapsed >= 0,
                "Invalid fixture request interval")
        if not row["windowAttached"]:
            require(all(row.get(key) is None for key in ("windowIsVisible", "windowIsMiniaturized",
                "windowIsOcclusionVisible", "windowIsHidden", "windowSceneState")),
                "Detached view has stale window fields")
        if apple_platform == "ios":
            require(all(row.get(key) is None for key in ("applicationIsHidden", "windowIsVisible",
                "windowIsMiniaturized", "windowIsOcclusionVisible")), "Invented iOS visibility")
            require(row.get("applicationState") in ("active", "inactive", "background", "unknown"),
                    "Missing iOS application state")
            if row["windowAttached"]:
                require(type(row.get("windowIsHidden")) is bool, "Missing iOS window hidden flag")
            require(row.get("windowSceneState") in (None, "unattached", "foregroundInactive",
                "foregroundActive", "background", "unknown"), "Invalid iOS scene state")
        else:
            require(row.get("applicationState") in ("active", "inactive"),
                    "Missing macOS application state")
            require(type(row.get("applicationIsHidden")) is bool, "Missing macOS application hidden flag")
            require(row.get("windowIsHidden") is None and row.get("windowSceneState") is None,
                    "Invented macOS UIKit metadata")
            if row["windowAttached"]:
                require(all(type(row.get(key)) is bool for key in ("windowIsVisible",
                    "windowIsMiniaturized", "windowIsOcclusionVisible")), "Missing macOS window flags")
        if policy_supported:
            require(row.get("inactiveSchedulingPolicy") in ("suspend", "throttle", "none", "unknown") and
                    type(row.get("inactiveSchedulingPolicyRawValue")) is int, "Missing native policy")
            if row["case"].startswith("policy-"):
                require(row["inactiveSchedulingPolicy"] == row["case"][len("policy-"):],
                        "Wrong test-owned policy observation")
        else:
            require(row.get("inactiveSchedulingPolicy") is None and
                    row.get("inactiveSchedulingPolicyRawValue") is None, "Invented old-OS policy")


class Runner:
    def __init__(self, output):
        self.output = output
        self.commands = []

    def run(self, command, timeout=120, check=True):
        started = time.monotonic()
        index = len(self.commands)
        log = self.output / f"command-{index:02d}.log"
        try:
            result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=timeout)
        except subprocess.TimeoutExpired as error:
            def decoded(value):
                return value.decode(errors="replace") if isinstance(value, bytes) else value or ""
            log.write_text(decoded(error.stdout) + decoded(error.stderr))
            self.commands.append({"command": list(map(str, command)), "exit": None,
                "timeoutSeconds": timeout, "seconds": round(time.monotonic() - started, 3),
                "log": log.name})
            (self.output / "commands.json").write_text(json.dumps(self.commands, indent=2) + "\n")
            raise
        log.write_text(result.stdout + result.stderr)
        self.commands.append({"command": list(map(str, command)), "exit": result.returncode,
            "seconds": round(time.monotonic() - started, 3), "log": log.name})
        (self.output / "commands.json").write_text(json.dumps(self.commands, indent=2) + "\n")
        if check and result.returncode:
            raise RuntimeError(f"Command failed: {command}\n{(result.stdout + result.stderr)[-8000:]}")
        return result.stdout.strip()

    def sdk(self, name):
        return self.run(["xcrun", "--sdk", name, "--show-sdk-path"])

    def compile(self, apple_platform, sdk, target, sources, output=None):
        self.run(["xcrun", "--sdk", sdk, "--show-sdk-version"])
        command = ["xcrun", "--sdk", sdk, "swiftc", "-swift-version", "5", "-sdk",
                   self.sdk(sdk), "-target", target]
        command += ["-typecheck"] if output is None else ["-parse-as-library", "-o", str(output)]
        command += [str(source) for source in sources]
        self.run(command)


def sdk_checks(runner):
    # Typecheck, never execute, deployment-floor targets. arm64 macOS and
    # arm64 Simulator targets cannot establish support for these older floors.
    for apple_platform, sdk, target in (
        ("macos", "macosx", "x86_64-apple-macos10.14"),
        ("ios", "iphoneos", "arm64-apple-ios12.0"),
    ):
        directory = runner.output / apple_platform
        runner.compile(apple_platform, sdk, target,
                       [directory / "Capture.swift", directory / "Delegate.swift"])


def macos_probe(runner, architecture):
    directory = runner.output / "macos"
    bundle = directory / "AppleActivityProbe.app"
    executable = bundle / "Contents/MacOS/AppleActivityProbe"
    executable.parent.mkdir(parents=True, exist_ok=True)
    (bundle / "Contents/Info.plist").write_bytes(plistlib.dumps({
        "CFBundleExecutable": executable.name, "CFBundleIdentifier": "org.otzaria.appleactivity",
        "CFBundleName": "Apple Activity Probe", "CFBundlePackageType": "APPL",
        "NSHighResolutionCapable": True, "LSMinimumSystemVersion": "11.0",
    }))
    runner.compile("macos", "macosx", f"{architecture}-apple-macos11.0",
        [directory / "Capture.swift", directory / "Delegate.swift", FIXTURE / "common.swift",
         FIXTURE / "macos.swift"], executable)
    output = directory / "result.json"
    runner.run([str(executable), str(output)], timeout=180)
    validate_report(json.loads(output.read_text()), "macos")


def ios_probe(runner, architecture):
    directory = runner.output / "ios"
    bundle = directory / "AppleActivityProbe.app"
    bundle.mkdir(parents=True, exist_ok=True)
    executable = bundle / "AppleActivityProbe"
    (bundle / "Info.plist").write_bytes(plistlib.dumps({
        "CFBundleExecutable": executable.name, "CFBundleIdentifier": "org.otzaria.appleactivity",
        "CFBundleName": "Apple Activity Probe", "CFBundlePackageType": "APPL",
        "CFBundleVersion": "1", "CFBundleShortVersionString": "1.0", "MinimumOSVersion": "15.0",
        "UIDeviceFamily": [1, 2], "UILaunchScreen": {}, "LSRequiresIPhoneOS": True,
        "UIApplicationSceneManifest": {"UIApplicationSupportsMultipleScenes": False,
            "UISceneConfigurations": {"UIWindowSceneSessionRoleApplication": [
                {"UISceneConfigurationName": "Activity Probe"}]}},
    }))
    runner.compile("ios", "iphonesimulator", f"{architecture}-apple-ios15.0-simulator",
        [directory / "Capture.swift", directory / "Delegate.swift", FIXTURE / "common.swift",
         FIXTURE / "ios.swift"], executable)
    # Ad-hoc signing only; no team, account, provisioning profile or device.
    runner.run(["codesign", "--force", "--sign", "-", str(bundle)])
    runtimes = json.loads(runner.run(["xcrun", "simctl", "list", "runtimes", "-j"]))["runtimes"]
    devices = json.loads(runner.run(["xcrun", "simctl", "list", "devices", "available", "-j"]))["devices"]
    types = json.loads(runner.run(["xcrun", "simctl", "list", "devicetypes", "-j"]))["devicetypes"]
    candidates = sorted((runtime for runtime in runtimes if runtime.get("isAvailable") and
        runtime["identifier"].startswith("com.apple.CoreSimulator.SimRuntime.iOS-")),
        key=lambda runtime: tuple(map(int, runtime["version"].split("."))), reverse=True)
    selected = None
    for runtime in candidates:
        for device in devices.get(runtime["identifier"], []):
            if device.get("isAvailable") and device["name"].startswith("iPhone"):
                device_type = device.get("deviceTypeIdentifier") or next(
                    (item["identifier"] for item in types if item["name"] == device["name"]), None)
                if device_type:
                    selected = (runtime, device_type)
                    break
        if selected:
            break
    if selected is None:
        raise RuntimeError("No available iOS iPhone Simulator runtime/device type; native gate not run")
    runtime, device_type = selected
    udid = runner.run(["xcrun", "simctl", "create", "AppleActivity-" + uuid.uuid4().hex[:12],
                       device_type, runtime["identifier"]])
    (directory / "simulator.json").write_text(json.dumps({"runtime": runtime,
        "deviceType": device_type, "udid": udid, "createdForThisProbe": True}, indent=2) + "\n")
    try:
        runner.run(["xcrun", "simctl", "boot", udid])
        runner.run(["xcrun", "simctl", "bootstatus", udid, "-b"], timeout=240)
        runner.run(["xcrun", "simctl", "install", udid, str(bundle)])
        runner.run(["xcrun", "simctl", "launch", udid, "org.otzaria.appleactivity"])
        container = Path(runner.run(["xcrun", "simctl", "get_app_container", udid,
                                     "org.otzaria.appleactivity", "data"]))
        result = container / "Documents/apple-activity.json"
        deadline = time.monotonic() + 120
        while not result.exists() and time.monotonic() < deadline:
            time.sleep(0.5)
        if not result.exists():
            raise RuntimeError("iOS Simulator probe did not write its completion report")
        output = directory / "result.json"
        shutil.copyfile(result, output)
        validate_report(json.loads(output.read_text()), "ios")
    finally:
        # Only the simulator created by this invocation is shut down/deleted.
        runner.run(["xcrun", "simctl", "shutdown", udid], check=False)
        runner.run(["xcrun", "simctl", "delete", udid])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=["source", "sdk", "macos", "ios-simulator"], required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    read_sources()
    if args.mode == "source":
        if args.output:
            args.output.mkdir(parents=True, exist_ok=True)
            emit_sources(args.output)
        print("Apple activity source checks passed (no Swift compilation or execution)")
        return
    if sys.platform != "darwin":
        raise SystemExit("Native mode requires actual macOS/Apple SDKs; no fallback")
    if args.output is None:
        parser.error("--output is required for native evidence")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    emit_sources(output)
    runner = Runner(output)
    runner.run(["xcodebuild", "-version"])
    runner.run(["xcrun", "swiftc", "--version"])
    architecture = platform.machine()
    if architecture not in ("arm64", "x86_64"):
        raise SystemExit("Unsupported runner architecture")
    (output / "execution.json").write_text(json.dumps({"mode": args.mode,
        "host": platform.platform(), "architecture": architecture,
        "githubSha": os.environ.get("GITHUB_SHA"), "githubRunId": os.environ.get("GITHUB_RUN_ID"),
        "fixtureSha256": {p.name: sha(p.read_bytes()) for p in FIXTURE.glob("*.swift")}}, indent=2) + "\n")
    if args.mode == "sdk":
        sdk_checks(runner)
    elif args.mode == "macos":
        macos_probe(runner, architecture)
    else:
        ios_probe(runner, architecture)
    print("Apple activity " + args.mode + " gate passed")


if __name__ == "__main__":
    main()
