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

---

## Native Code Structure

```
windows/
├── CMakeLists.txt                              # CMake build config (fetches WebView2 NuGet)
├── flutter_inappwebview_windows_plugin.cpp     # Plugin entry point
├── flutter_inappwebview_windows_plugin.h
├── flutter_inappwebview_windows_plugin_c_api.cpp  # C API wrapper
│
├── cookie_manager.cpp/h                        # ICoreWebView2CookieManager wrapper
├── platform_util.cpp/h                         # Platform utilities
│
├── in_app_webview/                             # Core WebView2 implementation
│   ├── in_app_webview.cpp/h                    # Main WebView2 wrapper class
│   ├── in_app_webview_manager.cpp/h            # WebView instance management
│   ├── in_app_webview_settings.cpp/h           # Settings mapping to WebView2
│   ├── webview_channel_delegate.cpp/h          # Dart-native bridge (MethodChannel)
│   └── user_content_controller.cpp/h           # Script injection
│
├── headless_in_app_webview/                    # Offscreen WebView2
│   ├── headless_in_app_webview.cpp/h           # Headless implementation
│   ├── headless_in_app_webview_manager.cpp/h   # Instance management
│   ├── headless_webview_channel_delegate.cpp/h # Channel delegate for headless
│
├── in_app_browser/                             # Browser window (HWND-based)
│   ├── in_app_browser.cpp/h                    # Browser window class
│   ├── in_app_browser_channel_delegate.cpp/h   # Channel communication
│   ├── in_app_browser_manager.cpp/h            # Instance management
│   └── in_app_browser_settings.cpp/h           # Browser settings
│
├── webview_environment/                        # ICoreWebView2Environment
│   ├── webview_environment.cpp/h               # Environment management
│   ├── webview_environment_channel_delegate.cpp/h # Channel communication
│   ├── webview_environment_manager.cpp/h       # Instance management
│   └── webview_environment_settings.cpp/h      # Environment settings
│
├── custom_platform_view/                       # Texture-based rendering
│   ├── custom_platform_view.cc/h               # Platform view implementation
│   ├── graphics_context.cc/h                   # Graphics context management
│   ├── texture_bridge.cc/h                     # Base texture bridge
│   ├── texture_bridge_fallback.cc/h            # CPU fallback renderer
│   ├── texture_bridge_gpu.cc/h                 # GPU-accelerated renderer
│   │
│   └── util/                                   # Platform view utilities
│       ├── composition.desktop.interop.h       # Desktop composition interop
│       ├── d3dutil.h                           # Direct3D utilities
│       ├── direct3d11.interop.cc/h             # D3D11 interop
│       ├── rohelper.cc/h                       # WinRT helper
│       ├── string_converter.cc/h               # String conversion
│       ├── swizzle.h                           # Texture swizzle operations
│       └── cpuid/                              # CPU identification
│
├── plugin_scripts_js/                          # Injected JavaScript
│   ├── javascript_bridge_js.h                  # Core JS bridge
│   └── plugin_scripts_util.h                   # Script utilities
│
└── utils/                                      # Utility functions
    ├── base64.cpp/h                            # Base64 encoding/decoding
    ├── defer.h                                 # RAII cleanup utilities
    ├── flutter.h                               # EncodableValue utilities
    ├── log.h                                   # Logging and HRESULT handling
    ├── map.h                                   # Map utilities
    ├── strconv.h                               # String encoding conversion
    ├── string.h                                # String utilities
    ├── timer.h                                 # Timer utilities
    ├── uri.h                                   # URI utilities
    ├── util.h                                  # General utilities
    ├── uuid.h                                  # UUID generation
    └── vector.h                                # Vector utilities
```

---

## Platform Requirements

- Windows 10/11
- [NuGet CLI](https://learn.microsoft.com/en-us/nuget/install-nuget-client-tools) on PATH
- WebView2 Runtime (auto-installed on modern Windows)

## Native APIs Used

- [WebView2](https://learn.microsoft.com/en-us/microsoft-edge/webview2/)
- Uses texture-based platform view rendering

---

## C++ Utilities Reference

### `utils/flutter.h` - EncodableValue Serialization

**ALWAYS use these utilities** when creating new C++ types or working with Flutter's EncodableValue.

#### EncodableValue Building (`make_fl_value`)

```cpp
#include "../utils/flutter.h"

flutter::EncodableMap SomeType::toEncodableMap() const {
  return flutter::EncodableMap{
      {"stringField", make_fl_value(someString)},
      {"intField", make_fl_value(someInt)},
      {"optionalField", make_fl_value(optionalValue)},  // auto handles std::optional
      {"nullField", make_fl_value()},                   // null value
  };
}
```

| `make_fl_value(T)` | Result |
|--------------------|--------|
| `(no args)` | `EncodableValue()` (null) |
| `T` (any basic type) | `EncodableValue(val)` |
| `T*` | null if nullptr, else `EncodableValue(*val)` |
| `std::vector<T>` | `EncodableList` (recursive) |
| `std::map<K, V>` | `EncodableMap` (recursive) |
| `std::optional<T>` | Value or null |
| `std::optional<std::vector<T>>` | List or null |
| `std::optional<std::map<K,V>>` | Map or null |

#### EncodableValue Extraction (`get_fl_map_value`, `get_optional_fl_map_value`)

```cpp
// Extract with type
std::string str = get_fl_map_value<std::string>(map, "key");
int64_t num = get_fl_map_value<int64_t>(map, "key");  // Use LongValue() internally

// Extract with default
std::string str = get_fl_map_value<std::string>(map, "key", "default");
std::vector<std::string> vec = get_fl_map_value(map, "key", std::vector<std::string>{});

// Extract optional
auto opt_str = get_optional_fl_map_value<std::string>(map, "key");
auto opt_map = get_optional_fl_map_value<std::map<std::string, std::string>>(map, "key");
```

#### Map Checking

```cpp
if (fl_map_contains(map, "key")) { ... }           // Key exists (may be null)
if (fl_map_contains_not_null(map, "key")) { ... }  // Key exists and not null
```

---

### `utils/strconv.h` - String Encoding Conversion (Windows-specific)

Essential for Windows Unicode handling:

| Function | Description |
|----------|-------------|
| `utf8_to_wide(s)` | Convert UTF-8 string to `std::wstring` |
| `wide_to_utf8(s)` | Convert `std::wstring` to UTF-8 |
| `ansi_to_wide(s)` | Convert ANSI to wide string |
| `wide_to_ansi(s)` | Convert wide to ANSI |
| `ansi_to_utf8(s)` | Convert ANSI to UTF-8 |
| `utf8_to_ansi(s)` | Convert UTF-8 to ANSI |
| `cp_to_wide(s, codepage)` | Convert any codepage to wide |
| `wide_to_cp(s, codepage)` | Convert wide to any codepage |
| `format(format, ...)` | Printf-style string formatting |
| `dbgmsg(title, format, ...)` | Show MessageBox with formatted text |
| `dbgout(ostrm, format, ...)` | Debug output to stream |

**Usage:**
```cpp
#include "../utils/strconv.h"

// WebView2 requires wide strings
std::wstring wideUrl = utf8_to_wide(url);
webview->Navigate(wideUrl.c_str());

// Convert back from WebView2
std::string utf8Title = wide_to_utf8(title);
```

---

### `utils/log.h` - Logging and HRESULT Handling

| Function | Description |
|----------|-------------|
| `debugLog(msg)` | Log debug message (only in debug builds) |
| `debugLog(hr)` | Log HRESULT with error message |
| `getHRMessage(hr)` | Get human-readable HRESULT message |
| `succeededOrLog(hr)` | Return true if SUCCEEDED, log if failed |
| `failedAndLog(hr)` | Return true if FAILED, log it |
| `failedLog(hr)` | Log HRESULT if failed |

**Usage with macros** (auto-includes file/line):
```cpp
debugLog("Message");           // Logs with file:line prefix
if (succeededOrLog(hr)) { ... }  // Check and log HRESULT
if (failedAndLog(hr)) { return; }  // Early return on failure
```

---

### `utils/timer.h` - Timer Utilities (Windows SetTimer wrapper)

| Function | Description |
|----------|-------------|
| `Timer::setTimeout(callback, delay)` | One-shot timer, returns timer ID |
| `Timer::setInterval(callback, delay)` | Repeating timer, returns timer ID |
| `Timer::clearTimeout(timerId)` | Cancel one-shot timer |
| `Timer::clearInterval(timerId)` | Cancel repeating timer |

```cpp
auto timerId = Timer::setTimeout([&]() {
  // Called once after delay
}, 1000);  // 1 second

Timer::clearTimeout(timerId);  // Cancel if needed
```

---

### `utils/base64.h` - Base64 Encoding/Decoding

| Function | Description |
|----------|-------------|
| `base64_encode(s)` | Encode string to base64 |
| `base64_encode(data, len)` | Encode bytes to base64 |
| `base64_encode_pem(s)` | Encode with PEM line breaks |
| `base64_encode_mime(s)` | Encode with MIME line breaks |
| `base64_decode(s)` | Decode base64 string |

---

### `utils/string.h` - String Utilities

| Function | Description |
|----------|-------------|
| `string_equals(s1, s2)` | Compare strings (supports optional) |
| `replace_all(source, from, to)` | Replace all occurrences in-place |
| `replace_all_copy(source, from, to)` | Replace all, return copy |
| `join(vec, delim)` | Join vector with delimiter |
| `split(s, delimiter)` | Split string into vector |
| `to_lowercase(s)` / `to_lowercase_copy(s)` | Convert to lowercase |
| `to_uppercase(s)` / `to_uppercase_copy(s)` | Convert to uppercase |
| `starts_with(str, prefix)` | Check prefix |
| `ends_with(str, suffix)` | Check suffix |
| `string_hash(data)` | Compile-time hash (constexpr) |
| `trim(str)` | Trim whitespace |

---

### `utils/map.h` - Map Utilities

| Function | Description |
|----------|-------------|
| `map_contains(map, key)` | Check if key exists |
| `map_at_or_null(map, key)` | Get value or nullptr |
| `map_at_optional(map, key)` | Get as `std::optional<T>` |

---

### `utils/vector.h` - Vector Utilities

| Function | Description |
|----------|-------------|
| `vector_remove(vec, el)` | Remove element |
| `vector_remove_if(vec, pre# `utils/uri.h` - URI Utilities

| Function | Description |
|----------|-------------|
| `get_origin_from_url(url)` | Extract origin |
| `is_valid_url(url)` | Validate URL |
| `get_scheme_from_url(url)` | Extract scheme |
| `get_host_from_url(url)` | Extract host |
| `url_encode(value)` | URL-encode string |

---

### `utils/defer.h` - RAII Cleanup

| Function | Description |
|----------|-------------|
| `defer(handle, callback)` | shared_ptr with custom deleter |
| `make_scope_guard(func)` | RAII guard |

---

### `utils/uuid.h` - UUID Generation

| Function | Description |
|----------|-------------|
| `get_uuid()` | Generate UUID v4 string |

---

### `utils/util.h` - General Utilities

| Function | Description |
|----------|-------------|
| `make_pointer_optional(ptr)` | Pointer to optional |
| `variant_to_string(var)` | Variant to string |

---

## Plugin Scripts JS Reference

JavaScript files injected into WebViews for native-web communication:

| Script | File | Description |
|--------|------|-------------|
| **JavaScriptBridgeJS** | `javascript_bridge_js.h` | Core bridge enabling `window.flutter_inappwebview.callHandler()` for Dart-JS communication. Uses `chrome.webview.postMessage` for WebView2 communication. |

**Helper class:** `plugin_scripts_util.h` contains utility functions for script management.

**Note:** Windows implementation currently has fewer plugin scripts than iOS/macOS. Most functionality is handled natively through WebView2 APIs:
- Console messages: `ICoreWebView2.add_ConsoleMessage`
- Resource loading: `ICoreWebView2.add_WebResourceRequested`
- Navigation: `ICoreWebView2.add_NavigationStarting`, `add_NavigationCompleted`
- Print: `ICoreWebView2PrintSettings`

Additional scripts may be needed for features not natively supported by WebView2 (e.g., AJAX/Fetch interception).

---

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

## Debugging & Inspection

- **Edge DevTools**:
  - Enable debugging in your app:
    ```dart
    InAppWebViewSettings(isInspectable: true) // or areDevToolsEnabled: true
    ```
  - Right-click in the WebView and select "Inspect".
  - Or open `edge://inspect` in Edge browser.
- **Logs**: Use `debugLog()` in C++ which prints to the Output window in Visual Studio.
- **Visual Studio**: Attach debugger to the running process for C++ debugging.
