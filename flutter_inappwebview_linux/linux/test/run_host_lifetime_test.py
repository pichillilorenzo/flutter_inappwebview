#!/usr/bin/env python3
"""Compile lifecycle and chooser methods extracted from production C++ on any host."""
import os
import platform
import subprocess
from pathlib import Path
import tempfile


test_dir = Path(__file__).resolve().parent
linux_dir = test_dir.parent
plugin_source = (linux_dir / "plugin_instance.cc").read_text()
webview_source = (linux_dir / "in_app_webview/in_app_webview.cc").read_text()

plugin_start = plugin_source.index("PluginInstance::PluginInstance(")
plugin_end = plugin_source.index("FlBinaryMessenger* PluginInstance::messenger()", plugin_start)
plugin_methods = plugin_source[plugin_start:plugin_end]

host_start = webview_source.index("void InAppWebView::SetHostView(")
host_end = webview_source.index("// === WPE Backend Callbacks ===", host_start)
host_methods = webview_source[host_start:host_end]

file_hide_start = webview_source.index("void InAppWebView::HideFileChooser(bool force)")
file_hide_end = webview_source.index("void InAppWebView::HideOptionMenu()", file_hide_start)
file_hide_method = webview_source[file_hide_start:file_hide_end]

cancel_start = webview_source.index("void InAppWebView::CancelHostBoundPopups()")
cancel_end = webview_source.index("void InAppWebView::ResolveInternalHandlerWithReply", cancel_start)
cancel_method = webview_source[cancel_start:cancel_end]

chooser_start = webview_source.index("gboolean InAppWebView::OnRunFileChooser(")
chooser_end = webview_source.index("// === Option Menu", chooser_start)
chooser_method = webview_source[chooser_start:chooser_end]

with tempfile.TemporaryDirectory(prefix="linux-host-lifetime-test-") as directory:
    build_dir = Path(directory)
    for name, contents in [
        ("plugin_instance_under_test.inc", plugin_methods),
        ("host_under_test.inc", host_methods),
        ("chooser_under_test.inc", file_hide_method + cancel_method + chooser_method),
    ]:
        (build_dir / name).write_text(contents)
    flags = []
    if platform.system() == "Darwin":
        sdk = os.environ.get("SDKROOT", "/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk")
        if not Path(sdk).is_dir():
            sdk = subprocess.check_output(["xcrun", "--show-sdk-path"], text=True).strip()
        flags += ["-isysroot", sdk]
    for define in ("HAVE_WPE_PLATFORM", "HAVE_WPE_BACKEND_LEGACY"):
        executable = build_dir / define.lower()
        subprocess.run([
            os.environ.get("CXX", "c++"), *flags, "-std=c++17", "-Wall", "-Wextra",
            "-Wno-unused-parameter", "-Wno-unused-private-field", "-D" + define + "=1", "-I", str(build_dir),
            str(test_dir / "host_lifetime_test.cc"), "-o", str(executable),
        ], check=True)
        subprocess.run([str(executable)], check=True)
print("Compiled Linux host lifetime and async chooser tests passed")
