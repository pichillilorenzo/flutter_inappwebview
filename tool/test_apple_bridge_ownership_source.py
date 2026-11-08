#!/usr/bin/env python3
"""Check ownership fixture generation/failure contracts; never executes Swift.

Actual ownership, intentional-retention and historical-baseline executables
remain required in the Apple job. These checks catch source-generation and
false-positive control regressions on hosts without an Apple SDK.
"""

import contextlib
import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import test_apple_bridge_ownership as ownership
from swift_source import extract_swift_block


class OwnershipSourceTests(unittest.TestCase):
    def test_registration_and_first_close_share_a_pool_before_weak_assertions(self):
        for platform in ['ios', 'macos']:
            with self.subTest(platform=platform):
                generated = ownership.build_source(platform)
                first_pool = extract_swift_block(generated, '\n                autoreleasepool {')
                for action in [
                    'parent = InAppWebView(', 'popup = InAppWebView(',
                    'controller.install(parent!)',
                    'parent!.releaseJavaScriptBridgeOwner()', 'parent = nil',
                    'popup!.releaseJavaScriptBridgeOwner()', 'popup = nil',
                ]:
                    self.assertIn(action, first_pool)
                after_pool = generated[generated.index(first_pool) + len(first_pool):]
                self.assertIn('require(weakParent == nil, "shared message handler retained disposed parent")', after_pool)
                self.assertIn('require(weakPopup == nil, "shared message handler retained disposed popup")', after_pool)
                self.assertIn('firstClose beforeDrain=', after_pool)
                self.assertIn('afterDrain=', after_pool)

    def test_last_close_drains_for_both_orders_and_all_eight_cases_remain(self):
        for platform in ['ios', 'macos']:
            with self.subTest(platform=platform):
                generated = ownership.build_source(platform)
                main = extract_swift_block(generated, '    @MainActor static func main()')
                self.assertIn('for enabled in [[false, false], [true, false], [false, true], [true, true]]', main)
                self.assertIn('for parentFirst in [true, false]', main)
                self.assertIn('require(completedCases == 8,', main)
                # The two later pools are nested one indentation level further.
                last_pools = main.split('                    autoreleasepool {')[1:]
                self.assertEqual(len(last_pools), 2)
                for text, owner in zip(last_pools, ['popup', 'parent']):
                    block = extract_swift_block('autoreleasepool {' + text, 'autoreleasepool {')
                    self.assertIn(f'{owner}!.releaseJavaScriptBridgeOwner()', block)
                    self.assertIn(f'{owner} = nil', block)
                    for kind in ['rpc', 'console-one-way', 'scroll-one-way', 'window-focus-one-way']:
                        self.assertIn(f'"{kind}"', block)
                tail = main[main.index('                let lastOwnerAliveAfterDrain'):]
                self.assertIn('require(weakParent == nil,', tail)
                self.assertIn('require(weakPopup == nil,', tail)
                self.assertIn('controller.oneWay.isEmpty && controller.replies.isEmpty && controller.scripts.isEmpty', tail)
                self.assertIn('controller.completeDisposals == 1', tail)

    def test_real_production_cleanup_adapters_and_registries_are_preserved(self):
        for platform in ['ios', 'macos']:
            with self.subTest(platform=platform):
                generated = ownership.build_source(platform)
                base = f'flutter_inappwebview_{platform}/{platform}/flutter_inappwebview_{platform}/Sources/flutter_inappwebview_{platform}'
                native = ownership.source(f'{base}/InAppWebView/InAppWebView.swift')
                cleanup = extract_swift_block(native, '    func releaseJavaScriptBridgeOwner()')
                self.assertIn(cleanup, generated)
                for filename in ['JavaScriptBridgeMessageHandler.swift', 'JavaScriptBridgeReplyHandler.swift']:
                    production = ownership.source(f'{base}/Types/{filename}').replace('import WebKit\n', '')
                    self.assertIn(production, generated)
                self.assertIn(ownership.STATELESS_SELECTION, generated)

    def test_extended_lifecycles_are_executed_for_both_platforms(self):
        for platform in ['ios', 'macos']:
            with self.subTest(platform=platform):
                generated = ownership.build_source(platform)
                main = extract_swift_block(generated, '    @MainActor static func main()')
                for name in [
                    'pendingRepliesSurviveSiblingClose',
                    'independentControllersReleaseIndependently',
                    'repeatedPopupClosePreservesLiveOwner',
                ]:
                    self.assertIn(name + '()', main)
                    self.assertIn(extract_swift_block(ownership.additional_lifecycle_tests,
                                                     '@MainActor func ' + name + '()'), generated)

    def test_retention_control_changes_only_actual_handler_selection(self):
        for platform in ['ios', 'macos']:
            with self.subTest(platform=platform):
                candidate = ownership.build_source(platform)
                control = ownership.retaining_handler_control(candidate)
                before, after = candidate.split(ownership.STATELESS_SELECTION)
                self.assertEqual(control, before + ownership.RETAINING_SELECTION + after)
                self.assertIn('require(weakParent == nil, "shared message handler retained disposed parent")', control)
                self.assertIn('autoreleasepool {', control)
        for invalid in ['', ownership.STATELESS_SELECTION * 2]:
            with self.subTest(invalid=invalid):
                with self.assertRaises(ValueError):
                    ownership.retaining_handler_control(invalid)

    def test_normal_ci_command_requires_retention_control_for_both_platforms(self):
        runs = []

        def record(swift, expected_failure=None):
            runs.append((swift.name, swift.read_text(), expected_failure))

        with patch.object(ownership, 'compile_and_run', side_effect=record), contextlib.redirect_stdout(io.StringIO()):
            ownership.main([])
        self.assertEqual([(name, reason) for name, _, reason in runs], [
            ('ios.swift', None), ('ios-retaining-handler.swift', ownership.RETENTION_FAILURE),
            ('macos.swift', None), ('macos-retaining-handler.swift', ownership.RETENTION_FAILURE),
        ])
        for candidate, control in [(runs[0], runs[1]), (runs[2], runs[3])]:
            self.assertEqual(control[1], ownership.retaining_handler_control(candidate[1]))

    def test_emit_source_never_reports_native_execution(self):
        with tempfile.TemporaryDirectory(prefix='ownership-source-contract-') as directory:
            target = Path(directory) / 'generated'
            output = io.StringIO()
            with patch.object(ownership, 'compile_and_run', side_effect=AssertionError('must not compile')), contextlib.redirect_stdout(output):
                ownership.main(['--emit-source', str(target)])
            self.assertEqual(sorted(path.name for path in target.iterdir()), [
                'ios-retaining-handler.swift', 'ios.swift', 'macos-retaining-handler.swift', 'macos.swift',
            ])
            self.assertEqual(output.getvalue().count('Swift not compiled or run'), 4)
            self.assertNotIn('passed', output.getvalue())


class ExpectedFailureTests(unittest.TestCase):
    def test_only_exact_assertion_with_runtime_exit_one_is_accepted(self):
        for reason in [ownership.BASELINE_FAILURE, ownership.RETENTION_FAILURE]:
            sentinel = 'REGRESSION: ' + reason
            with self.subTest(reason=reason):
                ownership.require_expected_failure(subprocess.CompletedProcess([], 1, 'OWNERSHIP diagnostic\n' + sentinel + '\n'), reason)
                for code, output in [
                    (0, sentinel), (-6, sentinel), (2, sentinel),
                    (1, ''), (1, 'REGRESSION: unrelated failure'),
                    (1, sentinel + ' extra'), (1, sentinel + '\nFatal error'),
                ]:
                    with self.subTest(code=code, output=output):
                        with self.assertRaises(RuntimeError):
                            ownership.require_expected_failure(subprocess.CompletedProcess([], code, output), reason)

    def test_compiler_failure_or_timeout_is_never_a_successful_control(self):
        for failure in [subprocess.CalledProcessError(1, 'swiftc'), subprocess.TimeoutExpired('swiftc', 120)]:
            with self.subTest(failure=type(failure).__name__):
                with patch.object(ownership.subprocess, 'run', side_effect=failure) as run:
                    with self.assertRaises(type(failure)):
                        ownership.compile_and_run(Path('control.swift'), ownership.RETENTION_FAILURE)
                    self.assertEqual(run.call_count, 1)
                    self.assertTrue(run.call_args.kwargs['check'])


if __name__ == '__main__':
    unittest.main(verbosity=2)
