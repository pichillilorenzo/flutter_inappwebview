# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "flutter_inappwebview_linux")
project(${PROJECT_NAME} LANGUAGES CXX C)

# This value is used when generating builds using this plugin, so it must
# not be changed.
set(PLUGIN_NAME "flutter_inappwebview_linux_plugin")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# nlohmann/json version for JSON parsing
set(NLOHMANN_JSON_VERSION "3.11.3")

# === WPE WebKit Backend ===
# This plugin uses WPE WebKit for offscreen web rendering.
# WPE WebKit is designed for embedded systems and provides excellent offscreen
# rendering performance through DMA-BUF buffer sharing.
#
# Required packages:
#   - wpe-webkit-2.0 (or wpe-webkit-1.1 on older systems)
#   - wpebackend-fdo-1.0
#   - libwpe-1.0
#
# See WPE_BACKEND.md for installation instructions.

find_package(PkgConfig REQUIRED)

# Always require epoxy for OpenGL support
pkg_check_modules(EPOXY REQUIRED IMPORTED_TARGET epoxy)

# GTK is still needed for GDK (display access, event handling)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

message(STATUS "flutter_inappwebview_linux: Using WPE WebKit backend")

# Try wpe-webkit-2.0 first (newer API), fall back to wpe-webkit-1.1, then wpe-webkit-1.0
pkg_check_modules(WPE_WEBKIT QUIET IMPORTED_TARGET wpe-webkit-2.0)
if(NOT WPE_WEBKIT_FOUND)
  pkg_check_modules(WPE_WEBKIT QUIET IMPORTED_TARGET wpe-webkit-1.1)
  if(WPE_WEBKIT_FOUND)
    message(STATUS "flutter_inappwebview_linux: Found wpe-webkit-1.1 (${WPE_WEBKIT_VERSION})")
  else()
    pkg_check_modules(WPE_WEBKIT QUIET IMPORTED_TARGET wpe-webkit-1.0)
    if(WPE_WEBKIT_FOUND)
      message(STATUS "flutter_inappwebview_linux: Found wpe-webkit-1.0 (${WPE_WEBKIT_VERSION})")
    endif()
  endif()
else()
  message(STATUS "flutter_inappwebview_linux: Found wpe-webkit-2.0 (${WPE_WEBKIT_VERSION})")
endif()

if(NOT WPE_WEBKIT_FOUND)
  message(FATAL_ERROR "WPE WebKit not found. Please install libwpewebkit-1.0-dev (Ubuntu/Debian) or wpe-webkit package.\n"
                      "See WPE_BACKEND.md or https://wpewebkit.org/about/get-wpe.html")
endif()

# Check for WPE Backend FDO (for DMA-BUF export)
pkg_check_modules(WPE_FDO QUIET IMPORTED_TARGET wpebackend-fdo-1.0)
if(WPE_FDO_FOUND)
  message(STATUS "flutter_inappwebview_linux: Found wpebackend-fdo-1.0 (DMA-BUF support enabled)")
  set(HAVE_WPE_FDO ON)
else()
  message(FATAL_ERROR "wpebackend-fdo-1.0 not found. Please install wpebackend-fdo-1.0-dev.\n"
                      "See WPE_BACKEND.md for installation instructions.")
endif()

# Check for libwpe
pkg_check_modules(LIBWPE QUIET IMPORTED_TARGET wpe-1.0)
if(NOT LIBWPE_FOUND)
  message(FATAL_ERROR "libwpe (wpe-1.0) not found. Please install libwpe-1.0-dev.")
endif()

# Check for libsecret for secure credential storage
pkg_check_modules(LIBSECRET REQUIRED IMPORTED_TARGET libsecret-1)
message(STATUS "flutter_inappwebview_linux: Found libsecret-1 (${LIBSECRET_VERSION})")

# Find wayland-server for SHM buffer handling
pkg_check_modules(WAYLAND_SERVER REQUIRED IMPORTED_TARGET wayland-server)

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
)
# Don't build tests/examples
set(JSON_BuildTests OFF CACHE INTERNAL "")
FetchContent_MakeAvailable(nlohmann_json)
# Suppress deprecated literal operator warnings from nlohmann_json
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-literal-operator")
message(STATUS "flutter_inappwebview_linux: nlohmann/json ${NLOHMANN_JSON_VERSION} configured")

# Plugin source files
list(APPEND PLUGIN_SOURCES
  "flutter_inappwebview_linux_plugin.cc"
  "cookie_manager.cc"
  "credential_database.cc"
  "proxy_manager.cc"
  "web_storage_manager.cc"
  "webview_environment.cc"
  "find_interaction/find_interaction_controller.cc"
  "find_interaction/find_interaction_channel_delegate.cc"
  "headless_in_app_webview/headless_in_app_webview.cc"
  "headless_in_app_webview/headless_in_app_webview_manager.cc"
  "in_app_webview/in_app_webview_manager.cc"
  "in_app_webview/custom_platform_view.cc"
  "in_app_webview/inappwebview_texture.cc"
  "in_app_webview/inappwebview_egl_texture.cc"
  "in_app_webview/in_app_webview.cc"
  "in_app_webview/in_app_webview_settings.cc"
  "in_app_webview/user_content_controller.cc"
  "in_app_webview/webview_channel_delegate.cc"
  "types/channel_delegate.cc"
  "types/color_picker_popup.cc"
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
  "types/permission_request.cc"
  "types/permission_response.cc"
  "types/plugin_script.cc"
  "types/server_trust_auth_response.cc"
  "types/server_trust_challenge.cc"
  "types/ssl_certificate.cc"
  "types/url_credential.cc"
  "types/url_protection_space.cc"
  "types/url_request.cc"
  "types/user_script.cc"
  "types/web_resource_error.cc"
  "types/web_resource_request.cc"
  "types/web_resource_response.cc"
  "types/web_view_transport.cc"
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

# Set RPATH so the plugin loads bundled WPE libraries from the same directory.
# $ORIGIN refers to the directory containing the plugin shared library.
# This eliminates the need for LD_LIBRARY_PATH or launcher scripts.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  INSTALL_RPATH "$ORIGIN"
  BUILD_RPATH "$ORIGIN"
  BUILD_WITH_INSTALL_RPATH TRUE)

# Source include directories and library dependencies
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
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::LIBWPE)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::WAYLAND_SERVER)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::WPE_FDO)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::LIBSECRET)

# === Library Bundling ===
# Collect WPE libraries to bundle with the application
# This ensures the app can run without setting LD_LIBRARY_PATH

set(WPE_BUNDLED_LIBS "")

# Helper function to find and add real shared library files (resolving symlinks)
function(find_and_add_library LIB_NAME SEARCH_PATHS OUT_LIST)
  foreach(SEARCH_PATH ${SEARCH_PATHS})
    # Look for the versioned .so file (e.g., libwpe-1.0.so.1.10.0)
    file(GLOB LIB_FILES "${SEARCH_PATH}/${LIB_NAME}.so.*.*.*")
    if(NOT LIB_FILES)
      # Try less specific pattern (e.g., libwpe-1.0.so.1)
      file(GLOB LIB_FILES "${SEARCH_PATH}/${LIB_NAME}.so.*")
    endif()
    if(LIB_FILES)
      # Get the first matching file
      list(GET LIB_FILES 0 LIB_FILE)
      # Resolve symlinks to get the real file
      get_filename_component(REAL_LIB "${LIB_FILE}" REALPATH)
      if(EXISTS "${REAL_LIB}")
        list(APPEND ${OUT_LIST} "${REAL_LIB}")
        set(${OUT_LIST} ${${OUT_LIST}} PARENT_SCOPE)
        message(STATUS "flutter_inappwebview_linux: Will bundle ${REAL_LIB}")
        return()
      endif()
    endif()
  endforeach()
  message(WARNING "flutter_inappwebview_linux: Could not find ${LIB_NAME} to bundle")
endfunction()

# Get library directories from pkg-config
set(WPE_LIB_DIRS "")
if(WPE_WEBKIT_LIBRARY_DIRS)
  list(APPEND WPE_LIB_DIRS ${WPE_WEBKIT_LIBRARY_DIRS})
endif()
if(LIBWPE_LIBRARY_DIRS)
  list(APPEND WPE_LIB_DIRS ${LIBWPE_LIBRARY_DIRS})
endif()
if(WPE_FDO_LIBRARY_DIRS)
  list(APPEND WPE_LIB_DIRS ${WPE_FDO_LIBRARY_DIRS})
endif()
# Add common paths as fallback
list(APPEND WPE_LIB_DIRS 
  "/usr/local/lib"
  "/usr/local/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
  "/usr/lib"
  "/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
)
list(REMOVE_DUPLICATES WPE_LIB_DIRS)

# Find WPE WebKit library
find_and_add_library("libWPEWebKit-2.0" "${WPE_LIB_DIRS}" WPE_BUNDLED_LIBS)

# Find libwpe library  
find_and_add_library("libwpe-1.0" "${WPE_LIB_DIRS}" WPE_BUNDLED_LIBS)

# Find WPE Backend FDO library
find_and_add_library("libWPEBackend-fdo-1.0" "${WPE_LIB_DIRS}" WPE_BUNDLED_LIBS)

# Also need to create symlinks for the sonames that the libraries expect
# This will be handled at install time in the example CMakeLists.txt

set(flutter_inappwebview_linux_bundled_libraries
  ${WPE_BUNDLED_LIBS}
  PARENT_SCOPE
)

# Export library info for downstream use
set(FLUTTER_INAPPWEBVIEW_WPE_LIBS ${WPE_BUNDLED_LIBS} CACHE INTERNAL "WPE libraries to bundle")

# === Tests ===
# These unit tests can be run from a terminal after building the example.

# Only enable test builds when building the example (which sets this variable)
# so that plugin clients aren't building the tests.
if (${include_${PROJECT_NAME}_tests})
if(${CMAKE_VERSION} VERSION_LESS "3.11.0")
message("Unit tests require CMake 3.11.0 or later")
else()
set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()

# Add the Google Test dependency.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/release-1.11.0.zip
)
# Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Disable install commands for gtest so it doesn't end up in the bundle.
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)

FetchContent_MakeAvailable(googletest)

# The plugin's exported API is not very useful for unit testing, so build the
# sources directly into the test binary rather than using the shared library.
add_executable(${TEST_RUNNER}
  test/flutter_inappwebview_linux_plugin_test.cc
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE 
  "${CMAKE_CURRENT_SOURCE_DIR}" 
  ${EPOXY_INCLUDE_DIRS}
  ${WPE_WEBKIT_INCLUDE_DIRS})
target_link_libraries(${TEST_RUNNER} PRIVATE flutter)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::GTK)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::EPOXY)
target_link_libraries(${TEST_RUNNER} PRIVATE nlohmann_json::nlohmann_json)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::WPE_WEBKIT)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::LIBWPE)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::WAYLAND_SERVER)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::WPE_FDO)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::LIBSECRET)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)

# Enable automatic test discovery.
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})

endif()  # CMake version check
endif()  # include_${PROJECT_NAME}_tests
