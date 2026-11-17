# flutter\_inappwebview\_windows

The Windows WebView2 implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Observing the Windows rendering backend

`WindowsInAppWebViewController.creationDetails` exposes an immutable observation
from the native widget creation response. It is available through the regular
`InAppWebViewController.platform` **inside `onWebViewCreated`**, including when a
controller wrapper is constructed by `controllerFromPlatform`.

```dart
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';

final view = InAppWebView(
  onWebViewCreated: (controller) {
    final platform = controller.platform;
    if (platform is! WindowsInAppWebViewController) return;

    final details = platform.creationDetails;
    final actualMode = details?.renderMode;
    if (actualMode == null) {
      // No verified native backend observation is available for this owner.
      return;
    }

    print({
      'nativeViewId': details!.nativeViewId,
      'actualBackend': actualMode.name,
      'fallbackReasonAvailable': details.isFallbackReasonAvailable,
      'fallbackStage': details.fallbackStage,
      'fallbackHresult': details.fallbackHresult,
    });
  },
);
```

The getter reads the observation already supplied by native code. It does not
query the platform, select a rendering mode, or infer one from environment
variables or the absence of `WindowsWebViewHwndFallbacks` events.

| Creation/lifetime case | Observation |
| --- | --- |
| Native result explicitly reports `composition` or `hwnd` | `renderMode` is verified; `isRenderModeVerified` is `true`. |
| Legacy integer result, missing mode, or unknown mode | `nativeViewId` is known, but `renderMode` is `null` and `isRenderModeVerified` is `false`. The existing rendering code still uses its composition compatibility default. |
| Complete native fallback stage and HRESULT | `isFallbackReasonAvailable` is `true`. `forced` with HRESULT `0` describes the explicit HWND test hook, not a failure. |
| Missing, partial, or invalid fallback fields | `isFallbackReasonAvailable` is `false`; individually valid fields can still be present. This is not evidence that no fallback occurred. |
| keepAlive reattachment | A new controller owns a new observation with the returned platform view id. Native code reports the current mode but currently omits the original selection reason, so that reason remains unavailable. |
| Headless view converted to a widget | The widget controller receives the new creation observation. The previous headless controller does not acquire it. |
| Static, direct, headless, or InAppBrowser controller without a widget creation result | `creationDetails` is `null`. Before widget creation completes there is no widget controller to publish; a failed creation does not invoke `onWebViewCreated`. |
| Disposed or detached widget controller, including keepAlive | The getter returns `null`. A snapshot retained earlier remains a historical observation of that attachment; it does not become the observation of a new owner, even if a native id is reused. |

`nativeViewId` identifies the returned platform view/texture, not a process or a
permanent WebView. It can differ from the controller's channel id for keepAlive
and converted headless views. Creation HRESULTs are unsigned 32-bit values;
signed native values are normalized once. This differs from the signed HRESULT
contract of WebView2 process-enumeration errors. Non-integer or out-of-range
HRESULTs do not become valid diagnostics through truncation.

The existing integer `CustomPlatformView.onPlatformViewCreated` callback remains
unchanged. An optional `onPlatformViewCreationDetails` callback delivers the
observation first; abandoned or failed creation delivers neither callback. Data
travels with the widget/controller owner, without an id-indexed global cache.

If a constructor-time `controllerFromPlatform` factory throws, the original
exception and stack are preserved. Its partial Dart channel binding is detached
before the failure leaves the constructor, without accessing storage that has
not been initialized, changing native subscriptions, or removing a newer owner's
handler. The remaining inert channel callback has no reference to the failed
controller. Captured failed controllers report no live creation details and
receive no subsequent channel events; disposing them again is a no-op.

For a composition/HWND comparison, record a verified mode for every measured
view and exclude unverified cases. A requested environment setting alone is
insufficient: RDP or capture-probe fallback can select HWND. This API records
creation facts; it does not establish latency, memory or GPU savings. Rendering
defaults are unchanged, and acceptance still requires measurements on two
physical GPU configurations with the application workload.
