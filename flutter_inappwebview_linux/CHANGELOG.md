## 0.1.0-beta.1

- Resolved current Linux host handles after pending creation and queued rehosts, avoiding destroyed or replaced native windows.

- Attached popups and dialogs to each WebView's Flutter window, including keep-alive reuse, host destruction, and fractional-scale moves between windows.
- Kept FDO focus requests independent of visibility so hidden views remain hidden until explicitly shown.
- Reported native WebView initialization failures with their stage and original diagnostics, and released Dart creation waiters after failures.
- Coalesced surface size reports to one update per frame and kept texture offsets current before pointer input.
- Batched console notifications while preserving message order and immediate warning/error delivery.
- Released oversized fallback pixel buffers in WPEPlatform and WPEBackend-FDO SHM/EGL readback after substantial viewport reductions while reusing capacity for modest resizes.
- Deferred inline DMA-BUF imports to Flutter and coordinated EGL failures with the pixel fallback.
- Released unused CPU frame buffers after 30 seconds hidden on WPEPlatform and FDO, retaining the last frame and native image leases until a replacement arrives.
- Converted fallback pixel frames directly into packed RGBA buffers without an intermediate full-frame copy.
- Coalesced cursor hit testing to one update per animation frame.
- Enforced `disableHorizontalScroll` and `disableVerticalScroll` for wheel and
  trackpad input.
- Initial release.
