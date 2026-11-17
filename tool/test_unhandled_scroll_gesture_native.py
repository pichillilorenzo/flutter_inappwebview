#!/usr/bin/env python3
"""Check that unused horizontal trackpad gestures reach a macOS platform-view host.

On macOS this compiles the production forwarder together with the production
InAppWebView glue, then drives a real WKWebView with native scroll events.
--source-checks-only also works on non-Apple hosts; it does not execute Swift.
"""

import argparse
from pathlib import Path
import subprocess
import sys
import tempfile

from swift_source import extract_swift_block

ROOT = Path(__file__).resolve().parents[1]
SOURCES = (ROOT / "flutter_inappwebview_macos/macos/flutter_inappwebview_macos/Sources/"
           "flutter_inappwebview_macos/InAppWebView")
FORWARDER = SOURCES / "UnhandledScrollGestureForwarder.swift"
PROBE = ROOT / "tool/unhandled_scroll_gesture_probe/macos.swift"

GLUE_SIGNATURES = [
    "private lazy var unhandledScrollGestureForwarder",
    "public override func scrollWheel(with event: NSEvent)",
    "@objc(_webView:didNotHandleWheelEvent:)",
]

web_view = (SOURCES / "InAppWebView.swift").read_text()
glue = [extract_swift_block(web_view, signature) for signature in GLUE_SIGNATURES]

assert "uiDelegate = self" in web_view, "WebKit reports unused events only to the UI delegate"
assert glue[1].index(".observe(event)") < glue[1].index("super.scrollWheel(with: event)")
assert "as? FlutterWebViewController" in glue[0], "only a Flutter host may receive the gesture"
dispose = extract_swift_block(web_view, "public func dispose()")
assert dispose.index("unhandledScrollGestureForwarder.reset()") < dispose.index("uiDelegate = nil")
host = (SOURCES / "FlutterWebViewController.swift").read_text()
assert host.index("self.addSubview(webView!)") < host.index(
    "UnhandledScrollGestureForwarder.stopHorizontalRubberBanding(webView!)")
podspec = (ROOT / "flutter_inappwebview_macos/macos/flutter_inappwebview_macos.podspec").read_text()
assert "Sources/flutter_inappwebview_macos/**/*.swift" in podspec

parser = argparse.ArgumentParser()
parser.add_argument("--source-checks-only", action="store_true")
args = parser.parse_args()
if args.source_checks_only:
    print("Unhandled scroll gesture wiring checks passed (no Swift execution)")
    raise SystemExit(0)

with tempfile.TemporaryDirectory() as directory:
    directory = Path(directory)
    probe = directory / "probe.swift"
    probe.write_text(PROBE.read_text().replace("__GLUE__", "\n\n".join(glue)))
    binary = directory / "probe"
    subprocess.run(["xcrun", "swiftc", "-swift-version", "5", "-parse-as-library",
                    str(FORWARDER), str(probe), "-o", str(binary)], check=True)
    result = subprocess.run([str(binary)], timeout=300)
    sys.exit(result.returncode)
