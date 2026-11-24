#!/usr/bin/env bash
# Compile/link the native plugin and run its display-independent unit tests.
# Usage: FLUTTER_LINUX_ENGINE_DIR=/path/to/engine/linux-x64 ./tool/check_linux_build.sh [CMake options...]
set -euo pipefail
if [[ "$(uname -s)" != Linux ]]; then
  echo "Run this check on Linux with the selected WPE development packages/SDK." >&2
  exit 1
fi
: "${FLUTTER_LINUX_ENGINE_DIR:?Set to Flutter engine directory containing flutter_linux/ and libflutter_linux_gtk.so}"
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$(cd "$FLUTTER_LINUX_ENGINE_DIR" && pwd)"
if [[ ! -f "$ENGINE_DIR/flutter_linux/flutter_linux.h" || ! -f "$ENGINE_DIR/libflutter_linux_gtk.so" ]]; then
  echo "Missing Flutter Linux engine headers or library in $ENGINE_DIR (flutter precache --linux)." >&2
  exit 1
fi
CHECK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/inappwebview-linux-check.XXXXXX")"
OUTPUT_DIR="${FLUTTER_LINUX_CHECK_OUTPUT_DIR:-$CHECK_DIR/logs}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
cleanup() {
  local status=$?
  for log in CMakeCache.txt CMakeFiles/CMakeConfigureLog.yaml CMakeFiles/CMakeError.log CMakeFiles/CMakeOutput.log Testing/Temporary/LastTest.log; do
    if [[ -f "$CHECK_DIR/build/$log" ]]; then
      cp "$CHECK_DIR/build/$log" "$OUTPUT_DIR/" || true
    fi
  done
  rm -rf "$CHECK_DIR"
  exit "$status"
}
trap cleanup EXIT
cat > "$CHECK_DIR/CMakeLists.txt" <<'CMAKE'
cmake_minimum_required(VERSION 3.21)
project(inappwebview_linux_check LANGUAGES CXX)
enable_testing()
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
add_library(flutter SHARED IMPORTED)
set_target_properties(flutter PROPERTIES
  IMPORTED_LOCATION "${ENGINE_DIR}/libflutter_linux_gtk.so"
  INTERFACE_INCLUDE_DIRECTORIES "${ENGINE_DIR}"
  INTERFACE_LINK_LIBRARIES PkgConfig::GTK)
function(apply_standard_settings target)
  target_compile_features(${target} PUBLIC cxx_std_17)
  target_compile_options(${target} PRIVATE -Wall -Werror)
endfunction()
set(include_flutter_inappwebview_linux_tests TRUE)
add_subdirectory("${PLUGIN_ROOT}/linux" plugin)
# Plugin shared-library builds must also resolve every native API at link time.
target_link_options(flutter_inappwebview_linux_plugin PRIVATE -Wl,--no-undefined)
CMAKE
cmake -S "$CHECK_DIR" -B "$CHECK_DIR/build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DENGINE_DIR="$ENGINE_DIR" -DPLUGIN_ROOT="$PLUGIN_ROOT" "$@" \
  2>&1 | tee "$OUTPUT_DIR/configure.log"
cmake --build "$CHECK_DIR/build" --parallel "${CMAKE_BUILD_PARALLEL_LEVEL:-2}" \
  2>&1 | tee "$OUTPUT_DIR/build.log"
ldd "$CHECK_DIR/build/plugin/libflutter_inappwebview_linux_plugin.so" \
  2>&1 | tee "$OUTPUT_DIR/plugin-ldd.log"
if grep -q 'not found' "$OUTPUT_DIR/plugin-ldd.log"; then
  echo "Unresolved native plugin dependencies." >&2
  exit 1
fi
ctest --test-dir "$CHECK_DIR/build" --output-on-failure --no-tests=error \
  --output-junit "$OUTPUT_DIR/tests.xml" 2>&1 | tee "$OUTPUT_DIR/test.log"
