---
applyTo: "flutter_inappwebview_platform_interface/**"
---

# Platform Interface Package Instructions

This is the **source of truth** for the entire plugin. All types, enums, and platform contracts are defined here.
Used by all platform implementations and the main plugin-facing-API package.
When adding new features here, you must propagate them also to the main `flutter_inappwebview` package.

## Main Platform Contracts

| Contract Class | File | Description |
|----------------|------|-------------|
| `InAppWebViewPlatform` | `inappwebview_platform.dart` | Factory interface - creates all platform-specific instances |
| `PlatformInAppWebViewWidget` | `in_app_webview/platform_inappwebview_widget.dart` | WebView widget contract |
| `PlatformInAppWebViewController` | `in_app_webview/platform_inappwebview_controller.dart` | WebView controller contract |
| `PlatformHeadlessInAppWebView` | `in_app_webview/platform_headless_in_app_webview.dart` | Offscreen WebView contract |
| `PlatformWebView` | `in_app_webview/platform_webview.dart` | Base WebView interface |
| `PlatformInAppBrowser` | `in_app_browser/platform_in_app_browser.dart` | Browser window contract |
| `PlatformChromeSafariBrowser` | `chrome_safari_browser/platform_chrome_safari_browser.dart` | Chrome Custom Tabs / SFSafariViewController |
| `PlatformCookieManager` | `platform_cookie_manager.dart` | Cookie management contract |
| `PlatformWebStorage` | `web_storage/platform_web_storage.dart` | Storage APIs contract |
| `PlatformFindInteractionController` | `find_interaction/platform_find_interaction_controller.dart` | Find-in-page contract |
| `PlatformPrintJobController` | `print_job/platform_print_job_controller.dart` | Print functionality contract |
| `PlatformPullToRefreshController` | `pull_to_refresh/platform_pull_to_refresh_controller.dart` | Pull-to-refresh contract |
| `PlatformWebMessageChannel/Port/Listener` | `web_message/` | postMessage API contracts |
| `PlatformWebAuthenticationSession` | `web_authentication_session/platform_web_authentication_session.dart` | Auth session contract |
| `PlatformHttpAuthCredentialDatabase` | `platform_http_auth_credentials_database.dart` | Credential storage contract |
| `PlatformProcessGlobalConfig` | `platform_process_global_config.dart` | Process configuration contract |
| `PlatformProxyController` | `platform_proxy_controller.dart` | Proxy settings contract |
| `PlatformServiceWorkerController` | `platform_service_worker_controller.dart` | Service worker contract |
| `PlatformTracingController` | `platform_tracing_controller.dart` | Tracing contract |
| `PlatformWebViewEnvironment` | `webview_environment/platform_webview_environment.dart` | WebView2 environment (Windows) |
| `PlatformWebViewFeature` | `platform_webview_feature.dart` | Feature detection contract |

## Directory Structure

```
lib/src/
├── inappwebview_platform.dart           # Main factory interface
├── main.dart                            # Exports
├── in_app_webview/                      # Core WebView contracts
│   ├── platform_inappwebview_widget.dart/.g.dart
│   ├── platform_inappwebview_controller.dart/.g.dart
│   ├── platform_headless_in_app_webview.dart/.g.dart
│   ├── platform_webview.dart/.g.dart
│   ├── in_app_webview_settings.dart/.g.dart   # InAppWebViewSettings
│   ├── android/                         # Android-specific settings
│   └── apple/                           # iOS/macOS-specific settings
├── in_app_browser/                      # InAppBrowser contracts
├── chrome_safari_browser/               # Chrome/Safari browser contracts
├── find_interaction/                    # Find-in-page contracts
├── print_job/                           # Print job contracts
├── pull_to_refresh/                     # Pull-to-refresh contracts
├── web_message/                         # WebMessage contracts
├── web_storage/                         # WebStorage contracts
├── web_authentication_session/          # Auth session contracts
├── webview_environment/                 # WebView2 environment (Windows)
├── context_menu/                        # Context menu types
├── x509_certificate/                    # X509 certificate parsing
├── types/                               # 200+ shared types & enums
│   ├── navigation_action.dart           # Navigation types
│   ├── url_request.dart                 # Request types
│   ├── permission_*.dart                # Permission types
│   ├── ssl_*.dart                       # SSL types
│   └── ...                              # Many more types
├── platform_cookie_manager.dart/.g.dart
├── platform_http_auth_credentials_database.dart/.g.dart
├── platform_process_global_config.dart/.g.dart
├── platform_proxy_controller.dart/.g.dart
├── platform_service_worker_controller.dart/.g.dart
├── platform_tracing_controller.dart/.g.dart
├── platform_webview_asset_loader.dart/.g.dart
├── platform_webview_feature.dart/.g.dart
├── content_blocker.dart                 # Content blocking rules
├── web_uri.dart                         # URI utilities
└── util.dart                            # General utilities
```

## Key Rules

1. **Code Generation**: Files with `@ExchangeableObject`, `@ExchangeableEnum`, or `@SupportedPlatforms` annotations generate `*.g.dart` files. After modifying, always run:
   ```bash
   npm run build
   # Or directly:
   cd flutter_inappwebview_platform_interface
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Never Edit Generated Files**: Files ending in `.g.dart` are auto-generated. Modify the source file (same name without `.g`) instead.

3. **Propagation**: Changes here require updates to ALL platform packages AND the main `flutter_inappwebview` package.

## InAppWebViewSettings

The main settings class for WebView configuration:

- **Source**: `lib/src/in_app_webview/in_app_webview_settings.dart` (`InAppWebViewSettings_` → generates `InAppWebViewSettings`)
- **Role**: Exhaustive configuration bag for `InAppWebView`/`InAppBrowser`. Mirrors platform capabilities via `@SupportedPlatforms`.
- **Defaults**: Flags like `useShouldOverrideUrlLoading`, `useOnLoadResource`, `useShouldInterceptRequest` auto-infer to `true` when callbacks are implemented.
- **Deprecated fields**: Use `@ExchangeableObjectProperty(leaveDeprecatedInToMapMethod: true)` for backward compatibility.
- **Complex types**: Uses exchangeable enums/objects like `MixedContentMode_`, `WebViewAssetLoader_`, `RendererPriorityPolicy_`.

## Adding New Features

1. Define the contract class (`Platform*`) extending `PlatformInterface`
2. Create corresponding `Platform*CreationParams` class
3. Add `@SupportedPlatforms` annotations to document platform availability
4. Use `{@template}` and `{@macro}` for documentation
5. Add factory methods to `InAppWebViewPlatform` class
6. Run code generation: `npm run build`
7. **Propagate** to all platform packages and the app-facing package

## Supported Platforms Pattern

When implementing a new platform interface class:

### 1. Creation Params Class (`Platform*CreationParams`)

```dart
@SupportedPlatforms(platforms: [WindowsPlatform()])
@immutable
class PlatformWebViewEnvironmentCreationParams {
  const PlatformWebViewEnvironmentCreationParams({this.settings});

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings}
  /// WebView Environment settings.
  ///{@endtemplate}
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  final WebViewEnvironmentSettings? settings;

  bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebViewEnvironment.isClassSupported(platform: platform);

  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      PlatformWebViewEnvironment.isPropertySupported(property, platform: platform);
}
```

### 2. Main Interface Class (`Platform*`)

```dart
@SupportedPlatforms(platforms: [WindowsPlatform()])
abstract class PlatformWebViewEnvironment extends PlatformInterface implements Disposable {
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings}
  WebViewEnvironmentSettings? get settings => params.settings;

  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      property is PlatformWebViewEnvironmentCreationParamsProperty
          ? params.isPropertySupported(property, platform: platform)
          : _PlatformWebViewEnvironmentPropertySupported.isPropertySupported(
              property, platform: platform);

  bool isMethodSupported(PlatformWebViewEnvironmentMethod method,
          {TargetPlatform? platform}) =>
      _PlatformWebViewEnvironmentMethodSupported.isMethodSupported(method,
          platform: platform);
}
```

**Key rules**:
- Use `{@template}` in CreationParams, `{@macro}` in Platform class
- **Don't** repeat `@SupportedPlatforms` on getters that use macros
- `isPropertySupported` must handle both CreationParams and class properties
- Reference implementations: `PlatformPrintJobController`, `PlatformFindInteractionController`, `PlatformCookieManager`

## Annotations Reference

```dart
@ExchangeableObject()      // Generates toMap(), fromMap(), copy()
@ExchangeableEnum()        // Generates enum serialization
@SupportedPlatforms(platforms: [
  AndroidPlatform(available: "21", apiName: "WebView.setAlpha", apiUrl: "..."),
  IOSPlatform(available: "12.0", apiName: "WKWebView", note: "Requires iOS 12+"),
])
@ExchangeableObjectProperty(leaveDeprecatedInToMapMethod: true)  // For deprecated fields
```
