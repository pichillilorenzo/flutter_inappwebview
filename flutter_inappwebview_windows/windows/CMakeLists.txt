# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

set(WIL_VERSION "1.0.231216.1")
set(WEBVIEW_VERSION "1.0.2210.55")

message(VERBOSE "CMake system version is ${CMAKE_SYSTEM_VERSION} (using SDK ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION})")

# Project-level configuration.
set(PROJECT_NAME "flutter_inappwebview_windows")
project(${PROJECT_NAME} LANGUAGES CXX)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_inappwebview_windows_plugin")

set(NUGET_URL https://dist.nuget.org/win-x86-commandline/latest/nuget.exe)

find_program(NUGET nuget)
if(NOT NUGET)
  message(NOTICE "Nuget is not installed.")
  set(NUGET ${CMAKE_BINARY_DIR}/nuget.exe)
  if (NOT EXISTS ${NUGET})
    message(NOTICE "Attempting to download nuget.")
    file(DOWNLOAD ${NUGET_URL} ${NUGET})
  endif()
endif()

add_custom_target(${PROJECT_NAME}_DEPENDENCIES_DOWNLOAD ALL)
add_custom_command(
  TARGET ${PROJECT_NAME}_DEPENDENCIES_DOWNLOAD PRE_BUILD
  COMMAND ${NUGET} install Microsoft.Windows.ImplementationLibrary -Version ${WIL_VERSION} -ExcludeVersion -OutputDirectory ${CMAKE_BINARY_DIR}/packages
  COMMAND ${NUGET} install Microsoft.Web.WebView2 -Version ${WEBVIEW_VERSION} -ExcludeVersion -OutputDirectory ${CMAKE_BINARY_DIR}/packages
  DEPENDS ${NUGET}
)

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "flutter_inappwebview_windows_plugin.cpp"
  "flutter_inappwebview_windows_plugin.h"
  "utils/strconv.h"
  "utils/util.h"
  "utils/flutter.h"
  "types/channel_delegate.cpp"
  "types/channel_delegate.h"
  "types/base_callback_result.h"
  "types/url_request.cpp"
  "types/url_request.h"
  "types/navigation_action.cpp"
  "types/navigation_action.h"
  "types/web_resource_error.cpp"
  "types/web_resource_error.h"
  "types/web_resource_request.cpp"
  "types/web_resource_request.h"
  "types/web_resource_response.cpp"
  "types/web_resource_response.h"
  "in_app_webview/in_app_webview_settings.cpp"
  "in_app_webview/in_app_webview_settings.h"
  "in_app_webview/in_app_webview.cpp"
  "in_app_webview/in_app_webview.h"
  "in_app_webview/webview_channel_delegate.cpp"
  "in_app_webview/webview_channel_delegate.h"
  "in_app_browser/in_app_browser_settings.cpp"
  "in_app_browser/in_app_browser_settings.h"
  "in_app_browser/in_app_browser_manager.cpp"
  "in_app_browser/in_app_browser_manager.h"
  "in_app_browser/in_app_browser.cpp"
  "in_app_browser/in_app_browser.h"
  "in_app_browser/in_app_browser_channel_delegate.cpp"
  "in_app_browser/in_app_browser_channel_delegate.h"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/flutter_inappwebview_windows/flutter_inappwebview_windows_plugin_c_api.h"
  "flutter_inappwebview_windows_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

target_link_libraries(${PLUGIN_NAME} PRIVATE ${CMAKE_BINARY_DIR}/packages/Microsoft.Web.WebView2/build/native/Microsoft.Web.WebView2.targets)
target_link_libraries(${PLUGIN_NAME} PRIVATE ${CMAKE_BINARY_DIR}/packages/Microsoft.Windows.ImplementationLibrary/build/native/Microsoft.Windows.ImplementationLibrary.targets)

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(flutter_inappwebview_windows_bundled_libraries
  PARENT_SCOPE
)

# === Tests ===
# These unit tests can be run from a terminal after building the example, or
# from Visual Studio after opening the generated solution file.

# Only enable test builds when building the example (which sets this variable)
# so that plugin clients aren't building the tests.
if (${include_${PROJECT_NAME}_tests})
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

# The plugin's C API is not very useful for unit testing, so build the sources
# directly into the test binary rather than using the DLL.
add_executable(${TEST_RUNNER}
  test/flutter_inappwebview_windows_plugin_test.cpp
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)
# flutter_wrapper_plugin has link dependencies on the Flutter DLL.
add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
)

# Enable automatic test discovery.
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})
endif()
