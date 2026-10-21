#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror \
  -fsyntax-only "$test_dir/egl_texture_fallback_stub_syntax_test.cc"
echo "EGL fallback stub API: syntax check passed"
