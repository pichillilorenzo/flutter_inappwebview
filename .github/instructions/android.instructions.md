---
applyTo: "flutter_inappwebview_android/**"
---

# Android Platform Implementation Instructions

## Implemented Dart Classes

| Class | File | Description |
|-------|------|-------------|
| `AndroidInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers all Android implementations |
| `AndroidInAppWebView` | `in_app_webview/in_app_webview.dart` | WebView widget using `AndroidView` |
| `AndroidInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | WebView controller |
| `AndroidHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Offscreen WebView |
| `AndroidInAppBrowser` | `in_app_browser/` | Activity-based browser |
| `AndroidChromeSafariBrowser` | `chrome_safari_browser/` | Chrome Custom Tabs wrapper |
| `AndroidCookieManager` | `cookie_manager.dart` | CookieManager wrapper |
| `AndroidWebStorage` | `web_storage/` | WebStorage wrapper |
| `AndroidFindInteractionController` | `find_interaction/` | Find in page |
| `AndroidPrintJobController` | `print_job/` | PrintDocumentAdapter |
| `AndroidPullToRefreshController` | `pull_to_refresh/` | SwipeRefreshLayout |
| `AndroidWebMessageChannel/Port/Listener` | `web_message/` | WebMessagePort |
| `AndroidHttpAuthCredentialDatabase` | `http_auth_credentials_database.dart` | WebViewDatabase |
| `AndroidProxyController` | `proxy_controller.dart` | ProxyController |
| `AndroidServiceWorkerController` | `service_worker_controller.dart` | ServiceWorkerController |
| `AndroidTracingController` | `tracing_controller.dart` | TracingController |
| `AndroidProcessGlobalConfig` | `process_global_config.dart` | ProcessGlobalConfig |
| `AndroidWebViewFeature` | `webview_feature.dart` | AndroidX WebView features |

---

## Native Code Structure

```
android/src/main/java/com/.../flutter_inappwebview_android/
├── InAppWebViewFlutterPlugin.java       # Plugin entry/registration
├── InAppWebViewFileProvider.java        # FileProvider for downloads
│
├── MyCookieManager.java                 # CookieManager wrapper
├── MyWebStorage.java                    # WebStorage wrapper
│
├── Util.java                            # General utilities (see below)
├── PlatformUtil.java                    # Platform utilities (see below)
├── WebViewFeatureManager.java           # AndroidX WebView feature detection
├── ISettings.java                       # Settings interface
│
├── webview/                             # Core WebView implementation
│   ├── ContextMenuSettings.java         # Context menu settings
│   ├── FlutterWebViewFactory.java       # PlatformView factory
│   ├── InAppWebViewInterface.java       # WebView interface definition
│   ├── InAppWebViewManager.java         # WebView instance management
│   ├── JavaScriptBridgeInterface.java   # @JavascriptInterface bridge
│   ├── PlatformWebView.java             # Platform WebView abstraction
│   ├── WebViewChannelDelegate.java      # Dart-native bridge (MethodChannel)
│   ├── WebViewChannelDelegateMethods.java # Channel delegate method implementations
│   │
│   ├── in_app_webview/                  # InAppWebView implementation
│   │   ├── DisplayListenerProxy.java    # Display listener for screen rotation
│   │   ├── FlutterWebView.java          # PlatformView implementation
│   │   ├── InAppWebView.java            # WebView subclass (main implementation)
│   │   ├── InAppWebViewChromeClient.java    # WebChromeClient (UI events)
│   │   ├── InAppWebViewClient.java          # WebViewClient (page lifecycle)
│   │   ├── InAppWebViewClientCompat.java    # Compat version of WebViewClient
│   │   ├── InAppWebViewRenderProcessClient.java # RenderProcessGoneDetail
│   │   ├── InAppWebViewSettings.java        # Settings mapping to WebView
│   │   ├── InputAwareWebView.java           # Keyboard handling
│   │   └── ThreadedInputConnectionProxyAdapterView.java # Input method handling
│   │
│   └── web_message/                     # WebMessagePort implementation
│       ├── WebMessageChannel.java       # WebMessageChannel wrapper
│       ├── WebMessageChannelChannelDelegate.java # Channel communication
│       ├── WebMessageListener.java      # WebMessageListener wrapper
│       └── WebMessageListenerChannelDelegate.java # Listener channel
│
├── headless_in_app_webview/             # Offscreen WebView
│   ├── HeadlessInAppWebView.java        # Headless WebView implementation
│   ├── HeadlessInAppWebViewManager.java # Instance management
│   └── HeadlessWebViewChannelDelegate.java # Channel delegate for headless
│
├── in_app_browser/                      # Activity-based browser
│   ├── ActivityResultListener.java      # Activity result handling
│   ├── InAppBrowserActivity.java        # Browser activity
│   ├── InAppBrowserChannelDelegate.java # Channel communication
│   ├── InAppBrowserDelegate.java        # Browser delegate interface
│   ├── InAppBrowserManager.java         # Instance management
│   └── InAppBrowserSettings.java        # Browser settings
│
├── chrome_custom_tabs/                  # Chrome Custom Tabs
│   ├── ActionBroadcastReceiver.java     # Action broadcast handling
│   ├── ChromeCustomTabsActivity.java    # Custom Tabs activity
│   ├── ChromeCustomTabsActivitySingleInstance.java # Single instance activity
│   ├── ChromeCustomTabsChannelDelegate.java # Channel communication
│   ├── ChromeCustomTabsSettings.java    # Custom Tabs settings
│   ├── ChromeSafariBrowserManager.java  # Instance management
│   ├── CustomTabActivityHelper.java     # Activity helper
│   ├── CustomTabsHelper.java            # Tabs helper utilities
│   ├── KeepAliveService.java            # Keep-alive service
│   ├── NoHistoryCustomTabsActivityCallbacks.java # No-history callbacks
│   ├── ServiceConnection.java           # Service connection
│   ├── ServiceConnectionCallback.java   # Connection callback interface
│   ├── TrustedWebActivity.java          # TWA implementation
│   └── TrustedWebActivitySingleInstance.java # Single instance TWA
│
├── credential_database/                 # WebViewDatabase wrapper
│   ├── CredentialDatabase.java          # Credential database implementation
│   ├── CredentialDatabaseHandler.java   # Database handler
│   ├── CredentialDatabaseHelper.java    # SQLite helper
│   ├── URLCredentialContract.java       # Credential contract
│   ├── URLCredentialDao.java            # Credential DAO
│   ├── URLProtectionSpaceContract.java  # Protection space contract
│   └── URLProtectionSpaceDao.java       # Protection space DAO
│
├── find_interaction/                    # Find in page
│   ├── FindInteractionChannelDelegate.java # Channel communication
│   ├── FindInteractionController.java   # Find controller
│   └── FindInteractionSettings.java     # Find settings
│
├── print_job/                           # PrintDocumentAdapter
│   ├── PrintJobChannelDelegate.java     # Channel communication
│   ├── PrintJobController.java          # Print job controller
│   ├── PrintJobManager.java             # Instance management
│   └── PrintJobSettings.java            # Print settings
│
├── pull_to_refresh/                     # SwipeRefreshLayout
│   ├── PullToRefreshChannelDelegate.java # Channel communication
│   ├── PullToRefreshLayout.java         # Custom SwipeRefreshLayout
│   └── PullToRefreshSettings.java       # Pull-to-refresh settings
│
├── proxy/                               # ProxyController
│   ├── ProxyManager.java                # Proxy management
│   └── ProxySettings.java               # Proxy settings
│
├── service_worker/                      # ServiceWorkerController
│   ├── ServiceWorkerChannelDelegate.java # Channel communication
│   └── ServiceWorkerManager.java        # Service worker management
│
├── tracing/                             # TracingController
│   ├── TracingControllerChannelDelegate.java # Channel communication
│   ├── TracingControllerManager.java    # Tracing management
│   └── TracingSettings.java             # Tracing settings
│
├── process_global_config/               # ProcessGlobalConfig
│   ├── ProcessGlobalConfigManager.java  # Config management
│   └── ProcessGlobalConfigSettings.java # Config settings
│
├── content_blocker/                     # Content blocking rules
│   ├── ContentBlocker.java              # Content blocker
│   ├── ContentBlockerAction.java        # Blocker action
│   ├── ContentBlockerActionType.java    # Action type enum
│   ├── ContentBlockerHandler.java       # Blocker handler
│   ├── ContentBlockerTrigger.java       # Blocker trigger
│   └── ContentBlockerTriggerResourceType.java # Resource type enum
│
├── plugin_scripts_js/                   # Injected JavaScript
│   ├── InterceptAjaxRequestJS.java      # AJAX interception script
│   ├── InterceptFetchRequestJS.java     # Fetch interception script
│   ├── JavaScriptBridgeJS.java          # Core JS bridge
│   ├── OnLoadResourceJS.java            # Resource loading script
│   ├── OnWindowBlurEventJS.java         # Window blur event
│   ├── OnWindowFocusEventJS.java        # Window focus event
│   ├── PluginScriptsUtil.java           # Script utilities
│   ├── PrintJS.java                     # Print handling script
│   └── PromisePolyfillJS.java           # Promise polyfill
│
└── types/                               # Type definitions and models
```

---

## Platform Requirements

- Android SDK >= 21 (minSdk)
- Android SDK >= 34 (compileSdk)
- Java support

## Native APIs Used

- [Android WebView](https://developer.android.com/reference/android/webkit/WebView)
- [AndroidX WebKit](https://developer.android.com/reference/androidx/webkit/package-summary) for modern features
- Uses `AndroidView` for rendering

---

## Java Utilities Reference

### `Util.java` - General Utilities

| Method | Description |
|--------|-------------|
| `Util.getUrlAsset(plugin, assetFilePath)` | Get `file:///android_asset/` URL for Flutter asset |
| `Util.getFileAsset(plugin, assetFilePath)` | Get InputStream for Flutter asset |
| `Util.invokeMethodAndWaitResult(channel, method, args, callback)` | Synchronously invoke Flutter method and wait for result |
| `Util.loadPrivateKeyAndCertificate(plugin, path, password, type)` | Load certificate from KeyStore |
| `Util.makeHttpRequest(url, method, headers)` | Make HTTP request with timeout |
| `Util.getX509CertFromSslCertHack(sslCert)` | Extract X509Certificate from SslCertificate |
| `Util.JSONStringify(value)` | Convert Map/List/String to JSON string |
| `Util.objEquals(a, b)` | Null-safe object equality |
| `Util.replaceAll(s, old, new)` | Replace all occurrences in string |
| `Util.log(tag, message)` | Log with automatic splitting for long messages |
| `Util.getPixelDensity(context)` | Get display pixel density |
| `Util.getFullscreenSize(context)` | Get screen size excluding insets |
| `Util.isClass(className)` | Check if class exists by name |
| `Util.isIPv6(address)` | Check if string is IPv6 address |
| `Util.normalizeIPv6(address)` | Normalize IPv6 to canonical form |
| `Util.getOrDefault(map, key, default)` | Get map value with default |
| `Util.readAllBytes(inputStream)` | Read all bytes from InputStream |
| `Util.invokeMethodIfExists(obj, method, args)` | Invoke method by reflection if exists |
| `Util.drawableFromBytes(context, data)` | Create Drawable from byte array |

**Constants:**
- `Util.ANDROID_ASSET_URL` = `"file:///android_asset/"`

**Usage:**
```java
// Asset loading
String assetUrl = Util.getUrlAsset(plugin, "assets/page.html");
InputStream stream = Util.getFileAsset(plugin, "assets/page.html");

// JSON serialization
String json = Util.JSONStringify(myMap);

// Sync method invocation
Util.invokeMethodAndWaitResult(channel, "getResult", args, callback);

// Map access with default
String value = Util.getOrDefault(map, "key", "default");

// Certificate loading
PrivateKeyAndCertificates cert = Util.loadPrivateKeyAndCertificate(
    plugin, "cert.p12", "password", "PKCS12"
);
```

---

### `PlatformUtil.java` - Platform Utilities

| Method | Description |
|--------|-------------|
| `getSystemVersion()` | Returns `Build.VERSION.SDK_INT` as String |
| `formatDate(date, format, locale, timezone)` | Format milliseconds timestamp |
| `getLocaleFromString(locale)` | Parse "en_US" to Locale object |

**Usage:**
```java
// Get Android SDK version
String sdkVersion = String.valueOf(Build.VERSION.SDK_INT);

// Format date
Locale locale = PlatformUtil.getLocaleFromString("en_US");
String formatted = PlatformUtil.formatDate(
    System.currentTimeMillis(), "yyyy-MM-dd", locale, TimeZone.getTimeZone("UTC")
);
```

---

### `WebViewFeatureManager.java` - AndroidX WebView Features

Used to check if AndroidX WebView features are supported:

| Method | Description |
|--------|-------------|
| `isFeatureSupported(feature)` | Check if WebViewFeature is supported |
| `isStartupFeatureSupported(activity, feature)` | Check startup feature support |

**Usage:**
```java
if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK)) {
    // Use force dark mode
}
```

---

### Common Java Patterns

#### FlutterMethodChannel Response

```java
@Override
public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
        case "myMethod":
            String param = call.argument("param");
            // Do work...
            result.success(returnValue);
            break;
        default:
            result.notImplemented();
    }
}
```

#### Converting to Flutter Map

```java
public Map<String, Object> toMap() {
    Map<String, Object> map = new HashMap<>();
    map.put("field1", fieldField")
    );
}
```

---

### AndroidX WebKit Features

Android uses AndroidX WebKit for modern WebView features. Always check feature support:

```java
import androidx.webkit.WebViewFeature;

// Check before using modern APIs
if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK)) {
    WebSettingsCompat.setForceDark(webSettings, forceDarkMode);
}

if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE)) {
    // Use WebMessagePort
}
```

Common features:
- `FORCE_DARK`, `FORCE_DARK_STRATEGY`
- `WEB_MESSAGE_PORT_*`
- `SERVICE_WORKER_*`
- `PROXY_OVERRIDE`
- `SAFE_BROWSING_*`

---

## Plugin Scripts JS Reference

JavaScript files injected into WebViews for native-web communication:

| Script | File | Description |
|--------|------|-------------|
| **JavaScriptBridgeJS** | `JavaScriptBridgeJS.java` | Core bridge enabling `window.flutter_inappwebview.callHandler()` for Dart-JS communication. Uses `@JavascriptInterface` annotation. |
| **InterceptAjaxRequestJS** | `InterceptAjaxRequestJS.java` | Wraps `XMLHttpRequest` to intercept AJAX requests. Enables `shouldInterceptAjaxRequest`, `onAjaxReadyStateChange`, `onAjaxProgress` callbacks. |
| **InterceptFetchRequestJS** | `InterceptFetchRequestJS.java` | Wraps `window.fetch()` to intercept Fetch API requests. Enables `shouldInterceptFetchRequest` callback. |
| **OnLoadResourceJS** | `OnLoadResourceJS.java` | Uses `PerformanceObserver` to track resource loading (images, scripts, etc.). Enables `onLoadResource` callback. |
| **PrintJS** | `PrintJS.java` | Overrides `window.print()` to trigger `onPrintRequest` callback instead of native print dialog. |
| **PromisePolyfillJS** | `PromisePolyfillJS.java` | Polyfill for `Promise` API on older Android WebView versions using RSVP.js library. |
| **OnWindowBlurEventJS** | `OnWindowBlurEventJS.java` | Listens for `blur` event on window and triggers `onWindowBlur` callback. |
| **OnWindowFocusEventJS** | `OnWindowFocusEventJS.java` | Listens for `focus` event on window and triggers `onWindowFocus` callback. |

**Note:** Android uses `@JavascriptInterface` for the bridge instead of `WKScriptMessageHandler`. Some iOS-specific scripts (FindTextHighlight, LastTouchedAnchorOrImage, WebMessageListener) are implemented natively in Java rather than via injected JS.

**Helper class:** `PluginScriptsUtil.java` contains:
- `GET_SELECTED_TEXT_JS_SOURCE` - Get selected text
- `CHECK_CONTEXT_MENU_SHOULD_BE_HIDDEN_JS_SOURCE` - Context menu visibility check
- `CALL_ASYNC_JAVA_SCRIPT_WRAPPER_JS_SOURCE` - Async JS execution wrapper
- `EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE` - Content world evaluation

---

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Extend `Platform*CreationParams` for Android-specific parameters
3. Register in `AndroidInAppWebViewPlatform.registerWith()`
4. Android-specific features: Chrome Custom Tabs, Service Workers, Tracing

## Native Code Development

When modifying Java code:
- Located in `android/src/main/java/`
- Main plugin class: `InAppWebViewFlutterPlugin`
- Use FlutterMethodChannel for Dart-native communication
- Always check AndroidX WebViewFeature support before using modern APIs

## Build Commands

```bash
cd flutter_inappwebview_android && flutter pub get
cd example && flutter build apk --debug
```

## AndroidManifest Requirements

Apps may need to add:
- `INTERNET` permission (usually auto-added)
- `CAMERA`, `RECORD_AUDIO` for WebRTC
- `ACCESS_FINE_LOCATION` for geolocation
- `WRITE_EXTERNAL_STORAGE` for downloads (Android < 10)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

## Proguard Rules

The plugin includes `proguard-rules.pro` for release builds:
- Keeps WebView JavaScript interface
- Preserves custom scheme handlers

## Debugging & Inspection

- **Chrome DevTools**: Enable debugging in your app:
  ```dart
  if (defaultTargetPlatform == TargetPlatform.android) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  ```
  Then open `chrome://inspect/#devices` in Chrome on your computer.
- **Logs**: Use `Log.d(LOG_TAG, "message")` in Java.
- **Android Studio**: Use the "App Inspection" tab for network and database inspection.
