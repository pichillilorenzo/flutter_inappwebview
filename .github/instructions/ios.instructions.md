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

---

## Native Code Structure

```
ios/Classes/
├── InAppWebViewFlutterPlugin.m/h        # Plugin entry (Obj-C bridge)
├── SwiftFlutterPlugin.swift             # Swift plugin implementation
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
├── InAppBrowser/                        # Browser ViewController
│   ├── InAppBrowserWebViewController.swift # Browser view controller
│   ├── InAppBrowserManager.swift        # Instance management
│   ├── InAppBrowserNavigationController.swift # Navigation controller
│   ├── InAppBrowserSettings.swift       # Browser settings
│   ├── InAppBrowserChannelDelegate.swift # Channel communication
│   └── InAppBrowserDelegate.swift       # Browser delegate protocol
│
├── SafariViewController/                # SFSafariViewController wrapper
│   ├── ChromeSafariBrowserManager.swift # Instance management
│   ├── CustomUIActivity.swift           # Custom share activity
│   ├── SafariBrowserSettings.swift      # Safari browser settings
│   ├── SafariViewController.swift       # SFSafariViewController wrapper
│   └── SafariViewControllerChannelDelegate.swift # Channel communication
│
├── WebAuthenticationSession/            # ASWebAuthenticationSession
│   ├── WebAuthenticationSession.swift   # Session wrapper
│   ├── WebAuthenticationSessionChannelDelegate.swift # Channel communication
│   ├── WebAuthenticationSessionManager.swift # Instance management
│   └── WebAuthenticationSessionSettings.swift # Session settings
│
├── FindInteraction/                     # UIFindInteraction
│   ├── FindInteractionChannelDelegate.swift # Channel communication
│   ├── FindInteractionController.swift  # Find controller
│   └── FindInteractionSettings.swift    # Find settings
│
├── PrintJob/                            # UIPrintInteractionController
│   ├── CustomUIPrintPageRenderer.swift  # Custom page renderer
│   ├── PrintAttributes.swift            # Print attributes
│   ├── PrintJobChannelDelegate.swift    # Channel communication
│   ├── PrintJobController.swift         # Print job controller
│   ├── PrintJobInfo.swift               # Print job info
│   ├── PrintJobManager.swift            # Instance management
│   └── PrintJobSettings.swift           # Print settings
│
├── PullToRefresh/                       # UIRefreshControl
│   ├── PullToRefreshChannelDelegate.swift # Channel communication
│   ├── PullToRefreshControl.swift       # Refresh control wrapper
│   ├── PullToRefreshDelegate.swift      # Refresh delegate
│   └── PullToRefreshSettings.swift      # Refresh settings
│
├── PluginScriptsJS/                     # Injected JavaScript for bridge
│   ├── CallAsyncJavaScriptBelowIOS14WrapperJS.swift # Async JS wrapper for older iOS
│   ├── ConsoleLogJS.swift               # Console interception
│   ├── EnableViewportScaleJS.swift      # Viewport scaling
│   ├── FindElementsAtPointJS.swift      # Hit-test elements
│   ├── FindTextHighlightJS.swift        # Text search highlighting
│   ├── InterceptAjaxRequestJS.swift     # AJAX interception
│   ├── InterceptFetchRequestJS.swift    # Fetch API interception
│   ├── JavaScriptBridgeJS.swift         # Core JS bridge
│   ├── LastTouchedAnchorOrImageJS.swift # Touch tracking for context menu
│   ├── OnLoadResourceJS.swift           # Resource loading tracking
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
├── UIApplication/                       # Application utilities
│   └── VisibleViewController.swift      # Get visible view controller
│
└── Types/                               # Type definitions
```

---

## Platform Requirements

- iOS 12.0+
- Xcode version >= 15.0
- Swift language support required

## Native APIs Used

- [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)
- Uses `UiKitView` for rendering

---

## Swift Utilities Reference

### `Util.swift` - General Utilities

| Method | Description |
|--------|-------------|
| `Util.getUrlAsset(plugin:assetFilePath:)` | Get URL for Flutter asset file |
| `Util.getAbsPathAsset(plugin:assetFilePath:)` | Get absolute path for Flutter asset |
| `Util.convertToDictionary(text:)` | Convert JSON string to Dictionary |
| `Util.JSONStringify(value:prettyPrinted:)` | Convert value to JSON string |
| `Util.getContentWorld(name:)` | Get WKContentWorld by name (iOS 14+) |
| `Util.getDataDetectorType(type:)` | Convert string to WKDataDetectorTypes |
| `Util.getDataDetectorTypeString(type:)` | Convert WKDataDetectorTypes to strings |
| `Util.getDecelerationRate(type:)` | Get UIScrollView.DecelerationRate |
| `Util.getDecelerationRateString(type:)` | Convert DecelerationRate to string |
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

// Content worlds (iOS 14+)
let world = Util.getContentWorld(name: "myWorld")

// IP validation
if Util.isIpAddress(address: host) { ... }
```

---

### `PlatformUtil.swift` - Platform Utilities

| Method | Description |
|--------|-------------|
| `PlatformUtil.getSystemVersion()` | Get iOS version string |
| `PlatformUtil.getLocaleFromString(locale:)` | Convert locale string to Locale |
| `PlatformUtil.getDateFromMilliseconds(date:)` | Convert milliseconds to Date |
| `PlatformUtil.formatDate(date:format:locale:timezone:)` | Format date with locale/timezone |

**Usage:**
```swift
let version = UIDevice.current.systemVersion
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
    let arguments = call.arguments as? NSDictionary
    
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

## Plugin Scripts JS Reference

JavaScript files injected into WebViews for native-web communication:

| Script | File | Description |
|--------|------|-------------|
| **JavaScriptBridgeJS** | `JavaScriptBridgeJS.swift` | Core bridge enabling `window.flutter_inappwebview.callHandler()` for Dart-JS communication. Sets up Promise-based message passing via `WKScriptMessageHandler`. |
| **ConsoleLogJS** | `ConsoleLogJS.swift` | Intercepts `console.log/debug/error/info/warn` and forwards messages to `onConsoleMessage` callback. Main frame only. |
| **InterceptAjaxRequestJS** | `InterceptAjaxRequestJS.swift` | Wraps `XMLHttpRequest` to intercept AJAX requests. Enables `shouldInterceptAjaxRequest`, `onAjaxReadyStateChange`, `onAjaxProgress` callbacks. |
| **InterceptFetchRequestJS** | `InterceptFetchRequestJS.swift` | Wraps `window.fetch()` to intercept Fetch API requests. Enables `shouldInterceptFetchRequest` callback. |
| **OnLoadResourceJS** | `OnLoadResourceJS.swift` | Uses `PerformanceObserver` to track resource loading (images, scripts, etc.). Enables `onLoadResource` callback. |
| **PrintJS** | `PrintJS.swift` | Overrides `window.print()` to trigger `onPrintRequest` callback instead of native print dialog. |
| **PromisePolyfillJS** | `PromisePolyfillJS.swift` | Polyfill for `Promise` API on older WebKit versions using RSVP.js library. |
| **FindTextHighlightJS** | `FindTextHighlightJS.swift` | JavaScript-based text search and highlighting for `FindInteractionController`. Highlights matches with CSS spans. |
| **WebMessageListenerJS** | `WebMessageListenerJS.swift` | Implements `FlutterInAppWebViewWebMessageListener` class for `postMessage` API. |
| **WebMessageChannelJS** | `WebMessageChannelJS.swift` | Variable definitions for `WebMessageChannel` ports storage. |
| **EnableViewportScaleJS** | `EnableViewportScaleJS.swift` | Adds viewport meta tag with `width=device-width` when `enableViewportScale` is true. |
| **SupportZoomJS** | `SupportZoomJS.swift` | Modifies viewport meta tag to disable/enable user zooming via `user-scalable=no`. |
| **LastTouchedAnchorOrImageJS** | `LastTouchedAnchorOrImageJS.swift` | Tracks touch events on links/images for context menu. Stores last touched anchor/image info. |
| **FindElementsAtPointJS** | `FindElementsAtPointJS.swift` | Implements hit-test to find elements at coordinates. Returns element type (image, link, input, etc.). |
| **OriginalViewPortMetaTagContentJS** | `OriginalViewPortMetaTagContentJS.swift` | Captures original viewport meta tag content before modifications. |
| **OnWindowBlurEventJS** | `OnWindowBlurEventJS.swift` | Listens for `blur` event on window and triggers `onWindowBlur` callback. |
| **OnWindowFocusEventJS** | `OnWindowFocusEventJS.swift` | Listens for `focus` event on window and triggers `onWindowFocus` callback. |
| **WindowIdJS** | `WindowIdJS.swift` | Manages window ID for multi-window scenarios (e.g., `window.open()`). |
| **CallAsyncJavaScriptBelowIOS14WrapperJS** | `CallAsyncJavaScript...swift` | Wrapper for `callAsyncJavaScript` on iOS versions below 14 that don't support native API. |

---

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
- `NSFaceIDUsageDescription` if using Face ID authentication

## Debugging & Inspection

- **Safari Web Inspector**:
  - Enable "Web Inspector" in Safari settings on your Mac (Preferences > Advanced).
  - Enable "Web Inspector" on your iOS device (Settings > Safari > Advanced).
  - Connect device via USB.
  - Open Safari on Mac > Develop > [Device Name] > [Page Title].
- **Inspectable API**:
  - For iOS 16.4+, `isInspectable` setting must be `true` (default in debug builds).
- **Logs**: Use `print()` in Swift or `NSLog` in Obj-C.

