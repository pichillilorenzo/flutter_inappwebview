#!/usr/bin/env bash
set -euo pipefail

: "${FLUTTER_ROOT:?Set FLUTTER_ROOT to a Flutter SDK with Linux artifacts}"
engine_dir="$FLUTTER_ROOT/bin/cache/artifacts/engine/linux-x64"
test_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

read -r -a native_flags <<< "$(pkg-config --cflags --libs gtk+-3.0 epoxy)"
"${CXX:-c++}" -std=c++17 -I"$engine_dir" \
  "$test_dir/egl_texture_fallback_test.cc" \
  -L"$engine_dir" -Wl,-rpath,"$engine_dir" -lflutter_linux_gtk \
  "${native_flags[@]}" -ldl -o "$build_dir/egl_texture_fallback_test"
"$build_dir/egl_texture_fallback_test"
