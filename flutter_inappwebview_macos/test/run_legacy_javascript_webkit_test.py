#!/usr/bin/env python3
"""Run the production legacy JS route and callback registry in real WKWebViews.

The unchanged call method, reply switch case, navigation/termination delegates,
and disposal settlement prefix are extracted from InAppWebView.swift. The rest
of the Flutter/plugin UI is represented by small no-op fixture dependencies.
Process termination is delivered as a delegate notification, not an OS crash.
"""
import argparse
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from swift_source import extract_swift_block

PACKAGE = Path(__file__).resolve().parents[1]
SOURCE = PACKAGE / "macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos"


def fixture_source():
    view = (SOURCE / "InAppWebView/InAppWebView.swift").read_text()
    constants = (SOURCE / "PluginScriptsJS/PluginScriptsUtil.swift").read_text()
    replacements = {
        "CONSTANTS": "\n".join(re.findall(r'    public static let VAR_.*', constants)),
        "JSON_STRINGIFY": extract_swift_block((SOURCE / "Util.swift").read_text(),
            'public static func JSONStringify(value:'),
        "LEGACY_CALL": extract_swift_block(view,
            'public func callAsyncJavaScript(functionBody: String, arguments: [String:Any], completionHandler:'),
        "COMMIT": extract_swift_block(view,
            'public func webView(_ webView: WKWebView,\n                        didCommit navigation:'),
        "TERMINATION": extract_swift_block(view,
            'public func webViewWebContentProcessDidTerminate(_ webView: WKWebView)'),
    }
    start = '                case "onCallAsyncJavaScriptResultBelowIOS14Received":\n'
    end = '                case "onWebMessagePortMessageReceived":\n'
    assert view.count(start) == 1 and view.count(end) == 1
    replacements["REPLY"] = start + view.split(start)[1].split(end)[0]
    disposal = extract_swift_block(view, 'public func dispose()')
    # Keep the actual ordering through channel disposal. The unrelated platform
    # view observers/dialogs are not installed in this lightweight fixture.
    replacements["DISPOSAL"] = disposal.split('        runWindowBeforeCreatedCallbacks()')[0] + '\n    }'
    assert 'channelDelegate = nil' in replacements["DISPOSAL"]
    fixture = (PACKAGE / "test/legacy_javascript_webkit_test.swift").read_text()
    for key, value in replacements.items():
        marker = '// PRODUCTION_' + key
        assert fixture.count(marker) == 1, marker
        fixture = fixture.replace(marker, value)
    assert '// PRODUCTION_' not in fixture
    return fixture


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract-only', action='store_true')
    args = parser.parse_args()
    source = fixture_source()
    if args.extract_only:
        print('PASS: complete production legacy JavaScript route extracted')
        return
    with tempfile.TemporaryDirectory(prefix='legacy-webkit-') as directory:
        directory = Path(directory)
        fixture = directory / 'Probe.swift'
        fixture.write_text(source)
        executable = directory / 'legacy_webkit_test'
        subprocess.run(['swiftc', '-o', str(executable),
            str(SOURCE / 'Types/PendingLegacyJavaScriptCallbacks.swift'),
            str(SOURCE / 'PluginScriptsJS/CallAsyncJavaScriptBelowIOS14WrapperJS.swift'),
            str(fixture)], check=True)
        subprocess.run([str(executable)], check=True, timeout=120)


if __name__ == '__main__':
    main()
