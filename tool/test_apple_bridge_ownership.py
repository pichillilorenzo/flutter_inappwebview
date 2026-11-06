#!/usr/bin/env python3
"""Compile the production shared-controller registration and cleanup in Swift.

Uses small WebKit doubles to make ownership/retention observable. The current
stateless adapters and weak-owner registries are compiled from their real files.
--source-ref selects older native source, and --expect-regression requires that
its parent-first cleanup actually loses the live popup's handler. This is not
an Apple SDK or live WebKit test; the separate workflow runs those as well.
"""
import argparse
from pathlib import Path
import re
import subprocess
import tempfile

from swift_source import extract_swift_block as method

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source-ref')
p.add_argument('--expect-regression', action='store_true')
args = p.parse_args()


def source(path):
    if args.source_ref:
        return subprocess.check_output(['git', 'show', f'{args.source_ref}:{path}'], cwd=ROOT, text=True)
    return (ROOT / path).read_text()


stubs = r'''
import Foundation
import ObjectiveC
@MainActor protocol WKScriptMessageHandler: AnyObject {
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage)
}
@MainActor protocol WKScriptMessageHandlerWithReply: AnyObject {
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage,
                               replyHandler: @escaping @MainActor @Sendable (Any?, String?) -> Void)
}
final class WKContentWorld: NSObject { static let page = WKContentWorld() }
@MainActor final class WKScriptMessage {
    weak var webView: AnyObject?
    let body: String
    init(_ view: InAppWebView, _ body: String) { webView = view; self.body = body }
}
@MainActor final class WKUserContentController: NSObject {
    var contentWorlds: Set<WKContentWorld> = [.page]
    var oneWay: [String: WKScriptMessageHandler] = [:]
    var replies: [String: WKScriptMessageHandlerWithReply] = [:]
    var scripts = ["bridge", "console", "scroll"]
    var releasedWindows: [Int64] = []
    var completeDisposals = 0
    func add(_ handler: WKScriptMessageHandler, name: String) { oneWay[name] = handler }
    func addScriptMessageHandler(_ handler: WKScriptMessageHandlerWithReply, contentWorld: WKContentWorld, name: String) { replies[name] = handler }
    func removeScriptMessageHandler(forName name: String) { oneWay.removeValue(forKey: name); replies.removeValue(forKey: name) }
    func removeScriptMessageHandler(forName name: String, contentWorld: WKContentWorld) { removeScriptMessageHandler(forName: name) }
    func removeAllPluginScriptMessageHandlers() { oneWay.removeAll(); replies.removeAll() }
    func removeAllUserScripts() { scripts.removeAll() }
    func removeAllContentRuleLists() {}
    func dispose(windowId: Int64?) {
        if let windowId = windowId { releasedWindows.append(windowId) }
        else { completeDisposals += 1 }
    }
    func install(_ scriptMessageHandler: WKScriptMessageHandler) {
        // REGISTRATION
    }
}
@MainActor final class Configuration {
    var userContentController: WKUserContentController
    init(_ controller: WKUserContentController) { userContentController = controller }
}
@MainActor final class Manager { var windowWebViews: [Int64: InAppWebView] = [:] }
@MainActor final class Plugin { var inAppWebViewManager: Manager? = Manager() }
@MainActor final class InAppWebView: NSObject, WKScriptMessageHandler {
    var configuration: Configuration
    var windowId: Int64?
    var plugin: Plugin?
    var javaScriptBridgeOwnerReleased = false
    var javaScriptBridgeDisposed = false
    let javaScriptBridgeReplies = JavaScriptBridgeReplyRegistry()
    var events: [String] = []
    init(_ controller: WKUserContentController, windowId: Int64?, enabled: Bool) {
        configuration = Configuration(controller)
        self.windowId = windowId
        super.init()
        // OWNER_REGISTRATION
    }
    func handleScriptMessage(_ controller: WKUserContentController, didReceive message: WKScriptMessage, reply: JavaScriptBridgeReply?) {
        events.append(message.body)
        reply?.succeed("null")
    }
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        handleScriptMessage(controller, didReceive: message, reply: nil)
    }
    // CLEANUP
}
@MainActor func require(_ condition: @autoclosure () -> Bool, _ reason: String) {
    if !condition() { print("REGRESSION: " + reason); exit(1) }
}
'''

tests = r'''
@main struct Run {
    @MainActor static func main() {
        for enabled in [[false, false], [true, false], [false, true], [true, true]] {
            for parentFirst in [true, false] {
                let controller = WKUserContentController()
                var parent: InAppWebView? = InAppWebView(controller, windowId: nil, enabled: enabled[0])
                let popup = InAppWebView(controller, windowId: 7, enabled: enabled[1])
                controller.install(parent!)
                weak var weakParent = parent
                if parentFirst {
                    parent!.releaseJavaScriptBridgeOwner()
                    parent = nil
                    require(controller.oneWay["callHandler"] != nil, "live popup lost callHandler when parent closed first")
                    require(weakParent == nil, "shared message handler retained disposed parent")
                    require(controller.scripts == ["bridge", "console", "scroll"], "parent removed live popup scripts")
                    for kind in ["rpc", "console-one-way", "scroll-one-way", "window-focus-one-way"] {
                        controller.oneWay["callHandler"]!.userContentController(controller, didReceive: WKScriptMessage(popup, kind))
                        require(popup.events.last == kind, "surviving popup did not receive \(kind)")
                    }
                    require(controller.completeDisposals == 0, "controller destroyed while popup alive")
                    // A new document still has bootstrap scripts and handlers.
                    require(controller.scripts.contains("bridge"), "popup navigation lost bootstrap")
                    // REPLY_SURVIVES_POPUP
                    popup.releaseJavaScriptBridgeOwner()
                    popup.releaseJavaScriptBridgeOwner()
                } else {
                    popup.releaseJavaScriptBridgeOwner()
                    require(controller.scripts.count == 3 && controller.oneWay["callHandler"] != nil, "popup removed live parent resources")
                    for kind in ["rpc", "console-one-way", "scroll-one-way", "window-focus-one-way"] {
                        controller.oneWay["callHandler"]!.userContentController(controller, didReceive: WKScriptMessage(parent!, kind))
                        require(parent!.events.last == kind, "surviving parent did not receive \(kind)")
                    }
                    // REPLY_SURVIVES_PARENT
                    parent!.releaseJavaScriptBridgeOwner()
                    parent = nil
                }
                require(controller.oneWay.isEmpty && controller.replies.isEmpty && controller.scripts.isEmpty, "last owner did not release shared resources")
                require(controller.completeDisposals == 1, "shared controller cleanup must happen once")
            }
        }
        print("production ownership: both close orders, four opt-in combinations, weak parent, bootstrap, RPC/one-way routes and final cleanup passed")
    }
}
'''

with tempfile.TemporaryDirectory(prefix='apple-bridge-owners-') as directory:
    for platform in ['ios', 'macos']:
        base = f'flutter_inappwebview_{platform}/{platform}/flutter_inappwebview_{platform}/Sources/flutter_inappwebview_{platform}'
        native = source(f'{base}/InAppWebView/InAppWebView.swift')
        controller = source(f'{base}/Types/WKUserContentController.swift')
        current = '    func releaseJavaScriptBridgeOwner()' in native
        sync = method(controller, '    public func sync(')
        selection = sync[sync.index('{') + 1:sync.index('        let pluginScriptsList')]
        registration = re.search(r'(                    removeScriptMessageHandler\(forName: messageHandlerName\)\n                    add\([^\n]+)', sync).group(1)
        registration = selection + '\nlet messageHandlerName = "callHandler"\n' + registration
        lifetime = (ROOT / f'{base}/Types/JavaScriptBridgeReply.swift').read_text()
        production = lifetime
        code = stubs.replace('        // REGISTRATION', registration)
        if current:
            for filename in ['JavaScriptBridgeMessageHandler.swift', 'JavaScriptBridgeReplyHandler.swift']:
                production += '\n' + source(f'{base}/Types/{filename}').replace('import WebKit\n', '')
            code = code.replace('        // OWNER_REGISTRATION', '''
        controller.registerJavaScriptBridgeOwner(self)
        if enabled { controller.registerJavaScriptBridgeReplyOwner(self) }
''')
            cleanup = method(native, '    func releaseJavaScriptBridgeOwner()')
            current_tests = tests.replace('// REPLY_SURVIVES_POPUP', 'require(controller.replies.isEmpty == !enabled[1], "popup reply opt-in leaked or was removed")')
            current_tests = current_tests.replace('// REPLY_SURVIVES_PARENT', 'require(controller.replies.isEmpty == !enabled[0], "parent reply opt-in leaked or was removed")')
            # The actual constructor must register unprepared/pending popups too.
            assert 'self.configuration.userContentController.registerJavaScriptBridgeOwner(self)' in native
            assert 'windowWebView?.releaseJavaScriptBridgeOwner()' in native
        else:
            dispose = method(native, '    public func dispose()')
            start = dispose.index('        if windowId == nil {')
            end = dispose.index('        NotificationCenter.default.removeObserver(self)', start)
            cleanup = '    func releaseJavaScriptBridgeOwner() {\n' + dispose[start:end] + '\n    }\n'
            current_tests = tests
        code = code.replace('    // CLEANUP', cleanup)
        # Every source path is compiled, not reimplemented as ownership flags.
        swift = Path(directory) / f'{platform}.swift'
        swift.write_text(code + '\n' + production + '\n' + current_tests)
        binary = Path(directory) / platform
        subprocess.run(['swiftc', '-swift-version', '5', '-parse-as-library', str(swift), '-o', str(binary)], check=True)
        result = subprocess.run([str(binary)], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        print(result.stdout, end='')
        if args.expect_regression:
            if result.returncode == 0 or 'REGRESSION: live popup lost callHandler when parent closed first' not in result.stdout:
                raise RuntimeError('expected the specific baseline ownership regression, not another failure')
            print(f'{platform}: reproduced expected parent-first ownership regression at {args.source_ref}')
        elif result.returncode:
            raise SystemExit(result.returncode)
