# GitHub Copilot Instructions — flutter_inappwebview

You are an expert Flutter and Dart plugin developer, specializing in the `flutter_inappwebview` plugin architecture.
Use these notes whenever you propose code for this repository.

## Architecture Overview

This repository follows the **Federated Plugin** architecture:

- **`flutter_inappwebview/`**: The **app-facing package**. This is the public API that developers depend on.
  - Files here usually wrap platform implementations via `Platform*` classes (e.g., `PlatformInAppWebViewWidget`).
  - It delegates logic to the platform interface or specific platform implementations.
- **`flutter_inappwebview_platform_interface/`**: The **platform interface package**.
  - Contains pure Dart contracts, typedefs, enums, and shared utilities.
  - Defines the `PlatformInterface` that all platform packages must implement.
  - **Crucial**: Anything added to the public API (`flutter_inappwebview`) MUST rely on or extend these definitions. DO NOT duplicate platform logic in the public package.
- **`flutter_inappwebview_<platform>/`**: The **platform implementation packages** (Android, iOS, macOS, Windows, Web).
  - These packages implement the abstract classes defined in `flutter_inappwebview_platform_interface`.
  - They contain platform-specific code (Dart and native: Java/Kotlin, Obj-C/Swift, C++, JavaScript).
  - Keep their APIs strictly aligned with the `platform_interface` layer.
- **`dev_packages/` and `scripts/`**: Internal tooling, generators, and maintenance scripts.

## Coding Guidelines

### General
- **Stay Dart-side unless explicitly working inside a platform package.** Never touch native (`.java`, `.kt`, `.mm`, `.swift`, `.cpp`, `.cs`) code when an issue only concerns the shared Dart API.
- **Null Safety**: Strictly adhere to null safety. Do not introduce nullable APIs unless absolutely necessary. Prefer optional named parameters with sensible defaults.
- **Avoid Breaking Changes**: In the public package (`flutter_inappwebview`), avoid breaking changes. Any API change requires updating the `platform_interface`, all federated implementations, and changelog entries.
- **Code Generation**: Use `@ExchangeableObject`, `@ExchangeableEnum`, and other annotations from `flutter_inappwebview_internal_annotations` to generate boilerplate code (e.g., `toMap`, `fromMap`, `copy`). Run `dart run build_runner build` to regenerate files.
- **Generated Files**: Never hand-edit generated artifacts (for example `*.g.dart`). Update the annotated source instead, rerun `dart run build_runner build`, and include only the regenerated outputs relevant to your change.

### Platform Interface & Public API
- **Constructor Helpers**: When exposing new public classes in `flutter_inappwebview`, prefer constructor helpers like `fromPlatformCreationParams` and `fromPlatform`. This allows downstream packages to inject platform overrides.
- **Documentation Macros**: Respect documentation macros (`{@macro ...}`) and keep comments synchronized with definitions in the `platform_interface` package.
- **`@SupportedPlatforms`**: Add `@SupportedPlatforms` annotations that mirror the contract comments in `platform_interface`. Only mark a platform supported when the corresponding federated implementation actually exists.
  - **Parameters**:
    - `platforms`: List of `Platform` objects (e.g., `AndroidPlatform`, `IOSPlatform`).
  - **Platform Object Parameters**:
    - `available`: Version string when the feature became available (e.g., "21").
    - `apiName`: Name of the underlying native API (e.g., "View.setAlpha").
    - `apiUrl`: URL to the official native documentation.
    - `note`: Special notes or restrictions.
- **Support Checks**: Implement support-check helpers (`isClassSupported`, `isPropertySupported`, `isMethodSupported`) by deferring to the `platform_interface` static singleton (`PlatformX.static()`).
- **Enums & Types**: Keep enums for methods/properties in the `platform_interface` package. The public package should use simple passthrough helpers.
- **Propagation Order**: Add or change APIs in `flutter_inappwebview_platform_interface` first, then update every `flutter_inappwebview_<platform>` implementation, and finally wire the public `flutter_inappwebview` wrapper. Each touched package needs an aligned changelog entry.

### Platform Implementations
- **`inappwebview_platform.dart`**: This file in each platform package implements `InAppWebViewPlatform` and handles the creation of platform-specific classes (e.g., `createPlatformInAppWebViewController`).
- **Unsupported Features**: If a feature is NOT supported on a specific platform, you must still implement the creation method in `inappwebview_platform.dart`. Return an instance of a private empty class (e.g., `class _PlatformProcessGlobalConfig extends PlatformProcessGlobalConfig`) that extends the platform interface class. This ensures `isClassSupported`, `isPropertySupported`, `isMethodSupported` static methods works correctly via the `@SupportedPlatforms` annotation.
- **Extending Params**: Platform implementations should extend `Platform*CreationParams` (e.g., `AndroidInAppWebViewWidgetCreationParams` extends `PlatformInAppWebViewWidgetCreationParams`) to add platform-specific fields.
- **Platform Views**:
  - **Android**: Uses `PlatformViewLink` and `AndroidViewSurface` (or `AndroidView` for simple cases) to render native views.
  - **iOS**: Uses `UiKitView`.
- **Method Channels**: Use `MethodChannel` for communication between Dart and native code, but ensure it's encapsulated within the platform implementation classes.

## Testing & Validation
- **Run Tests**: Run `flutter test` inside the relevant package before suggesting changes.
- **Analyze**: For analyzer-only updates, run `dart analyze` and ensure `analysis_options.yaml` lints stay satisfied.
- **Contract Updates**: When touching `platform_interface` contracts, explicitly explain how downstream packages must be updated and list the follow-up steps.

## Documentation & Examples
- **Update Docs**: Update `README.md`, `doc/`, or example apps when you expose new public APIs.
- **Snippets**: Show simple snippets that exercise the new API on supported platforms only.
- **Changelog**: Keep changelog entries scoped under the correct package (e.g., `flutter_inappwebview/CHANGELOG.md`).

## Pull Request Tips
- **Title**: Reference the federated package you changed in the PR title (e.g., `[flutter_inappwebview] Add PrintJobController helpers`).
- **Testing Instructions**: Call out any manual steps required for testers (running example app, enabling permissions, etc.).
- **Platform Parity**: Mention unsupported platforms explicitly instead of assuming parity.

