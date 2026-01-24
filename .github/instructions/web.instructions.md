---
applyTo: "flutter_inappwebview_web/**"
---

# Web Platform Implementation Instructions

## Implemented Dart Classes

| Class | File | Description |
|-------|------|-------------|
| `WebPlatformInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers Web implementations |
| `WebPlatformInAppWebView` | `in_app_webview/in_app_webview.dart` | WebView widget using iframe |
| `WebPlatformInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | WebView controller |
| `WebPlatformHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Offscreen iframe |
| `WebPlatformCookieManager` | `cookie_manager.dart` | document.cookie wrapper |
| `WebPlatformWebStorage` | `web_storage/` | localStorage/sessionStorage |

---

## Source Code Structure

### Dart Side (`flutter_inappwebview_web/lib/src/`)

```
lib/src/
├── inappwebview_platform.dart       # Platform factory/registration
├── main.dart                        # Package entry point
├── platform_util.dart               # Platform utilities
├── cookie_manager.dart              # Document.cookie wrapper
│
├── in_app_webview/                  # Core iframe-based WebView
│   ├── _static_channel.dart         # Static method channel
│   ├── in_app_webview.dart          # Widget (HtmlElementView with iframe)
│   ├── in_app_webview_controller.dart # Controller implementation
│   ├── headless_in_app_webview.dart # Offscreen iframe
│   └── main.dart                    # Barrel file
│
└── web_storage/                     # localStorage/sessionStorage
    ├── main.dart                    # Barrel file
    └── web_storage.dart             # Storage implementation
```

### TypeScript Side (`web_support/src/`)

```
web_support/src/
├── index.ts                         # Main JavaScript bridge (flutter_inappwebview_plugin)
└── types.ts                         # TypeScript type definitions
```

---

## Platform Limitations

The Web platform has significant limitations compared to native platforms:

| Feature | Status | Notes |
|---------|--------|-------|
| InAppWebView | ✅ | iframe-based, same-origin restrictions |
| HeadlessInAppWebView | ✅ | Hidden iframe |
| InAppBrowser | ❌ | Not implemented |
| ChromeSafariBrowser | ❌ | Not applicable |
| CookieManager | ✅ | Same-origin only |
| WebStorage | ✅ | localStorage/sessionStorage |
| WebMessageChannel/Port | ❌ | Not implemented |
| FindInteractionController | ❌ | Not implemented |
| PrintJobController | ❌ | Not implemented |
| PullToRefreshController | ❌ | Not implemented |

### Same-Origin Restrictions

Due to browser security (CORS), the Web platform cannot:
- Access iframe content from different origins
- Inject JavaScript into cross-origin iframes
- Read/modify cookies for other domains
- Access cross-origin document properties

---

## JavaScript Bridge Architecture

### `web_support/src/index.ts`

The TypeScript module provides the `flutter_inappwebview_plugin` global object:

```typescript
window.flutter_inappwebview_plugin = {
  createFlutterInAppWebView(viewId, iframe, iframeContainer, bridgeSecret),
  getCookieExpirationDate(timestamp),
  nativeAsyncCommunication(method, viewId, args),
  nativeSyncCommunication(method, viewId, args),
  nativeCommunication(method, viewId, args),
};
```

### InAppWebView Methods (iframe wrapper)

| Method | Description |
|--------|-------------|
| `prepare(settings)` | Initialize iframe with settings and event listeners |
| `setSettings(newSettings)` | Update iframe settings dynamically |
| `reload()` | Reload iframe content |
| `goBack()` | Navigate back in iframe history |
| `goForward()` | Navigate forward in iframe history |
| `goBackOrForward(steps)` | Navigate by number of steps |
| `evaluateJavascript(source)` | Execute JS in iframe (same-origin only) |
| `stopLoading()` | Stop iframe loading |
| `getUrl()` | Get current iframe URL |
| `getTitle()` | Get iframe document title |
| `injectJavascriptFileFromUrl(url, attrs)` | Inject script tag |
| `injectCSSCode(source)` | Inject style element |
| `injectCSSFileFromUrl(url, attrs)` | Inject link element |
| `scrollTo(x, y, animated)` | Scroll to position |
| `scrollBy(x, y, animated)` | Scroll by offset |
| `printCurrentPage()` | Trigger print dialog |
| `getContentHeight()` | Get document scroll height |
| `getContentWidth()` | Get document scroll width |
| `getSelectedText()` | Get selected text |
| `getScrollX()` / `getScrollY()` | Get scroll position |
| `isSecureContext()` | Check if HTTPS context |
| `canScrollVertically()` / `canScrollHorizontally()` | Check scrollability |
| `getSize()` | Get iframe container size |

### Events Forwarded to Dart

| Event | Trigger |
|-------|---------|
| `onLoadStart` | iframe load event start |
| `onLoadStop` | iframe load event complete |
| `onTitleChanged` | Document title mutation |
| `onConsoleMessage` | Console method intercept |
| `onUpdateVisitedHistory` | pushState/replaceState/popstate |
| `onScrollChanged` | scroll event |
| `onZoomScaleChanged` | devicePixelRatio change |
| `onEnterFullscreen` / `onExitFullscreen` | Fullscreen API |
| `onCreateWindow` | window.open() intercept |
| `onCloseWindow` | window.close() intercept |
| `onPrintRequest` | window.print() intercept |
| `onCallJsHandler` | JavaScript bridge handler call |
| `onWindowFocus` / `onWindowBlur` | Focus events |

---

## Dart Utilities Reference

### `platform_util.dart` - Platform Utilities

| Method | Description |
|--------|-------------|
| `PlatformUtil.instance()` | Get singleton instance |
| `getSystemVersion()` | Get browser/platform version |
| `getWebCookieExpirationDate(date)` | Format date for cookie expiration |

**Usage:**
```dart
final util = PlatformUtil.instance();
final version = await util.getSystemVersion();
final expiry = await util.getWebCookieExpirationDate(date: expiryDate);
```

---

## Development Workflow

### Building TypeScript

The `web_support/` folder contains TypeScript that compiles to JavaScript:

```bash
cd web_support
npm install
npm run build  # Compiles TypeScript to JavaScript
```

The compiled output is used by the Dart web plugin.

### Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Register in `WebPlatformInAppWebViewPlatform.registerWith()`
3. Use `dart:js_interop` for JavaScript interop
4. Use `dart:html` for DOM manipulation

### Adding New Features

1. Update TypeScript in `web_support/src/` if JS bridge changes needed
2. Run `npm run build` in `web_support/`
3. Update Dart wrappers in `flutter_inappwebview_web/lib/src/`
4. Implement platform interface methods

---

## Common Web Patterns

### Calling Native (Dart) from JavaScript

```typescript
// In TypeScript
_nativeCommunication('methodName', viewId, [arg1, arg2]);
```

### Calling JavaScript from Dart

```dart
// Using js_interop
@JS('flutter_inappwebview_plugin')
external FlutterInAppWebViewPlugin get flutterInAppWebViewPlugin;
```

### Handling Same-Origin Restrictions

```typescript
try {
  // Attempt cross-origin access
  const title = iframe.contentDocument?.title;
} catch (e) {
  // SecurityError: blocked by same-origin policy
  console.log(e);
}
```

---

## Build Commands

```bash
# Dart package
cd flutter_inappwebview_web && flutter pub get

# TypeScript (if modified)
cd web_support && npm install && npm run build

# Example app
cd flutter_inappwebview_web/example && flutter run -d chrome
```

## Testing Considerations

- Test with same-origin iframes for full functionality
- Cross-origin iframes will have limited capabilities
- Use `--disable-web-security` Chrome flag for development testing (not production)
- Browser console shows CORS errors for blocked operations

## Debugging & Inspection

- **Browser DevTools**:
  - Right-click > Inspect.
  - Console tab for logs and errors.
  - Network tab for request inspection.
  - Elements tab to inspect the iframe structure.
- **Logs**: Use `console.log()` in TypeScript/JavaScript or `print()` in Dart.
- **Source Maps**: `npm run build` generates source maps for debugging TypeScript in the browser.
