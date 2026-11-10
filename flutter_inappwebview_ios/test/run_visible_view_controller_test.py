#!/usr/bin/env python3
"""Exercise the production hierarchy resolver with lightweight UIKit doubles."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent
source = (root.parent / "ios/flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/UIApplication/VisibleViewController.swift").read_text()
# UIKit is unavailable to macOS executables. Only replace the import: all
# resolver logic below is compiled directly from the production source.
source = source.replace("import UIKit", "import Foundation")
with tempfile.TemporaryDirectory(prefix="ios-visible-controller-test-") as directory:
    directory = Path(directory)
    (directory / "VisibleViewController.swift").write_text(source)
    sdk = subprocess.check_output(["xcrun", "--sdk", "macosx", "--show-sdk-path"], text=True).strip()
    executable = directory / "visible_controller_test"
    subprocess.run(["xcrun", "swiftc", "-sdk", sdk,
                    str(directory / "VisibleViewController.swift"),
                    str(root / "visible_view_controller_test.swift"),
                    "-o", str(executable)], check=True)
    subprocess.run([str(executable)], check=True)
