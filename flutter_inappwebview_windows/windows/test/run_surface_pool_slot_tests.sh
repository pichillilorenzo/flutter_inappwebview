#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM
cxx=${CXX:-c++}
set --
if [ "$(uname -s)" = Darwin ]; then
  sdkroot=${SDKROOT:-/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk}
  if [ ! -d "$sdkroot" ]; then
    sdkroot=$(xcrun --show-sdk-path)
  fi
  set -- -isysroot "$sdkroot"
fi

"$cxx" "$@" -pthread -std=c++17 -Wall -Wextra -Werror \
  "$script_dir/surface_pool_slot_test.cpp" \
  -o "$build_dir/surface_pool_slot_test"
"$build_dir/surface_pool_slot_test"
