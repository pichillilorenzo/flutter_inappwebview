#!/usr/bin/env python3
"""Compile the production shared-controller registration and cleanup in Swift.

Uses small WebKit doubles to make ownership/retention observable. The current
stateless adapters and weak-owner registries are compiled from their real files.
Each close phase drains a local autorelease pool before checking weak references.
Additional cases keep sibling replies pending across either closing order, reject
late completion after disposal, isolate independent controllers, and close 1,000
opted-in popups while a sibling retains the shared scripts and one-way route.
The current-source run also requires an intentionally retaining handler to fail
that same check. --emit-source writes these inputs without compiling/running them.
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
BASELINE_FAILURE = 'live popup lost callHandler when parent closed first'
RETENTION_FAILURE = 'shared message handler retained disposed parent'
STATELESS_SELECTION = '''        let registeredHandler: WKScriptMessageHandler = scriptMessageHandler is InAppWebView ?
            JavaScriptBridgeMessageHandler() : scriptMessageHandler'''
RETAINING_SELECTION = '''        let registeredHandler: WKScriptMessageHandler = scriptMessageHandler'''


def source(path, source_ref=None):
    if source_ref:
        return subprocess.check_output(
            ['git', 'show', f'{source_ref}:{path}'],
            cwd=ROOT, text=True, encoding='utf-8',
        )
    return (ROOT / path).read_text(encoding='utf-8')


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
        var completedCases = 0
        for enabled in [[false, false], [true, false], [false, true], [true, true]] {
            for parentFirst in [true, false] {
                let controller = WKUserContentController()
                var parent: InAppWebView? = nil
                var popup: InAppWebView? = nil
                weak var weakParent: InAppWebView? = nil
                weak var weakPopup: InAppWebView? = nil
                var firstOwnerAliveBeforeDrain = false
                var lastOwnerAliveBeforeDrain = false
                let label = "parentOptIn=\(enabled[0]) popupOptIn=\(enabled[1]) parentFirst=\(parentFirst)"
                // This Foundation command-line process has no UIKit/AppKit event
                // loop to drain temporary Cocoa objects. Include registration:
                // reading a weak NSHashTable may retain owners until this drain.
                autoreleasepool {
                    parent = InAppWebView(controller, windowId: nil, enabled: enabled[0])
                    popup = InAppWebView(controller, windowId: 7, enabled: enabled[1])
                    weakParent = parent
                    weakPopup = popup
                    controller.install(parent!)
                    if parentFirst {
                        parent!.releaseJavaScriptBridgeOwner()
                        parent = nil
                    } else {
                        popup!.releaseJavaScriptBridgeOwner()
                        popup = nil
                    }
                    firstOwnerAliveBeforeDrain = parentFirst ? weakParent != nil : weakPopup != nil
                }
                let firstOwnerAliveAfterDrain = parentFirst ? weakParent != nil : weakPopup != nil
                print("OWNERSHIP \(label) firstClose beforeDrain=\(firstOwnerAliveBeforeDrain) afterDrain=\(firstOwnerAliveAfterDrain)")
                if parentFirst {
                    require(controller.oneWay["callHandler"] != nil, "live popup lost callHandler when parent closed first")
                    require(weakParent == nil, "shared message handler retained disposed parent")
                    require(controller.scripts == ["bridge", "console", "scroll"], "parent removed live popup scripts")
                    autoreleasepool {
                        for kind in ["rpc", "console-one-way", "scroll-one-way", "window-focus-one-way"] {
                            controller.oneWay["callHandler"]!.userContentController(controller, didReceive: WKScriptMessage(popup!, kind))
                            require(popup!.events.last == kind, "surviving popup did not receive \(kind)")
                        }
                        require(controller.completeDisposals == 0, "controller destroyed while popup alive")
                        // A new document still has bootstrap scripts and handlers.
                        require(controller.scripts.contains("bridge"), "popup navigation lost bootstrap")
                        // REPLY_SURVIVES_POPUP
                        popup!.releaseJavaScriptBridgeOwner()
                        popup!.releaseJavaScriptBridgeOwner()
                        popup = nil
                        lastOwnerAliveBeforeDrain = weakPopup != nil
                    }
                } else {
                    require(weakPopup == nil, "shared message handler retained disposed popup")
                    require(controller.scripts.count == 3 && controller.oneWay["callHandler"] != nil, "popup removed live parent resources")
                    autoreleasepool {
                        for kind in ["rpc", "console-one-way", "scroll-one-way", "window-focus-one-way"] {
                            controller.oneWay["callHandler"]!.userContentController(controller, didReceive: WKScriptMessage(parent!, kind))
                            require(parent!.events.last == kind, "surviving parent did not receive \(kind)")
                        }
                        // REPLY_SURVIVES_PARENT
                        parent!.releaseJavaScriptBridgeOwner()
                        parent = nil
                        lastOwnerAliveBeforeDrain = weakParent != nil
                    }
                }
                let lastOwnerAliveAfterDrain = parentFirst ? weakPopup != nil : weakParent != nil
                print("OWNERSHIP \(label) lastClose beforeDrain=\(lastOwnerAliveBeforeDrain) afterDrain=\(lastOwnerAliveAfterDrain)")
                require(weakParent == nil, "last-owner cleanup retained parent")
                require(weakPopup == nil, "last-owner cleanup retained popup")
                require(controller.oneWay.isEmpty && controller.replies.isEmpty && controller.scripts.isEmpty, "last owner did not release shared resources")
                require(controller.completeDisposals == 1, "shared controller cleanup must happen once")
                completedCases += 1
            }
        }
        require(completedCases == 8, "ownership matrix did not complete all eight cases")
        // ADDITIONAL_LIFECYCLES
        print("production ownership: eight cases, both close orders, four opt-in combinations, weak parent/popup after pool drain, bootstrap, RPC/one-way routes and final cleanup passed")
    }
}
'''


additional_lifecycle_tests = r'''
// Compile the real release method together with the real per-view reply
// registry: closing one owner must cancel only its outstanding native replies.
@MainActor func pendingRepliesSurviveSiblingClose() {
    for parentFirst in [true, false] {
        let controller = WKUserContentController()
        var parent: InAppWebView?
        var popup: InAppWebView?
        weak var weakParent: InAppWebView?
        weak var weakPopup: InAppWebView?
        var closedCalls = 0
        var closedError: String?
        var survivingCalls = 0
        var survivingValue: String?
        let closedReply = JavaScriptBridgeReply { _, error in
            closedCalls += 1
            closedError = error
        }
        let survivingReply = JavaScriptBridgeReply { value, error in
            require(error == nil, "sibling disposal canceled the surviving reply")
            survivingCalls += 1
            survivingValue = value as? String
        }
        autoreleasepool {
            parent = InAppWebView(controller, windowId: nil, enabled: true)
            popup = InAppWebView(controller, windowId: 7, enabled: true)
            weakParent = parent
            weakPopup = popup
            controller.install(parent!)
            let closing = parentFirst ? parent! : popup!
            let surviving = parentFirst ? popup! : parent!
            closing.javaScriptBridgeReplies.track(closedReply, documentId: "same-document-id")
            surviving.javaScriptBridgeReplies.track(survivingReply, documentId: "same-document-id")
            closing.releaseJavaScriptBridgeOwner()
            closing.releaseJavaScriptBridgeOwner()
            require(closedCalls == 1 && closedError != nil,
                    "closed owner's reply did not terminate exactly once")
            require(closing.javaScriptBridgeReplies.count == 0,
                    "closed owner retained a canceled reply")
            require(survivingCalls == 0 && surviving.javaScriptBridgeReplies.count == 1,
                    "shared controller cleanup touched a sibling's pending reply")
            closedReply.succeed("late-success")
            closedReply.fail("late-error")
            require(closedCalls == 1, "late completion settled a disposed owner's reply twice")
            if parentFirst { parent = nil } else { popup = nil }
        }
        require(parentFirst ? weakParent == nil : weakPopup == nil,
                "pending reply retained the disposed owner after pool drain")
        autoreleasepool {
            let surviving = parentFirst ? popup! : parent!
            require(controller.oneWay["callHandler"] != nil && !controller.replies.isEmpty,
                    "pending survivor lost its shared handlers")
            survivingReply.succeed("42")
            require(survivingCalls == 1 && survivingValue == "42" &&
                    surviving.javaScriptBridgeReplies.count == 0,
                    "survivor's already-pending reply could not finish normally")
            surviving.releaseJavaScriptBridgeOwner()
            surviving.releaseJavaScriptBridgeOwner()
            survivingReply.fail("late-after-final-close")
            require(survivingCalls == 1, "final disposal repeated an already completed reply")
            if parentFirst { popup = nil } else { parent = nil }
        }
        require(weakParent == nil && weakPopup == nil,
                "reply cleanup retained a shared-controller owner")
        require(controller.oneWay.isEmpty && controller.replies.isEmpty &&
                controller.scripts.isEmpty && controller.completeDisposals == 1,
                "pending-reply scenario did not release the last owner's resources once")
    }
}

@MainActor func independentControllersReleaseIndependently() {
    let firstController = WKUserContentController()
    let secondController = WKUserContentController()
    autoreleasepool {
        let first = InAppWebView(firstController, windowId: nil, enabled: true)
        let second = InAppWebView(secondController, windowId: nil, enabled: true)
        firstController.install(first)
        secondController.install(second)
        first.releaseJavaScriptBridgeOwner()
        require(firstController.oneWay.isEmpty && firstController.replies.isEmpty &&
                firstController.scripts.isEmpty && firstController.completeDisposals == 1,
                "independent controller did not release its final owner")
        require(secondController.oneWay["callHandler"] != nil &&
                !secondController.replies.isEmpty && secondController.scripts.count == 3 &&
                secondController.completeDisposals == 0,
                "last-owner cleanup leaked across independent controllers")
        secondController.oneWay["callHandler"]!.userContentController(
            secondController, didReceive: WKScriptMessage(second, "independent-survivor"))
        require(second.events == ["independent-survivor"],
                "independent survivor stopped routing messages")
        second.releaseJavaScriptBridgeOwner()
        require(secondController.completeDisposals == 1 && secondController.oneWay.isEmpty &&
                secondController.replies.isEmpty && secondController.scripts.isEmpty,
                "second independent controller retained resources")
    }
}

@MainActor func repeatedPopupClosePreservesLiveOwner() {
    let controller = WKUserContentController()
    var anchor: InAppWebView?
    weak var weakAnchor: InAppWebView?
    autoreleasepool {
        anchor = InAppWebView(controller, windowId: nil, enabled: false)
        weakAnchor = anchor
        controller.install(anchor!)
    }
    for cycle in 0..<1000 {
        weak var weakPopup: InAppWebView?
        autoreleasepool {
            let popup = InAppWebView(controller, windowId: Int64(cycle), enabled: true)
            weakPopup = popup
            require(!controller.replies.isEmpty, "new opted-in popup did not restore reply registration")
            popup.releaseJavaScriptBridgeOwner()
            popup.releaseJavaScriptBridgeOwner()
        }
        require(weakPopup == nil, "repeated close retained a popup after pool drain")
        require(controller.replies.isEmpty && controller.oneWay["callHandler"] != nil &&
                controller.scripts.count == 3 && controller.completeDisposals == 0,
                "repeated popup close removed a live sibling's shared resources")
        require(controller.releasedWindows.count == cycle + 1,
                "repeated popup cleanup was skipped or duplicated")
    }
    autoreleasepool {
        controller.oneWay["callHandler"]!.userContentController(
            controller, didReceive: WKScriptMessage(anchor!, "after-1000-closes"))
        require(anchor!.events == ["after-1000-closes"], "live owner lost routing after repeated popup closes")
        anchor!.releaseJavaScriptBridgeOwner()
        anchor!.releaseJavaScriptBridgeOwner()
        anchor = nil
    }
    require(weakAnchor == nil && controller.oneWay.isEmpty && controller.replies.isEmpty &&
            controller.scripts.isEmpty && controller.completeDisposals == 1,
            "repeated popup scenario retained the last owner's resources")
}
'''


def retaining_handler_control(swift):
    """Change only production handler selection; keep all lifecycle assertions."""
    if swift.count(STATELESS_SELECTION) != 1:
        raise ValueError('expected exactly one stateless registration to mutate')
    return swift.replace(STATELESS_SELECTION, RETAINING_SELECTION)


def build_source(platform, source_ref=None):
    if platform not in ['ios', 'macos']:
        raise ValueError(f'unsupported ownership platform: {platform}')
    base = f'flutter_inappwebview_{platform}/{platform}/flutter_inappwebview_{platform}/Sources/flutter_inappwebview_{platform}'
    native = source(f'{base}/InAppWebView/InAppWebView.swift', source_ref)
    controller = source(f'{base}/Types/WKUserContentController.swift', source_ref)
    current = '    func releaseJavaScriptBridgeOwner()' in native
    sync = method(controller, '    public func sync(')
    selection = sync[sync.index('{') + 1:sync.index('        let pluginScriptsList')]
    registration = re.search(r'(                    removeScriptMessageHandler\(forName: messageHandlerName\)\n                    add\([^\n]+)', sync).group(1)
    registration = selection + '\nlet messageHandlerName = "callHandler"\n' + registration
    # The reply lifetime type supplies fields used by the common doubles even
    # for the old source. Selected registration and cleanup always come from ref.
    production = source(f'{base}/Types/JavaScriptBridgeReply.swift')
    code = stubs.replace('        // REGISTRATION', registration)
    if current:
        for filename in ['JavaScriptBridgeMessageHandler.swift', 'JavaScriptBridgeReplyHandler.swift']:
            production += '\n' + source(f'{base}/Types/{filename}', source_ref).replace('import WebKit\n', '')
        code = code.replace('        // OWNER_REGISTRATION', '''
        controller.registerJavaScriptBridgeOwner(self)
        if enabled { controller.registerJavaScriptBridgeReplyOwner(self) }
''')
        cleanup = method(native, '    func releaseJavaScriptBridgeOwner()')
        current_tests = tests.replace('// REPLY_SURVIVES_POPUP', 'require(controller.replies.isEmpty == !enabled[1], "popup reply opt-in leaked or was removed")')
        current_tests = current_tests.replace('// REPLY_SURVIVES_PARENT', 'require(controller.replies.isEmpty == !enabled[0], "parent reply opt-in leaked or was removed")')
        current_tests = current_tests.replace('// ADDITIONAL_LIFECYCLES', '''
        pendingRepliesSurviveSiblingClose()
        independentControllersReleaseIndependently()
        repeatedPopupClosePreservesLiveOwner()
        print("production ownership: pending replies and late completions, independent controllers and 1,000 shared-controller popup close cycles passed")
''')
        current_tests += '\n' + additional_lifecycle_tests
        # The actual constructor must register unprepared/pending popups too.
        assert 'self.configuration.userContentController.registerJavaScriptBridgeOwner(self)' in native
        assert 'windowWebView?.releaseJavaScriptBridgeOwner()' in native
    else:
        dispose = method(native, '    public func dispose()')
        start = dispose.index('        if windowId == nil {')
        end = dispose.index('        NotificationCenter.default.removeObserver(self)', start)
        cleanup = '    func releaseJavaScriptBridgeOwner() {\n' + dispose[start:end] + '\n    }\n'
        current_tests = tests
    return code.replace('    // CLEANUP', cleanup) + '\n' + production + '\n' + current_tests


def require_expected_failure(result, reason):
    """Only our specific runtime assertion is evidence for a negative control."""
    lines = result.stdout.rstrip().splitlines()
    if result.returncode != 1 or not lines or lines[-1] != 'REGRESSION: ' + reason:
        raise RuntimeError(f'expected the specific regression "{reason}", not another failure')


def compile_and_run(swift, expected_failure=None):
    binary = swift.with_suffix('')
    # A compiler failure or timeout is never accepted as a control's failure.
    subprocess.run(
        ['swiftc', '-swift-version', '5', '-parse-as-library', str(swift), '-o', str(binary)],
        check=True, timeout=120,
    )
    result = subprocess.run(
        [str(binary)], text=True, encoding='utf-8', stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, timeout=30,
    )
    print(result.stdout, end='')
    if expected_failure:
        require_expected_failure(result, expected_failure)
    elif result.returncode:
        raise SystemExit(result.returncode)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-ref')
    parser.add_argument('--expect-regression', action='store_true')
    parser.add_argument('--emit-source', type=Path, help='empty directory; do not compile or run Swift')
    args = parser.parse_args(argv)
    if args.expect_regression and not args.source_ref:
        parser.error('--expect-regression requires --source-ref')
    if args.emit_source:
        args.emit_source.mkdir(parents=True, exist_ok=True)
        if any(args.emit_source.iterdir()):
            parser.error('--emit-source requires an empty directory')

    with tempfile.TemporaryDirectory(prefix='apple-bridge-owners-') as temporary:
        directory = args.emit_source or Path(temporary)
        for platform in ['ios', 'macos']:
            swift = directory / f'{platform}.swift'
            swift.write_text(build_source(platform, args.source_ref), encoding='utf-8')
            if args.emit_source:
                print(f'{platform}: emitted production ownership source only; Swift not compiled or run')
            else:
                compile_and_run(swift, BASELINE_FAILURE if args.expect_regression else None)
                if args.expect_regression:
                    print(f'{platform}: reproduced expected parent-first ownership regression at {args.source_ref}')

            if not args.expect_regression:
                # Keep the disposed parent in the shared controller deliberately.
                # The unchanged post-drain weak assertion must reject this leak.
                negative = directory / f'{platform}-retaining-handler.swift'
                negative.write_text(retaining_handler_control(swift.read_text(encoding='utf-8')), encoding='utf-8')
                if args.emit_source:
                    print(f'{platform}: emitted retaining-handler control only; Swift not compiled or run')
                else:
                    compile_and_run(negative, RETENTION_FAILURE)
                    print(f'{platform}: retaining-handler control rejected after autorelease pool drain')


if __name__ == '__main__':
    main()
