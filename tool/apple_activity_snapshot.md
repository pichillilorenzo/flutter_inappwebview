# Apple WebView activity metadata

`controller.getAppleWebViewActivitySnapshot()` performs one read of public
native properties on the main queue. It is a diagnostic prerequisite for
[Otzaria/otzaria#4120](https://github.com/Otzaria/otzaria/issues/4120), not a change
to WebKit's scheduling policy or proof of the issue's acceptance criteria.

```dart
final sample = await controller.getAppleWebViewActivitySnapshot();
if (sample.availability == AppleWebViewActivityAvailability.available) {
  saveDiagnostic(sample.toMap());
}
```

The result is immutable and is not cached. Native capture time is recorded as
UTC wall-clock milliseconds. Wall clocks can change; use a caller-owned
monotonic clock such as Dart's `Stopwatch` for elapsed measurement intervals.
The result reflects capture time, not an indefinitely current state. The public
snapshot does not expose system uptime or introduce a system-boot-time API use.

## What is observed

| Field | iOS | macOS | Limit |
| --- | --- | --- | --- |
| `windowAttached` | `WKWebView.window != nil` | Same | A hidden/minimized window can remain attached. |
| `viewIsHidden` | `isHidden` | Same | The view's own flag. |
| `viewOrAncestorIsHidden` | Walk `UIView.superview` hidden flags | `isHiddenOrHasHiddenAncestor` | Does not include alpha, clipping, offscreen geometry or occlusion. |
| `applicationState` | `UIApplication.applicationState` | active/inactive from `NSApplication.isActive` | Global application state; iOS can reflect another, more active scene. |
| `applicationIsHidden` | Unavailable | `NSApplication.isHidden` | Inactivity and hiding are distinct. |
| `windowIsVisible` | Unavailable | `NSWindow.isVisible` | Not inferred from UIKit's hidden flag. |
| `windowIsMiniaturized` | Unavailable | `NSWindow.isMiniaturized` | Not a suspension or process-liveness flag. |
| `windowIsOcclusionVisible` | Unavailable | `occlusionState.contains(.visible)` | AppKit's window-wide reported state, not a per-WebView pixel test. |
| `windowIsHidden` | `UIWindow.isHidden` | Unavailable | False does not establish visible pixels. |
| `windowSceneState` | Owning scene's `activationState`, iOS 13+ | Unavailable | Null without a window/scene, or before iOS 13. |
| `inactiveSchedulingPolicy*` | Public preference on iOS 17+ | Public preference on macOS 14+ | Configured policy, not actual JavaScript execution state. |

Window fields are null without an attached window. Unsupported fields stay
null; an observed false remains false. The policy has a separate support flag,
so older OS versions never acquire an inferred `suspend` value. Future native
policy cases are `unknown` with the raw integer preserved.

Apple's public headers declare the policy at iOS 17/macOS 14. Their default
scheduling behavior depends on attachment, idleness and WebKit exemptions.
WebKit also documents that evaluating JavaScript can wake background content.
This getter calls no JavaScript API and writes no preferences. It still adds
host-side method-channel/main-queue work, so capture it at measurement boundaries
outside timed quiet intervals. Metadata cannot establish timer progress, CPU
usage, WebContent process liveness, or whether WebKit actually suspended work.

## Availability and lifecycle

- Other platform implementations inherit `unsupportedPlatform`; the supported
  method metadata identifies iOS/macOS only.
- A static controller has `noNativeView`. A native delegate without a view also
  replies `noNativeView`, without timestamps or stale flags.
- After Dart disposal, including keepAlive detachment, calls return `disposed`
  without sending a native method call. An in-flight answer is discarded if the
  controller was disposed before its future resumes. A replacement controller
  on the same native/channel id can make its own fresh observations.
- A missing native method/channel returns `methodUnavailable`. This can be an
  older plugin or a channel already removed by native teardown; it is not an
  observation about the old view or engine.
- Other native errors and malformed native responses throw. They do not become
  false flags or trigger a JavaScript fallback.

The route uses the plugin's GCD/main-thread conventions; the synchronous helper
checks the main-thread precondition. Swift async/await is confined to the test
apps, which target newer OS versions than the package deployment floors.
The route queues one main-thread read and captures its delegate weakly. It does
not retain a view while waiting. Native disposal or delegate release before
capture returns `noNativeView`. Native capture itself is synchronous on the
main thread, so it does not keep a mutable observation open over an async gap.

## Reproducible checks

Linux checks do not execute Apple code:

```sh
python3 tool/test_apple_activity_snapshot.py --mode source
python3 tool/test_apple_activity_snapshot_contracts.py
cd flutter_inappwebview_platform_interface
flutter pub get --no-example
flutter test --no-pub test/apple_webview_activity_snapshot_test.dart
cd ../flutter_inappwebview
flutter pub get --no-example
flutter test --no-pub test/apple_activity_snapshot_test.dart
```

The new workflow also runs these independent native gates on macOS:

```sh
python3 tool/test_apple_activity_snapshot.py --mode sdk --output /tmp/activity-sdk
python3 tool/test_apple_activity_snapshot.py --mode macos --output /tmp/activity-macos
python3 tool/test_apple_activity_snapshot.py --mode ios-simulator --output /tmp/activity-ios
```

The SDK gate compiles the exact production helper and exact extracted channel
branch against real SDKs at the package deployment floors: iOS 12 and macOS
10.14, using an arm64 iOS device SDK target and an x86_64 macOS target for
those floors. Typechecking does not run a physical device. Only the delegate
surrounding that branch is a fixture; it has the same
weak `WKWebView` member and `(Any?) -> Void` result signature, without Flutter.
This is not a compilation of the entire plugin. Source hashes, emitted inputs,
SDK versions, commands and compiler output remain in the evidence directory.

The macOS gate creates real `WKWebView`s in an `NSWindow`, including hidden
views/ancestors, detach/reattach, order-out, minimize/restore, application
hide/unhide, and a never-attached view. The iOS gate creates one fresh, isolated
Simulator from an installed iPhone runtime, observes real `WKWebView`s through
attachment/hidden-window transitions, then deletes only that Simulator. Runtime
and device identifiers are recorded; no account or physical device is used.
Unavailable runtimes, failed compilation, UI transition timeout, incomplete
reports and failed native assertions fail their gates.

Both probes test a queued read after native disposal, a released delegate, and
a request originating off the main thread. Three test-owned views verify all
three policy values and that capture leaves their preferences unchanged. These
fixture policy assignments are not production settings or performance results.

The macOS fixture has no App Sandbox entitlement. The iOS fixture runs in an
iOS Simulator application container. Both load only local static HTML, never
wait for a network load or call `evaluateJavaScript`. They test the getter and
route with native framework views; they do **not** create Flutter platform
views or exercise Flutter `Offstage`, the actual Otzaria background host,
application suspension on physical iOS, or timer/async/RPC progress. The iOS
fixture uses an actual foreground scene and also checks an attached view in a
never-shown, scene-less window. It does not simulate multiple scenes with
opposing activation states or physical app suspension.
All those distinctions remain visible in the artifact and the follow-up app
measurement must establish its own lifecycle evidence.

The fixture's `requestElapsedSeconds` is its native-call envelope, not WebView
work or a performance comparison. CPU and WebContent liveness remain null. No
improvement in memory, latency or battery usage is claimed. No app dependency
pin or public scheduling setting is changed by this PR.

## Primary references

- [WKPreferences.inactiveSchedulingPolicy](https://developer.apple.com/documentation/webkit/wkpreferences/inactiveschedulingpolicy-swift.property)
- [WebKit public WKPreferences header and OS availability](https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/API/Cocoa/WKPreferences.h)
- [WebKit explanation of SDK-dependent suspension and JavaScript wakeup](https://bugs.webkit.org/show_bug.cgi?id=283794#c4)
- [NSView hidden ancestor semantics](https://developer.apple.com/documentation/appkit/nsview/ishiddenorhashiddenancestor)
- [NSWindow occlusion state](https://developer.apple.com/documentation/appkit/nswindow/occlusionstate-swift.property)
- [UIApplication.applicationState and the most active scene](https://developer.apple.com/documentation/uikit/uiapplication/applicationstate)
- [UIScene activation state](https://developer.apple.com/documentation/uikit/uiscene/activationstate-swift.enum)
