#!/usr/bin/env bash
set -euo pipefail

test_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
linux_dir=$(cd -- "$test_dir/.." && pwd)
fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
fixture_dir=$(cd -- "$fixture_dir" && pwd -P)

cxx=${CXX:-c++}
"$cxx" -std=c++17 -Wall -Wextra -Wpedantic \
  "$test_dir/wpe_bundle_paths_test.cc" \
  "$linux_dir/utils/wpe_bundle_paths.cc" \
  $(pkg-config --cflags --libs glib-2.0) \
  -o "$fixture_dir/wpe_bundle_paths_test"

cp "$fixture_dir/wpe_bundle_paths_test" "$fixture_dir/WPEWebProcess"
cp "$fixture_dir/wpe_bundle_paths_test" "$fixture_dir/WPENetworkProcess"
touch "$fixture_dir/libWPEInjectedBundle.so"

run_clean() {
  env -u WEBKIT_EXEC_PATH -u WEBKIT_INJECTED_BUNDLE_PATH \
    -u LD_LIBRARY_PATH "$fixture_dir/wpe_bundle_paths_test"
}

full_output=$(run_clean)
grep -F "EXEC=$fixture_dir" <<<"$full_output"
grep -F "BUNDLE=$fixture_dir" <<<"$full_output"
grep -F "LD=$fixture_dir" <<<"$full_output"

mv "$fixture_dir/libWPEInjectedBundle.so" "$fixture_dir/libWPEInjectedBundle.missing"
missing_output=$(run_clean)
grep -F 'EXEC=<unset>' <<<"$missing_output"
grep -F 'BUNDLE=<unset>' <<<"$missing_output"
grep -F 'LD=<unset>' <<<"$missing_output"
mv "$fixture_dir/libWPEInjectedBundle.missing" "$fixture_dir/libWPEInjectedBundle.so"

cp "$fixture_dir/wpe_bundle_paths_test" "$fixture_dir/WPEGPUProcess"
chmod 0644 "$fixture_dir/WPEGPUProcess"
gpu_output=$(run_clean)
grep -F "EXEC=$fixture_dir" <<<"$gpu_output"
test -x "$fixture_dir/WPEGPUProcess"

override_output=$(WEBKIT_EXEC_PATH=/custom LD_LIBRARY_PATH=/original \
  env -u WEBKIT_INJECTED_BUNDLE_PATH "$fixture_dir/wpe_bundle_paths_test")
grep -F 'EXEC=/custom' <<<"$override_output"
grep -F 'BUNDLE=<unset>' <<<"$override_output"
grep -F 'LD=/original' <<<"$override_output"

echo 'wpe_bundle_paths tests passed'
