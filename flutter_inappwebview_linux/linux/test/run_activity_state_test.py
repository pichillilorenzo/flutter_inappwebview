#!/usr/bin/env python3
"""Compile production focus/visibility methods against both WPE API doubles."""
import os
from pathlib import Path
import platform
import shlex
import subprocess
import tempfile


test_dir = Path(__file__).resolve().parent
source = (test_dir.parent / "in_app_webview/in_app_webview.cc").read_text()
sections = []
for first, following in [
    ("void InAppWebView::setFocused(", "// === Refresh Rate Management ==="),
    ("bool InAppWebView::isVisible()", "// === Fullscreen Control ==="),
    ("bool InAppWebView::clearFocus()", "// === Web Archive ==="),
]:
    start = source.index(first)
    sections.append(source[start:source.index(following, start)])

with tempfile.TemporaryDirectory(prefix="webview-activity-state-test-") as directory:
    build_dir = Path(directory)
    (build_dir / "activity_state_under_test.inc").write_text("\n".join(sections))
    flags = shlex.split(os.environ.get("CXXFLAGS", ""))
    if platform.system() == "Darwin":
        sdk = os.environ.get("SDKROOT") or subprocess.check_output(
            ["xcrun", "--show-sdk-path"], text=True).strip()
        flags += ["-isysroot", sdk]
    for define in ("HAVE_WPE_BACKEND_LEGACY", "HAVE_WPE_PLATFORM"):
        executable = build_dir / define.lower()
        subprocess.run([
            os.environ.get("CXX", "c++"), "-std=c++17", "-Wall", "-Wextra", "-Werror",
            *flags, "-D" + define + "=1", "-I", str(build_dir),
            str(test_dir / "activity_state_test.cc"), "-o", str(executable),
        ], check=True)
        subprocess.run([str(executable)], check=True)
