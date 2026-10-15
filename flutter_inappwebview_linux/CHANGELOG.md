## 0.1.0-beta.1

- Released oversized fallback pixel buffers after substantial viewport reductions while reusing capacity for modest resizes.
- Deferred inline DMA-BUF imports to Flutter and coordinated EGL failures with the pixel fallback.
- Converted fallback pixel frames directly into packed RGBA buffers without an intermediate full-frame copy.
- Coalesced cursor hit testing to one update per animation frame.
- Enforced `disableHorizontalScroll` and `disableVerticalScroll` for wheel and
  trackpad input.
- Initial release.
