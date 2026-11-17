#!/usr/bin/env python3
"""Compile the real enumeration and conversion methods with narrow COM doubles.

This does not replace the Windows SDK build or live WebView2 measurements. An
alternate --source-root and --filter allow regression checks against an earlier
checkout; the legacy vector result is adapted only for observing its outcome.
"""

import argparse
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile


def definition(source, marker):
    position = source.index(marker)
    start = source.rfind("\n", 0, position) + 1
    brace = source.index("{", position)
    depth = 1
    end = brace + 1
    while depth:
        if source[end] == "{":
            depth += 1
        elif source[end] == "}":
            depth -= 1
        end += 1
    return source[start:end]


def without_includes(path):
    return re.sub(r"^#include[^\n]*\n", "", path.read_text(), flags=re.MULTILINE)


def main():
    here = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, default=here.parents[2])
    parser.add_argument("--filter", default="")
    parser.add_argument("--sanitize", action="store_true")
    args = parser.parse_args()
    native = args.source_root.resolve() / "flutter_inappwebview_windows/windows"
    environment = (native / "webview_environment/webview_environment.cpp").read_text()
    method = definition(environment, "void WebViewEnvironment::getProcessInfos(")
    signature = method[:method.index("{")].replace("WebViewEnvironment::", "").strip()
    process_source = (native / "types/browser_process_info.cpp").read_text()
    event_source = (native / "types/browser_process_infos_changed_detail.cpp").read_text()
    generated = [
        '#include "process_infos_test_support.h"',
        '#include "types/lifetime_token.h"',
        without_includes(native / "types/browser_process_info.h"),
        without_includes(native / "types/browser_process_infos_changed_detail.h"),
        # The result type is also the observer for older vector-only methods.
        f'#include "{here.parent / "webview_environment/process_infos_result.h"}"',
        "namespace flutter_inappwebview_plugin {",
        "using namespace Microsoft::WRL;",
        "struct WebViewEnvironment {",
        "  explicit WebViewEnvironment(wil::com_ptr<ICoreWebView2Environment> value)",
        "    : environment_(std::move(value)) {}",
        "  ~WebViewEnvironment() { alive_.expire(); }",
        "  wil::com_ptr<ICoreWebView2Environment> environment_;",
        "  LifetimeToken alive_;",
        f"  {signature};",
        "};",
    ]
    for marker in (
        "BrowserProcessInfo::BrowserProcessInfo(",
        "BrowserProcessInfo::fromICoreWebView2ProcessInfo(",
        "BrowserProcessInfo::fromICoreWebView2ProcessExtendedInfo(",
    ):
        generated.append(definition(process_source, marker))
    for marker in (
        "BrowserProcessInfosChangedDetail::BrowserProcessInfosChangedDetail(",
        "BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessInfoCollection(",
        "BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessExtendedInfoCollection(",
    ):
        generated.append(definition(event_source, marker))
    generated.extend([method, "}"])
    with tempfile.TemporaryDirectory(prefix="process-infos-test-") as temp:
        build = Path(temp)
        (build / "process_infos_generated.h").write_text("\n".join(generated))
        executable = build / "process_infos_test"
        command = shlex.split(os.environ.get("CXX", "c++")) + [
            "-std=c++17", "-Wall", "-Wextra", "-Werror", "-g",
            "-I", str(build), "-I", str(here), "-I", str(native),
            str(here / "process_infos_test.cpp"), "-o", str(executable),
        ]
        if args.sanitize:
            command += ["-fsanitize=address,undefined", "-fno-omit-frame-pointer"]
        subprocess.run(command, check=True)
        return subprocess.run([str(executable), args.filter]).returncode


if __name__ == "__main__":
    raise SystemExit(main())
