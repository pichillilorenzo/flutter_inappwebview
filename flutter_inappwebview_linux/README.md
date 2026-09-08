# flutter\_inappwebview\_linux

The Linux WPE WebKit implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Requirements

The plugin renders web content with WebKit. Two backends are supported and the
right one is picked automatically when the app is built:

| Backend | Selected when | Install |
|---------|---------------|---------|
| **WPE WebKit** (preferred, zero-copy GPU rendering) | `wpe-webkit-2.0` is found by pkg-config | Not packaged by Ubuntu 22.10+ (including 24.04 and 26.04) or Debian stable; build from source as described in [WPE_BACKEND.md](WPE_BACKEND.md). |
| **WebKitGTK** (fallback) | WPE WebKit is not found and `webkit2gtk-4.1` is | `sudo apt install libwebkit2gtk-4.1-dev` (Debian/Ubuntu), `sudo dnf install webkit2gtk4.1-devel` (Fedora), `sudo pacman -S webkit2gtk-4.1` (Arch) |

Both backends also need `libgtk-3-dev`, `libsecret-1-dev` and `libepoxy-dev`
(pulled in by `libgtk-3-dev` on Debian/Ubuntu):

```bash
sudo apt install libgtk-3-dev libsecret-1-dev libwebkit2gtk-4.1-dev
```

To force a backend, set the environment variable
`FLUTTER_INAPPWEBVIEW_LINUX_BACKEND=wpe` or `=webkitgtk` when running
`flutter build linux` / `flutter run` (the default is `auto`).

The WebKitGTK backend hosts the `WebKitWebView` widget in an offscreen GTK
window and copies its frames into the Flutter texture, so it needs no extra
runtime files: the app uses the system WebKitGTK library. The WPE backend
bundles the WPE libraries with the app instead. See
[WPE_BACKEND.md](WPE_BACKEND.md) for details and known differences.
