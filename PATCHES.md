# Betclic patches

Fork of [pichillilorenzo/flutter_inappwebview](https://github.com/pichillilorenzo/flutter_inappwebview) `master` (the `6.2.0-beta.3` line).
flutter-front consumes branch `feat/swift-package-manager`; pin it by **full commit SHA**, never by branch.

On each upstream release: rebase, drop the patches that landed, bump the SHA in one flutter-front PR.

| Patch | Fork PR | Upstream PR | Drop when |
| --- | --- | --- | --- |
| iOS/macOS as Swift packages only, macOS builds at the 10.14 floor (QUANTUM-1422) | branch `feat/swift-package-manager` | — | upstream drops CocoaPods |
| Multi-window host HWND resolved from the Flutter view id; every `registrar->GetView()` null-safe | #1 | — | released upstream |
| Per-hosting-view device pixel ratio, stale WGC capture frames after resize, texture use-after-free on dispose, async-callback crash guards | #2 | — | released upstream |
| AVX2 swizzle isolated in its own translation unit (pre-Haswell illegal instruction) | #3 | — | released upstream |
| `applicationNameForUserAgent` applied on macOS without a default name and on Windows | #4 | — | released upstream |
