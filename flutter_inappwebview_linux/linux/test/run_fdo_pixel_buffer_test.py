#!/usr/bin/env python3
"""Compile the production FDO pixel producers against fake EGL/Wayland APIs."""
import argparse
import os
from pathlib import Path
import shlex
import subprocess
import tempfile


test_dir = Path(__file__).resolve().parent
webview_dir = test_dir.parent / "in_app_webview"
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", type=Path, default=webview_dir / "in_app_webview.cc")
parser.add_argument("--producer", choices=("egl", "shm", "both"), default="both")
args = parser.parse_args()
source = args.source.read_text()
header = (webview_dir / "in_app_webview.h").read_text()


def between(text, start, end):
    first = text.index(start)
    return text[first:text.index(end, first)]


methods = between(
    source, "void InAppWebView::ReadPixelsFromEglImage(", "// === Navigation Methods ==="
) + between(
    source, "void InAppWebView::OnExportShmBuffer(", "#endif  // HAVE_WPE_BACKEND_LEGACY"
) + between(
    source, "size_t InAppWebView::GetPixelBufferSize(", "bool InAppWebView::HasDmaBufExport()"
) + between(
    source, "void InAppWebView::TrimUnusedPixelBuffers()", "uint32_t InAppWebView::getActivityState()"
)
members = between(
    header, "static constexpr size_t kNumBuffers =", "// Flag to skip pixel readback"
)

with tempfile.TemporaryDirectory(prefix="fdo-pixel-buffer-test-") as directory:
    build_dir = Path(directory)
    (build_dir / "fdo_pixels_under_test.inc").write_text(methods)
    (build_dir / "pixel_buffer_members_under_test.inc").write_text(members)
    executable = build_dir / "fdo_pixel_buffer_test"
    subprocess.run([
        os.environ.get("CXX", "c++"), "-std=c++17", "-O2", "-Wall", "-Wextra",
        "-Werror", "-pthread", *shlex.split(os.environ.get("CXXFLAGS", "")),
        "-I", str(build_dir), str(test_dir / "fdo_pixel_buffer_test.cc"),
        "-o", str(executable),
    ], check=True)
    subprocess.run([str(executable), args.producer], check=True)
