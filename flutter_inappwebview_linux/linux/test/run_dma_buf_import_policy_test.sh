#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

SDKROOT="${SDKROOT:-/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk}"
export SDKROOT
"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror \
  "$test_dir/dma_buf_import_policy_test.cc" \
  -o "$build_dir/dma_buf_import_policy_test"
"$build_dir/dma_buf_import_policy_test"
echo "DMA-BUF import policy: all tests passed"
