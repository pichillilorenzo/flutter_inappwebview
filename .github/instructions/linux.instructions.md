---
applyTo: "flutter_inappwebview_linux/**"
---

# Linux Platform Implementation Instructions

## Implemented Dart Classes

| Class | File | Description |
|-------|------|-------------|
| \`LinuxInAppWebViewPlatform\` | \`inappwebview_platform.dart\` | Platform factory - registers all Linux implementations |
| \`LinuxInAppWebViewWidget\` | \`in_app_webview/in_app_webview.dart\` | WebView widget using texture-based rendering |
| \`LinuxInAppWebViewController\` | \`in_app_webview/in_app_webview_controller.dart\` | WPE WebKit controller |
| \`LinuxHeadlessInAppWebView\` | \`in_app_webview/headless_in_app_webview.dart\` | Offscreen WebView |
| \`LinuxInAppBrowser\` | \`in_app_browser/\` | Full-screen browser |
| \`LinuxCookieManager\` | \`cookie_manager/\` | WebKit cookie management |
| \`LinuxWebStorageManager\` | \`web_storage/\` | Website data management |
| \`LinuxFindInteractionController\` | \`find_interaction/\` | Find in page |
| \`LinuxWebMessageChannel/Port/Listener\` | \`web_message/\` | WKScriptMessageHandler wrapper |
| \`LinuxJavaScriptReplyProxy\` | \`web_message/\` | JavaScript reply proxy |
| \`LinuxProxyController\` | \`proxy_controller/\` | Proxy configuration |
| \`LinuxHttpAuthCredentialDatabase\` | \`http_auth_credentials_database.dart\` | HTTP auth credentials storage |
| \`LinuxWebViewEnvironment\` | \`webview_environment/\` | WebView environment configuration |

---

## Native Code Structure

\`\`\`
linux/
├── CMakeLists.txt                           # CMake build config (links WPE WebKit)
├── flutter_inappwebview_linux_plugin.cc     # Plugin entry point
├── flutter_inappwebview_linux_plugin_private.h
│
├── plugin_instance.cc/h                     # Plugin instance management
├── cookie_manager.cc/h                      # WebKit cookie manager wrapper
├── web_storage_manager.cc/h                 # WebKit website data manager
├── credential_database.cc/h                 # HTTP auth credentials storage
├── proxy_manager.cc/h                       # Proxy configuration
├── webview_environment.cc/h                 # WebView environment configuration
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
├── in_app_browser/                          # Browser implementation
│   ├── in_app_browser.cc/h                  # Browser window implementation
│   ├── in_app_browser_manager.cc/h          # Instance management
│   ├── in_app_browser_settings.cc/h         # Browser settings
│   └── in_app_browser_channel_delegate.cc/h # Channel communication
│
├── find_interaction/                        # Find in page
│   ├── find_interaction_controller.cc/h     # Find controller
│   └── find_interaction_channel_delegate.cc/h # Channel communication
│
├── web_message/                             # WKScriptMessageHandler implementation
│   ├── web_message_channel.cc/h             # WebMessageChannel wrapper
│   ├── web_message_listener.cc/h            # WebMessageListener implementation
│   └── web_message_listener_channel_delegate.cc/h # Listener channel
│
├── content_blocker/                         # Content blocking
│   └── content_blocker_handler.cc/h         # Content blocker handler
│
├── plugin_scripts_js/                       # Injected JavaScript for bridge
│   ├── javascript_bridge_js.h               # Core JS bridge
│   ├── console_log_js.h                     # Console interception
│   ├── intercept_ajax_request_js.h          # AJAX interception
│   ├── intercept_fetch_request_js.h         # Fetch API interception
│   ├── on_load_resource_js.h                # Resource loading tracking
│   ├── print_interception_js.h              # Print request handling
│   ├── web_message_listener_js.h            # PostMessage API
│   ├── web_message_channel_js.h             # WebMessage channel variables
│   ├── window_id_js.h                       # Window ID management
│   ├── color_input_js.h                     # Color input handling
│   ├── date_input_js.h                      # Date input handling
│   └── cursor_detection_js.h                # Cursor detection for hover states
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
│   ├── util.h                               # General utilities
│   ├── gl_context.h                         # OpenGL context utilities
│   └── software_rendering.cc/h              # Software rendering fallback
│
└── types/                                   # Type definitions
\`\`\`

---

## Platform Requirements

- **Required**: WPE WebKit libraries (\`libwpe\`, \`wpewebkit\`)
- **Optional**: \`wpebackend-fdo\` (legacy fallback backend - only needed if WPEPlatform is not available)

## Native APIs Used

- [WPE WebKit 2.0](https://wpewebkit.org/) for offscreen rendering
- Official documentation: https://wpewebkit.org/reference(zero-copy GPU textures) or SHM (shared memory) as fallback
- Backend: WPEPlatform (default, modern API) or WPEBackend-FDO (legacy fallback)-2.0/index.html
- Uses texture-based platform view rendering via DMA-BUF or SHM as fallback

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

ForExtend \`Platform*CreationParams\` for Linux-specific parameters
3. Register in \`LinuxInAppWebViewPlatform.registerWith()\`
4. Linux-specific features: Texture-based rendering, DMA-BUF GPU integration, WPE WebKit backend selectionterface\`
2. Linux implementation is newer and has fewer features than other platforms
3. Check \`LinuxInAppWebViewPlatform\` for currently supported features

## Native Code Development

When modifying C++ code:
- Main plugin class: \`FlutterInappwebviewLinuxPlugin\`
- Core WebView class: \`InAppWebView\` (handles WPE WebKit integration)
- WPE WebKit handles headless rendering to texture via EGL or SHM
- Use provided utilities in \`utils/\` for FlValue serialization, string operations, etc. APIs for maintainability
- Plugin class: \`FlutterInappwebviewLinuxPlugin\`
- WPE WebKit handles headless rendering to texture
