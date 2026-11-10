#!/usr/bin/env python3
"""Compile the production WPE reply function and test real JSON semantics."""
import json
import os
from pathlib import Path
import platform
import subprocess
import tempfile

test_dir = Path(__file__).resolve().parent
root = test_dir.parents[2]
source = (test_dir.parent / "in_app_webview/in_app_webview.cc").read_text()
start = source.index("void InAppWebView::ResolveInternalHandlerWithReply(")
end = source.index("void InAppWebView::RejectInternalHandlerWithReply(", start)
cases = json.loads((root / "tool/javascript_handler_json_cases.json").read_text())

with tempfile.TemporaryDirectory(prefix="linux-handler-json-") as directory:
    build_dir = Path(directory)
    (build_dir / "javascript_handler_reply_under_test.inc").write_text(source[start:end])
    flags = []
    if platform.system() == "Darwin":
        sdk = subprocess.check_output(["xcrun", "--show-sdk-path"], text=True).strip()
        flags += ["-isysroot", sdk, "-framework", "JavaScriptCore"]
    else:
        flags += subprocess.check_output([
            "pkg-config", "--cflags", "--libs", "javascriptcoregtk-4.1"
        ], text=True).split()
    executable = build_dir / "reply-test"
    subprocess.run([
        os.environ.get("CXX", "c++"), "-std=c++17", "-Wall", "-Wextra", "-Werror",
        "-I", str(build_dir), str(test_dir / "javascript_handler_json_reply_test.cc"),
        *flags, "-o", str(executable),
    ], check=True)
    for raw in cases["valid"]:
        output = subprocess.check_output([str(executable), raw], text=True)
        assert json.loads(output) == json.loads(raw), (raw, output)
    for raw in cases["invalid"]:
        assert subprocess.check_output([str(executable), raw], text=True) == "error", raw
print(f"Linux native JSON replies: {sum(map(len, cases.values()))} cases passed")
