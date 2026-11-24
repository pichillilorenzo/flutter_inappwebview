# Linux / WPE compatibility

The plugin requires `wpe-webkit-2.0 >= 2.48`. Backend selection happens at build time.

| WPE release | Backend                                  |
|-------------|------------------------------------------|
| 2.54.1      | WPEPlatform + headless, without libwpe/FDO |
| 2.52.6      | WPEPlatform + headless / WPEBackend-FDO   |
| 2.50.6      | WPEBackend-FDO                           |
| 2.48.7      | WPEBackend-FDO                           |
| <2.48       | Unsupported, including with FDO          |

## API compatibility

- WebKit <2.48 lacks some required APIs: network sessions, JavaScript message replies and all-cookie
  retrieval. FDO does not provide them; use a newer SDK.
- `disableAnimations` uses the available preference: reduced motion in 2.54, disable animations in
  2.52.
- `getMetaThemeColor` returns null on WebKit <2.50.

## Backend selection

Set `FLUTTER_INAPPWEBVIEW_WPE_BACKEND` before loading the plugin in CMake:

- `AUTO` (default): prefer WPEPlatform + headless >= 2.52, otherwise try FDO.
- `PLATFORM`: require WPEPlatform + headless.
- `LEGACY`: require FDO and a WebKit build with the legacy API enabled.

Use `PKG_CONFIG_PATH` to select an SDK. WebKit, WPEPlatform and headless must have matching versions
and prefixes. GTK, epoxy and libsecret are required; libwpe, FDO and wayland-server are plugin
dependencies only for the legacy backend.

## Runtime packaging

`FLUTTER_INAPPWEBVIEW_BUNDLE_WPE` defaults to `ON` and copies the selected WPE libraries with their
SONAME links. Set it to `OFF` when packaging a separate runtime; use
`FLUTTER_INAPPWEBVIEW_WPE_INSTALL_RPATH` to override `$ORIGIN`. WebKit subprocesses, resources and
OS dependencies must also be provided. These options do not relocate WebKit's internal paths.
