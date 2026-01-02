---
applyTo: "flutter_inappwebview_macos/**"
---

# macOS Platform Implementation Instructions

## Implemented Dart Classes

| Class | File | Description |
|-------|------|-------------|
| `MacOSInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers all macOS implementations |
| `MacOSInAppWebView` | `in_app_webview/in_app_webview.dart` | WebView widget using `AppKitView` |
| `MacOSInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | WebView controller |
| `MacOSHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Offscreen WebView |
| `MacOSInAppBrowser` | `in_app_browser/` | Browser window |
| `MacOSCookieManager` | `cookie_manager.dart` | WKHTTPCookieStore wrapper |
| `MacOSWebStorage` | `web_storage/` | WKWebsiteDataStore wrapper |
| `MacOSFindInteractionController` | `find_interaction/` | Find-in-page |
| `MacOSPrintJobController` | `print_job/` | NSPrintOperation wrapper |
| `MacOSWebMessageChannel/Port/Listener` | `web_message/` | WKScriptMessageHandler |
| `MacOSWebAuthenticationSession` | `web_authentication_session/` | ASWebAuthenticationSession |
| `MacOSHttpAuthCredentialDatabase` | `http_auth_credentials_database.dart` | URLCredentialStorage |
| `MacOSProxyController` | `proxy_controller.dart` | Proxy settings |

## Native Code Structure

```
macos/Classes/
├── InAppWebViewFlutterPlugin.swift    # Plugin entry point
├── MyCookieManager.swift              # WKHTTPCookieStore wrapper
├── MyWebStorageManager.swift          # WKWebsiteDataStore wrapper
├── CredentialDatabase.swift           # URLCredentialStorage wrapper
├── ProxyManager.swift                 # Proxy configuration
├── WKProcessPoolManager.swift         # Process pool management
├── LeakAvoider.swift                  # Memory leak prevention
├── PlatformUtil.swift                 # Platform utilities
├── Util.swift                         # General utilities
├── InAppWebView/                      # Core WebView (similar to iOS)
│   ├── InAppWebView.swift             # WKWebView subclass
│   ├── FlutterWebViewController.swift # ViewController
│   ├── FlutterWebViewFactory.swift    # PlatformView factory
│   └── WebViewChannelDelegate.swift   # Dart-native bridge
├── InAppBrowser/                      # NSWindow-based browser
├── HeadlessInAppWebView/              # Offscreen WebView
├── WebAuthenticationSession/          # ASWebAuthenticationSession
├── FindInteraction/                   # Find-in-page
├── PrintJob/                          # NSPrintOperation
├── Types/                             # Type definitions
└── PluginScriptsJS/                   # Injected JavaScript
```

**Note**: macOS shares significant code patterns with iOS but uses AppKit instead of UIKit.

## Platform Requirements
- macOS 10.14+
- Xcode version >= 15.0

## Native APIs Used
- [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)
- Uses `AppKitView` for rendering (different from iOS's `UiKitView`)

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Extend `Platform*CreationParams` for macOS-specific parameters
3. macOS-specific features: `WebAuthenticationSession`, window management

## Native Code Development

When modifying Swift code:
- Located in `macos/Classes/`
- Shares significant code patterns with iOS
- Main differences: AppKit vs UIKit, window handling

## Build Commands
```bash
cd flutter_inappwebview_macos && flutter pub get
cd example && flutter build macos --debug
```

## macOS Sandbox Entitlements
Apps need entitlements for:
- Network access (client/server)
- File access if using file URLs
