---
applyTo: "flutter_inappwebview/lib/**,flutter_inappwebview/example/**"
---

# App-Facing Package Instructions

This is the **public API** package that developers depend on. It wraps all platform implementations.

## Key Rules

1. **No Platform Logic Here**: This package only wraps platform implementations. Never add platform-specific code.

2. **Delegate to Platform Interface**: All functionality must delegate to `flutter_inappwebview_platform_interface` types.

3. **Avoid Breaking Changes**: Public API changes affect all users. Maintain backward compatibility.

## Directory Structure

- `lib/flutter_inappwebview.dart` - Main export file
- `lib/src/` - Public API wrappers
- `example/` - Example app and integration tests
- `example/integration_test/` - Integration test suite

### Source Code Structure (`lib/src/`)

```
lib/src/
├── in_app_webview/                  # Core WebView widgets & controllers
│   ├── in_app_webview.dart          # InAppWebView widget
│   ├── in_app_webview_controller.dart # Controller
│   ├── headless_in_app_webview.dart # Headless WebView
│   └── ...
├── in_app_browser/                  # InAppBrowser
├── chrome_safari_browser/           # ChromeCustomTabs / SFSafariViewController
├── find_interaction/                # Find interaction controller
├── print_job/                       # Print job controller
├── pull_to_refresh/                 # Pull-to-refresh controller
├── web_message/                     # Web Message channels/ports
├── web_storage/                     # Web Storage (Local/Session)
├── web_authentication_session/      # Web Authentication Session
├── webview_environment/             # WebView Environment (Windows)
├── cookie_manager.dart              # Cookie Manager
├── http_auth_credentials_database.dart # Auth Database
├── process_global_config.dart       # Process Global Config
├── proxy_controller.dart            # Proxy Controller
├── service_worker_controller.dart   # Service Worker Controller
├── tracing_controller.dart          # Tracing Controller
└── webview_asset_loader.dart        # Asset Loader
```

## Adding Public API Classes

1. Create wrapper class in `lib/src/`
2. Use constructor helpers: `fromPlatformCreationParams`, `fromPlatform`
3. Delegate all methods to the platform implementation
4. Add support check helpers: `isClassSupported`, `isPropertySupported`, `isMethodSupported`

## Example Pattern

```dart
class MyFeature {
  MyFeature.fromPlatformCreationParams(
    PlatformMyFeatureCreationParams params,
  ) : this.fromPlatform(platform: PlatformMyFeature(params));
  
  MyFeature.fromPlatform({required this.platform});
  
  final PlatformMyFeature platform;
  
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformMyFeature.static().isClassSupported(platform: platform);
}
```

## Integration Tests

Located in `example/integration_test/`:
```bash
# Run with device/emulator
cd flutter_inappwebview/example
NODE_SERVER_IP=<ip> flutter driver --driver=test_driver/integration_test.dart \
  --target=integration_test/webview_flutter_test.dart
```

Requires `test_node_server/` to be running for full test coverage.
