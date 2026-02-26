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
| `MacOSInAppBrowser` | `in_app_browser/` | Full-screen browser window |
| `MacOSCookieManager` | `cookie_manager.dart` | WKHTTPCookieStore wrapper |
| `MacOSWebStorage` | `web_storage/` | WKWebsiteDataStore wrapper |
| `MacOSFindInteractionController` | `find_interaction/` | NSFindPanelAction wrapper |
| `MacOSPrintJobController` | `print_job/` | NSPrintOperation wrapper |
| `MacOSWebMessageChannel/Port/Listener` | `web_message/` | WKScriptMessageHandler |
| `MacOSHttpAuthCredentialDatabase` | `http_auth_credentials_database.dart` | URLCredentialStorage |

---

## Native Code Structure

```
macos/Classes/
├── InAppWebViewFlutterPlugin.swift      # Plugin entry/registration
│
├── MyCookieManager.swift                # WKHTTPCookieStore wrapper
├── MyWebStorageManager.swift            # WKWebsiteDataStore wrapper
├── CredentialDatabase.swift             # URLCredentialStorage wrapper
├── ProxyManager.swift                   # Proxy configuration
├── WKProcessPoolManager.swift           # Process pool management
│
├── LeakAvoider.swift                    # Memory leak prevention helper
├── PlatformUtil.swift                   # Platform utilities (date formatting, system version)
├── Util.swift                           # General utilities (see below)
├── ISettings.swift                      # Settings protocol
│
├── InAppWebView/                        # Core WKWebView implementation
│   ├── InAppWebView.swift               # WKWebView subclass (main implementation)
│   ├── InAppWebViewManager.swift        # WebView instance management
│   ├── InAppWebViewSettings.swift       # Settings mapping to WKWebView
│   ├── FlutterWebViewController.swift   # ViewController for platform view
│   ├── FlutterWebViewFactory.swift      # PlatformView factory
│   ├── WebViewChannelDelegate.swift     # Dart-native bridge (MethodChannel)
│   ├── WebViewChannelDelegateMethods.swift # Channel delegate method implementations
│   ├── ContextMenuSettings.swift        # Context menu settings
│   ├── CustomSchemeHandler.swift        # Custom URL scheme handling
│   │
│   └── WebMessage/                      # WKScriptMessageHandler implementation
│       ├── WebMessageChannel.swift      # WebMessageChannel wrapper
│       ├── WebMessageChannelChannelDelegate.swift # Channel communication
│       ├── WebMessageListener.swift     # WebMessageListener implementation
│       └── WebMessageListenerChannelDelegate.swift # Listener channel
│
├── HeadlessInAppWebView/                # Offscreen WebView
│   ├── HeadlessInAppWebView.swift       # Headless WebView implementation
│   ├── HeadlessInAppWebViewManager.swift # Instance management
│   └── HeadlessWebViewChannelDelegate.swift # Channel delegate for headless
│
├── InAppBrowser/                        # Browser NSWindow/NSWindowController
│   ├── InAppBrowserWebViewController.swift # Browser view controller
│   ├── InAppBrowserManager.swift        # Instance management
│   ├── InAppBrowserWindow.swift         # NSWindow subclass
│   ├── InAppBrowserSettings.swift       # Browser settings
│   ├── InAppBrowserChannelDelegate.swift # Channel communication
│   └── InAppBrowserDelegate.swift       # Browser delegate protocol
│
├── FindInteraction/                     # NSFindPanelAction
│   ├── FindInteractionChannelDelegate.swift # Channel communication
│   ├── FindInteractionController.swift  # Find controller
│   └── FindInteractionSettings.swift    # Find settings
│
├── PrintJob/                            # NSPrintOperation
│   ├── CustomUIPrintPageRenderer.swift  # Custom page renderer
│   ├── PrintAttributes.swift            # Print attributes
│   ├── PrintJobChannelDelegate.swift    # Channel communication
│   ├── PrintJobController.swift         # Print job controller
│   ├── PrintJobInfo.swift               # Print job info
│   ├── PrintJobManager.swift            # Instance management
│   └── PrintJobSettings.swift           # Print settings
│
├── WebAuthenticationSession/            # ASWebAuthenticationSession (macOS 10.15+)
│   ├── WebAuthenticationSession.swift   # Session wrapper
│   ├── WebAuthenticationSessionChannelDelegate.swift # Channel communication
│   ├── WebAuthenticationSessionManager.swift # Instance management
│   └── WebAuthenticationSessionSettings.swift # Session settings
│
├── PluginScriptsJS/                     # Injected JavaScript for bridge
│   ├── CallAsyncJavaScriptBelowIOS14WrapperJS.swift # Async JS wrapper for older macOS
│   ├── ConsoleLogJS.swift               # Console interception
│   ├── EnableViewportScaleJS.swift      # Viewport scaling
│   ├── FindElementsAtPointJS.swift      # Hit-test elements
│   ├── FindTextHighlightJS.swift        # Text search highlighting
│   ├── InterceptAjaxRequestJS.swift     # AJAX interception
│   ├── InterceptFetchRequestJS.swift    # Fetch API interception
│   ├── JavaScriptBridgeJS.swift         # Core JS bridge
│   ├── OnLoadResourceJS.swift           # Resource loading tracking
│   ├── OnScrollChangedJS.swift          # Scroll event tracking (macOS-specific)
│   ├── OnWindowBlurEventJS.swift        # Window blur event
│   ├── OnWindowFocusEventJS.swift       # Window focus event
│   ├── OriginalViewPortMetaTagContentJS.swift # Viewport meta capture
│   ├── PluginScriptsUtil.swift          # Script utilities
│   ├── PrintJS.swift                    # Print handling
│   ├── PromisePolyfillJS.swift          # Promise polyfill
│   ├── SupportZoomJS.swift              # Zoom control
│   ├── WebMessageChannelJS.swift        # WebMessage channel variables
│   ├── WebMessageListenerJS.swift       # PostMessage API
│   └── WindowIdJS.swift                 # Window ID management
│
└── Types/                               # Type definitions
```

---

## Platform Requirements

- macOS 10.14+
- Xcode version >= 15.0
- Swift language support required

## Native APIs Used

- [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)
- Uses `AppKitView` for rendering (not UiKitView like iOS)

---

## Swift Utilities Reference

### `Util.swift` - General Utilities

| Method | Description |
|--------|-------------|
| `Util.getUrlAsset(plugin:assetFilePath:)` | Get URL for Flutter asset file |
| `Util.getAbsPathAsset(plugin:assetFilePath:)` | Get absolute path for Flutter asset |
| `Util.convertToDictionary(text:)` | Convert JSON string to Dictionary |
| `Util.JSONStringify(value:prettyPrinted:)` | Convert value to JSON string |
| `Util.getContentWorld(name:)` | Get WKContentWorld by name (macOS 11+) |
| `Util.isIPv4(address:)` | Check if string is IPv4 address |
| `Util.isIPv6(address:)` | Check if string is IPv6 address |
| `Util.isIpAddress(address:)` | Check if string is IP address |
| `Util.normalizeIPv6(address:)` | Normalize IPv6 address to full form |

**Usage:**
```swift
// Asset loading
let url = try Util.getUrlAsset(plugin: plugin, assetFilePath: "assets/page.html")

// JSON handling
let dict = Util.convertToDictionary(text: jsonString)
let json = Util.JSONStringify(value: myDict, prettyPrinted: true)

// Content worlds (macOS 11+)
let world = Util.getContentWorld(name: "myWorld")

// IP validation
if Util.isIpAddress(address: host) { ... }
```

**Note:** macOS does not have `UIScrollView.DecelerationRate` or `WKDataDetectorTypes`, so those utilities are iOS-only.

---

### `PlatformUtil.swift` - Platform Utilities

| Method | Description |
|--------|-------------|
| `PlatformUtil.getSystemVersion()` | Get macOS version string |
| `PlatformUtil.getLocaleFromString(locale:)` | Convert locale string to Locale |
| `PlatformUtil.getDateFromMilliseconds(date:)` | Convert milliseconds to Date |
| `PlatformUtil.formatDate(date:format:locale:timezone:)` | Format date with locale/timezone |

**Usage:**
```swift
let version = ProcessInfo.processInfo.operatingSystemVersionString
let locale = PlatformUtil.getLocaleFromString(locale: "en_US")
let formatted = PlatformUtil.formatDate(date: timestamp, format: "yyyy-MM-dd", locale: locale, timezone: .current)
```

---

### `LeakAvoider.swift` - Memory Leak Prevention

Used to prevent retain cycles with WKWebView delegates:

```swift
// LeakAvoider wraps the actual delegate to prevent retain cycles
let leakAvoider = LeakAvoider(delegate: self)
configuration.userContentController.add(leakAvoider, name: "handler")
```

---

### `WKProcessPoolManager.swift` - Process Pool Management

Manages shared WKProcessPool instances for session sharing across WebViews:

| Property/Method | Description |
|-----------------|-------------|
| `WKProcessPoolManager.shared` | Singleton instance |
| `getProcessPool(processPoolId:)` | Get/create process pool by ID |

---

### Common Swift Patterns

#### FlutterMethodChannel Response

```swift
public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any]
    
    switch call.method {
    case "myMethod":
        let param = arguments?["param"] as? String ?? ""
        // Do work...
        result(returnValue)
    default:
        result(FlutterMethodNotImplemented)
    }
}
```

#### Converting to Flutter Map

```swift
public func toMap() -> [String: Any?] {
    return [
        "field1": field1,
        "field2": field2,
        "optionalField": optionalField  // nil becomes null in Dart
    ]
}
```

#### Parsing from Flutter Map

```swift
public static func fromMap(map: [String: Any?]?) -> MyType? {
    guard let map = map else { return nil }
    return MyType(
        field1: map["field1"] as? String ?? "",
        field2: map["field2"] as? Int ?? 0,
        optionalField: map["optionalField"] as? String
    )
}
```

---

## macOS vs iOS Differences

| Aspect | iOS | macOS |
|--------|-----|-------|
| View Type | `UiKitView` | `AppKitView` |
| Browser Window | UIViewController | NSWindow/NSWindowController |
| Find Panel | UIFindInteraction | NSFindPanelAction |
| Print | UIPrintInteractionController | NSPrintOperation |
| Scroll Deceleration | UIScrollView.DecelerationRate | Not applicable |
| Data Detectors | WKDataDetectorTypes | Not applicable |
| Safari Browser | SFSafariViewController | Not available |
| WebAuthSession | ASWebAuthenticationSession | Not implemented |

---

## Plugin Scripts JS Reference

JavaScript files injected into WebViews for native-web communication:

| Script | File | Description |
|--------|------|-------------|
| **JavaScriptBridgeJS** | `JavaScriptBridgeJS.swift` | Core bridge enabling `window.flutter_inappwebview.callHandler()` for Dart-JS communication. |
| **ConsoleLogJS** | `ConsoleLogJS.swift` | Intercepts `console.log/debug/error/info/warn` and forwards to `onConsoleMessage`. |
| **InterceptAjaxRequestJS** | `InterceptAjaxRequestJS.swift` | Wraps `XMLHttpRequest` to intercept AJAX requests. |
| **InterceptFetchRequestJS** | `InterceptFetchRequestJS.swift` | Wraps `window.fetch()` to intercept Fetch API requests. |
| **OnLoadResourceJS** | `OnLoadResourceJS.swift` | Uses `PerformanceObserver` to track resource loading. |
| **OnScrollChangedJS** | `OnScrollChangedJS.swift` | Listens for scroll events and triggers `onScrollChanged` callback (macOS-specific). |
| **PrintJS** | `PrintJS.swift` | Overrides `window.print()` to trigger `onPrintRequest` callback. |
| **PromisePolyfillJS** | `PromisePolyfillJS.swift` | Polyfill for `Promise` API on older WebKit versions. |
| **FindTextHighlightJS** | `FindTextHighlightJS.swift` | JavaScript-based text search and highlighting. |
| **WebMessageListenerJS** | `WebMessageListenerJS.swift` | Implements `FlutterInAppWebViewWebMessageListener` for `postMessage` API. |
| **WebMessageChannelJS** | `WebMessageChannelJS.swift` | Variable definitions for `WebMessageChannel` ports. |
| **EnableViewportScaleJS** | `EnableViewportScaleJS.swift` | Adds viewport meta tag for viewport scaling. |
| **SupportZoomJS** | `SupportZoomJS.swift` | Modifies viewport meta tag for zoom control. |
| **FindElementsAtPointJS** | `FindElementsAtPointJS.swift` | Hit-test to find elements at coordinates. |
| **OriginalViewPortMetaTagContentJS** | `OriginalViewPortMetaTagContentJS.swift` | Captures original viewport meta tag. |
| **OnWindowBlurEventJS** | `OnWindowBlurEventJS.swift` | Triggers `onWindowBlur` callback. |
| **OnWindowFocusEventJS** | `OnWindowFocusEventJS.swift` | Triggers `onWindowFocus` callback. |
| **WindowIdJS** | `WindowIdJS.swift` | Manages window ID for multi-window scenarios. |
| **CallAsyncJavaScriptBelowIOS14WrapperJS** | `CallAsyncJavaScript...swift` | Wrapper for `callAsyncJavaScript` on older macOS. |

**Note:** macOS does not have `LastTouchedAnchorOrImageJS` (touch-specific) but adds `OnScrollChangedJS` for scroll tracking.

---

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Extend `Platform*CreationParams` for macOS-specific parameters
3. Register in `MacOSInAppWebViewPlatform.registerWith()`
4. Note: macOS lacks `ChromeSafariBrowser` and `WebAuthenticationSession`

## Native Code Development

When modifying Swift code:
- Located in `macos/Classes/`
- Main plugin class: `InAppWebViewFlutterPlugin`
- Use FlutterMethodChannel for Dart-native communication
- macOS uses AppKit (NSWindow, NSView) vs iOS UIKit (UIWindow, UIView)

## Build Commands

```bash
cd flutter_inappwebview_macos && flutter pub get
cd example && flutter build macos --debug
```

## Entitlements

Apps may need to add entitlements:
- `com.apple.security.network.client` - Network access
- `com.apple.security.network.server` - Local server access
- App Sandbox entitlements for file access

## Debugging & Inspection

- **Safari Web Inspector**:
  - Enable "Web Inspector" in Safari settings (Preferences > Advanced).
  - Open Safari > Develop > [Computer Name] > [Page Title].
- **Inspectable API**:
  - For macOS 13.3+, `isInspectable` setting must be `true` (default in debug builds).
- **Logs**: Use `print()` in Swift.

