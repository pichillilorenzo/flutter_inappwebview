#!/usr/bin/env python3
"""Compile production Apple reply routing/settlement with small framework doubles.

The complete shared authorization/probe and Dart callback code is extracted
unchanged. Only the unrelated internal-handler switch is replaced with one
sentinel handler, and OS availability is parameterized to cover old OS paths.
--sdk-check also typechecks the actual WKScriptMessageHandlerWithReply adapter
against both macOS and iOS simulator SDKs (requires Xcode).
This is not a live Flutter or WebKit performance measurement.
"""
import argparse
from pathlib import Path
import subprocess
import tempfile

from swift_source import extract_swift_block as method

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--sdk-check', action='store_true')
args = parser.parse_args()


stubs = r'''
import Foundation
import CoreGraphics
struct JavaScriptBridgeJS { static func get_JAVASCRIPT_BRIDGE_NAME() -> String { "flutter_inappwebview" } }
final class WKUserContentController { var javaScriptBridgeSecret: String? = "secret" }
final class Configuration { var userContentController = WKUserContentController() }
final class World: Equatable {
    static let page = World(nil)
    var name: String?
    var windowId: Int64?
    init(_ id: Int64?, _ name: String? = nil) { windowId = id; self.name = name }
    static func == (a: World, b: World) -> Bool { a === b }
}
final class Settings {
    var javaScriptHandlersForMainFrameOnly = false
    var javaScriptHandlersOriginAllowList: [String]? = nil
}
struct SecurityOrigin { var `protocol` = "https"; var host = "allowed.test"; var port = 0 }
struct Request { var url: URL? = URL(string: "https://allowed.test/path") }
final class FrameInfo { var isMainFrame = true; var securityOrigin = SecurityOrigin(); var request = Request() }
final class WKScriptMessage {
    weak var webView: AnyObject?
    var frameInfo = FrameInfo()
    var world = World.page
    var name = "callHandlerWithReply"
    var body: Any
    init(_ owner: InAppWebView, _ body: Any) { webView = owner; self.body = body }
}
struct JavaScriptHandlerFunctionData {
    let args: String; let isMainFrame: Bool; let origin: String; let requestUrl: String
}
final class WebViewChannelDelegate {
    final class CallJsHandlerCallback {
        var defaultBehaviour: (Any?) -> Void = { _ in }
        var error: (String, String?, Any?) -> Void = { _, _, _ in }
    }
    var requests: [(String, JavaScriptHandlerFunctionData, CallJsHandlerCallback)] = []
    func onCallJsHandler(handlerName: String, data: JavaScriptHandlerFunctionData, callback: CallJsHandlerCallback) {
        requests.append((handlerName, data, callback))
    }
}
final class Answer {
    var calls = 0; var value: Any?; var error: String?
    func finish(_ value: Any?, _ error: String?) { calls += 1; self.value = value; self.error = error }
}
var modern = true
final class InAppWebView {
    var configuration = Configuration()
    var windowId: Int64?
    var windowCreated = true
    var javaScriptBridgeDisposed = false
    var javaScriptBridgeEnabled = true
    var scriptMessageReplyPolicy: Bool? = false
    var usesScriptMessageHandlerWithReply: Bool { scriptMessageReplyPolicy == true }
    let javaScriptBridgeReplies = JavaScriptBridgeReplyRegistry()
    var settings: Settings? = Settings()
    let javaScriptHandlerOriginRules = JavaScriptHandlerOriginRules()
    var channelDelegate: WebViewChannelDelegate? = WebViewChannelDelegate()
    var internalHandlerCalls = 0
    var evaluations = 0
    var scripts: [String] = []
    func evaluateJavaScript(_ source: String, completionHandler: (() -> Void)?) { evaluations += 1; scripts.append(source) }
    func callAsyncJavaScript(_ source: String, arguments: [String: String], frame: Any?, contentWorld: World, completionHandler: (() -> Void)?) {
        evaluations += 1; scripts.append(source)
    }
    // PRODUCTION_ROUTE
}
func require(_ value: @autoclosure () -> Bool, _ message: String) {
    if !value() { fatalError(message) }
}
func body(_ overrides: [String: Any] = [:]) -> [String: Any] {
    var body: [String: Any] = ["_bridgeSecret": "secret", "handlerName": "echo", "args": "[1]", "_callHandlerID": Int64(7), "_bridgeReplyDocumentId": "document-a"]
    for (key, value) in overrides { body[key] = value }
    return body
}
@discardableResult
func receive(_ owner: InAppWebView, _ message: WKScriptMessage, via delegate: InAppWebView? = nil, reply: Bool = true, controller: WKUserContentController? = nil) -> Answer {
    let answer = Answer()
    (delegate ?? owner).handleScriptMessage(controller ?? owner.configuration.userContentController, didReceive: message,
                                            reply: reply ? JavaScriptBridgeReply(answer.finish) : nil)
    return answer
}
'''

tests = r'''
let root = InAppWebView()
let defaultProbe = receive(root, WKScriptMessage(root, body(["_bridgeReplyProbe": true])))
require(defaultProbe.calls == 1 && defaultProbe.value as? String == "false", "default disabled")
let refused = receive(root, WKScriptMessage(root, body()))
require(refused.calls == 1 && refused.error != nil && root.channelDelegate!.requests.isEmpty, "disabled direct API fails once")
root.scriptMessageReplyPolicy = true
let successful = receive(root, WKScriptMessage(root, body()))
require(root.javaScriptBridgeReplies.count == 1, "pending reply retained")
let response = root.channelDelegate!.requests.last!.2
let raw = "{\"__proto__\":{\"inherited\":1},\"text\":\"עברית 😀\"}"
response.defaultBehaviour(raw)
response.error("LATE", nil, nil)
response.defaultBehaviour("null")
require(successful.calls == 1 && successful.value as? String == raw && successful.error == nil, "text is unchanged; settles once")
require(root.javaScriptBridgeReplies.count == 0 && root.evaluations == 0, "reply does not evaluate JavaScript")
let invalidJSON = receive(root, WKScriptMessage(root, body()))
root.channelDelegate!.requests.last!.2.defaultBehaviour("{broken")
require(invalidJSON.calls == 1 && invalidJSON.value as? String == "{broken", "JSON validation remains in JavaScript")
let dartFailure = receive(root, WKScriptMessage(root, body()))
root.channelDelegate!.requests.last!.2.error("ERR", "quotes '\" \\ עברית\u{2028}", nil)
require(dartFailure.calls == 1 && dartFailure.error == "ERR, quotes '\" \\ עברית\u{2028}", "Dart error unchanged")
let internalAnswer = receive(root, WKScriptMessage(root, body(["handlerName": "internal"])))
require(internalAnswer.calls == 1 && internalAnswer.value == nil && internalAnswer.error == nil, "internal undefined result")

// Exercise the production one-way early return on the default-OFF transport.
// A successful notification must dispatch internally but never evaluate a reply.
let notificationOwner = InAppWebView()
notificationOwner.settings!.javaScriptHandlersOriginAllowList = ["^https://allowed\\.test$"]
let notification = WKScriptMessage(notificationOwner, body(["handlerName": "internal", "_callHandlerOneWay": true]))
notification.name = "callHandler"
let noReply = receive(notificationOwner, notification, reply: false)
require(notificationOwner.internalHandlerCalls == 1, "authorized one-way notification reaches the internal handler")
require(notificationOwner.evaluations == 0 && noReply.calls == 0 && notificationOwner.javaScriptBridgeReplies.count == 0, "one-way notification has no native reply or JavaScript evaluation")
require(notificationOwner.channelDelegate!.requests.isEmpty, "internal notification does not dispatch an application RPC")
let ordinaryInternal = WKScriptMessage(notificationOwner, body(["handlerName": "internal"]))
ordinaryInternal.name = "callHandler"
receive(notificationOwner, ordinaryInternal, reply: false)
require(notificationOwner.internalHandlerCalls == 2 && notificationOwner.evaluations == 1, "ordinary internal Promise still receives its legacy evaluation")
for invalidSecret in [false, true] {
    let deniedOwner = InAppWebView()
    let deniedBody = body(["handlerName": "internal", "_callHandlerOneWay": true,
                           "_bridgeSecret": invalidSecret ? "wrong" : "secret"])
    if !invalidSecret { deniedOwner.settings!.javaScriptHandlersOriginAllowList = [] }
    let deniedNotification = WKScriptMessage(deniedOwner, deniedBody)
    deniedNotification.name = "callHandler"
    receive(deniedOwner, deniedNotification, reply: false)
    require(deniedOwner.internalHandlerCalls == 0 && deniedOwner.channelDelegate!.requests.isEmpty, "secret/origin gates precede internal one-way dispatch")
    require(deniedOwner.evaluations == 0 && deniedOwner.javaScriptBridgeReplies.count == 0, "denied one-way notification produces no reply evaluation")
}

for scenario in 0..<12 {
    let owner = InAppWebView(); owner.scriptMessageReplyPolicy = true
    let message = WKScriptMessage(owner, body())
    switch scenario {
    case 0: message.body = body(["_bridgeSecret": "wrong"])
    case 1: message.body = "not a map"
    case 2: owner.settings!.javaScriptHandlersOriginAllowList = []
    case 3: owner.settings!.javaScriptHandlersOriginAllowList = ["^https://different\\.test$"]
    case 4: owner.settings!.javaScriptHandlersForMainFrameOnly = true; message.frameInfo.isMainFrame = false
    case 5: message.body = body(["_windowId": Int64(99)])
    case 6: message.world = World(99, "other-popup")
    case 7: owner.javaScriptBridgeDisposed = true
    case 8: owner.javaScriptBridgeEnabled = false
    case 9: message.body = body(["_callHandlerOneWay": true])
    case 10: var b = body(); b.removeValue(forKey: "handlerName"); message.body = b
    default: message.body = body(["_bridgeReplyDocumentId": ""])
    }
    let denied = receive(owner, message)
    require(denied.calls == 1 && denied.error != nil && owner.channelDelegate!.requests.isEmpty, "denied once: \(scenario)")
    require(owner.javaScriptBridgeReplies.count == 0, "denied reply removed")
    require(owner.evaluations == 0, "denied reply cannot evaluate a legacy completion")
    message.name = "callHandler"
    if scenario != 9 && scenario != 11 { // one-way and document IDs are transport-specific
        receive(owner, message, reply: false)
        require(owner.channelDelegate!.requests.isEmpty, "legacy uses same authorization: \(scenario)")
        require(owner.evaluations == 0, "denied legacy request cannot evaluate a completion")
    }
}
let otherController = WKUserContentController()
let wrongController = receive(root, WKScriptMessage(root, body()), controller: otherController)
require(wrongController.calls == 1 && wrongController.error != nil, "controller must match sender")

for parentOptIn in [false, true] {
    let parent = InAppWebView(); parent.scriptMessageReplyPolicy = parentOptIn
    let popup = InAppWebView(); popup.windowId = 11; popup.scriptMessageReplyPolicy = !parentOptIn
    popup.configuration.userContentController = parent.configuration.userContentController
    parent.settings!.javaScriptHandlersOriginAllowList = ["^https://parent\\.test$"]
    popup.settings!.javaScriptHandlersOriginAllowList = ["^https://allowed\\.test$"]
    let message = WKScriptMessage(popup, body(["_windowId": Int64(11)]))
    let probe = WKScriptMessage(popup, body(["_bridgeReplyProbe": true]))
    let policy = receive(popup, probe, via: parent)
    require(parentOptIn ? policy.value as? String == "false" : (policy.value as? String)?.hasPrefix("enabled:") == true, "popup owns its opt-in")
    message.name = "callHandler"
    receive(popup, message, via: parent, reply: false)
    require(popup.channelDelegate!.requests.count == 1 && parent.channelDelegate!.requests.isEmpty, "legacy routes/authorizes actual popup")
    message.name = "callHandlerWithReply"
    let answer = receive(popup, message, via: parent)
    if parentOptIn {
        require(answer.error != nil && popup.channelDelegate!.requests.count == 1, "enabled parent cannot enable popup")
    } else {
        require(answer.calls == 0 && popup.channelDelegate!.requests.count == 2, "disabled parent cannot disable enabled popup")
        popup.channelDelegate!.requests.last!.2.defaultBehaviour("12")
        require(answer.calls == 1 && answer.value as? String == "12", "popup reply reaches caller")
    }
}
let uncreated = InAppWebView(); uncreated.windowId = 12; uncreated.windowCreated = false; uncreated.scriptMessageReplyPolicy = true
let pendingPolicy = receive(uncreated, WKScriptMessage(uncreated, body(["_bridgeReplyProbe": true])))
require(pendingPolicy.value as? String == "pending", "uncreated popup does not cache parent policy")
uncreated.windowCreated = true
let readyPolicy = receive(uncreated, WKScriptMessage(uncreated, body(["_bridgeReplyProbe": true])))
require((readyPolicy.value as? String)?.hasPrefix("enabled:") == true, "popup becomes ready with its own settings")

let concurrentOwner = InAppWebView(); concurrentOwner.scriptMessageReplyPolicy = true
let answers = (0..<256).map { index in receive(concurrentOwner, WKScriptMessage(concurrentOwner, body(["args": "[\(index)]"]))) }
for index in (0..<256).reversed() { concurrentOwner.channelDelegate!.requests[index].2.defaultBehaviour("\(index)") }
for index in 0..<256 { require(answers[index].calls == 1 && answers[index].value as? String == "\(index)", "concurrent replies stay correlated") }
require(concurrentOwner.javaScriptBridgeReplies.count == 0, "concurrent registry drains")

let a = receive(root, WKScriptMessage(root, body()))
let callbackA = root.channelDelegate!.requests.last!.2
let b = receive(root, WKScriptMessage(root, body(["_bridgeReplyDocumentId": "document-b"])))
let callbackB = root.channelDelegate!.requests.last!.2
let cancel = WKScriptMessage(root, body(["_bridgeReplyCancelDocument": "document-a"]))
cancel.name = "callHandler"
receive(root, cancel, reply: false)
require(a.calls == 1 && a.error != nil && b.calls == 0, "pagehide cancels only its document")
callbackA.defaultBehaviour("42")
require(a.calls == 1, "late result after frame navigation ignored")
root.javaScriptBridgeReplies.cancel(error: "navigation")
callbackB.error("LATE", nil, nil)
require(b.calls == 1 && b.error == "navigation", "navigation cancellation is terminal")
root.javaScriptBridgeReplies.cancel(error: "dispose")
require(b.calls == 1 && root.javaScriptBridgeReplies.count == 0, "repeated lifecycle cancellation is harmless")

// Tightening new-work policy must not prevent an authenticated document from
// cancelling an already accepted request. Wrong secrets still cannot cancel.
let restrictedOwner = InAppWebView(); restrictedOwner.scriptMessageReplyPolicy = true
let acceptedFrame = WKScriptMessage(restrictedOwner, body()); acceptedFrame.frameInfo.isMainFrame = false
let accepted = receive(restrictedOwner, acceptedFrame)
let acceptedCallback = restrictedOwner.channelDelegate!.requests.last!.2
restrictedOwner.settings!.javaScriptHandlersForMainFrameOnly = true
restrictedOwner.settings!.javaScriptHandlersOriginAllowList = []
let restrictedCancel = WKScriptMessage(restrictedOwner, body(["_bridgeReplyCancelDocument": "document-a", "_bridgeSecret": "wrong"]))
restrictedCancel.name = "callHandler"; restrictedCancel.frameInfo.isMainFrame = false
receive(restrictedOwner, restrictedCancel, reply: false)
require(accepted.calls == 0, "unauthenticated lifecycle message cannot cancel")
restrictedCancel.body = body(["_bridgeReplyCancelDocument": "document-a"])
receive(restrictedOwner, restrictedCancel, reply: false)
require(accepted.calls == 1 && accepted.error != nil && restrictedOwner.channelDelegate!.requests.count == 1, "policy changes allow release but no new application work")
acceptedCallback.defaultBehaviour("42")
require(accepted.calls == 1 && restrictedOwner.javaScriptBridgeReplies.count == 0, "late reply after restricted document cancellation stays terminal")

let namedWorld = World(nil, "isolated")
let scopedMessage = WKScriptMessage(root, body()); scopedMessage.world = namedWorld
let scoped = receive(root, scopedMessage)
let scopedCallback = root.channelDelegate!.requests.last!.2
receive(root, cancel, reply: false)
require(scoped.calls == 0, "page world cannot cancel named-world reply")
root.javaScriptBridgeReplies.cancel(error: "dispose")
scopedCallback.defaultBehaviour("true")
require(scoped.calls == 1 && scoped.error == "dispose", "named-world disposal")

var releasedOwner: InAppWebView? = InAppWebView(); releasedOwner!.scriptMessageReplyPolicy = true
weak var weakOwner = releasedOwner
let releasedAnswer = receive(releasedOwner!, WKScriptMessage(releasedOwner!, body()))
let late = releasedOwner!.channelDelegate!.requests.last!.2
releasedOwner = nil
require(weakOwner == nil && releasedAnswer.calls == 1 && releasedAnswer.error != nil, "pending Dart callback must not retain WebView")
late.defaultBehaviour("false")
require(releasedAnswer.calls == 1, "reply remains terminal after owner release")
let noDart = InAppWebView(); noDart.scriptMessageReplyPolicy = true; noDart.channelDelegate = nil
let noDartAnswer = receive(noDart, WKScriptMessage(noDart, body()))
require(noDartAnswer.calls == 1 && noDartAnswer.error != nil, "missing Dart channel settles")
let oldOS = InAppWebView(); modern = false
let oldMessage = WKScriptMessage(oldOS, body()); oldMessage.name = "callHandler"
receive(oldOS, oldMessage, reply: false)
oldOS.channelDelegate!.requests.last!.2.defaultBehaviour("42")
require(oldOS.evaluations == 1, "legacy OS keeps script resolution")
print("production native route: authorization, popup ownership, 256 replies, raw text, errors, scoped cancellation, deallocation and old OS passed")
'''

with tempfile.TemporaryDirectory(prefix='apple-reply-native-') as directory:
    temp = Path(directory)
    for platform in ['ios', 'macos']:
        sources = ROOT / f'flutter_inappwebview_{platform}/{platform}/flutter_inappwebview_{platform}/Sources/flutter_inappwebview_{platform}'
        native = (sources / 'InAppWebView/InAppWebView.swift').read_text()
        route = method(native, '    func handleScriptMessage(')
        switch_start = route.index('            var isInternalHandler = true')
        switch_end = route.index('            let _callHandlerID =', switch_start)
        route = route[:switch_start] + '''            let isInternalHandler = handlerName == "internal"
            if isInternalHandler { webView.internalHandlerCalls += 1 }
''' + route[switch_end:]
        import re
        route = re.sub(r'if #available\([^)]*\)', 'if modern', route)
        util = (sources / 'Util.swift').read_text()
        util_func = method(util, '    public static func JSONStringify(')
        lifetime = (sources / 'Types/JavaScriptBridgeReply.swift').read_text()
        origin_rules = (sources / 'Types/JavaScriptHandlerOriginRules.swift').read_text()
        code = stubs.replace('    // PRODUCTION_ROUTE', route)
        code += '\nstruct Util {\n' + util_func + '\n}\n' + origin_rules + lifetime + tests
        file = temp / f'{platform}.swift'
        file.write_text(code)
        binary = temp / platform
        subprocess.run(['swiftc', '-swift-version', '5', str(file), '-o', str(binary)], check=True)
        subprocess.run([str(binary)], check=True)
        # Assert the real lifecycle/creation hooks call the exercised helper.
        for signature in ['    public func dispose()', '    public func webViewWebContentProcessDidTerminate(', '    public func webView(_ webView: WKWebView, didStartProvisionalNavigation']:
            assert 'javaScriptBridgeReplies.cancel(' in method(native, signature), signature
        assert 'newSettings.useScriptMessageHandlerWithReply = usesScriptMessageHandlerWithReply' in native
        if args.sdk_check:
            sdk = 'iphonesimulator' if platform == 'ios' else 'macosx'
            arch = subprocess.check_output(['uname', '-m'], text=True).strip()
            target = f'{arch}-apple-ios14.0-simulator' if platform == 'ios' else f'{arch}-apple-macos11.0'
            sdk_path = subprocess.check_output(['xcrun', '--sdk', sdk, '--show-sdk-path'], text=True).strip()
            stub = temp / f'{platform}_sdk.swift'
            availability = 'iOS 14.0' if platform == 'ios' else 'macOS 11.0'
            stub.write_text(f'''import Foundation
import WebKit
@available({availability}, *)
class InAppWebView: WKWebView {{
    func handleScriptMessage(_ controller: WKUserContentController, didReceive message: WKScriptMessage, reply: JavaScriptBridgeReply?) {{ reply?.succeed("null") }}
}}
extension WKUserContentController {{
    @available({availability}, *)
    var contentWorlds: Set<WKContentWorld> {{ [.page] }}
}}
''')
            subprocess.run(['xcrun', '--sdk', sdk, 'swiftc', '-swift-version', '5', '-typecheck', '-sdk', sdk_path, '-target', target,
                            str(stub), str(sources / 'Types/JavaScriptBridgeReply.swift'), str(sources / 'Types/JavaScriptBridgeReplyHandler.swift'), str(sources / 'Types/JavaScriptBridgeMessageHandler.swift')], check=True)
            print(f'{platform}: production reply adapter typechecked against {sdk} ({target})')
