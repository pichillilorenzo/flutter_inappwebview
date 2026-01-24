# Project-level configuration.
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "flutter_inappwebview_linux_example")
# The unique GTK application identifier for this application. See:
# https://wiki.gnome.org/HowDoI/ChooseApplicationID
set(APPLICATION_ID "com.pichillilorenzo.flutter_inappwebview_linux")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

# Load bundled libraries from the lib/ directory relative to the binary.
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Root filesystem for cross-building.
if(FLUTTER_TARGET_PLATFORM_SYSROOT)
  set(CMAKE_SYSROOT ${FLUTTER_TARGET_PLATFORM_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif()

# Define build configuration options.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE
    STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Only the install-generated bundle's copy of the executable will launch
# correctly, since the resources must in the right relative locations. To avoid
# people trying to run the unbundled copy, put it in a subdirectory instead of
# the default top-level location.
set_target_properties(${BINARY_NAME}
  PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run"
)

# Enable the test target.
set(include_flutter_inappwebview_linux_tests TRUE)

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# By default, "installing" just makes a relocatable bundle in the build
# directory.
set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

# Start with a clean build bundle directory every time.
install(CODE "
  file(REMOVE_RECURSE \"${BUILD_BUNDLE_DIR}/\")
  " COMPONENT Runtime)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endforeach(bundled_library)

# === WPE Library Symlink Creation ===
# Create the necessary soname symlinks so the WPE libraries can find each other at runtime
install(CODE "
  # Create symlinks for WPE libraries in the lib directory
  set(LIB_DIR \"${INSTALL_BUNDLE_LIB_DIR}\")
    
    # Function to create soname symlinks for a library
    macro(create_lib_symlinks LIB_PATTERN SONAME_BASE)
      file(GLOB LIB_FILES \"\${LIB_DIR}/\${LIB_PATTERN}\")
      if(LIB_FILES)
        list(GET LIB_FILES 0 REAL_LIB)
        get_filename_component(REAL_LIB_NAME \"\${REAL_LIB}\" NAME)
        
        # Create .so.X symlink (e.g., libwpe-1.0.so.1 -> libwpe-1.0.so.1.10.0)
        set(SONAME_LINK \"\${LIB_DIR}/\${SONAME_BASE}.so.1\")
        if(NOT EXISTS \"\${SONAME_LINK}\")
          execute_process(COMMAND \${CMAKE_COMMAND} -E create_symlink
            \"\${REAL_LIB_NAME}\" \"\${SONAME_LINK}\")
          message(STATUS \"Created symlink: \${SONAME_LINK} -> \${REAL_LIB_NAME}\")
        endif()
        
        # Create .so symlink (e.g., libwpe-1.0.so -> libwpe-1.0.so.1)
        set(SO_LINK \"\${LIB_DIR}/\${SONAME_BASE}.so\")
        if(NOT EXISTS \"\${SO_LINK}\")
          execute_process(COMMAND \${CMAKE_COMMAND} -E create_symlink
            \"\${SONAME_BASE}.so.1\" \"\${SO_LINK}\")
          message(STATUS \"Created symlink: \${SO_LINK} -> \${SONAME_BASE}.so.1\")
        endif()
      endif()
    endmacro()
    
    # Create symlinks for each WPE library
    create_lib_symlinks(\"libWPEWebKit-2.0.so.*.*.*\" \"libWPEWebKit-2.0\")
    create_lib_symlinks(\"libwpe-1.0.so.*.*.*\" \"libwpe-1.0\")
    create_lib_symlinks(\"libWPEBackend-fdo-1.0.so.*.*.*\" \"libWPEBackend-fdo-1.0\")
    
    # Create the default backend symlink that WPE expects
    set(DEFAULT_BACKEND_LINK \"\${LIB_DIR}/libWPEBackend-default.so\")
    if(NOT EXISTS \"\${DEFAULT_BACKEND_LINK}\")
      execute_process(COMMAND \${CMAKE_COMMAND} -E create_symlink
        \"libWPEBackend-fdo-1.0.so.1\" \"\${DEFAULT_BACKEND_LINK}\")
      message(STATUS \"Created symlink: \${DEFAULT_BACKEND_LINK} -> libWPEBackend-fdo-1.0.so.1\")
    endif()
  " COMPONENT Runtime)

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/linux/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
if(NOT CMAKE_BUILD_TYPE MATCHES "Debug")
  install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()
