# flutter\_inappwebview\_linux

The Linux WPE WebKit implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Multiple Flutter windows

Applications that use several Flutter views in one engine can set
`LinuxWebViewHostWindow.resolver` before creating a WebView. The resolver receives
the Flutter view ID and returns the addresses of its live `GtkWindow*` and
`FlView*` as a `LinuxWebViewHostHandles` record:

```dart
LinuxWebViewHostWindow.resolver = (viewId) {
  // Look up this pair through your application's native window integration.
  return hostHandlesByFlutterViewId[viewId];
};
```

Returning `null` selects the registration window while that window is alive.
Update the application's handle map when windows are created or destroyed;
only return live native objects. A WebView follows its Flutter view when moved
between windows, including when reused with a keep-alive ID. Host changes close
dialogs attached to the previous window and resend the surface geometry.

When its host closes, a surviving WebView falls back to the live registration
window. If that window has also closed, it waits without a host until attached
to another window.
