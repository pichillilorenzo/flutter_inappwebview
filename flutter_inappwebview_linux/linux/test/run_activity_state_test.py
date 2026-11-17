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
def extract_method(signature):
    start = source.index(signature)
    opening = source.index("{", start)
    depth = 1
    for position in range(opening + 1, len(source)):
        if source[position] == "{":
            depth += 1
        elif source[position] == "}":
            depth -= 1
            if depth == 0:
                return source[start:position + 1]
    raise ValueError("Unclosed method: " + signature)


# Select activity methods only; adjacent resource/lifetime helpers have their
# own harness and should not become dependencies of this focused API test.
sections = [extract_method(signature) for signature in (
    "void InAppWebView::setFocused(",
    "void InAppWebView::setVisible(",
    "uint32_t InAppWebView::getActivityState()",
    "bool InAppWebView::isVisible()",
    "bool InAppWebView::clearFocus()",
    "bool InAppWebView::requestFocus()",
)]

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
