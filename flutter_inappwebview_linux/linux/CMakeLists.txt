# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "flutter_inappwebview_linux")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed.
set(PLUGIN_NAME "flutter_inappwebview_linux_plugin")

# The WebView implementation uses C++17 (for example, std::optional).
# Keep this requirement even when the application's standard settings use C++14.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# nlohmann/json version for JSON parsing
set(NLOHMANN_JSON_VERSION "3.12.0")

# === WPE WebKit Backend ===
# This plugin uses WPE WebKit for offscreen web rendering.
# WPE WebKit is designed for embedded systems and provides excellent offscreen
# rendering performance through DMA-BUF buffer sharing.
#
# Prefer WPEPlatform 2.54, retain the 2.52 API and legacy FDO backend.
# Backend selection is made at build time, not by switching libraries at runtime.
# See WPE_BACKEND.md for dependencies and SDK configuration.
set(FLUTTER_INAPPWEBVIEW_WPE_BACKEND "AUTO" CACHE STRING
    "WPE backend: AUTO, PLATFORM or LEGACY")
set_property(CACHE FLUTTER_INAPPWEBVIEW_WPE_BACKEND PROPERTY STRINGS AUTO PLATFORM LEGACY)
if(NOT FLUTTER_INAPPWEBVIEW_WPE_BACKEND MATCHES "^(AUTO|PLATFORM|LEGACY)$")
  message(FATAL_ERROR "FLUTTER_INAPPWEBVIEW_WPE_BACKEND must be AUTO, PLATFORM or LEGACY")
endif()
option(FLUTTER_INAPPWEBVIEW_BUNDLE_WPE "Bundle WPE libraries with the Flutter application" ON)
set(FLUTTER_INAPPWEBVIEW_WPE_INSTALL_RPATH "$ORIGIN" CACHE STRING
    "Runtime search paths relative to the installed plugin")

find_package(PkgConfig REQUIRED)

# Always require epoxy for OpenGL support
pkg_check_modules(EPOXY REQUIRED IMPORTED_TARGET epoxy)

# GTK is still needed for GDK (display access, event handling)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

message(STATUS "flutter_inappwebview_linux: Using WPE WebKit backend")

# The implementation uses the 2.0 API (network sessions and JS replies).
# FDO is a rendering backend, not a compatibility layer for WebKit's 1.x API.
pkg_check_modules(WPE_WEBKIT QUIET IMPORTED_TARGET wpe-webkit-2.0>=2.48)
if(NOT WPE_WEBKIT_FOUND)
  message(FATAL_ERROR
    "This plugin requires wpe-webkit-2.0 >= 2.48. "
    "WebKit <2.48 lacks some APIs required by this plugin, including network sessions, "
    "JavaScript message replies and all-cookie retrieval. FDO does not provide these APIs. "
    "Install a newer WPE SDK and select it with PKG_CONFIG_PATH. See WPE_BACKEND.md.")
endif()
message(STATUS "flutter_inappwebview_linux: WPE WebKit ${WPE_WEBKIT_VERSION}")

# Use imported targets in link probes: bare -l names lose a custom SDK's -L
# paths and can either fail or accidentally test a system WebKit instead.
include(CheckCXXSourceCompiles)
include(CMakePushCheckState)
cmake_push_check_state(RESET)
set(CMAKE_REQUIRED_LIBRARIES PkgConfig::WPE_WEBKIT)
unset(WEBKIT_HAS_NETWORK_SESSION_API CACHE)
check_cxx_source_compiles("
  #include <wpe/webkit.h>
  int main() {
    auto* session = webkit_network_session_new(nullptr, nullptr);
    g_object_unref(session);
    return 0;
  }
" WEBKIT_HAS_NETWORK_SESSION_API)
if(NOT WEBKIT_HAS_NETWORK_SESSION_API)
  message(FATAL_ERROR "The plugin requires the WebKit network-session API (wpe-webkit-2.0). "
                      "The legacy FDO backend does not imply support for the old 1.x WebKit API.")
endif()

set(HAVE_WPE_PLATFORM OFF)
set(HAVE_WPE_FDO OFF)
if(NOT FLUTTER_INAPPWEBVIEW_WPE_BACKEND STREQUAL "LEGACY")
  pkg_check_modules(WPE_PLATFORM QUIET IMPORTED_TARGET wpe-platform-2.0>=2.52)
  pkg_check_modules(WPE_PLATFORM_HEADLESS QUIET IMPORTED_TARGET wpe-platform-headless-2.0>=2.52)
  if(WPE_PLATFORM_FOUND AND WPE_PLATFORM_HEADLESS_FOUND)
    # All three modules belong to the same WebKit build. Do not mix SDK and
    # distribution headers/libraries just because their module names match.
    if(NOT WPE_PLATFORM_VERSION VERSION_EQUAL WPE_WEBKIT_VERSION OR
       NOT WPE_PLATFORM_HEADLESS_VERSION VERSION_EQUAL WPE_WEBKIT_VERSION OR
       NOT WPE_PLATFORM_PREFIX STREQUAL WPE_WEBKIT_PREFIX OR
       NOT WPE_PLATFORM_HEADLESS_PREFIX STREQUAL WPE_WEBKIT_PREFIX)
      message(FATAL_ERROR "WPE WebKit, WPEPlatform and headless must come from the same SDK")
    endif()
    set(CMAKE_REQUIRED_LIBRARIES PkgConfig::WPE_WEBKIT
        PkgConfig::WPE_PLATFORM PkgConfig::WPE_PLATFORM_HEADLESS)
    unset(WEBKIT_HAS_WPE_PLATFORM_API CACHE)
    check_cxx_source_compiles("
      #include <wpe/webkit.h>
      #include <wpe/wpe-platform.h>
      #include <wpe/headless/wpe-headless.h>
      int main() {
        auto* display = wpe_display_headless_new();
        auto* view = webkit_web_view_get_wpe_view(nullptr);
        auto* toplevel = wpe_view_get_toplevel(view);
        wpe_toplevel_resize(toplevel, 1, 1);
        g_object_unref(display);
        return 0;
      }
    " WEBKIT_HAS_WPE_PLATFORM_API)
    if(WEBKIT_HAS_WPE_PLATFORM_API)
      set(HAVE_WPE_PLATFORM ON)
      add_compile_definitions(HAVE_WPE_PLATFORM=1)
      message(STATUS "flutter_inappwebview_linux: WPEPlatform ${WPE_PLATFORM_VERSION} + headless")
    endif()
  endif()
endif()

if(NOT HAVE_WPE_PLATFORM)
  if(FLUTTER_INAPPWEBVIEW_WPE_BACKEND STREQUAL "PLATFORM")
    message(FATAL_ERROR "WPEPlatform >= 2.52 with headless is required by the selected backend")
  endif()
  pkg_check_modules(WPE_FDO REQUIRED IMPORTED_TARGET wpebackend-fdo-1.0)
  pkg_check_modules(LIBWPE REQUIRED IMPORTED_TARGET wpe-1.0)
  pkg_check_modules(WAYLAND_SERVER REQUIRED IMPORTED_TARGET wayland-server)
  set(CMAKE_REQUIRED_LIBRARIES PkgConfig::WPE_WEBKIT PkgConfig::WPE_FDO PkgConfig::LIBWPE)
  unset(WEBKIT_HAS_WPE_LEGACY_API CACHE)
  check_cxx_source_compiles("
    #include <wpe/webkit.h>
    int main() {
      auto* backend = webkit_web_view_backend_new(nullptr, nullptr, nullptr);
      webkit_web_view_backend_unref(backend);
      return 0;
    }
  " WEBKIT_HAS_WPE_LEGACY_API)
  if(NOT WEBKIT_HAS_WPE_LEGACY_API)
    message(FATAL_ERROR "Selected WebKit has no legacy API. Use WPEPlatform + headless, "
                        "or a WebKit build with ENABLE_WPE_LEGACY_API=ON for FDO.")
  endif()
  set(HAVE_WPE_FDO ON)
  add_compile_definitions(HAVE_WPE_BACKEND_LEGACY=1)
  message(STATUS "flutter_inappwebview_linux: Legacy WPEBackend-FDO")
endif()
cmake_pop_check_state()

# Check for libsecret for secure credential storage
pkg_check_modules(LIBSECRET REQUIRED IMPORTED_TARGET libsecret-1)
message(STATUS "flutter_inappwebview_linux: Found libsecret-1 (${LIBSECRET_VERSION})")

# Enable SIMD optimizations for color conversion
# These flags enable NEON on ARM64 and SSE/SSSE3 on x86_64
include(CheckCXXCompilerFlag)
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64|ARM64")
  # ARM64: NEON is always available
  message(STATUS "flutter_inappwebview_linux: ARM64 detected, NEON enabled")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|amd64")
  # x86_64: Check for SSSE3 support
  check_cxx_compiler_flag("-mssse3" COMPILER_SUPPORTS_SSSE3)
  if(COMPILER_SUPPORTS_SSSE3)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mssse3")
    message(STATUS "flutter_inappwebview_linux: x86_64 with SSSE3 enabled")
  else()
    check_cxx_compiler_flag("-msse2" COMPILER_SUPPORTS_SSE2)
    if(COMPILER_SUPPORTS_SSE2)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse2")
      message(STATUS "flutter_inappwebview_linux: x86_64 with SSE2 enabled")
    endif()
  endif()
endif()

# === nlohmann/json dependency for JSON parsing ===
include(FetchContent)
FetchContent_Declare(
  nlohmann_json
  URL https://github.com/nlohmann/json/releases/download/v${NLOHMANN_JSON_VERSION}/json.tar.xz
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
# Don't build tests/examples
set(JSON_BuildTests OFF CACHE INTERNAL "")
FetchContent_MakeAvailable(nlohmann_json)
# Suppress deprecated literal operator warnings from nlohmann_json
check_cxx_compiler_flag("-Wdeprecated-literal-operator" COMPILER_SUPPORTS_DEPRECATED_LITERAL_OPERATOR)
if(COMPILER_SUPPORTS_DEPRECATED_LITERAL_OPERATOR)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-literal-operator")
endif()
message(STATUS "flutter_inappwebview_linux: nlohmann/json ${NLOHMANN_JSON_VERSION} configured")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "flutter_inappwebview_linux_plugin.cc"
  "plugin_instance.cc"
  "cookie_manager.cc"
  "credential_database.cc"
  "proxy_manager.cc"
  "utils/software_rendering.cc"
  "web_storage_manager.cc"
  "webview_environment.cc"
  "content_blocker/content_blocker_handler.cc"
  "find_interaction/find_interaction_controller.cc"
  "find_interaction/find_interaction_channel_delegate.cc"
  "headless_in_app_webview/headless_in_app_webview.cc"
  "headless_in_app_webview/headless_in_app_webview_manager.cc"
  "headless_in_app_webview/headless_webview_channel_delegate.cc"
  "in_app_browser/in_app_browser.cc"
  "in_app_browser/in_app_browser_channel_delegate.cc"
  "in_app_browser/in_app_browser_manager.cc"
  "in_app_browser/in_app_browser_settings.cc"
  "in_app_webview/in_app_webview_manager.cc"
  "in_app_webview/custom_platform_view.cc"
  "in_app_webview/inappwebview_texture.cc"
  "in_app_webview/inappwebview_egl_texture.cc"
  "in_app_webview/in_app_webview.cc"
  "in_app_webview/in_app_webview_settings.cc"
  "in_app_webview/user_content_controller.cc"
  "in_app_webview/webview_channel_delegate.cc"
  "types/channel_delegate.cc"
  "types/client_cert_challenge.cc"
  "types/client_cert_response.cc"
  "types/content_world.cc"
  "types/context_menu_popup.cc"
  "types/create_window_action.cc"
  "types/custom_scheme_response.cc"
  "types/download_start_request.cc"
  "types/download_start_response.cc"
  "types/find_session.cc"
  "types/http_auth_response.cc"
  "types/http_authentication_challenge.cc"
  "types/javascript_handler_function_data.cc"
  "types/js_alert_request.cc"
  "types/js_alert_response.cc"
  "types/js_before_unload_response.cc"
  "types/js_confirm_request.cc"
  "types/js_confirm_response.cc"
  "types/js_prompt_request.cc"
  "types/js_prompt_response.cc"
  "types/hit_test_result.cc"
  "types/navigation_action.cc"
  "types/option_menu_popup.cc"
  "types/permission_request.cc"
  "types/permission_response.cc"
  "types/plugin_script.cc"
  "types/server_trust_auth_response.cc"
  "types/server_trust_challenge.cc"
  "types/show_file_chooser_response.cc"
  "types/ssl_certificate.cc"
  "types/url_credential.cc"
  "types/url_protection_space.cc"
  "types/url_request.cc"
  "types/user_script.cc"
  "types/web_resource_error.cc"
  "types/web_resource_request.cc"
  "types/web_resource_response.cc"
  "types/web_view_transport.cc"
  "web_message/web_message_channel.cc"
  "web_message/web_message_listener.cc"
  "web_message/web_message_listener_channel_delegate.cc"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Flutter copies the plugin via install(FILES), which does not rewrite RPATH.
# Link with the runtime paths already set, including for flutter run bundles.
# WebKit subprocesses and resources still need a complete runtime installation.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  INSTALL_RPATH "${FLUTTER_INAPPWEBVIEW_WPE_INSTALL_RPATH}"
  BUILD_WITH_INSTALL_RPATH TRUE)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  ${EPOXY_INCLUDE_DIRS}
  ${WPE_WEBKIT_INCLUDE_DIRS})

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::EPOXY)
target_link_libraries(${PLUGIN_NAME} PRIVATE nlohmann_json::nlohmann_json)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::WPE_WEBKIT)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::LIBSECRET)

# Link WPEPlatform if available (new API - default)
if(HAVE_WPE_PLATFORM)
  target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::WPE_PLATFORM)
  target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::WPE_PLATFORM_HEADLESS)
endif()

# Link WPEBackend-FDO if available (legacy fallback)
if(HAVE_WPE_FDO)
  target_link_libraries(${PLUGIN_NAME} PRIVATE
    PkgConfig::WPE_FDO PkgConfig::LIBWPE PkgConfig::WAYLAND_SERVER)
endif()

# === Library Bundling ===
# Collect WPE libraries to bundle with the application
# This ensures the app can run without setting LD_LIBRARY_PATH

set(WPE_BUNDLED_LIBS "")

# Keep the linker/SONAME symlinks as well as their real file. Flutter installs
# the returned list as files and does not create missing SONAME links for us.
# Search only directories belonging to the selected pkg-config module.
function(find_and_add_library LIB_NAME SEARCH_PATHS OUT_LIST)
  unset(WPE_BUNDLE_LIBRARY CACHE)
  find_library(WPE_BUNDLE_LIBRARY NAMES "${LIB_NAME}.so"
    PATHS ${SEARCH_PATHS} NO_DEFAULT_PATH)
  if(NOT WPE_BUNDLE_LIBRARY)
    message(FATAL_ERROR "Could not find ${LIB_NAME} in the selected WPE SDK")
  endif()
  get_filename_component(REAL_LIB "${WPE_BUNDLE_LIBRARY}" REALPATH)
  get_filename_component(LIB_DIR "${WPE_BUNDLE_LIBRARY}" DIRECTORY)
  file(GLOB LIB_FILES "${LIB_DIR}/${LIB_NAME}.so*")
  foreach(LIB_FILE IN LISTS LIB_FILES)
    get_filename_component(RESOLVED_LIB "${LIB_FILE}" REALPATH)
    if(RESOLVED_LIB STREQUAL REAL_LIB)
      list(APPEND ${OUT_LIST} "${LIB_FILE}")
    endif()
  endforeach()
  list(REMOVE_DUPLICATES ${OUT_LIST})
  set(${OUT_LIST} ${${OUT_LIST}} PARENT_SCOPE)
  unset(WPE_BUNDLE_LIBRARY CACHE)
endfunction()

if(FLUTTER_INAPPWEBVIEW_BUNDLE_WPE)
  find_and_add_library("libWPEWebKit-2.0" "${WPE_WEBKIT_LIBRARY_DIRS}" WPE_BUNDLED_LIBS)
  # WPEPlatform/headless are part of libWPEWebKit, not separate libraries.
  if(HAVE_WPE_FDO)
    find_and_add_library("libwpe-1.0" "${LIBWPE_LIBRARY_DIRS}" WPE_BUNDLED_LIBS)
    find_and_add_library("libWPEBackend-fdo-1.0" "${WPE_FDO_LIBRARY_DIRS}" WPE_BUNDLED_LIBS)
  endif()
endif()

set(flutter_inappwebview_linux_bundled_libraries
  ${WPE_BUNDLED_LIBS}
  PARENT_SCOPE
)

# Export library info for downstream use
set(FLUTTER_INAPPWEBVIEW_WPE_LIBS ${WPE_BUNDLED_LIBS} CACHE INTERNAL "WPE libraries to bundle")

# === Tests ===
# Opt in from the host application's CMakeLists.txt before loading plugins:
# set(include_flutter_inappwebview_linux_tests TRUE)
if(include_${PROJECT_NAME}_tests)
  enable_testing()
  add_executable(${PROJECT_NAME}_frame_pixels_test test/frame_pixels_test.cc)
  target_compile_features(${PROJECT_NAME}_frame_pixels_test PRIVATE cxx_std_17)
  add_test(NAME ${PROJECT_NAME}_frame_pixels_test COMMAND ${PROJECT_NAME}_frame_pixels_test)
  if(CMAKE_VERSION VERSION_LESS "3.11.0")
    message("Unit tests require CMake 3.11.0 or later")
  else()
    set(TEST_RUNNER "${PROJECT_NAME}_test")
    enable_testing()

    # Match the Flutter Linux plugin template's Google Test setup.
    include(FetchContent)
    FetchContent_Declare(
      googletest
      URL https://github.com/google/googletest/archive/release-1.11.0.zip
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
    FetchContent_MakeAvailable(googletest)

    # Compile the implementation directly to test private, non-exported helpers.
    add_executable(${TEST_RUNNER}
      test/flutter_inappwebview_linux_plugin_test.cc
      test/wpe_settings_test.cc
      ${PLUGIN_SOURCES}
    )
    apply_standard_settings(${TEST_RUNNER})
    target_include_directories(${TEST_RUNNER} PRIVATE
      "${CMAKE_CURRENT_SOURCE_DIR}"
      ${EPOXY_INCLUDE_DIRS}
      ${WPE_WEBKIT_INCLUDE_DIRS})
    target_link_libraries(${TEST_RUNNER} PRIVATE
      flutter
      PkgConfig::GTK
      PkgConfig::EPOXY
      nlohmann_json::nlohmann_json
      PkgConfig::WPE_WEBKIT
      PkgConfig::LIBSECRET
      gtest_main
      gmock)
    if(HAVE_WPE_PLATFORM)
      target_link_libraries(${TEST_RUNNER} PRIVATE
        PkgConfig::WPE_PLATFORM
        PkgConfig::WPE_PLATFORM_HEADLESS)
    endif()
    if(HAVE_WPE_FDO)
      target_link_libraries(${TEST_RUNNER} PRIVATE
        PkgConfig::WPE_FDO PkgConfig::LIBWPE PkgConfig::WAYLAND_SERVER)
    endif()

    include(GoogleTest)
    gtest_discover_tests(${TEST_RUNNER})
  endif()
endif()
