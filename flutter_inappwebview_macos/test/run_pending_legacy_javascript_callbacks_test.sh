#!/bin/sh
set -eu
PACKAGE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
swiftc -o "$TMP_DIR/test_pending_legacy_js" \
  "$PACKAGE_DIR/macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/Types/PendingLegacyJavaScriptCallbacks.swift" \
  "$PACKAGE_DIR/test/pending_legacy_javascript_callbacks_test.swift"
"$TMP_DIR/test_pending_legacy_js"
swiftc -frontend -parse "$PACKAGE_DIR/macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/InAppWebView/InAppWebView.swift"
