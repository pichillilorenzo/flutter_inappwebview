#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM
cxx=${CXX:-c++}
set --
if [ "$(uname -s)" = Darwin ]; then
  sdkroot=${SDKROOT:-$(xcrun --sdk macosx --show-sdk-path)}
  set -- -isysroot "$sdkroot"
fi

# Optional sanitizers exercise the same cases as Windows CTest.
if [ -n "${SANITIZERS:-}" ]; then
  set -- "$@" "-fsanitize=$SANITIZERS" -fno-omit-frame-pointer -g
fi
"$cxx" "$@" -pthread -std=c++17 -Wall -Wextra -Werror \
  "$script_dir/async_resource_build_test_main.cpp" \
  -o "$build_dir/async_resource_build_test"
"$build_dir/async_resource_build_test"
