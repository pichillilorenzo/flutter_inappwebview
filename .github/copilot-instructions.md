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

### Main App-Facing Classes
- Web view: `InAppWebView`, `InAppWebViewController`, `HeadlessInAppWebView`
- Browser shells: `InAppBrowser`, `ChromeSafariBrowser`, `WebAuthenticationSession`
- Platform helpers: `WebViewEnvironment`, `ProcessGlobalConfig`, `ProxyController`, `ServiceWorkerController`, `TracingController`, `PrintJobController`, `PullToRefreshController`, `FindInteractionController`
- Storage & messaging: `WebStorage`, `LocalStorage`, `SessionStorage`, `WebStorageManager`, `WebMessageChannel`, `WebMessageListener`
- Cookies: `CookieManager`
- Auth storage: `HttpAuthCredentialDatabase`

### InAppWebViewSettings quick reference
- Source of truth: `flutter_inappwebview_platform_interface/lib/src/in_app_webview/in_app_webview_settings.dart` (`InAppWebViewSettings_` with `@ExchangeableObject` → generated public `InAppWebViewSettings`). Always edit the annotated source, then run `npm run build` to regenerate `*.g.dart`.
- Role: exhaustive configuration bag for `InAppWebView`/`InAppBrowser` creation params. Mirrors platform capabilities via `@SupportedPlatforms` on each field; no platform-specific logic belongs here.
- Defaults/inference: several flags (e.g., `useShouldOverrideUrlLoading`, `useOnLoadResource`, `useShouldInterceptRequest`, AJAX/fetch hooks) auto-infer to `true` when the related callback is implemented and the flag is `null`. Set explicitly in browsers to avoid surprises.
- Deprecated fields: keep deprecated properties tagged with `@ExchangeableObjectProperty(leaveDeprecatedInToMapMethod: true)` so serialization remains backward compatible. Prefer new alternatives (e.g., `algorithmicDarkeningAllowed` over `forceDark`).
- Complex types: uses exchangeable enums/objects such as `MixedContentMode_`, `WebViewAssetLoader_`, `RendererPriorityPolicy_`, `ContentBlocker`. Add new fields only after defining the enum/object in `platform_interface` and regenerating code.
- Support checks: rely on generated support helpers; when adding a field, annotate with `@SupportedPlatforms` and ensure downstream platform packages handle the field (or stub it) to preserve parity.

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
- **Static-only Helpers**: If a class only exposes static helpers (no instance properties/methods), you can skip overriding `isPropertySupported`/`isMethodSupported` altogether; make sure the public wrapper still calls the static singleton when exposing support checks.
- **Enums & Types**: Keep enums for methods/properties in the `platform_interface` package. The public package should use simple passthrough helpers.
- **Propagation Order**: Add or change APIs in `flutter_inappwebview_platform_interface` first, then update every `flutter_inappwebview_<platform>` implementation, and finally wire the public `flutter_inappwebview` wrapper. Each touched package needs an aligned changelog entry.

### Supported Platforms Pattern
When implementing a new platform interface class (e.g., `PlatformWebViewEnvironment`), follow this strict pattern to ensure correct documentation generation and runtime support checks:

1.  **Creation Params Class (`Platform*CreationParams`)**:
    - Define the property documentation using `{@template ...}`.
    - Apply the `@SupportedPlatforms` annotation to the property here.
    - Implement `isClassSupported`, implement `isPropertySupported` if the class has properties, and `isMethodSupported` if the class has methods.
    - **Crucial**: `isPropertySupported` must accept `dynamic property` and check if the property name exists in the `CreationParams` class first.

    ```dart
    @SupportedPlatforms(platforms: [WindowsPlatform()])
    @immutable
    class PlatformWebViewEnvironmentCreationParams {
      const PlatformWebViewEnvironmentCreationParams({this.settings});

      ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings}
      /// WebView Environment settings.
      ///{@endtemplate}
      ///
      ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings.supported_platforms}
      @SupportedPlatforms(platforms: [WindowsPlatform()])
      final WebViewEnvironmentSettings? settings;

      bool isClassSupported({TargetPlatform? platform}) =>
          PlatformWebViewEnvironment.isClassSupported(platform: platform);

      bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
          PlatformWebViewEnvironment.isPropertySupported(property, platform: platform);
    }
    ```

2.  **Main Interface Class (`Platform*`)**:
    - Use `{@macro ...}` to reuse the documentation from `CreationParams`.
    - **Do NOT** repeat `@SupportedPlatforms` on the getters/properties in this class. The macro will pull the supported platforms documentation.
    - Implement `isClassSupported`, `isPropertySupported`, and `isMethodSupported` instance methods (which are called by the static singleton).
    - **Crucial**: `isPropertySupported` and `isMethodSupported` should ONLY be implemented if the class actually has properties or methods to check. If the class has no properties, do not implement `isPropertySupported`. If it has no methods, do not implement `isMethodSupported`.
    - **Crucial**: `isPropertySupported` must handle both `CreationParams` properties and the class's own properties (using the generated `*CreationParamsProperty` and `*PropertySupported` classes).
    - **Crucial**: `isMethodSupported` delegates to the generated `_Platform*MethodSupported` class.
  - **Reference Implementations**: `PlatformPrintJobController` shows the full property+method pattern, `PlatformFindInteractionController` shows params-only property forwarding, and `PlatformCookieManager` mixes environment-specific params with method support.

    ```dart
    @SupportedPlatforms(platforms: [WindowsPlatform()])
    abstract class PlatformWebViewEnvironment extends PlatformInterface implements Disposable {
      // ... factory constructors ...

      ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings}
      ///
      ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings.supported_platforms}
      WebViewEnvironmentSettings? get settings => params.settings;

      ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.isClassSupported}
      bool isClassSupported({TargetPlatform? platform}) =>
          params.isClassSupported(platform: platform);

      ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isPropertySupported}
      ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
      ///{@endtemplate}
      bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
          property is PlatformWebViewEnvironmentCreationParamsProperty
              ? params.isPropertySupported(property, platform: platform)
              : _PlatformWebViewEnvironmentPropertySupported.isPropertySupported(
                  property,
                  platform: platform);

      ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isMethodSupported}
      ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
      ///{@endtemplate}
      bool isMethodSupported(PlatformWebViewEnvironmentMethod method,
              {TargetPlatform? platform}) =>
          _PlatformWebViewEnvironmentMethodSupported.isMethodSupported(method,
              platform: platform);
    }
    ```

### Platform Implementations
- **`inappwebview_platform.dart`**: This file in each platform package implements `InAppWebViewPlatform` and handles the creation of platform-specific classes (e.g., `createPlatformInAppWebViewController`).
- **Unsupported Features**: If a feature is NOT supported on a specific platform, you must still implement the creation method in `inappwebview_platform.dart`. Return an instance of a private empty class (e.g., `class _PlatformProcessGlobalConfig extends PlatformProcessGlobalConfig`) that extends the platform interface class. This ensures `isClassSupported`, `isPropertySupported`, `isMethodSupported` static methods works correctly via the `@SupportedPlatforms` annotation.
- **Extending Params**: Platform implementations should extend `Platform*CreationParams` (e.g., `AndroidInAppWebViewWidgetCreationParams` extends `PlatformInAppWebViewWidgetCreationParams`) to add platform-specific fields.
- **Platform Views**:
  - **Android**: Uses `PlatformViewLink` and `AndroidViewSurface` (or `AndroidView` for simple cases) to render native views; [android.webkit.WebView](https://developer.android.com/reference/android/webkit/WebView).
  - **iOS**: Uses `UiKitView`; [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview).
  - **macOS**: Uses `AppKitView`; [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview).
  - **Windows**: Uses a custom platform view implementation using textures; [WebView2](https://learn.microsoft.com/en-us/microsoft-edge/webview2/).
  - **Web**: Uses an `HtmlElementView` to embed an `<iframe>`; [HTMLIFrameElement](https://developer.mozilla.org/en-US/docs/Web/API/HTMLIFrameElement).
  - **Linux**: Currently not supported.
- **Method Channels**: Use `MethodChannel` for communication between Dart and native code, but ensure it's encapsulated within the platform implementation classes.

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

