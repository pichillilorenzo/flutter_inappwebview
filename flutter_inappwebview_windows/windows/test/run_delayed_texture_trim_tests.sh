#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM
cxx=${CXX:-c++}
"$cxx" -pthread -std=c++17 -Wall -Wextra -Werror \
  "$script_dir/delayed_texture_trim_test_main.cpp" \
  -o "$build_dir/delayed_texture_trim_test"
"$build_dir/delayed_texture_trim_test"
