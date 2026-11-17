#!/usr/bin/env python3
"""Run real Linux trim/producer/texture methods with a deterministic native API.

The fake APIs allow ownership, timer races and allocation failures to be checked
on hosts without WPE. This is not a live WPE, Flutter engine or GPU measurement.
"""
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
args = parser.parse_args()
source = args.source.read_text()
header = (webview_dir / "in_app_webview.h").read_text()
texture = (webview_dir / "inappwebview_texture.cc").read_text()


def between(text, start, end):
    first = text.index(start)
    return text[first:text.index(end, first)]


methods = between(
    source, "void InAppWebView::setVisible(", "uint32_t InAppWebView::getActivityState()"
) + between(
    source, "void InAppWebView::setSize(", "void InAppWebView::setScaleFactor("
) + between(
    source, "void InAppWebView::ReadPixelsFromEglImage(", "// === Navigation Methods ==="
) + between(
    source, "size_t InAppWebView::GetPixelBufferSize(", "bool InAppWebView::HasDmaBufExport()"
) + between(
    source, "void* InAppWebView::GetCurrentEglImage(", "void* InAppWebView::ImportCurrentBufferToEglImage("
)
methods += "\n#ifdef HAVE_WPE_PLATFORM\n" + between(
    source, "void InAppWebView::OnWpePlatformBufferRendered(", "#endif"
) + "\n#endif\n#ifdef HAVE_WPE_BACKEND_LEGACY\n" + between(
    source, "void InAppWebView::OnExportDmaBuf(", "#endif"
) + between(
    source, "void InAppWebView::OnExportShmBuffer(", "#endif  // HAVE_WPE_BACKEND_LEGACY"
) + "\n#endif\n"

# Run the real destructor's cancellation/lifetime prologue, without pretending
# to emulate WebKit/GObject teardown or the texture registrar's finalization.
methods += between(
    source, "InAppWebView::~InAppWebView() {", "  DisconnectHostWindowDestroyHandler();"
) + "}\n"

members = between(
    header, "static constexpr size_t kNumBuffers =", "// Flag to skip pixel readback"
)
timer_members = between(
    header, "static constexpr guint kHiddenPixelBufferTrimDelayMs =", "// Target refresh rate"
)
texture_methods = between(
    texture, "struct _InAppWebViewTexture {", "G_DEFINE_TYPE("
) + between(
    texture, "static gboolean inappwebview_texture_copy_pixels(",
    "static void inappwebview_texture_finalize("
)

with tempfile.TemporaryDirectory(prefix="linux-hidden-pixels-test-") as directory:
    build_dir = Path(directory)
    for name, contents in [
        ("hidden_pixel_methods_under_test.inc", methods),
        ("pixel_buffer_members_under_test.inc", members),
        ("hidden_pixel_timer_members_under_test.inc", timer_members),
        ("pixel_texture_under_test.inc", texture_methods),
    ]:
        (build_dir / name).write_text(contents)
    for backend in ("HAVE_WPE_PLATFORM", "HAVE_WPE_BACKEND_LEGACY"):
        executable = build_dir / backend.lower()
        subprocess.run([
            os.environ.get("CXX", "c++"), "-std=c++17", "-O1", "-g", "-pthread",
            "-Wall", "-Wextra", "-Werror", "-Wno-unused-parameter",
            *shlex.split(os.environ.get("CXXFLAGS", "")), "-D" + backend + "=1",
            "-I", str(build_dir), str(test_dir / "hidden_pixel_buffer_test.cc"),
            "-o", str(executable),
        ], check=True)
        subprocess.run([str(executable)], check=True)
print("Hidden pixel buffer ownership and lifecycle tests passed for both Linux backends")
