---
applyTo: "flutter_inappwebview_ios/**"
---

# iOS Platform Implementation Instructions

## Implemented Dart Classes

| Class | File | Description |
|-------|------|-------------|
| `IOSInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers all iOS implementations |
| `IOSInAppWebView` | `in_app_webview/in_app_webview.dart` | WebView widget using `UiKitView` |
| `IOSInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | WebView controller |
| `IOSHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Offscreen WebView |
| `IOSInAppBrowser` | `in_app_browser/` | Full-screen browser |
| `IOSChromeSafariBrowser` | `chrome_safari_browser/` | SFSafariViewController wrapper |
| `IOSCookieManager` | `cookie_manager.dart` | WKHTTPCookieStore wrapper |
| `IOSWebStorage` | `web_storage/` | WKWebsiteDataStore wrapper |
| `IOSFindInteractionController` | `find_interaction/` | UIFindInteraction wrapper |
| `IOSPrintJobController` | `print_job/` | UIPrintInteractionController |
| `IOSPullToRefreshController` | `pull_to_refresh/` | UIRefreshControl |
| `IOSWebMessageChannel/Port/Listener` | `web_message/` | WKScriptMessageHandler |
| `IOSWebAuthenticationSession` | `web_authentication_session/` | ASWebAuthenticationSession |
| `IOSHttpAuthCredentialDatabase` | `http_auth_credentials_database.dart` | URLCredentialStorage |
| `IOSProxyController` | `proxy_controller.dart` | Proxy settings |

## Native Code Structure

```
ios/Classes/
├── InAppWebViewFlutterPlugin.m/.h     # Plugin entry (Obj-C bridge)
├── SwiftFlutterPlugin.swift           # Swift plugin implementation
├── MyCookieManager.swift              # WKHTTPCookieStore wrapper
├── MyWebStorageManager.swift          # WKWebsiteDataStore wrapper
├── CredentialDatabase.swift           # URLCredentialStorage wrapper
├── ProxyManager.swift                 # Proxy configuration
├── WKProcessPoolManager.swift         # Process pool management
├── LeakAvoider.swift                  # Memory leak prevention
├── PlatformUtil.swift                 # Platform utilities
├── Util.swift                         # General utilities
├── InAppWebView/                      # Core WebView
│   ├── InAppWebView.swift             # WKWebView subclass
│   ├── InAppWebViewSettings.swift     # Settings mapping
│   ├── FlutterWebViewController.swift # ViewController
│   ├── FlutterWebViewFactory.swift    # PlatformView factory
│   ├── WebViewChannelDelegate.swift   # Dart-native bridge
│   ├── CustomSchemeHandler.swift      # Custom URL schemes
│   └── WebMessage/                    # WKScriptMessageHandler
├── InAppBrowser/                      # Browser ViewController
├── HeadlessInAppWebView/              # Offscreen WebView
├── SafariViewController/              # SFSafariViewController
├── WebAuthenticationSession/          # ASWebAuthenticationSession
├── FindInteraction/                   # UIFindInteraction
├── PrintJob/                          # UIPrintInteractionController
├── PullToRefresh/                     # UIRefreshControl
├── Types/                             # Type definitions
├── PluginScriptsJS/                   # Injected JavaScript
└── UIApplication/                     # Application utilities
```

## Platform Requirements
- iOS 12.0+
- Xcode version >= 15.0
- Swift language support required

## Native APIs Used
- [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)
- Uses `UiKitView` for rendering

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Extend `Platform*CreationParams` for iOS-specific parameters
3. Register in `IOSInAppWebViewPlatform.registerWith()`
4. iOS-specific features: `WebAuthenticationSession`, Safari-style callbacks

## Native Code Development

When modifying Swift/Obj-C code:
- Located in `ios/Classes/`
- Main plugin class: `InAppWebViewFlutterPlugin`
- Use FlutterMethodChannel for Dart-native communication
- Common workarounds exist for SSL certificate handling (see `WebViewChannelDelegate.swift`)

## Build Commands
```bash
cd flutter_inappwebview_ios && flutter pub get
cd example && flutter build ios --debug --no-codesign
```

## Info.plist Requirements
Apps may need to add:
- `NSAppTransportSecurity` for HTTP URLs
- Camera/microphone permissions for WebRTC
