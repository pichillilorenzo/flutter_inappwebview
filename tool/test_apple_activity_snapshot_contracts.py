#!/usr/bin/env python3
"""Source/JSON negative controls only; these do not run Swift or WebKit."""

import copy
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import test_apple_activity_snapshot as activity


def report(apple_platform="macos"):
    labels = activity.BASE_CASES + (["window-ordered-out", "window-minimized",
        "window-deminimized", "application-hidden", "application-unhidden"]
        if apple_platform == "macos" else ["window-hidden", "window-without-scene"])
    result = {
        "schemaVersion": 1, "status": "passed", "error": None,
        "probe": "apple-native-activity-getter", "os": "unit-test fixture",
        "hostProcessId": 123, "javaScriptEvaluationApiCallsInFixture": 0,
        "cpuMeasurement": None, "webContentProcessLiveness": None,
        "lifecycleCases": list(activity.LIFECYCLE_CASES),
        "observations": [{"case": label, "availability": "available", "schemaVersion": 1,
            "platform": apple_platform, "callbackOnMain": True,
            "applicationState": "active",
            "windowAttached": label not in ("detached", "never-attached"),
            "viewIsHidden": label == "view-hidden",
            "viewOrAncestorIsHidden": label in ("view-hidden", "ancestor-hidden"),
            "inactiveSchedulingPolicyIsSupported": False,
            "wallBefore": 100, "capturedAtMillisecondsSinceEpoch": 101,
            "wallAfter": 102, "requestElapsedSeconds": .2} for label in labels],
    }
    for row in result["observations"]:
        if apple_platform == "macos":
            row["applicationIsHidden"] = row["case"] == "application-hidden"
            if row["windowAttached"]:
                row.update(windowIsVisible=row["case"] not in ("window-ordered-out", "window-minimized"),
                           windowIsMiniaturized=row["case"] == "window-minimized",
                           windowIsOcclusionVisible=row["case"] != "window-ordered-out")
        elif row["windowAttached"]:
            row["windowIsHidden"] = row["case"] == "window-hidden"
            if row["case"] != "window-without-scene":
                row["windowSceneState"] = "foregroundActive"
    return result


class ReportContracts(unittest.TestCase):
    def test_complete_fixture_is_accepted_for_each_platform(self):
        for apple_platform in ("ios", "macos"):
            activity.validate_report(report(apple_platform), apple_platform)

    def test_failed_partial_duplicate_or_wrong_platform_is_rejected(self):
        mutations = [
            lambda r: r.update(status="failed"),
            lambda r: r.update(error="native assertion failed"),
            lambda r: r["observations"].pop(),
            lambda r: r["observations"].append(copy.deepcopy(r["observations"][0])),
            lambda r: r["observations"][0].update(platform="ios"),
            lambda r: r["observations"][0].update(availability="noNativeView"),
            lambda r: r["observations"][0].update(callbackOnMain=False),
            lambda r: r["lifecycleCases"].pop(),
        ]
        for mutate in mutations:
            with self.subTest(mutation=mutate):
                value = report()
                mutate(value)
                with self.assertRaises(AssertionError):
                    activity.validate_report(value, "macos")

    def test_invalid_capture_boundaries_and_missing_values_are_rejected(self):
        mutations = [
            {"capturedAtMillisecondsSinceEpoch": 103},
            {"requestElapsedSeconds": -1},
            {"requestElapsedSeconds": float("nan")},
            {"windowAttached": None},
            {"viewIsHidden": 0},
            {"inactiveSchedulingPolicyIsSupported": None},
            {"schemaVersion": True},
            {"capturedAtMillisecondsSinceEpoch": 101.0},
            {"applicationState": None},
            {"windowIsVisible": None},
            {"inactiveSchedulingPolicyRawValue": 0},
        ]
        for mutation in mutations:
            with self.subTest(mutation=mutation):
                value = report()
                value["observations"][0].update(mutation)
                with self.assertRaises(AssertionError):
                    activity.validate_report(value, "macos")

    def test_incomplete_policy_observations_are_rejected(self):
        value = report()
        template = next(row for row in value["observations"] if row["case"] == "never-attached")
        for name in ("suspend", "throttle", "none"):
            row = copy.deepcopy(template)
            row["case"] = "policy-" + name
            value["observations"].append(row)
        for row in value["observations"]:
            row.update(inactiveSchedulingPolicyIsSupported=True,
                       inactiveSchedulingPolicy="suspend", inactiveSchedulingPolicyRawValue=0)
            if row["case"].startswith("policy-"):
                row["inactiveSchedulingPolicy"] = row["case"][len("policy-"):]
                row["inactiveSchedulingPolicyRawValue"] = ("suspend", "throttle", "none").index(
                    row["inactiveSchedulingPolicy"])
        activity.validate_report(value, "macos")
        for changes in ({"inactiveSchedulingPolicy": None},
                        {"inactiveSchedulingPolicyRawValue": None},
                        {"inactiveSchedulingPolicyRawValue": True}):
            modified = copy.deepcopy(value)
            modified["observations"][0].update(changes)
            with self.assertRaises(AssertionError):
                activity.validate_report(modified, "macos")

    def test_stale_window_fields_on_detached_view_are_rejected(self):
        value = report()
        row = next(row for row in value["observations"] if row["case"] == "detached")
        row["windowIsVisible"] = False
        with self.assertRaises(AssertionError):
            activity.validate_report(value, "macos")

    def test_ios_cannot_claim_appkit_visibility(self):
        value = report("ios")
        value["observations"][0]["windowIsOcclusionVisible"] = True
        with self.assertRaises(AssertionError):
            activity.validate_report(value, "ios")

    def test_metadata_cannot_be_presented_as_cpu_or_process_proof(self):
        for key, replacement in [("cpuMeasurement", 0),
                                 ("webContentProcessLiveness", "alive"),
                                 ("javaScriptEvaluationApiCallsInFixture", 1)]:
            value = report()
            value[key] = replacement
            with self.assertRaises(AssertionError):
                activity.validate_report(value, "macos")


class SourceContracts(unittest.TestCase):
    def test_production_source_and_emitted_route_are_identical(self):
        sources = activity.read_sources()
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp)
            activity.emit_sources(output)
            for apple_platform, (capture, route) in sources.items():
                self.assertEqual((output / apple_platform / "Capture.swift").read_bytes(), capture)
                self.assertIn(route, (output / apple_platform / "Delegate.swift").read_text())

    def test_removing_weak_queue_or_adding_side_effects_is_rejected(self):
        originals = {apple_platform: activity.source_dir(apple_platform)
                     for apple_platform in ("ios", "macos")}
        mutations = [
            ("WebViewChannelDelegate.swift", "[weak self]", "[self]"),
            ("WebViewChannelDelegate.swift", "DispatchQueue.main.async", "DispatchQueue.global().async"),
            ("AppleWebViewActivitySnapshot.swift", "precondition(Thread.isMainThread)",
             'webView.evaluateJavaScript("1")'),
            ("AppleWebViewActivitySnapshot.swift", "precondition(Thread.isMainThread)",
             "webView.configuration.preferences.inactiveSchedulingPolicy = .none"),
        ]
        for filename, old, new in mutations:
            with self.subTest(mutation=new), tempfile.TemporaryDirectory() as temp:
                root = Path(temp)
                for apple_platform, original in originals.items():
                    package = f"flutter_inappwebview_{apple_platform}"
                    target = root / package / apple_platform / package / "Sources" / package / "InAppWebView"
                    target.mkdir(parents=True)
                    for source in ("AppleWebViewActivitySnapshot.swift", "WebViewChannelDelegate.swift",
                                   "WebViewChannelDelegateMethods.swift"):
                        text = (original / source).read_text()
                        if source == filename:
                            text = text.replace(old, new)
                        (target / source).write_text(text)
                with patch.object(activity, "ROOT", root), self.assertRaises((AssertionError, ValueError)):
                    activity.read_sources()


if __name__ == "__main__":
    unittest.main()
