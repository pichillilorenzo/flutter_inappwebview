#!/usr/bin/env python3
"""Test production WPE initialization with fake native API failures."""
import os
from pathlib import Path
import platform
import subprocess
import tempfile


test_dir = Path(__file__).resolve().parent
source = (test_dir.parent / "in_app_webview/in_app_webview.cc").read_text()
start = source.index("void InAppWebView::SetCreationError(")
end = source.index("bool InAppWebView::InitWebView(", start)

with tempfile.TemporaryDirectory(prefix="webview-creation-test-") as directory:
    build_dir = Path(directory)
    (build_dir / "creation_backend_under_test.inc").write_text(source[start:end])
    flags = []
    if platform.system() == "Darwin":
        sdk = os.environ.get("SDKROOT", "/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk")
        if not Path(sdk).is_dir():
            sdk = subprocess.check_output(["xcrun", "--show-sdk-path"], text=True).strip()
        flags += ["-isysroot", sdk]
    for define, test_file in [
        ("HAVE_WPE_PLATFORM", "creation_backend_test.cc"),
        ("HAVE_WPE_BACKEND_LEGACY", "creation_legacy_backend_test.cc"),
    ]:
        executable = build_dir / Path(test_file).stem
        subprocess.run([
            os.environ.get("CXX", "c++"), *flags, "-std=c++17",
            "-Wall", "-Wextra", "-Werror", "-D" + define + "=1",
            "-I", str(build_dir), str(test_dir / test_file),
            "-o", str(executable),
        ], check=True)
        subprocess.run([str(executable)], check=True)
print("WebView backend creation failure and software fallback tests passed")
