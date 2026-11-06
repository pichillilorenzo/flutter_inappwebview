#!/usr/bin/env python3
"""Compile production Apple scroll methods against narrow Foundation stubs.

This checks the actual iOS bookkeeping/axis code and macOS native gate, without
requiring a Flutter engine. --source-checks-only also works on non-Apple hosts;
it does not claim to execute or compile Swift.
"""

import argparse
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def apple(platform, name):
    return (ROOT / f"flutter_inappwebview_{platform}" / platform /
            f"flutter_inappwebview_{platform}/Sources/flutter_inappwebview_{platform}/InAppWebView" /
            name).read_text()


def method(source, signature):
    start = source.index(signature)
    opening = source.index("{", start)
    depth = 1
    end = opening + 1
    while depth:
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    return source[start:end]


ios = apple("ios", "InAppWebView.swift")
macos = apple("macos", "InAppWebView.swift")
ios_scroll = method(ios, "public func onScrollChanged(startedByUser:")
ios_setter = method(ios, "public func setScrollChangedListener(hasListener:")
macos_setter = method(macos, "public func setScrollChangedListener(hasListener:")
macos_update = method(macos, "private func updateScrollChangedListener()")
macos_gate = macos.split('case "onScrollChanged":', 1)[1].split("                default:", 1)[0]

# Creation, reuse and the wire method must agree with the Dart subscription.
for platform in ["ios", "macos"]:
    assert 'var hasScrollChangedListener = true' in apple(platform, "InAppWebView.swift")
    assert 'params["hasScrollChangedListener"] as? Bool ?? true' in apple(platform, "FlutterWebViewController.swift")
    assert 'arguments?["hasScrollChangedListener"] as? Bool ?? true' in apple(platform, "FlutterWebViewFactory.swift")
    assert 'case setScrollChangedListener' in apple(platform, "WebViewChannelDelegateMethods.swift")
    assert 'case .setScrollChangedListener:' in apple(platform, "WebViewChannelDelegate.swift")
assert ios_scroll.index("if hasScrollChangedListener") < ios_scroll.index("channelDelegate?.onScrollChanged")
assert ios_scroll.index("lastScrollX =") > ios_scroll.index("channelDelegate?.onScrollChanged")
assert "return" not in ios_scroll, "the gate must not skip iOS bookkeeping/overscroll"
assert macos_gate.index("webView.hasScrollChangedListener") < macos_gate.index("JSONSerialization")
assert "configuration.userContentController" not in macos_update, "popup updates must not change shared scripts"
assert "allowedOriginRules: settings?.pluginScriptsOriginAllowList" in macos_update
assert "windowId == nil || windowCreated" in macos_update
for signature in ["public func webView(_ webView: WKWebView, didFinish", "                        didCommit navigation:"]:
    start = macos.index(signature)
    assert "updateScrollChangedListener()" in macos[start:start + 350]

android_root = ROOT / "flutter_inappwebview_android/android/src/main/java/com/pichillilorenzo/flutter_inappwebview_android/webview"
android = (android_root / "in_app_webview/InAppWebView.java").read_text()
android_scroll = method(android, "protected void onScrollChanged(")
assert android_scroll.index("super.onScrollChanged") < android_scroll.index("hasScrollChangedListener")
assert android_scroll.index("floatingContextMenu.setVisibility") < android_scroll.index("hasScrollChangedListener")
assert "public boolean hasScrollChangedListener = true" in android
for name in ["in_app_webview/FlutterWebView.java", "FlutterWebViewFactory.java"]:
    assert '!Boolean.FALSE.equals(params.get("hasScrollChangedListener"))' in (android_root / name).read_text()

parser = argparse.ArgumentParser()
parser.add_argument("--source-checks-only", action="store_true")
args = parser.parse_args()
if args.source_checks_only:
    print("Android/iOS/macOS scroll wiring and source contract checks passed (no Swift execution)")
    raise SystemExit(0)

harness = r'''
import Foundation
import CoreGraphics

class Settings {
    var disableVerticalScroll = false
    var disableHorizontalScroll = false
    var pluginScriptsOriginAllowList: [String]? = nil
}
class ScrollView {
    var contentOffset = CGPoint.zero
    var contentScaleFactor: CGFloat = 2
    var contentSize = CGSize(width: 50000, height: 50000)
    var frame = CGRect(x: 0, y: 0, width: 100, height: 100)
}
class Channel {
    var scrolls: [[Int]] = []
    var overscrolls: [[Int]] = []
    func onScrollChanged(x: Int, y: Int) { scrolls.append([x, y]) }
    func onOverScrolled(x: Int, y: Int, clampedX: Bool, clampedY: Bool) {
        overscrolls.append([x, y, clampedX ? 1 : 0, clampedY ? 1 : 0])
    }
}
class IOSView {
    var settings: Settings? = Settings()
    var channelDelegate: Channel? = Channel()
    var scrollView = ScrollView()
    var lastScrollX: CGFloat = 0
    var lastScrollY: CGFloat = 0
    var hasScrollChangedListener = true
    __IOS_SETTER__
    __IOS_SCROLL__
}
struct Script { var source: String }
enum OnScrollChangedJS {
    static func ON_SCROLL_CHANGED_EVENT_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?, enabled: Bool? = nil) -> Script {
        return Script(source: "subscription:\(enabled == true)")
    }
}
class MacView {
    var settings: Settings? = Settings()
    var channelDelegate: Channel? = Channel()
    var javaScriptBridgeEnabled = true
    var hasScrollChangedListener = true
    var windowId: Int? = nil
    var windowCreated = false
    var scripts: [String] = []
    func evaluateJavaScript(_ source: String, completionHandler: ((Any?, Error?) -> Void)?) {
        scripts.append(source)
    }
    __MAC_SETTER__
    __MAC_UPDATE__
    func receive(_ body: [String: Any]) {
        let webView = self
        switch "onScrollChanged" {
        case "onScrollChanged":
            __MAC_GATE__
        default: break
        }
    }
}

let ios = IOSView()
assert(ios.hasScrollChangedListener) // Older clients and InAppBrowser.
ios.setScrollChangedListener(hasListener: false)
for i in 1...10000 {
    let old = ios.scrollView.contentOffset
    ios.scrollView.contentOffset = CGPoint(x: CGFloat(i), y: CGFloat(i * 2))
    ios.onScrollChanged(startedByUser: true, oldContentOffset: old)
}
assert(ios.channelDelegate!.scrolls.isEmpty)
assert(ios.lastScrollX == 10000 && ios.lastScrollY == 20000)
ios.settings!.disableVerticalScroll = true
ios.scrollView.contentOffset = CGPoint(x: 10002, y: 25000)
ios.onScrollChanged(startedByUser: true, oldContentOffset: CGPoint(x: 10000, y: 20000))
assert(ios.lastScrollX == 10002 && ios.lastScrollY == 20000)
ios.settings!.disableVerticalScroll = false
ios.settings!.disableHorizontalScroll = true
ios.scrollView.contentOffset = CGPoint(x: 15000, y: 20004)
ios.onScrollChanged(startedByUser: true, oldContentOffset: CGPoint(x: 10002, y: 20000))
assert(ios.lastScrollX == 10002 && ios.lastScrollY == 20004)
ios.settings!.disableHorizontalScroll = false
ios.scrollView.contentOffset = CGPoint(x: -8, y: 60000)
ios.onScrollChanged(startedByUser: false, oldContentOffset: nil)
assert(ios.channelDelegate!.scrolls.isEmpty)
assert(ios.channelDelegate!.overscrolls.last! == [-4, 30000, 1, 1])
ios.setScrollChangedListener(hasListener: true)
ios.scrollView.contentOffset = CGPoint(x: 61, y: 79)
ios.onScrollChanged(startedByUser: false, oldContentOffset: nil)
assert(ios.channelDelegate!.scrolls == [[30, 39]])
ios.setScrollChangedListener(hasListener: false)
ios.scrollView.contentOffset = CGPoint(x: 91, y: 101)
ios.onScrollChanged(startedByUser: false, oldContentOffset: nil)
assert(ios.channelDelegate!.scrolls.count == 1)
assert(ios.lastScrollX == 91 && ios.lastScrollY == 101)

let parent = MacView()
let popup = MacView()
popup.windowId = 7
popup.setScrollChangedListener(hasListener: true)
assert(popup.scripts.isEmpty, "an unclaimed popup must not bypass its owner's script policy")
popup.windowCreated = true
popup.setScrollChangedListener(hasListener: true)
assert(popup.scripts == ["subscription:true"])
parent.setScrollChangedListener(hasListener: false)
let event: [String: Any] = ["args": "[{\"x\":37,\"y\":53}]"]
for _ in 1...10000 { parent.receive(event) }
assert(parent.channelDelegate!.scrolls.isEmpty)
popup.receive(event)
assert(popup.channelDelegate!.scrolls == [[37, 53]])
parent.setScrollChangedListener(hasListener: true)
parent.receive(event)
assert(parent.channelDelegate!.scrolls == [[37, 53]])
assert(parent.scripts == ["subscription:false", "subscription:true"])
popup.setScrollChangedListener(hasListener: false)
assert(parent.hasScrollChangedListener)
parent.javaScriptBridgeEnabled = false
parent.setScrollChangedListener(hasListener: false)
assert(parent.scripts.count == 2)
print("Production Apple native scroll methods: message counts, axis limits, bookkeeping, overscroll and popup isolation passed")
'''

for token, value in {
    "__IOS_SETTER__": ios_setter, "__IOS_SCROLL__": ios_scroll,
    "__MAC_SETTER__": macos_setter, "__MAC_UPDATE__": macos_update,
    "__MAC_GATE__": macos_gate,
}.items():
    harness = harness.replace(token, value)
with tempfile.TemporaryDirectory(prefix="scroll-subscriptions-") as directory:
    source = Path(directory) / "main.swift"
    executable = Path(directory) / "scroll-tests"
    source.write_text(harness)
    subprocess.run(["swiftc", str(source), "-o", str(executable)], check=True)
    subprocess.run([str(executable)], check=True)
