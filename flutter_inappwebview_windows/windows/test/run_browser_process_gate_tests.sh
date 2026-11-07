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

"$cxx" "$@" -std=c++17 -Wall -Wextra -Werror \
  "$script_dir/browser_process_gate_test_main.cpp" \
  -o "$build_dir/browser_process_gate_test"
"$build_dir/browser_process_gate_test"
