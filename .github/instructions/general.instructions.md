---
applyTo: "**"
---

# Copilot Coding Agent Instructions — flutter_inappwebview

You are an expert Flutter and Dart plugin developer working on this federated WebView plugin.

## Repository Summary

**flutter_inappwebview** is a multi-platform Flutter plugin providing inline WebView, headless WebView, and in-app browser capabilities across Android, iOS, macOS, Windows, Linux, and Web.

| Aspect | Details |
|--------|---------|
| Languages | Dart, Java (Android), Swift/Obj-C (iOS/macOS), C++ (Windows/Linux), JavaScript (Web) |
| Framework | Flutter ≥3.32.0, Dart SDK ^3.8.0 |
| Build Tools | `flutter`, `dart`, `build_runner`, npm scripts |

---

## Quick Reference: Build & Validation Commands

### Dependencies (Always Run First)
```bash
cd flutter_inappwebview_platform_interface && flutter pub get
cd ../flutter_inappwebview && flutter pub get
# Repeat for any platform package you modify
```

### Code Generation (After Modifying Annotated Files)
```bash
# From repo root - REQUIRED after editing @ExchangeableObject/@ExchangeableEnum files
npm run build # or npm run build:windows for Windows only
# Or directly:
cd flutter_inappwebview_platform_interface && flutter pub run build_runner build --delete-conflicting-outputs
```

### Static Analysis (Validation)
```bash
cd flutter_inappwebview_platform_interface && dart analyze
cd flutter_inappwebview && dart analyze
```
**Expected**: Only `info`-level `constant_identifier_names` warnings (intentional for API naming).

### Code Formatting
```bash
npm run format # or npm run format:windows for Windows only
```

### Unit Tests
```bash
cd flutter_inappwebview && flutter test
```

### Integration Tests (Requires Device + Node Server)
```bash
cd flutter_inappwebview/example
NODE_SERVER_IP=<ip> flutter driver --driver=test_driver/integration_test.dart --target=integration_test/webview_flutter_test.dart
```

---

## Architecture Overview

This repository follows the **Federated Plugin** architecture:

- **`flutter_inappwebview/`**: The **plugin-facing-API package**. This is the public API that developers depend on.
  - Files here usually wrap platform implementations via `Platform*` classes (e.g., `PlatformInAppWebViewWidget`).
  - It delegates logic to the platform interface or specific platform implementations.
- **`flutter_inappwebview_platform_interface/`**: The **platform interface package**.
  - Contains pure Dart contracts, typedefs, enums, and shared utilities.
  - Defines the `PlatformInterface` that all platform packages must implement.
  - **Crucial**: Anything added to the public API (`flutter_inappwebview`) MUST rely on or extend these definitions. DO NOT duplicate platform logic in the public package.
- **`flutter_inappwebview_<platform>/`**: The **platform implementation packages** (Android, iOS, macOS, Windows, Linux, Web).
  - These packages implement the abstract classes defined in `flutter_inappwebview_platform_interface`.
  - They contain platform-specific code (Dart and native: Java, Obj-C/Swift, C++, JavaScript).
  - Keep their APIs strictly aligned with the `platform_interface` layer.
- **`dev_packages/` and `scripts/`**: Internal tooling, generators, and maintenance scripts.

### Main Plugin-Facing-API Classes
- Web view: `InAppWebView`, `InAppWebViewController`, `HeadlessInAppWebView`
- Browser shells: `InAppBrowser`, `ChromeSafariBrowser`, `WebAuthenticationSession`
- Platform helpers: `WebViewEnvironment`, `ProcessGlobalConfig`, `ProxyController`, `ServiceWorkerController`, `TracingController`, `PrintJobController`, `PullToRefreshController`, `FindInteractionController`
- Storage & messaging: `WebStorage`, `LocalStorage`, `SessionStorage`, `WebStorageManager`, `WebMessageChannel`, `WebMessageListener`
- Cookies: `CookieManager`
- Auth storage: `HttpAuthCredentialDatabase`

### Platform Native API References

When implementing platform-specific features, consult the official API documentation:

| Platform | API Documentation | Main Classes |
|----------|-------------------|--------------|
| **Android** | [Android WebView](https://developer.android.com/reference/android/webkit/WebView) and [androidx.webkit](https://developer.android.com/reference/androidx/webkit/package-summary) | `WebView`, `WebViewClient`, `WebChromeClient`, `WebSettings`, `CookieManager` |
| **iOS/macOS** | [WebKit](https://developer.apple.com/documentation/webkit) | `WKWebView`, `WKNavigationDelegate`, `WKUIDelegate`, `WKWebViewConfiguration`, `WKUserContentController` |
| **Windows** | [WebView2](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/) | `ICoreWebView2`, `ICoreWebView2Controller`, `ICoreWebView2Settings`, `ICoreWebView2Environment` |
| **Linux** | [WPE WebKit 2.0](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/) | `WebKitWebView`, `WebKitSettings`, `WebKitUserContentManager`, `WebKitCookieManager`, `WebKitWebsiteDataManager` |
| **Web** | [HTMLIFrameElement](https://developer.mozilla.org/en-US/docs/Web/API/HTMLIFrameElement) | `HTMLIFrameElement`, `postMessage`, `Window` |

## Coding Guidelines

### General
- **Stay Dart-side unless explicitly working inside a platform package.** Never touch native (`.java`, `.kt`, `.mm`, `.swift`, `.cpp`, `.cs`) code when an issue only concerns the shared Dart API.
- **Null Safety**: Strictly adhere to null safety. Do not introduce nullable APIs unless absolutely necessary.
- **Avoid Breaking Changes**: Any API change requires updating the `platform_interface`, all federated implementations, and changelog entries.
- **Code Generation**: Use `@ExchangeableObject`, `@ExchangeableEnum` annotations. Run `npm run build` to regenerate files.
- **Generated Files**: Never hand-edit `*.g.dart` files. Update the annotated source instead.

### Platform Interface & Public API
- **Propagation Order**: Add or change APIs in `flutter_inappwebview_platform_interface` first, then update every platform implementation, and finally wire the public `flutter_inappwebview` wrapper.
- **Documentation Macros**: Respect `{@macro ...}` and keep comments synchronized with `platform_interface`.
- **`@SupportedPlatforms`**: Add annotations to document platform availability. Only mark supported when implementation exists.
- **Support Checks**: Implement `isClassSupported`, `isPropertySupported`, `isMethodSupported` by deferring to `platform_interface` static singleton.

> **Detailed patterns**: See `.github/instructions/platform-interface.instructions.md` for the full `Supported Platforms Pattern` with code examples.

### Platform Implementations
- **`inappwebview_platform.dart`**: Each platform package implements `InAppWebViewPlatform` with factory methods.
- **Unsupported Features**: Return stub classes for unsupported features to ensure `isClassSupported` works correctly.
- **Extending Params**: Platform implementations extend `Platform*CreationParams` for platform-specific fields.

> **Platform-specific details**: See `.github/instructions/<platform>.instructions.md` for native code structure and implemented classes.

### Feature Update Checklist
1. Update or add the contract inside `flutter_inappwebview_platform_interface`.
2. Run `npm run build` (or the equivalent `build_runner` command) to regenerate annotated files.
3. Mirror the new contract in every federated implementation under `flutter_inappwebview_<platform>/lib/src/inappwebview_platform.dart` (returning stub implementations for unsupported platforms).
4. Wire the public API in `flutter_inappwebview/` (controllers, widgets, helpers) and update the example app if the feature is user-facing.
5. Add or update tests/analyzer coverage where possible.
6. Update documentation (README, docs site) and add changelog entries for every package you touched (interface, each platform, public plugin, etc.).
7. Re-run `dart analyze`/`flutter test` in the affected packages before sending the PR.

## Testing & Validation
- **Run Tests**: Run `flutter test` inside the relevant package before suggesting changes.
- **Analyze**: For analyzer-only updates, run `dart analyze` and ensure `analysis_options.yaml` lints stay satisfied.
- **Contract Updates**: When touching `platform_interface` contracts, explicitly explain how downstream packages must be updated and list the follow-up steps.
- **Integration Tests**: Live under `flutter_inappwebview/example/integration_test` and can be executed via `scripts/test_and_log.sh` (accepts optional `NODE_SERVER_IP` and `DEVICE_ID`).

## Documentation & Examples
- **Update Docs**: Update `README.md`, `doc/`, or example apps when you expose new public APIs.
- **Snippets**: Show simple snippets that exercise the new API on supported platforms only.
- **Changelog**: Keep changelog entries scoped under the correct package (e.g., `flutter_inappwebview/CHANGELOG.md`).
  - If a change spans multiple packages, add a short entry to each relevant `CHANGELOG.md` so consumers of standalone packages understand what changed.

## Pull Request Tips
- **Title**: Reference the federated package you changed in the PR title (e.g., `[flutter_inappwebview] Add PrintJobController helpers`).
- **Testing Instructions**: Call out any manual steps required for testers (running example app, enabling permissions, etc.).
- **Platform Parity**: Mention unsupported platforms explicitly instead of assuming parity.

## NPM Scripts

The root `package.json` contains useful scripts for development and maintenance:

- **`npm run build`**: Runs `build_runner build` in `flutter_inappwebview_platform_interface`. Use this when you change code that requires generation (e.g., `*.g.dart` files).
- **`npm run watch`**: Runs `build_runner watch` in `flutter_inappwebview_platform_interface`.
- **`npm run format`**: Formats code in all packages using `dart format`.
- **`npm run docs:gen`**: Generates API documentation.
- **`npm run docs:serve`**: Serves the generated API documentation locally.
- **`npm run publish:dry`**: Runs a dry-run publish check.

---

## Development Workflow (CRITICAL: Propagation Order)

**ALWAYS follow this order when adding/changing APIs:**

1. **`flutter_inappwebview_platform_interface/`** - Define contracts, types, enums first
2. Run `npm run build` to regenerate `*.g.dart` files
3. **`flutter_inappwebview_<platform>/`** - Implement in each platform package
4. **`flutter_inappwebview/`** - Wire the public API wrapper last
5. Update `CHANGELOG.md` in EACH touched package

### Critical Rules
- **Never hand-edit `*.g.dart` files** - modify the source and regenerate
- **Never touch native code** (`.java`, `.kt`, `.swift`, `.mm`, `.cpp`) for Dart-only API changes
- **Always create stub implementations** for unsupported platforms in `inappwebview_platform.dart`
- **Always run `dart analyze`** before considering work complete

---

## Common Errors & Solutions

| Error | Solution |
|-------|----------|
| "Platform implementation not found" | Check `pubspec.yaml` has correct `implements` and `dartPluginClass` |
| Build runner conflicts | Add `--delete-conflicting-outputs` flag |
| Missing generated file | Run `npm run build` from repo root |
| Import errors after interface changes | Run `flutter pub get` in dependent packages |

---

## Validation Checklist Before Submitting

- [ ] `flutter pub get` in all modified packages
- [ ] `npm run build` if annotated files were modified
- [ ] `dart analyze` passes (only info-level warnings acceptable)
- [ ] `npm run format` applied
- [ ] CHANGELOG.md updated in each modified package
- [ ] Platform stub implementations added for unsupported features

---

## Trust These Instructions

This document contains validated workflows. Only search the codebase if:
- Information appears outdated or incorrect
- Implementation details are not covered here
- Working on native platform code (see `.github/instructions/` for platform-specific guidance)

Here is a list of instruction files that contain rules for modifying or creating new code.
These files are important for ensuring that the code is modified or created correctly.
Please make sure to follow the rules specified in these files when working with the codebase.
If the file is not already available as attachment, use the 'read_file' tool to acquire it.
Make sure to acquire the instructions before making any changes to the code.

<instruction>
<file>.github/instructions/android.instructions.md</file>
<description>Android platform implementation details (Java). Use this as reference when implementing Android-specific features.</description>
</instruction>
<instruction>
<file>.github/instructions/plugin-facing-api.instructions.md</file>
<description>Public API wrapper implementation details. Use this when working on the `flutter_inappwebview` package and expose new API from the platform interface.</description>
</instruction>
<instruction>
<file>.github/instructions/ios.instructions.md</file>
<description>iOS platform implementation details (Swift/Obj-C). Use this as reference when implementing iOS-specific features.</description>
</instruction>
<instruction>
<file>.github/instructions/linux.instructions.md</file>
<description>Linux platform implementation details (C++). Use this as reference when implementing Linux-specific features.</description>
</instruction>
<instruction>
<file>.github/instructions/macos.instructions.md</file>
<description>macOS platform implementation details (Swift/Obj-C). Use this as reference when implementing macOS-specific features.</description>
</instruction>
<instruction>
<file>.github/instructions/platform-interface.instructions.md</file>
<description>Platform interface definitions and contracts. This is the starting point for any new API.</description>
</instruction>
<instruction>
<file>.github/instructions/web.instructions.md</file>
<description>Web platform implementation details (Dart/TypeScript). Use this as reference when implementing Web-specific features.</description>
</instruction>
<instruction>
<file>.github/instructions/windows.instructions.md</file>
<description>Windows platform implementation details (C++). Use this as reference when implementing Windows-specific features.</description>
</instruction>

