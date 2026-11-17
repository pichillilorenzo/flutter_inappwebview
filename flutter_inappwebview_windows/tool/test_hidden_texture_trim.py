#!/usr/bin/env python3
"""Compile production bridge methods with platform doubles on non-Windows hosts.

The source is extracted without rewriting method bodies. Windows CI separately
builds both complete backends and tests real DXGI shared resources with WARP.
"""
from pathlib import Path
import argparse
import os
import re
import subprocess
import tempfile


def definition(source: str, signature: str, *, struct=False) -> str:
    start = source.index(signature)
    opening = source.index("{", start)
    # Skip comments/string literals while balancing the C++ body.
    tokens = re.finditer(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|[{}]',
                        source[opening:])
    depth = 0
    for token in tokens:
        if token.group() == "{":
            depth += 1
        elif token.group() == "}":
            depth -= 1
            if depth == 0:
                return source[start:opening + token.end()] + (";" if struct else "")
    raise RuntimeError(f"Unclosed definition: {signature}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sanitize", action="store_true")
    args = parser.parse_args()
    package = Path(__file__).resolve().parents[1]
    native = package / "windows"
    bridge = native / "custom_platform_view"
    parts = ['#include <cassert>\n#include <iostream>\n#include <stdexcept>',
             '#include "hidden_texture_trim_test_support.h"']
    for backend in ("gpu", "fallback"):
        header = (bridge / f"texture_bridge_{backend}.h").read_text()
        header = re.sub(r"^\s*#(?:include|pragma)[^\n]*", "", header, flags=re.M)
        # Inspect state in tests without changing the production declarations.
        parts.append(header.replace("private:", "public:")
                     .replace("protected:", "public:"))
    sources = {name: (bridge / f"texture_bridge{name}.cc").read_text()
               for name in ("", "_gpu", "_fallback")}
    parts.append("namespace flutter_inappwebview_plugin {")
    for name in ("SurfacePool", "FrameLease", "ComparerResources"):
        parts.append(definition(sources["_gpu"],
                     f"struct TextureBridgeGpu::{name}", struct=True))
    methods = {
        "": ["bool TextureBridge::Start()", "void TextureBridge::SetCaptureSuspended(",
             "void TextureBridge::Stop()", "void TextureBridge::StopInternal()",
             "bool TextureBridge::TrimHiddenResources(",
             "void TextureBridge::ScheduleHiddenTrim()"],
        "_gpu": ["TextureBridgeGpu::~TextureBridgeGpu()",
                 "bool TextureBridgeGpu::AcceptFrame(",
                 "bool TextureBridgeGpu::EnsureSurfacePool(",
                 "bool TextureBridgeGpu::EnsureReference(",
                 "bool TextureBridgeGpu::EnsureIncoming(",
                 "const FlutterDesktopGpuSurfaceDescriptor*\n    TextureBridgeGpu::GetSurfaceDescriptor(",
                 "void TextureBridgeGpu::ReleaseSurface(",
                 "void TextureBridgeGpu::OnCaptureSuspended()",
                 "bool TextureBridgeGpu::TrimHiddenResources(",
                 "void TextureBridgeGpu::StopInternal()"],
        "_fallback": ["TextureBridgeFallback::~TextureBridgeFallback()",
                      "void TextureBridgeFallback::ProcessFrame(",
                      "bool TextureBridgeFallback::EnsureStagingTexture(",
                      "bool TextureBridgeFallback::TrimHiddenResources(",
                      "const FlutterDesktopPixelBuffer* TextureBridgeFallback::CopyPixelBuffer("],
    }
    for source, signatures in methods.items():
        parts.extend(definition(sources[source], signature) for signature in signatures)
    parts.append("}")
    parts.append((native / "test/hidden_texture_trim_test_main.cpp").read_text())
    with tempfile.TemporaryDirectory(prefix="webview-trim-") as temp:
        build = Path(temp)
        for header in ("d3d11.h", "winrt/base.h"):
            path = build / header
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('#pragma once\n#include "hidden_texture_trim_test_support.h"\n')
        source = build / "production_trim_test.cpp"
        source.write_text("\n\n".join(parts))
        binary = build / "production_trim_test"
        command = [os.environ.get("CXX", "c++"), "-std=c++17", "-pthread",
                   "-Wall", "-Wextra", "-Werror", "-Wno-unused-parameter",
                   f"-I{build}", f"-I{native}", f"-I{native / 'test'}", str(source),
                   "-o", str(binary)]
        if args.sanitize:
            command[1:1] = ["-fsanitize=address,undefined", "-fno-omit-frame-pointer"]
        subprocess.run(command, check=True)
        subprocess.run([str(binary)], check=True)


if __name__ == "__main__":
    main()
