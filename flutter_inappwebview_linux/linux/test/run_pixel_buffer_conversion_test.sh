#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror \
  "$test_dir/pixel_buffer_conversion_test.cc" \
  -o "$build_dir/pixel_buffer_conversion_test"
"$build_dir/pixel_buffer_conversion_test"
echo "Pixel buffer conversion: all tests passed"
