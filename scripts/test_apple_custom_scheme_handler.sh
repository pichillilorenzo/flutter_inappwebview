#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/apple-scheme-handler.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/modules"

cat > "$tmp_dir/FlutterStub.swift" <<'SWIFT'
public protocol MethodChannelResult {}
SWIFT
cat > "$tmp_dir/FlutterMacOSStub.swift" <<'SWIFT'
public protocol MethodChannelResult {}
SWIFT
swiftc -emit-library -emit-module -module-name Flutter \
  "$tmp_dir/FlutterStub.swift" \
  -emit-module-path "$tmp_dir/modules/Flutter.swiftmodule" \
  -o "$tmp_dir/modules/libFlutter.dylib"
swiftc -emit-library -emit-module -module-name FlutterMacOS \
  "$tmp_dir/FlutterMacOSStub.swift" \
  -emit-module-path "$tmp_dir/modules/FlutterMacOS.swiftmodule" \
  -o "$tmp_dir/modules/libFlutterMacOS.dylib"

cat > "$tmp_dir/main.swift" <<'SWIFT'
import Foundation
import WebKit
#if IOS_STUB
import Flutter
#else
import FlutterMacOS
#endif

final class CustomSchemeResponse {
    let data: Data
    let contentType: String
    let contentEncoding: String
    let headers: [String: String]?

    init(data: Data = Data("ok".utf8), contentType: String = "text/plain", contentEncoding: String = "utf-8", headers: [String: String]? = nil) {
        self.data = data
        self.contentType = contentType
        self.contentEncoding = contentEncoding
        self.headers = headers
    }
}

struct WebResourceRequest {
    let url: URL
    init(fromURLRequest request: URLRequest) { self.url = request.url! }
}

class CallbackResult<T>: MethodChannelResult {
    var notImplemented: () -> Void = {}
    var success: (Any?) -> Void = { _ in }
    var error: (String, String?, Any?) -> Void = { _, _, _ in }
    var nonNullSuccess: (T) -> Bool = { _ in true }
    var nullSuccess: () -> Bool = { true }
    var defaultBehaviour: (T?) -> Void = { _ in }
    var decodeResult: (Any?) -> T? = { $0 as? T }
}

class BaseCallbackResult<T>: CallbackResult<T> {
    override init() {
        super.init()
        success = { [weak self] value in
            guard let self else { return }
            let result = self.decodeResult(value)
            let shouldRunDefault: Bool
            if let result { shouldRunDefault = self.nonNullSuccess(result) }
            else { shouldRunDefault = self.nullSuccess() }
            if shouldRunDefault { self.defaultBehaviour(result) }
        }
        notImplemented = { [weak self] in self?.defaultBehaviour(nil) }
    }
}

final class WebViewChannelDelegate {
    final class LoadResourceWithCustomSchemeCallback: BaseCallbackResult<CustomSchemeResponse> {}
    var callbacks: [LoadResourceWithCustomSchemeCallback] = []

    func onLoadResourceWithCustomScheme(request: WebResourceRequest, callback: LoadResourceWithCustomSchemeCallback) {
        callbacks.append(callback)
    }
}

final class InAppWebView: WKWebView {
    var channelDelegate: WebViewChannelDelegate?
}

final class FakeTask: NSObject, WKURLSchemeTask {
    let request = URLRequest(url: URL(string: "custom://host/path")!)
    var responseCount = 0
    var dataCount = 0
    var finishCount = 0
    var errors: [Error] = []
    var onResponse: (() -> Void)?
    var onData: (() -> Void)?
    var webKitCallsOnMainThread = true
    override var hash: Int { 101 }

    func didReceive(_ response: URLResponse) {
        webKitCallsOnMainThread = webKitCallsOnMainThread && Thread.isMainThread
        responseCount += 1
        onResponse?()
    }
    func didReceive(_ data: Data) {
        webKitCallsOnMainThread = webKitCallsOnMainThread && Thread.isMainThread
        dataCount += 1
        onData?()
    }
    func didFinish() {
        webKitCallsOnMainThread = webKitCallsOnMainThread && Thread.isMainThread
        finishCount += 1
    }
    func didFailWithError(_ error: Error) {
        webKitCallsOnMainThread = webKitCallsOnMainThread && Thread.isMainThread
        errors.append(error)
    }
}

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() { fatalError("FAIL: \(message)") }
}

func begin(_ task: FakeTask, handler: CustomSchemeHandler, view: InAppWebView, delegate: WebViewChannelDelegate?) {
    view.channelDelegate = delegate
    handler.webView(view, start: task)
}

func pumpMainQueue(until condition: () -> Bool) {
    let deadline = Date(timeIntervalSinceNow: 2)
    while !condition() && Date() < deadline {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
    }
}

let view = InAppWebView(frame: .zero, configuration: WKWebViewConfiguration())
let handler = CustomSchemeHandler()
let successDelegate = WebViewChannelDelegate()
let successTask = FakeTask()
begin(successTask, handler: handler, view: view, delegate: successDelegate)
successDelegate.callbacks[0].success(CustomSchemeResponse(headers: ["Content-Security-Policy": "default-src 'none'"]))
check(successTask.finishCount == 1 && successTask.errors.isEmpty, "success finishes exactly once")
check(successTask.responseCount == 1 && successTask.dataCount == 1, "success delivers response and data")
let response = CustomSchemeHandler.urlResponse(for: CustomSchemeResponse(headers: ["X-Test": "yes"]), url: successTask.request.url!) as? HTTPURLResponse
check(response?.allHeaderFields["X-Test"] as? String == "yes", "response headers are preserved")
successDelegate.callbacks[0].error("late", "error", nil)
check(successTask.finishCount == 1 && successTask.errors.isEmpty, "a second terminal callback is ignored")

let nullDelegate = WebViewChannelDelegate()
let nullTask = FakeTask()
begin(nullTask, handler: handler, view: view, delegate: nullDelegate)
nullDelegate.callbacks[0].success(nil)
check(nullTask.errors.count == 1 && nullTask.finishCount == 0, "null success fails the task")

let errorDelegate = WebViewChannelDelegate()
let errorTask = FakeTask()
begin(errorTask, handler: handler, view: view, delegate: errorDelegate)
errorDelegate.callbacks[0].error("failure", "reason", nil)
check(errorTask.errors.count == 1 && errorTask.finishCount == 0, "callback error fails the task")

let notImplementedDelegate = WebViewChannelDelegate()
let notImplementedTask = FakeTask()
begin(notImplementedTask, handler: handler, view: view, delegate: notImplementedDelegate)
notImplementedDelegate.callbacks[0].notImplemented()
check(notImplementedTask.errors.count == 1 && notImplementedTask.finishCount == 0, "notImplemented fails the task")

let missingDelegateTask = FakeTask()
begin(missingDelegateTask, handler: handler, view: view, delegate: nil)
check(missingDelegateTask.errors.count == 1 && missingDelegateTask.finishCount == 0, "missing delegate fails the task")

let responseStopDelegate = WebViewChannelDelegate()
let responseStopTask = FakeTask()
begin(responseStopTask, handler: handler, view: view, delegate: responseStopDelegate)
responseStopTask.onResponse = { handler.webView(view, stop: responseStopTask) }
responseStopDelegate.callbacks[0].success(CustomSchemeResponse())
check(responseStopTask.responseCount == 1 && responseStopTask.dataCount == 0 && responseStopTask.finishCount == 0, "stop during response suppresses data and finish")

let dataStopDelegate = WebViewChannelDelegate()
let dataStopTask = FakeTask()
begin(dataStopTask, handler: handler, view: view, delegate: dataStopDelegate)
dataStopTask.onData = { handler.webView(view, stop: dataStopTask) }
dataStopDelegate.callbacks[0].success(CustomSchemeResponse())
check(dataStopTask.responseCount == 1 && dataStopTask.dataCount == 1 && dataStopTask.finishCount == 0, "stop during data suppresses finish")

let stoppedDelegate = WebViewChannelDelegate()
let stoppedTask = FakeTask()
begin(stoppedTask, handler: handler, view: view, delegate: stoppedDelegate)
handler.webView(view, stop: stoppedTask)
stoppedDelegate.callbacks[0].success(CustomSchemeResponse())
check(stoppedTask.responseCount == 0 && stoppedTask.dataCount == 0 && stoppedTask.finishCount == 0 && stoppedTask.errors.isEmpty, "late callback after stop is ignored")

let collisionDelegate = WebViewChannelDelegate()
let firstTask = FakeTask()
let secondTask = FakeTask()
begin(firstTask, handler: handler, view: view, delegate: collisionDelegate)
begin(secondTask, handler: handler, view: view, delegate: collisionDelegate)
collisionDelegate.callbacks[0].success(CustomSchemeResponse())
collisionDelegate.callbacks[1].success(CustomSchemeResponse())
check(firstTask.finishCount == 1 && secondTask.finishCount == 1, "different tasks with equal hash complete independently")

let backgroundDelegate = WebViewChannelDelegate()
let backgroundTask = FakeTask()
begin(backgroundTask, handler: handler, view: view, delegate: backgroundDelegate)
let backgroundCallbackReturned = DispatchSemaphore(value: 0)
DispatchQueue.global().async {
    backgroundDelegate.callbacks[0].success(CustomSchemeResponse())
    backgroundCallbackReturned.signal()
}
check(backgroundCallbackReturned.wait(timeout: .now() + 2) == .success, "background callback returns")
pumpMainQueue { backgroundTask.finishCount == 1 }
check(backgroundTask.finishCount == 1 && backgroundTask.webKitCallsOnMainThread, "background callback delivers on the main thread")

let queuedStopDelegate = WebViewChannelDelegate()
let queuedStopTask = FakeTask()
begin(queuedStopTask, handler: handler, view: view, delegate: queuedStopDelegate)
let queuedCallbackReturned = DispatchSemaphore(value: 0)
DispatchQueue.global().async {
    queuedStopDelegate.callbacks[0].success(CustomSchemeResponse())
    queuedCallbackReturned.signal()
}
check(queuedCallbackReturned.wait(timeout: .now() + 2) == .success, "queued callback returns")
handler.webView(view, stop: queuedStopTask)
RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
check(queuedStopTask.responseCount == 0 && queuedStopTask.finishCount == 0, "stop cancels a response queued from a background callback")

print("PASS: success, null, error, notImplemented, missing delegate, reentrant stop, late callback, equal hashes, main-queue delivery, exactly-once, headers")
SWIFT

ios_source="$repo_root/flutter_inappwebview_ios/ios/flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/InAppWebView/CustomSchemeHandler.swift"
macos_source="$repo_root/flutter_inappwebview_macos/macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/InAppWebView/CustomSchemeHandler.swift"
swiftc -swift-version 5 -DIOS_STUB -I "$tmp_dir/modules" -L "$tmp_dir/modules" -lFlutter \
  -Xlinker -rpath -Xlinker "$tmp_dir/modules" \
  "$tmp_dir/main.swift" "$ios_source" -o "$tmp_dir/ios-harness"
"$tmp_dir/ios-harness"
swiftc -swift-version 5 -I "$tmp_dir/modules" -L "$tmp_dir/modules" -lFlutterMacOS \
  -Xlinker -rpath -Xlinker "$tmp_dir/modules" \
  "$tmp_dir/main.swift" "$macos_source" -o "$tmp_dir/macos-harness"
"$tmp_dir/macos-harness"
