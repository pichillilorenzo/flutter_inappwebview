---
applyTo: "flutter_inappwebview_web/**"
---

# Web Platform Implementation Instructions

## Implemented Dart Classes

Web has the most limited feature set due to browser security restrictions:

| Class | File | Description |
|-------|------|-------------|
| `WebInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers Web implementations |
| `WebInAppWebView` | `in_app_webview/in_app_webview.dart` | iframe using `HtmlElementView` |
| `WebInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | Limited iframe controller |
| `WebHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Hidden iframe |
| `WebCookieManager` | `cookie_manager.dart` | document.cookie wrapper (same-origin only) |
| `WebLocalStorage` | `web_storage/` | window.localStorage wrapper |
| `WebSessionStorage` | `web_storage/` | window.sessionStorage wrapper |

**Not implemented (browser limitations)**: InAppBrowser, ChromeSafariBrowser, FindInteraction, PrintJob, PullToRefresh, WebMessage (cross-origin), HttpAuthCredentialDatabase, ProxyController, ProcessGlobalConfig, ServiceWorkerController, TracingController.

## Source Structure

```
lib/src/
├── inappwebview_platform.dart   # Platform factory
├── main.dart                    # Exports
├── platform_util.dart           # Web platform utilities
├── cookie_manager.dart          # document.cookie wrapper
├── in_app_webview/              # Core iframe implementation
│   ├── in_app_webview.dart      # HtmlElementView with iframe
│   ├── in_app_webview_controller.dart  # postMessage-based control
│   └── headless_in_app_webview.dart
└── web_storage/                 # localStorage/sessionStorage
```

## Platform Approach
- Uses `HtmlElementView` to embed an `<iframe>` element
- Most features are limited due to browser security (same-origin policy)
- No native code - pure Dart/JavaScript implementation

## Native APIs Used
- [HTMLIFrameElement](https://developer.mozilla.org/en-US/docs/Web/API/HTMLIFrameElement)

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Web has significantly fewer features than native platforms
3. Main limitations:
   - No JavaScript injection across origins
   - No cookie management across origins
   - No request interception
   - Limited to iframe sandboxing rules

## Available Features
- Basic URL loading
- Local/session storage (same-origin only)
- Basic cookie management (same-origin only)

## Build Commands
```bash
cd flutter_inappwebview_web && flutter pub get
cd example && flutter build web --debug
```

## JavaScript Interop
Located in `web_support/src/` at repo root:
- Contains TypeScript source for web-specific functionality
- Compiled JavaScript is bundled with the package
