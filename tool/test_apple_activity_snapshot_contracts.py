#!/usr/bin/env python3
"""Source/JSON negative controls only; these do not run Swift or WebKit."""

import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import test_apple_activity_snapshot as activity


def capture_evidence(row, expected=None):
    """Synthetic dictionaries only, never evidence of a native execution."""
    native_keys = ["schemaVersion", "availability", "platform", "capturedAtMillisecondsSinceEpoch",
        "applicationState", "windowSceneState", "inactiveSchedulingPolicy",
        "inactiveSchedulingPolicyRawValue"] + activity.REFERENCE_BOOLEAN_FIELDS
    native = {key: row[key] for key in native_keys if key in row}
    row.update(nativeResult=native,
               callbackReference={key: native[key] for key in activity.REFERENCE_FIELDS if key in native},
               expected={"windowAttached": row["windowAttached"]} if expected is None else expected,
               callbackAt=101, callbackElapsedSeconds=.1,
               referenceBoundary="native-result-callback-before-resume", validationStatus="passed")


def comparison_control(row):
    captured = copy.deepcopy(row)
    captured["case"] = "callback-state-change"
    capture_evidence(captured, expected={})
    captured.pop("validationStatus")
    late = dict(captured["callbackReference"], viewIsHidden=True, viewOrAncestorIsHidden=True)
    error = "callback-state-change: reference mismatch: viewIsHidden"
    control = {"case": "callback-state-change", "validationStatus": "passed", "observation": captured,
        "viewIsHiddenAfterResume": True, "lateReference": late, "lateReferenceRejected": error,
        "lateReferenceFailure": dict(captured, callbackReference=late, validationStatus="failed",
                                     validationError=error), "wrongNativeValuesRejected": []}
    for field in activity.REFERENCE_BOOLEAN_FIELDS:
        wrong = copy.deepcopy(captured)
        value = not wrong["nativeResult"].get(field, True)
        wrong["nativeResult"][field] = wrong[field] = value
        error = "callback-state-change: reference mismatch: " + field
        wrong.update(validationStatus="failed", validationError=error)
        control["wrongNativeValuesRejected"].append(
            {"field": field, "value": value, "error": error, "failedObservation": wrong})
    return control


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
        capture_evidence(row)
    result["comparisonControls"] = [comparison_control(result["observations"][0])]
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
        for apple_platform in ("ios", "macos"):
            value = report(apple_platform)
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
                capture_evidence(row)
            value["comparisonControls"] = [comparison_control(value["observations"][0])]
            activity.validate_report(value, apple_platform)
            for changes in ({"inactiveSchedulingPolicy": None},
                            {"inactiveSchedulingPolicyRawValue": None},
                            {"inactiveSchedulingPolicyRawValue": True}):
                modified = copy.deepcopy(value)
                modified["observations"][0].update(changes)
                with self.assertRaises(AssertionError):
                    activity.validate_report(modified, apple_platform)

    def test_wrong_native_flags_still_fail_at_the_callback_reference(self):
        for apple_platform in ("ios", "macos"):
            captured = report(apple_platform)["comparisonControls"][0]["observation"]
            for field in activity.REFERENCE_BOOLEAN_FIELDS:
                with self.subTest(platform=apple_platform, field=field):
                    wrong = copy.deepcopy(captured)
                    # Change both the raw result and its display copy. Rejection
                    # must come from comparison with the independent reference.
                    value = not wrong["nativeResult"].get(field, True)
                    wrong["nativeResult"][field] = value
                    wrong[field] = value
                    with self.assertRaisesRegex(AssertionError, "Callback reference mismatch: " + field):
                        activity.validate_capture_evidence(wrong, apple_platform)

    def test_wrong_application_scene_and_policy_values_still_fail(self):
        for apple_platform in ("ios", "macos"):
            for field, value in (("applicationState", "inactive"),
                                 ("windowSceneState", "background"),
                                 ("inactiveSchedulingPolicyRawValue", 123)):
                with self.subTest(platform=apple_platform, field=field):
                    wrong = copy.deepcopy(report(apple_platform)["comparisonControls"][0]["observation"])
                    wrong["nativeResult"][field] = wrong[field] = value
                    with self.assertRaisesRegex(AssertionError, "Callback reference mismatch: " + field):
                        activity.validate_capture_evidence(wrong, apple_platform)

    def test_saved_callback_data_survives_a_simulated_change_before_resumption(self):
        for apple_platform in ("ios", "macos"):
            control = report(apple_platform)["comparisonControls"][0]
            captured = control["observation"]
            self.assertIs(captured["nativeResult"]["viewIsHidden"], False)
            self.assertIs(control["viewIsHiddenAfterResume"], True)
            activity.validate_comparison_controls([control], apple_platform)
            changed = dict(captured, callbackReference=control["lateReference"])
            with self.assertRaisesRegex(AssertionError, "Callback reference mismatch: viewIsHidden"):
                activity.validate_capture_evidence(changed, apple_platform)

    def test_missing_boundary_evidence_and_unvalidated_rows_are_rejected(self):
        changes = [{"nativeResult": None}, {"callbackReference": None}, {"expected": None},
                   {"referenceBoundary": "after-await"}, {"callbackAt": 99}, {"callbackAt": 103},
                   {"callbackAt": True}, {"callbackElapsedSeconds": .3},
                   {"callbackElapsedSeconds": float("nan")}, {"validationStatus": "pending"},
                   {"validationStatus": "failed"}, {"validationError": "window mismatch"}]
        for change in changes:
            with self.subTest(change=change):
                value = report()
                value["observations"][0].update(change)
                with self.assertRaises(AssertionError):
                    activity.validate_report(value, "macos")

    def test_comparison_controls_cannot_be_omitted_or_faked(self):
        mutations = [
            lambda r: r.update(comparisonControls=[]),
            lambda r: r["comparisonControls"][0].update(validationStatus="failed"),
            lambda r: r["comparisonControls"][0].update(viewIsHiddenAfterResume=False),
            lambda r: r["comparisonControls"][0]["lateReference"].update(viewIsHidden=False),
            lambda r: r["comparisonControls"][0].update(lateReferenceRejected=""),
            lambda r: r["comparisonControls"][0]["wrongNativeValuesRejected"].pop(),
            lambda r: r["comparisonControls"][0]["wrongNativeValuesRejected"][0].update(value=False),
            lambda r: r["comparisonControls"][0]["wrongNativeValuesRejected"][0].update(error=""),
            lambda r: r["comparisonControls"][0]["lateReferenceFailure"].pop("nativeResult"),
            lambda r: r["comparisonControls"][0]["wrongNativeValuesRejected"][0]["failedObservation"].pop("callbackReference"),
            lambda r: r["comparisonControls"][0]["wrongNativeValuesRejected"][0]["failedObservation"].update(callbackAt=102),
        ]
        for mutate in mutations:
            value = report()
            mutate(value)
            with self.subTest(mutation=mutate), self.assertRaises(AssertionError):
                activity.validate_report(value, "macos")

    def test_failed_report_preserves_raw_native_reference_and_timing(self):
        value = report()
        value.update(status="failed", error="wrong native window occlusion flag")
        row = value["observations"][0]
        row["nativeResult"]["windowIsOcclusionVisible"] = row["windowIsOcclusionVisible"] = False
        row.update(validationStatus="failed", validationError=value["error"])
        encoded = json.dumps(value)
        with self.assertRaises(AssertionError):
            activity.validate_report(value, "macos")
        self.assertEqual(json.dumps(value), encoded)
        saved = json.loads(encoded)["observations"][0]
        self.assertEqual(saved["case"], "visible")
        self.assertIs(saved["nativeResult"]["windowIsOcclusionVisible"], False)
        self.assertIs(saved["callbackReference"]["windowIsOcclusionVisible"], True)
        self.assertEqual((saved["wallBefore"], saved["callbackAt"], saved["wallAfter"]), (100, 101, 102))

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
