#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_dir=$(dirname -- "$script_dir")
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/flutter-inappwebview-dialog-test.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT HUP INT TERM

# Exercise the production owner/retention code without linking Flutter/WebKit.
python3 - "$package_dir" "$build_dir" <<'PYTHON'
from pathlib import Path
import sys
source = (Path(sys.argv[1]) / "macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/InAppWebView/InAppWebView.swift").read_text()
start = source.index("    private func runJavaScriptDialog(")
end = source.index("    public override func viewWillMove(", start)
methods = source[start:end].replace("private func ", "func ")
deinit_start = source.index("    deinit {")
deinit_end = source.index("\n    }", deinit_start) + len("\n    }")
methods += source[deinit_start:deinit_end]
(Path(sys.argv[2]) / "DialogHostUnderTest.swift").write_text("""import AppKit
final class DialogHostUnderTest: NSObject {
    var window: NSWindow?
    var currentOpenPanel: NSOpenPanel?
    var currentOpenPanelCompletion: JavaScriptDialogCompletion<[URL]?>?
    var activeJavaScriptDialogPresentations: [UUID: PendingJavaScriptDialog] = [:]
    var hostDialogWindowCloseObserver: NSObjectProtocol?
""" + methods + "}\n")
PYTHON

sdk_path=$(xcrun --sdk macosx --show-sdk-path)
xcrun --sdk macosx swiftc \
  -sdk "$sdk_path" \
  -framework AppKit \
  "$package_dir/macos/flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/InAppWebView/JavaScriptDialogPresenter.swift" \
  "$build_dir/DialogHostUnderTest.swift" \
  "$script_dir/java_script_dialog_presenter_test.swift" \
  -o "$build_dir/java_script_dialog_presenter_test"
"$build_dir/java_script_dialog_presenter_test"
