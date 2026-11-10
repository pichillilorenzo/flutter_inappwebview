#!/usr/bin/env python3
"""Run real deferred POST/navigation methods with deterministic native doubles.

This tests cancellation, ownership and reentrancy without a Flutter/WPE build;
it does not execute JavaScript or perform network/document rendering.
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


def between(start, end):
    first = source.index(start)
    return source[first:source.index(end, first)]


methods = between(
    "void InAppWebView::loadUrl(", "// === Navigation History ==="
) + between(
    "void InAppWebView::goBackOrForward(", "// === Getters ==="
)
# Include production lifetime invalidation without emulating the unrelated
# WebKit/GTK/texture teardown that follows it.
methods += between(
    "InAppWebView::~InAppWebView() {", "  DisconnectHostWindowDestroyHandler();"
) + "}\n"

with tempfile.TemporaryDirectory(prefix="linux-posturl-test-") as directory:
    build_dir = Path(directory)
    (build_dir / "post_url_methods_under_test.inc").write_text(methods)
    asset = build_dir / "data/flutter_assets/post-url-test.html"
    asset.parent.mkdir(parents=True)
    asset.write_text("<!doctype html><title>asset navigation</title>")
    executable = build_dir / "posturl-test"
    subprocess.run([
        os.environ.get("CXX", "c++"), "-std=c++17", "-O0", "-g",
        "-Wall", "-Wextra", "-Werror",
        *shlex.split(os.environ.get("CXXFLAGS", "")),
        "-I", str(build_dir), str(test_dir / "deferred_post_url_test.cpp"),
        "-o", str(executable),
    ], check=True)
    subprocess.run([str(executable)], check=True)
