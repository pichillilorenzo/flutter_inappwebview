## Unreleased

- Added a WebKitGTK (`webkit2gtk-4.1`) rendering backend, used automatically when WPE WebKit is not installed. This makes the plugin build with distribution packages only (`sudo apt install libwebkit2gtk-4.1-dev`) on Ubuntu 24.04/26.04 and other systems that do not ship WPE WebKit ([#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862)).
- The backend can be forced with `FLUTTER_INAPPWEBVIEW_LINUX_BACKEND=wpe|webkitgtk` (CMake cache variable or environment variable).
- Fixed misleading CMake error message when no WebKit port is found (`libwpewebkit-1.0-dev` does not exist on current Ubuntu releases).
- Fixed the example app build with CMake 4.x (updated googletest, optional native assets directory).
- Fixed `InAppBrowser` `show`/`hide`/`isHidden`/`close`/settings method calls failing with `MissingPluginException`: the embedded WebView never had its InAppBrowser delegate set.
- Added Linux integration tests covering rendering into the Flutter texture, JavaScript, pointer/keyboard/scroll input, `HeadlessInAppWebView` and `InAppBrowser`.

## 0.1.0-beta.1

- Initial release.
