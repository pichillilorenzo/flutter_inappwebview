# Experimental Apple JavaScript reply transport (#4121)

This fork adds an **opt-in, default-OFF** `WKScriptMessageHandlerWithReply`
transport on iOS 14+ and macOS 11+. It preserves the public `callHandler`
Promise and Dart callback API. The already-implemented raw JSON result path
remains in place: a `JavaScriptHandlerJsonResult` is still sent as JSON text.
This change does not decode/re-encode that response into native containers.

```dart
InAppWebView(
  initialSettings: InAppWebViewSettings(
    useScriptMessageHandlerWithReply: true,
  ),
  onWebViewCreated: (controller) {
    controller.addJavaScriptHandler(
      handlerName: 'raw',
      callback: (JavaScriptHandlerFunctionData data) =>
          const JavaScriptHandlerJsonResult('{"value":42}'),
    );
  },
)
```

The setting belongs to the **native WebView at creation**. `setSettings` cannot
change it, a kept-alive WebView retains its original setting, and a popup uses
its own initial setting. Create a new WebView to change the transport policy.
No application dependency pin or default policy is changed by this experiment.

## Selection, ownership, and lifetime

When no owner of a `WKUserContentController` opts in, the controller has **no
additional reply handler**. JavaScript sends no capability probe and creates no
probe timer. Old operating systems follow this same existing bridge path.

An opted-in owner registers a stateless reply adapter in the controller's
registered content worlds. Owners are weak references and live as long as the
native WebView; widget attachment does not transfer this policy. Removing the
last opted-in owner removes only the experimental handler. Parent and popup
scripts are never replaced to encode a view's opt-in value.

A separate weak owner registry covers **every** related WebView, including
unprepared popups and views with the experiment disabled. Both message adapters
are stateless. Shared scripts/handlers are released by the last native owner,
which may be a popup; closing a parent first preserves a surviving popup's
bootstrap, legacy bridge, console/scroll and one-way messages. Closing a popup
first removes only its content-world registrations. Abandoned popup creation
also releases its owner without requiring a fully prepared view. This is an
intentional shared-lifetime correction to the default legacy path as well.

Each frame/world in a controller with a reply API checks its own native sender's
policy. The first calls wait for that probe **before dispatching an application
request**. A disabled sibling can therefore incur one startup probe when it
shares a controller with an enabled sibling; its application requests still use
the existing transport. Named-world bootstraps use the same decision process.

The probe has a **1,000 ms deadline**. On timeout it selects the existing path
before any application RPC, and ignores a late policy result. An authorization
failure rejects the waiting call. A popup whose Flutter owner is not ready also
rejects that call without invoking Dart; a later call can probe again. The
probe promise always resolves to a decision, so a bootstrap with no application
caller does not produce an unhandled rejection. Navigation clears its timer.

After application dispatch, a synchronous exception, rejected Promise,
non-Promise transport result, malformed JSON, or disposal **never causes a
retry through the other transport**. One-way notifications continue through
`WKScriptMessageHandler`, without a reply Promise or registry entry.

Successful Dart replies are `NSString` JSON text and are parsed by the captured
JavaScript `JSON.parse`. Internal void handlers still resolve `undefined`; Dart
`null` still resolves JSON `null`. Errors use the existing code/message text.

The native reply registry settles each WebKit callback once. It removes pending
entries on success/error, provisional navigation, document commit, WebKit
process termination, and WebView disposal. Frame `pagehide` cancels that frame's
pending document scope. The document token comes from a native UUID, independent
of a page's clock/random generator, and is scoped by its native WebView, content
world, and main-frame identity. Cancellation keeps the sender/controller/secret
and content-world checks, but can release previously accepted work after the app
has tightened its origin/main-frame policy. It invokes no Dart handler or new
application work. Late Dart callbacks hold a weak WebView and cannot
settle the reply again. Reinjection retains the bridge closure and pending
legacy callback entries.

## Shared authorization change, including the default legacy path

Both transports call the **same** native authorization and dispatch method.
The native `message.webView` selects the owner before checking its bridge state,
handler origin allowlist, main-frame policy, and content-world ownership. Its
configuration must match the supplied user-content controller. The shared
script secret belongs to that controller; `_windowId` is only a consistency
check and cannot redirect a request to another owner.

This also corrects legacy behavior: previously a shared handler could check the
parent's origin policy and then select a popup using a JavaScript body window
ID. Legacy requests now use the actual popup's policy and Dart channel. Apple
also now enforces the already-public `javaScriptHandlersForMainFrameOnly`
setting. These are intentional authorization corrections, tested for **both**
transports. Existing user-script injection origin/frame restrictions remain in
place. A denied experimental native callback rejects once; existing legacy
handling of a denied request remains unchanged.

## Verification layers

| Layer | Command / CI | What it establishes |
| --- | --- | --- |
| Production JavaScript | `node tool/test_apple_reply_transport.js` | JSON/prototype/Unicode parity; 256 concurrent out-of-order replies; separate frame/world closures; one-way routing; missing API; default disabled; mixed popup policies; reinjection; navigation; probe timeout, late answers, pending owner; no duplicate dispatch |
| Production Swift route | `python3 tool/test_apple_reply_native.py` | Compiles the actual common authorization/probe and Dart callback bodies, plus reply/registry classes; exercises origin/frame/world/controller/window denials, both popup policy directions, 256 replies, errors, nil/JSON text, cancellation and late callbacks |
| Shared-controller ownership | `python3 tool/test_apple_bridge_ownership.py` | Compiles production registration selection, weak-owner registries, adapters and cleanup; tests both closing orders, all four opt-in combinations, parent retention, surviving RPC/one-way routes, bootstrap retention, and last-owner cleanup |
| SDK protocol conformance | `python3 tool/test_apple_reply_native.py --sdk-check` | Also typechecks the production reply adapter against actual macOS and iOS simulator WebKit SDKs, including availability and actor-isolated reply signatures |
| Existing reply regressions | `node tool/test_javascript_handler_json_replies.js apple` and `node tool/test_apple_bridge_errors.js` | Existing raw-text, argument, old-OS script, popup fallback, malformed JSON and error quoting paths remain tested |
| Flutter settings / callbacks | `flutter test` in platform interface, iOS and macOS; public subscription regression tests | Serialization/defaults plus existing Dart raw JSON and lifecycle contracts |
| Live macOS / Flutter | `python3 tool/run_apple_reply_flutter_probe.py --output apple-reply-live-macos.json` | Builds a temporary **release** Flutter app against this checkout and runs actual WKWebView requests, raw JSON/errors/concurrency, frames/worlds, origin/main-frame rejection, mixed popup opt-ins, last-owner removal, creation-only settings, and a late callback after disposal |

The ownership harness also accepts `--source-ref` with `--expect-regression`.
CI uses published base commit `782b4389440336966f1f05f7a32ae8302ac91a32`
(the same tree as local base `2d9d02c77dc7dbd4692a53cd0b2a28146ce40bf0`)
and requires the specific failure that closing the parent deletes a live popup's
`callHandler`. This is a reproduction against the previous production cleanup,
not just an assertion that the new source contains a guard. The live macOS
probe additionally tests both closing orders and navigation with **no opt-in**,
and all mixed/enabled combinations, including console/scroll/focus one-way
notifications and a surviving owner's already-pending reply.

The Swift route harness substitutes only the unrelated internal-handler switch
with a sentinel and uses small WebKit/Flutter doubles. It parameterizes OS
availability to run both branches. That is a production-code harness, **not** a
full application or an SDK substitute. The separate SDK step compiles the real
adapter signatures; the live macOS probe builds the full macOS plugin.

The workflow `.github/workflows/apple-reply-transport.yaml` runs these Apple
checks and uploads the JSON measurement reports. From a Linux development host,
the Swift/SDK and live WebKit steps are **pending Apple CI**, not local passes.
The live probe's Dart source can still be analyzed on Linux. Its runner creates
an isolated temporary app and uses the same checked-in JSON fixture file as the
other tests.

## Measurements and acceptance

Two commands intentionally produce different kinds of evidence:

```sh
node tool/test_apple_reply_transport.js --benchmark > apple-reply-v8-harness.json
python3 tool/run_apple_reply_flutter_probe.py --output apple-reply-live-macos.json
```

The first reports V8 execution of the production JavaScript with mocked native
handlers. It records bootstrap-plus-first-call time, first-call wait,
steady-state median/p95, startup probe and
timer counts, logical RPC posts, and explicit legacy JavaScript evaluations.
Those counts are **harness operations**, not measured WebKit IPC, native CPU,
physical-device results, or allocation counts. A WithReply completion is still
a response to JavaScript; removing an explicit `evaluateJavaScript` /
`callAsyncJavaScript` operation does not establish fewer physical IPC hops.

The live probe uses identical JSON payloads, the same Dart result wrapper,
release build, runtime, and process for both modes. It reports the document-start
first-call latency separately, then 64-byte, 64-KiB and 1-MiB payload workloads
with concurrency 1 and 16, median/p95 and wall time. A callback-registration
counter verifies that an enabled parity run did not silently use legacy
fallback. Dart invocation counts verify that each application request executes
once. The report records the commit, Flutter/Dart versions, OS, architecture and
build mode. Startup records include the remaining policy wait from the first
application call; they do not isolate native policy-only latency, because the
bootstrap starts its probe before that call. The probe deadline is reported
explicitly; disabled controllers have no probe/timer work. Shared-popup lifecycle
results are reported under `compatibility`, separately from latency records.

**Native main-thread CPU and allocations are not measured by these harnesses**
and remain `null` in the report. Real iOS builds/device runs, supported old Apple
OS versions, platform keep-alive/popup lifecycle acceptance, and native
main-thread/allocation profiling remain additional acceptance gates. CI timings
are useful diagnostics and are not a substitute for device profiling.

The default remains OFF. Enabling it in Otzaria or changing an application pin
requires passing native/live parity gates and demonstrating a useful repeatable
benefit on the target workload. V8 timings alone do not authorize activation.

## Primary API references

Verified against Apple's documentation and WebKit's public headers:

- [WKScriptMessageHandlerWithReply](https://developer.apple.com/documentation/webkit/wkscriptmessagehandlerwithreply)
- [Reply callback](https://developer.apple.com/documentation/webkit/wkscriptmessagehandlerwithreply/usercontentcontroller(_:didreceive:replyhandler:))
- [WebKit protocol header](https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/API/Cocoa/WKScriptMessageHandlerWithReply.h)
- [WKUserContentController registration header](https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/API/Cocoa/WKUserContentController.h)

The public headers declare the reply callback and registration API available
from iOS 14.0 and macOS 11.0. Apple documents `NSString` as a supported result,
`nil` as JavaScript `undefined`, an error string as Promise rejection, and an
at-most-once reply callback. The adapter preserves the current main-actor reply
contract; the older one-way handler remains installed independently.
