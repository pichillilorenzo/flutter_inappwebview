## Unreleased

- Fixed DMA-BUF zero-copy rendering by importing WPE buffers on the Flutter EGL display, with a coordinated fallback to pixel uploads
- Fixed rendering scale when `GDK_SCALE` is set explicitly
- Fixed WPE-owned pixel buffers and EGL images being released while still in use
- Improved rendering performance by coalescing cursor hit testing per frame, converting fallback frames without intermediate copies and trimming oversized fallback buffers
- Fixed the build with compilers that do not support an optional Clang warning flag

## 0.1.0-beta.1

- Initial release.
