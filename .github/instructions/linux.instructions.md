---
applyTo: "flutter_inappwebview_linux/**"
---

# Linux Platform Implementation Instructions

## Implemented Dart Classes

Linux implementation is newer and has fewer features than other platforms:

| Class | File | Description |
|-------|------|-------------|
| `LinuxInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers Linux implementations |
| `LinuxInAppWebView` | `in_app_webview/in_app_webview.dart` | WebView widget using texture |
| `LinuxInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | WPE WebKit controller |
| `LinuxHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Offscreen WebView |
| `LinuxCookieManager` | `cookie_manager/` | WebKit cookie management |

**Not yet implemented**: InAppBrowser, FindInteraction, PrintJob, PullToRefresh, WebMessage, WebStorage, HttpAuthCredentialDatabase, ProxyController.

## Native Code Structure

```
linux/
├── CMakeLists.txt                        # CMake build config (links WPE WebKit)
├── flutter_inappwebview_linux_plugin.cc  # Plugin entry point
├── flutter_inappwebview_linux_plugin_private.h
├── cookie_manager.cc/h                   # WebKit cookie manager
├── in_app_webview/                       # Core WPE WebKit
│   ├── in_app_webview.cc/h               # Main WebView wrapper (5000+ lines)
│   ├── in_app_webview_manager.cc/h       # WebView instance management
│   ├── in_app_webview_settings.cc/h      # Settings mapping
│   ├── webview_channel_delegate.cc/h     # Dart-native bridge
│   ├── user_content_controller.cc/h      # Script injection
│   ├── custom_platform_view.cc/h         # Flutter platform view
│   ├── inappwebview_texture.cc/h         # Base texture class
│   └── inappwebview_egl_texture.cc/h     # EGL texture rendering
├── types/                                # Type definitions
├── utils/                                # Utility functions
└── plugin_scripts_js/                    # Injected JavaScript
```

## Platform Requirements
- WPE WebKit libraries installed
- See `linux/WPE_BACKEND.md` for backend setup documentation

## Native APIs Used
- [WPE WebKit](https://wpewebkit.org/) for offscreen rendering
- Uses texture-based platform view rendering

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Linux implementation is newer and has fewer features than other platforms
3. Check `LinuxInAppWebViewPlatform` for currently supported features

## Native Code Development

When modifying C++ code:
- Located in `linux/`
- **Prefer standard C++17** over platform-specific APIs for maintainability
- Plugin class: `FlutterInappwebviewLinuxPlugin`
- WPE WebKit handles headless rendering to texture

## Build Commands
```bash
cd flutter_inappwebview_linux && flutter pub get
cd example && flutter build linux --debug
```

## Known TODOs in Native Code
- Multi-window implementation (see `in_app_webview.cc:3304`)
- Print request handling (see `in_app_webview.cc:3379`)
- Find result handling (see `in_app_webview.cc:3382`)

## Dependencies
The example includes WPE WebKit source for reference. Production apps need:
- `libwpe` 
- `wpebackend-fdo`
- `wpewebkit`
