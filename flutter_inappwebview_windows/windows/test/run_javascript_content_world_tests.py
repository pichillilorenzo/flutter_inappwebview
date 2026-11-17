#!/usr/bin/env python3
"""Execute the production CDP request methods with small WebView2 doubles."""

import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[3]
NATIVE = "flutter_inappwebview_windows/windows"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sanitize", action="store_true")
    parser.add_argument("--json-include", type=Path)
    parser.add_argument("--source-ref", help="Read production methods at a git ref for regression checks")
    parser.add_argument("--case", help="Run one named scenario")
    args = parser.parse_args()

    def read(relative):
        if args.source_ref:
            return subprocess.check_output(
                ["git", "show", f"{args.source_ref}:{relative}"], cwd=ROOT, text=True
            )
        return (ROOT / relative).read_text()

    def method(source, start, end):
        return source[source.index(start):source.index(end)]

    view = read(f"{NATIVE}/in_app_webview/in_app_webview.cpp")
    view_header = read(f"{NATIVE}/in_app_webview/in_app_webview.h")
    controller = read(f"{NATIVE}/in_app_webview/user_content_controller.cpp")
    controller_header = read(f"{NATIVE}/in_app_webview/user_content_controller.h")
    declaration = re.search(r"    void createContentWorld\([^;]+;", controller_header)
    cache_declaration = re.search(r"    [^\n;]+ contentWorlds_;", controller_header)
    if declaration is None:
        raise RuntimeError("Could not extract the production content-world declaration")
    if cache_declaration is None:
        raise RuntimeError("Could not extract the production content-world cache type")

    production = "\n".join([
        method(view_header, "  const std::string CALL_ASYNC_JAVASCRIPT_WRAPPER_JS", "  struct InAppWebViewCreationParams"),
        method(controller, "  void UserContentController::createContentWorld(", "  void UserContentController::addScriptToWebView("),
        method(view, "  void InAppWebView::evaluateJavascript(", "  void InAppWebView::callAsyncJavaScript("),
        method(view, "  void InAppWebView::callAsyncJavaScript(", "  void InAppWebView::addUserScript("),
    ])
    fixture = (Path(__file__).with_name("javascript_content_world_test.cpp")).read_text()
    fixture = fixture.replace("// PRODUCTION_CONTENT_WORLD_DECLARATION", declaration.group())
    fixture = fixture.replace("// PRODUCTION_CONTENT_WORLD_CACHE", cache_declaration.group())
    fixture = fixture.replace("// PRODUCTION_METHODS", production)

    with tempfile.TemporaryDirectory(prefix="javascript-content-world-") as temp:
        temp = Path(temp)
        source = temp / "javascript_content_world_test.cpp"
        source.write_text(fixture)
        binary = temp / "javascript_content_world_test"
        command = [os.environ.get("CXX", "g++"), "-std=c++17", "-Wall", "-Wextra", "-Werror",
                   "-I", str(ROOT / NATIVE), str(source), "-o", str(binary)]
        if args.json_include:
            command.extend(["-I", str(args.json_include)])
        if args.sanitize:
            command.extend(["-fsanitize=address,undefined", "-fno-omit-frame-pointer"])
        subprocess.run(command, check=True)
        subprocess.run([str(binary)] + ([args.case] if args.case else []), check=True)


if __name__ == "__main__":
    main()
