---
applyTo: "flutter_inappwebview_linux/**"
---

# Linux Platform Implementation Instructions

## 📋 Implementation Task Tracking

**IMPORTANT**: Before implementing any Linux feature, consult the comprehensive task list:

**[LINUX_IMPLEMENTATION_TASKS.md](../flutter_inappwebview_linux/LINUX_IMPLEMENTATION_TASKS.md)**

This file contains:
- ✅ Current implementation status (~45-50% complete)
- 🚨 Critical issues that need fixing (multi-window, settings mismatch)
- 🔍 Verification checklist for "complete" APIs against iOS reference
- 📝 Detailed tasks for each feature with WPE WebKit API mappings
- 🎯 Priority order for implementation

### Before Starting Any Task

1. **Check the task file** to see if the feature is already tracked
2. **Verify "complete" APIs** - many marked ✅ are unverified (⏳)
3. **Follow the testing guidelines** in the task file
4. **Update the task file** when you complete or verify work

## Implemented Dart Classes

Linux implementation is newer and has fewer features than other platforms:

| Class | File | Description |
|-------|------|-------------|
| \`LinuxInAppWebViewPlatform\` | \`inappwebview_platform.dart\` | Platform factory - registers Linux implementations |
| \`LinuxInAppWebView\` | \`in_app_webview/in_app_webview.dart\` | WebView widget using texture |
| \`LinuxInAppWebViewController\` | \`in_app_webview/in_app_webview_controller.dart\` | WPE WebKit controller |
| \`LinuxHeadlessInAppWebView\` | \`in_app_webview/headless_in_app_webview.dart\` | Offscreen WebView |
| \`LinuxCookieManager\` | \`cookie_manager/\` | WebKit cookie management |
| \`LinuxFindInteractionController\` | \`find_interaction/\` | Find in page |
| \`LinuxWebStorageManager\` | \`web_storage/\` | Website data management |

**Not yet implemented**: InAppBrowser, PrintJob, PullToRefresh, WebMessage, HttpAuthCredentialDatabase, ProxyController.

---

## Native Code Structure

\`\`\`
linux/
├── CMakeLists.txt                           # CMake build config (links WPE WebKit)
├── WPE_BACKEND.md                           # WPE backend setup documentation
├── flutter_inappwebview_linux_plugin.cc     # Plugin entry point
├── flutter_inappwebview_linux_plugin_private.h
│
├── cookie_manager.cc/h                      # WebKit cookie manager wrapper
├── web_storage_manager.cc/h                 # WebKit website data manager
│
├── in_app_webview/                          # Core WPE WebKit implementation
│   ├── in_app_webview.cc/h                  # Main WebView wrapper (5000+ lines)
│   ├── in_app_webview_manager.cc/h          # WebView instance management
│   ├── in_app_webview_settings.cc/h         # Settings mapping to WPE WebKit
│   ├── webview_channel_delegate.cc/h        # Dart-native bridge (MethodChannel)
│   ├── user_content_controller.cc/h         # Script injection (UserContentManager)
│   ├── custom_platform_view.cc/h            # Flutter platform view integration
│   ├── inappwebview_texture.cc/h            # Base texture class for rendering
│   ├── inappwebview_egl_texture.cc/h        # EGL texture rendering (DMA-BUF)
│   └── simd_convert.h                       # SIMD color conversion utilities
│
├── headless_in_app_webview/                 # Offscreen WebView (WPE is inherently headless)
│   ├── headless_in_app_webview.cc/h         # Headless WebView implementation
│   └── headless_in_app_webview_manager.cc/h # Instance management
│
├── plugin_scripts_js/                       # Injected JavaScript for bridge
│   ├── javascript_bridge_js.h               # Core JS bridge
│   ├── console_log_js.h                     # Console interception
│   ├── window_id_js.h                       # Window ID management
│   └── color_input_js.h                     # Color input handling
│
├── utils/                                   # Utility functions
│   ├── flutter.h                            # FlValue serialization utilities
│   ├── string.h                             # String utilities
│   ├── map.h                                # Map utilities
│   ├── vector.h                             # Vector utilities
│   ├── uri.h                                # URI utilities
│   ├── log.h                                # Logging utilities
│   ├── defer.h                              # RAII cleanup utilities
│   ├── uuid.h                               # UUID generation
│   └── util.h                               # General utilities
│
└── types/                                   # Type definitions
\`\`\`

---

## Platform Requirements

- WPE WebKit libraries installed (\`libwpe\`, \`wpebackend-fdo\`, \`wpewebkit\`)
- See \`linux/WPE_BACKEND.md\` for backend setup documentation

## Native APIs Used

- [WPE WebKit 2.0](https://wpewebkit.org/) for offscreen rendering
- Official documentation: https://wpewebkit.org/reference/stable/wpe-webkit-2.0/index.html
- Uses texture-based platform view rendering via DMA-BUF

### Linux (WPE WebKit 2.0) Key Classes

For Linux platform implementation, the following WPE WebKit classes are used:

| Class | Purpose | API Docs |
|-------|---------|----------|
| `WebKitWebView` | Main WebView widget | [WebView](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebView.html) |
| `WebKitSettings` | WebView configuration | [Settings](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.Settings.html) |
| `WebKitUserContentManager` | User scripts/styles injection | [UserContentManager](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.UserContentManager.html) |
| `WebKitCookieManager` | Cookie management | [CookieManager](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.CookieManager.html) |
| `WebKitWebsiteDataManager` | Website data storage | [WebsiteDataManager](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebsiteDataManager.html) |
| `WebKitFindController` | Find in page | [FindController](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.FindController.html) |
| `WebKitDownload` | Download handling | [Download](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.Download.html) |
| `WebKitURISchemeRequest` | Custom URI scheme | [URISchemeRequest](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.URISchemeRequest.html) |
| `WebKitWebContext` | Shared browsing context | [WebContext](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html) |

> **Important**: Linux uses **WPE WebKit** (for headless/embedded rendering), NOT WebKitGTK. Always use `https://wpewebkit.org/reference/stable/wpe-webkit-2.0/` for API documentation.

## Debugging & Inspection

- **Inspector**: Use `WEBKIT_INSPECTOR_SERVER` environment variable to enable remote inspection.
  ```bash
  WEBKIT_INSPECTOR_SERVER=127.0.0.1:9222 ./build/linux/x64/debug/bundle/flutter_inappwebview_linux_example
  ```
  Then open `inspector://127.0.0.1:9222` in a WebKit-based browser (like Epiphany/GNOME Web) or use `http://127.0.0.1:9222` in Chrome/Edge.
- **Logs**: Use `debugLog()` in C++ which prints to stdout/stderr.
- **GDB**: Standard GDB debugging works for the native plugin code.

---

## C++ Utilities Reference

### \`utils/flutter.h\` - FlValue Serialization

**ALWAYS use these utilities** when creating new C++ types or working with FlValue.

#### FlValue Map Building (\`to_fl_map\`, \`make_fl_value\`)

\`\`\`cpp
#include "../utils/flutter.h"

FlValue* SomeType::toFlValue() const {
  return to_fl_map({
      {"stringField", make_fl_value(someString)},
      {"intField", make_fl_value(someInt)},
      {"optionalField", make_fl_value(optionalValue)},  // auto handles std::optional
      {"nullField", make_fl_value(nullptr)},
  });
}
\`\`\`

| \`make_fl_value(T)\` | Result |
|--------------------|--------|
| \`nullptr\`, \`std::nullopt\` | \`fl_value_new_null()\` |
| \`bool\` | \`fl_value_new_bool()\` |
| \`int32_t\`, \`int64_t\` | \`fl_value_new_int()\` |
| \`double\` | \`fl_value_new_float()\` |
| \`const char*\`, \`std::string\` | \`fl_value_new_string()\` |
| \`std::vector<uint8_t>\` | \`fl_value_new_uint8_list()\` |
| \`std::vector<T>\` | FlValue list (recursive) |
| \`std::map<K, V>\` | FlValue map (recursive) |
| \`std::optional<T>\` | Value or null |

#### FlValue Extraction (\`get_fl_map_value\`, \`get_optional_fl_map_value\`)

\`\`\`cpp
// Constructor from FlValue map
MyType::MyType(FlValue* map)
    : stringField(get_fl_map_value<std::string>(map, "stringField", "")),
      intField(get_fl_map_value<int32_t>(map, "intField", 0)),
      optionalField(get_optional_fl_map_value<std::string>(map, "optionalField")) {}
\`\`\`

| Template Type | With Default | Optional |
|---------------|--------------|----------|
| \`bool\` | ✅ | ✅ |
| \`int32_t\`, \`int64_t\` | ✅ | ✅ |
| \`double\` | ✅ | ✅ |
| \`std::string\` | ✅ | ✅ |
| \`std::vector<std::string>\` | ✅ | ✅ |
| \`std::vector<uint8_t>\` | ❌ | ✅ |
| \`std::map<std::string, std::string>\` | ❌ | ✅ |

#### Map Checking

\`\`\`cpp
if (fl_map_contains(map, "key")) { ... }        // Key exists (may be null)
if (fl_map_contains_not_null(map, "key")) { ... } // Key exists and not null
\`\`\`

---

### \`utils/string.h\` - String Utilities

| Function | Description |
|----------|-------------|
| \`string_equals(s1, s2)\` | Compare strings (supports \`std::string\`, \`const char*\`, \`std::optional<std::string>\`) |
| \`replace_all(source, from, to)\` | Replace all occurrences in-place |
| \`replace_all_copy(source, from, to)\` | Replace all occurrences, return copy |
| \`join(vec, delim)\` | Join vector of strings with delimiter |
| \`split(s, delimiter)\` | Split string into vector |
| \`to_lowercase(s)\` / \`to_lowercase_copy(s)\` | Convert to lowercase |
| \`to_uppercase(s)\` / \`to_uppercase_copy(s)\` | Convert to uppercase |
| \`starts_with(str, prefix)\` | Check if string starts with prefix |
| \`ends_with(str, suffix)\` | Check if string ends with suffix |
| \`string_hash(data)\` | Compile-time string hash (constexpr) |
| \`trim(str)\` | Trim whitespace from both ends |

---

### \`utils/map.h\` - Map Utilities

| Function | Description |
|----------|-------------|
| \`map_contains(map, key)\` | Check if key exists in map |
| \`map_at_or_null(map, key)\` | Get value or nullptr if not found |
| \`map_at_optional(map, key)\` | Get value as \`std::optional<T>\` |

---

### \`utils/vector.h\` - Vector Utilities

| Function | Description |
|----------|-------------|
| \`vector_remove(vec, el)\` | Remove element from vector |
| \`vector_remove_if(vec, predicate)\` | Remove elements matching predicate |
| \`vector_contains(vec, value)\` | Check if vector contains value |
| \`vector_contains_if(vec, predicate)\` | Check if any element matches predicate |
| \`functional_map(iterable, func)\` | Transform iterable (like JS map) |

---

### \`utils/uri.h\` - URI Utilities

| Function | Description |
|----------|-------------|
| \`get_origin_from_url(url)\` | Extract origin (scheme + host + port) |
| \`is_valid_url(url)\` | Check if URL is valid |
| \`get_scheme_from_url(url)\` | Extract scheme (http, https, etc.) |
| \`get_host_from_url(url)\` | Extract host |
| \`url_encode(value)\` | URL-encode a string |

---

### \`utils/log.h\` - Logging Utilities

| Function | Description |
|----------|-------------|
| \`debugLog(msg)\` | Log debug message (only in debug builds) |
| \`errorLog(msg)\` | Log error message |
| \`logGError(error)\` | Log GError with details |
| \`succeededOrLog(error)\` | Return true if no error, log if error |
| \`failedAndLog(error)\` | Return true if error, log it |
| \`failedLog(error)\` | Log error without returning status |

**Usage with macros** (auto-includes file/line):
\`\`\`cpp
debugLog("Message");           // Logs with file:line prefix
if (succeededOrLog(&error)) { ... }  // Check and log GError
\`\`\`

---

### \`utils/defer.h\` - RAII Cleanup Utilities

| Function | Description |
|----------|-------------|
| \`defer(handle, callback)\` | Create shared_ptr with custom deleter |
| \`make_scope_guard(func)\` | RAII guard that calls func on destruction |

\`\`\`cpp
auto guard = make_scope_guard([&]() { cleanup(); });
// cleanup() called when guard goes out of scope
\`\`\`

---

### \`utils/uuid.h\` - UUID Generation

| Function | Description |
|----------|-------------|
| \`get_uuid()\` | Generate UUID v4 string |

---

### \`utils/util.h\` - General Utilities

| Function | Description |
|----------|-------------|
| \`make_pointer_optional(ptr)\` | Convert pointer to \`std::optional<T>\` |
| \`variant_to_string(var)\` | Convert \`std::variant<string, int64_t>\` to string |

---

## Dart-Side Development

For Dart-only changes:
1. Implement platform interface from \`flutter_inappwebview_platform_interface\`
2. Linux implementation is newer and has fewer features than other platforms
3. Check \`LinuxInAppWebViewPlatform\` for currently supported features

## Native Code Development

When modifying C++ code:
- Located in \`linux/\`
- **Prefer standard C++17** over platform-specific APIs for maintainability
- Plugin class: \`FlutterInappwebviewLinuxPlugin\`
- WPE WebKit handles headless rendering to texture

---

## Plugin Scripts JS Reference

JavaScript files injected into WebViews for native-web communication:

| Script | File | Description |
|--------|------|-------------|
| **JavaScriptBridgeJS** | \`javascript_bridge_js.h\` | Core bridge enabling \`window.flutter_inappwebview.callHandler()\` for Dart-JS communication. Uses \`webkit.messageHandlers\` to communicate with WPE WebKit. |
| **ConsoleLogJS** | \`console_log_js.h\` | Intercepts \`console.log/debug/error/info/warn\` and forwards to \`onConsoleMessage\`. Required because WPE WebKit lacks native console-message signal. |
| **WindowIdJS** | \`window_id_js.h\` | Manages window ID for multi-window scenarios (e.g., \`window.open()\`). |
| **ColorInputJS** | \`color_input_js.h\` | Intercepts \`<input type="color">\` clicks since WPE WebKit lacks built-in color picker. Supports \`list\` attribute for predefined colors. |

**Note:** Linux implementation is growing. Current scripts match the most essential iOS/macOS functionality. Additional scripts needed for full parity:
- \`InterceptAjaxRequestJS\` - AJAX interception
- \`InterceptFetchRequestJS\` - Fetch API interception
- \`OnLoadResourceJS\` - Resource loading tracking
- \`PrintJS\` - Print request handling
- \`WebMessageListenerJS\` - postMessage API
- \`FindTextHighlightJS\` - Find in page

---

## Build Commands

\`\`\`bash
cd flutter_inappwebview_linux && flutter pub get
cd example && flutter build linux --debug
\`\`\`

## Dependencies

The example includes WPE WebKit source for reference. Production apps need:
- \`libwpe\` 
- \`wpebackend-fdo\`
- \`wpewebkit\`

## Task File Reference

For detailed implementation tasks, WPE WebKit API mappings, and verification checklists, see:

**[LINUX_IMPLEMENTATION_TASKS.md](../flutter_inappwebview_linux/LINUX_IMPLEMENTATION_TASKS.md)**

Key sections:
- **Critical Issues**: Multi-window support, settings name mismatch
- **Verification Needed**: ~50 APIs marked "complete" need verification against iOS
- **New Features**: Custom Scheme Handler, Download Manager, Content Blockers, etc.
- **Linux-Specific**: Spell Checking, ITP, Geolocation Manager, WebDriver
