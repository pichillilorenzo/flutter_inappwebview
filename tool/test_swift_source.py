#!/usr/bin/env python3
"""Linux-executable regression for Swift extraction, without claiming compilation."""

from pathlib import Path
import unittest

from swift_source import extract_swift_block


ROOT = Path(__file__).resolve().parents[1]


class SwiftBlockTests(unittest.TestCase):
    def test_embedded_javascript_cannot_end_the_swift_method(self):
        expected = '''    func bridge() {
        evaluateJavaScript("""
if (pending) {
    try {
        resolve();
    } catch (error) {
        reject(error);
    }
}
""")
        callback.error = { error in finish(error) }
        invokeDart()
    }'''
        source = expected + '\n    func following() {}\n'
        self.assertEqual(extract_swift_block(source, '    func bridge('), expected)

    def test_literals_interpolation_comments_and_default_closures(self):
        expected = r'''    func sample(_ defaultValue: () -> String = { "}" }) {
        // A comment can contain } """ and /*
        /* Nested comments { /* } */ and " do not end the method. */
        let ordinary = "an escaped \" quote and }"
        let interpolated = "value \({ () -> String in return "}" }())"
        let raw = #"literal } and " with \#(format("}")) interpolation"#
        let multiline = ##"""
    }
        """ is not this raw string's closing delimiter.
        \##(format("}", nested: (1, 2)))
        """##
        finish(defaultValue())
    }'''
        for newline in ['\n', '\r\n']:
            with self.subTest(newline=repr(newline)):
                block = expected.replace('\n', newline)
                source = block + newline + '    func following() {}'
                self.assertEqual(extract_swift_block(source, '    func sample('), block)

    def test_unterminated_input_fails_instead_of_returning_partial_coverage(self):
        cases = [
            '    func sample() {',
            '    func sample() { let value = "unterminated }',
            '    func sample() { let value = """\n    }\n',
            '    func sample() { /* comment /* nested */ }',
            r'    func sample() { let value = "value \(call("}")',
        ]
        for source in cases:
            with self.subTest(source=source):
                with self.assertRaises(ValueError):
                    extract_swift_block(source, '    func sample(')
        with self.assertRaises(ValueError):
            extract_swift_block('func other() {}', 'func missing(')
        with self.assertRaisesRegex(ValueError, 'Ambiguous'):
            extract_swift_block('func same() {}\nfunc same() {}', 'func same(')


class ProductionSwiftBoundaryTests(unittest.TestCase):
    def sources(self):
        for platform in ['ios', 'macos']:
            base = ROOT / f'flutter_inappwebview_{platform}/{platform}/flutter_inappwebview_{platform}/Sources/flutter_inappwebview_{platform}'
            yield platform, base, (base / 'InAppWebView/InAppWebView.swift').read_text()

    def test_full_route_includes_both_callbacks_and_final_dart_dispatch(self):
        signature = '    func handleScriptMessage('
        for platform, _, source in self.sources():
            with self.subTest(platform=platform):
                start = source.index(signature)
                # The following declaration is an independent expected boundary,
                # after both callbacks and the final dispatch/channel failure.
                expected = source[start:source.index('\n    public func scrollTo(', start)].rstrip()
                route = extract_swift_block(source, signature)
                self.assertEqual(route, expected)
                self.assertIn('callback.defaultBehaviour = { [weak webView]', route)
                self.assertIn('callback.error = { [weak webView]', route)
                self.assertIn('channelDelegate.onCallJsHandler(', route)
                self.assertIn('JavaScript bridge Dart handler is unavailable', route)
                # Reproduce PR 53's original extraction failure on both actual
                # sources: a JS catch brace looked like the Swift method end.
                broken = source[start:source.index('\n    }\n', start) + len('\n    }\n')]
                self.assertNotIn('callback.error = { [weak webView]', broken)
                with self.assertRaisesRegex(ValueError, 'Unterminated Swift string'):
                    extract_swift_block(broken, signature)

    def test_other_apple_harness_boundaries(self):
        for platform, base, source in self.sources():
            controller = (base / 'Types/WKUserContentController.swift').read_text()
            delegate = (base / 'InAppWebView/WebViewChannelDelegate.swift').read_text()
            util = (base / 'Util.swift').read_text()
            targets = [
                (source, '    public func dispose()', 'releaseJavaScriptBridgeOwner()'),
                (source, '    func releaseJavaScriptBridgeOwner()', 'controller.dispose(windowId: nil)'),
                (source, '    public func webViewWebContentProcessDidTerminate(', 'javaScriptBridgeReplies.cancel('),
                (source, '    public func webView(_ webView: WKWebView, didStartProvisionalNavigation', 'javaScriptBridgeReplies.cancel('),
                (source, 'public func acceptsConsoleMessage(', 'settings?.consoleMessageLevels?.contains(level)'),
                (controller, '    public func sync(', 'let userOnlyScriptsList'),
                (delegate, 'public func onConsoleMessage(', 'onConsoleMessages('),
                (delegate, 'public func onConsoleMessages(', 'flush()'),
                (util, '    public static func JSONStringify(', 'return ""'),
            ]
            for text, signature, tail in targets:
                with self.subTest(platform=platform, signature=signature):
                    block = extract_swift_block(text, signature)
                    self.assertTrue(block.endswith('}'))
                    self.assertIn(tail, block)
                    # A block cannot accidentally contain the next method.
                    self.assertNotIn('\n    public func ', block[len(signature):])
            # The existing Node reply/error harnesses use explicit callback and
            # next-member anchors, not a JS-like closing brace. Check those
            # ranges against complete Swift closures as well.
            for signature, following in [
                ('            callback.defaultBehaviour = { [weak webView] (response: Any?) in',
                 '            callback.error = '),
                ('            callback.error = { [weak webView] (code: String, message: String?, details: Any?) in',
                 '            if let channelDelegate = webView.channelDelegate'),
            ]:
                with self.subTest(platform=platform, callback=signature):
                    start = source.index(signature, source.index('    func handleScriptMessage('))
                    anchored = source[start:source.index(following, start)].rstrip()
                    self.assertEqual(extract_swift_block(source, signature), anchored)
            # Node's JSONStringify helper is also bounded at the next member.
            signature = '    public static func JSONStringify('
            start = util.index(signature)
            self.assertEqual(extract_swift_block(util, signature),
                             util[start:util.index('    @available', start)].rstrip())


if __name__ == '__main__':
    unittest.main(verbosity=2)
