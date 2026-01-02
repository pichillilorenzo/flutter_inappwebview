---
applyTo: "flutter_inappwebview_android/**"
---

# Android Platform Implementation Instructions

## Implemented Dart Classes

| Class | File | Description |
|-------|------|-------------|
| `AndroidInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers all Android implementations |
| `AndroidInAppWebView` | `in_app_webview/in_app_webview.dart` | WebView widget using `PlatformViewLink` |
| `AndroidInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | WebView controller with MethodChannel |
| `AndroidHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Offscreen WebView |
| `AndroidInAppBrowser` | `in_app_browser/` | Full-screen browser window |
| `AndroidChromeSafariBrowser` | `chrome_safari_browser/` | Chrome Custom Tabs wrapper |
| `AndroidCookieManager` | `cookie_manager.dart` | Cookie management |
| `AndroidWebStorage` | `web_storage/` | Local/session storage |
| `AndroidFindInteractionController` | `find_interaction/` | Find-in-page |
| `AndroidPrintJobController` | `print_job/` | Print functionality |
| `AndroidPullToRefreshController` | `pull_to_refresh/` | Pull-to-refresh gesture |
| `AndroidWebMessageChannel/Port/Listener` | `web_message/` | postMessage API |
| `AndroidHttpAuthCredentialDatabase` | `http_auth_credentials_database.dart` | Auth credential storage |
| `AndroidProcessGlobalConfig` | `process_global_config.dart` | WebView process config |
| `AndroidProxyController` | `proxy_controller.dart` | Proxy settings |
| `AndroidServiceWorkerController` | `service_worker_controller.dart` | Service worker control |
| `AndroidTracingController` | `tracing_controller.dart` | WebView tracing |
| `AndroidWebViewFeature` | `webview_feature.dart` | Feature detection |

## Native Code Structure

```
android/src/main/java/com/pichillilorenzo/flutter_inappwebview_android/
├── InAppWebViewFlutterPlugin.java    # Plugin entry point
├── MyCookieManager.java              # Cookie management
├── MyWebStorage.java                 # Storage APIs
├── PlatformUtil.java                 # Platform utilities
├── WebViewFeatureManager.java        # Feature detection
├── webview/                          # Core WebView
│   ├── InAppWebViewInterface.java    # WebView interface
│   ├── PlatformWebView.java          # Base WebView class
│   ├── WebViewChannelDelegate.java   # Dart-native bridge
│   ├── FlutterWebViewFactory.java    # PlatformView factory
│   ├── in_app_webview/               # InAppWebView implementation
│   └── web_message/                  # WebMessage implementation
├── chrome_custom_tabs/               # Chrome Custom Tabs
├── in_app_browser/                   # InAppBrowser activity
├── headless_in_app_webview/          # Headless WebView
├── find_interaction/                 # Find in page
├── print_job/                        # Printing
├── pull_to_refresh/                  # SwipeRefreshLayout
├── service_worker/                   # Service workers
├── tracing/                          # WebView tracing
├── proxy/                            # Proxy configuration
├── credential_database/              # Credential storage
├── process_global_config/            # Process configuration
├── content_blocker/                  # Content blocking
├── types/                            # Type definitions
└── plugin_scripts_js/                # Injected JavaScript
```

## Platform Requirements
- `minSdkVersion >= 19`
- `compileSdk >= 34`
- AGP version `>= 7.3.0`
- AndroidX support required

## Native APIs Used
- [android.webkit.WebView](https://developer.android.com/reference/android/webkit/WebView)
- Uses `PlatformViewLink` and `AndroidViewSurface` for rendering

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Extend `Platform*CreationParams` for Android-specific parameters
3. Register in `AndroidInAppWebViewPlatform.registerWith()`
4. For unsupported features, create private stub classes

## Native Code Development

When modifying native Java/Kotlin code:
- Located in `android/src/main/java/`
- Use MethodChannel for Dart-native communication
- Follow existing patterns for WebView callbacks
- Test with Android emulator or physical device

## Build Commands
```bash
cd flutter_inappwebview_android && flutter pub get
cd example && flutter build apk --debug
```
