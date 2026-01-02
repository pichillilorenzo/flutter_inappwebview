---
applyTo: "flutter_inappwebview_windows/**"
---

# Windows Platform Implementation Instructions

## Implemented Dart Classes

| Class | File | Description |
|-------|------|-------------|
| `WindowsInAppWebViewPlatform` | `inappwebview_platform.dart` | Platform factory - registers all Windows implementations |
| `WindowsInAppWebView` | `in_app_webview/in_app_webview.dart` | WebView widget using texture |
| `WindowsInAppWebViewController` | `in_app_webview/in_app_webview_controller.dart` | WebView2 controller |
| `WindowsHeadlessInAppWebView` | `in_app_webview/headless_in_app_webview.dart` | Offscreen WebView2 |
| `WindowsInAppBrowser` | `in_app_browser/` | Browser window |
| `WindowsCookieManager` | `cookie_manager.dart` | ICoreWebView2CookieManager |
| `WindowsWebStorage` | `web_storage/` | WebView2 storage APIs |
| `WindowsFindInteractionController` | `find_interaction/` | ICoreWebView2Find |
| `WindowsPrintJobController` | `print_job/` | ICoreWebView2PrintSettings |
| `WindowsHttpAuthCredentialDatabase` | `http_auth_credentials_database.dart` | Credential storage |
| `WindowsWebViewEnvironment` | `webview_environment/` | ICoreWebView2Environment (session isolation) |

## Native Code Structure

```
windows/
├── CMakeLists.txt                           # CMake build config (fetches WebView2 NuGet)
├── flutter_inappwebview_windows_plugin.cpp  # Plugin entry point
├── flutter_inappwebview_windows_plugin.h
├── flutter_inappwebview_windows_plugin_c_api.cpp  # C API wrapper
├── cookie_manager.cpp/h                     # ICoreWebView2CookieManager wrapper
├── platform_util.cpp/h                      # Platform utilities
├── in_app_webview/                          # Core WebView2
│   ├── in_app_webview.cpp/h                 # Main WebView2 wrapper class
│   ├── in_app_webview_manager.cpp/h         # WebView instance management
│   ├── in_app_webview_settings.cpp/h        # Settings mapping
│   ├── webview_channel_delegate.cpp/h       # Dart-native bridge
│   └── user_content_controller.cpp/h        # Script injection
├── headless_in_app_webview/                 # Offscreen WebView2
├── in_app_browser/                          # Browser window
├── webview_environment/                     # ICoreWebView2Environment
│   └── webview_environment.cpp/h            # Environment management
├── custom_platform_view/                    # Texture-based rendering
├── types/                                   # Type definitions
├── utils/                                   # Utility functions
└── plugin_scripts_js/                       # Injected JavaScript
```

## Platform Requirements
- Windows 10/11
- [NuGet CLI](https://learn.microsoft.com/en-us/nuget/install-nuget-client-tools) on PATH
- WebView2 Runtime (auto-installed on modern Windows)

## Native APIs Used
- [WebView2](https://learn.microsoft.com/en-us/microsoft-edge/webview2/)
- Uses texture-based platform view rendering

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from `flutter_inappwebview_platform_interface`
2. Windows-specific features: `WebViewEnvironment` for session isolation
3. `WebViewInterface` enum maps to ICoreWebView2 interface versions

## Native Code Development

When modifying C++ code:
- Located in `windows/`
- **Prefer standard C++17** over Windows-specific APIs for maintainability
- Plugin class: `FlutterInappwebviewWindowsPluginCApi`
- Uses Flutter texture for rendering WebView2 content

## Build Commands
```bash
cd flutter_inappwebview_windows && flutter pub get
cd example && flutter build windows --debug
```

## Key C++ Files
- `flutter_inappwebview_windows_plugin.cpp` - Plugin entry point
- `in_app_webview/in_app_webview.cpp` - WebView2 wrapper
- `webview_environment/webview_environment.cpp` - Environment management
