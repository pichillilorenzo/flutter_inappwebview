#!/usr/bin/env bash
# Verifies the linker behavior required by the WPEPlatform API probe. A WPE
# library can be in an SDK directory while one of its DT_NEEDED libraries is in
# a different SDK directory; -rpath-link must locate that dependency at build
# time without weakening unresolved-symbol checks.
set -euo pipefail

cc_bin="${CC:-cc}"
fixture_dir="$(mktemp -d)"
trap 'rm -rf "$fixture_dir"' EXIT

sdk_dir="$fixture_dir/sdk"
deps_dir="$fixture_dir/deps"
mkdir -p "$sdk_dir" "$deps_dir"

printf 'int fake_dependency(void) { return 0; }\n' |
  "$cc_bin" -x c - -shared -fPIC -Wl,-soname,libFakeDependency.so -o "$deps_dir/libFakeDependency.so"
printf 'extern int fake_dependency(void); int fake_wpe_api(void) { return fake_dependency(); }\n' |
  "$cc_bin" -x c - -shared -fPIC -Wl,-soname,libFakeWPE.so \
    -L"$deps_dir" -lFakeDependency -o "$sdk_dir/libFakeWPE.so"

# The default executable link must fail: its direct WPE dependency has an
# unresolved DT_NEEDED entry that is intentionally outside the SDK lib dir.
if printf 'extern int fake_wpe_api(void); int main(void) { return fake_wpe_api(); }\n' |
  "$cc_bin" -x c - -L"$sdk_dir" -lFakeWPE -o "$fixture_dir/without-rpath-link" 2>/dev/null; then
  echo "expected the link without -rpath-link to fail" >&2
  exit 1
fi

# This is the behavior used by CMakeLists.txt: preserve dependency validation,
# but make the SDK's dependency directory visible to the linker.
printf 'extern int fake_wpe_api(void); int main(void) { return fake_wpe_api(); }\n' |
  "$cc_bin" -x c - -L"$sdk_dir" -Wl,-rpath-link,"$deps_dir" -lFakeWPE \
    -o "$fixture_dir/with-rpath-link"

if grep -Fq -- '"-Wl,--allow-shlib-undefined"' "${BASH_SOURCE[0]%/test/*}/CMakeLists.txt"; then
  echo "WPE probe must validate DT_NEEDED dependencies rather than ignore them" >&2
  exit 1
fi
grep -q -- '-Wl,-rpath-link,' "${BASH_SOURCE[0]%/test/*}/CMakeLists.txt"
