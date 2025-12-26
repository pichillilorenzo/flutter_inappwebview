## 1.2.0-beta.3

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.3
- Implemented `saveState`, `restoreState` InAppWebViewController methods
- Implemented `PlatformProxyController` class
- Merged "Add proxy support for iOS" [#2362](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2362) (thanks to [yerkejs](https://github.com/yerkejs))
- Fixed "[iOS] Webview opened with windowId does not receive javascript handler callback." [#2393](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2393)
- Fixed internal javascript callback handlers when the WebView has windowId not null
- Fixed "When useShouldInterceptAjaxRequest is true, some ajax requests doesn't work" [#2197](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2197)
- Merged "fix #2484, Remove not-empty assert for Cookie.value" [#2486](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2486) (thanks to [laishere](https://github.com/laishere))
- Merged "Fix gesture recognition delay prevention for latest Flutter versions" [#2538](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2538) (thanks to [muccy-timeware](https://github.com/muccy-timeware))

## 1.2.0-beta.2

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.2
- Implemented `setInputMethodEnabled`, `hideInputMethod` InAppWebViewController methods
- Implemented `isUserInteractionEnabled`, `alpha` properties of `InAppWebViewSettings`
- Merged "Show / Hide / Disable / Enable soft Keyboard Input (Android & iOS)" [#2408](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2408) (thanks to [Mecharyry](https://github.com/Mecharyry))
- Fixed "In iOS version 17.2, when moving the input focus in a WebView, an unknown area appears at the top of the screen." [#1947](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1947)

## 1.2.0-beta.1

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.1
- Implemented `requestFocus` WebView method
- Updated ConsoleLogJS internal PluginScript to main-frame only as using it on non-main frames could cause issues such as [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)
- Added support for `UserScript.allowedOriginRules` parameter
- Moved `WKUserContentController` initialization on `preWKWebViewConfiguration` to fix possible `undefined is not an object (evaluating 'window.webkit.messageHandlers')` javascript error
- Merged "change priority of DispatchQueue" [#2322](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2322) (thanks to [nnnlog](https://github.com/nnnlog))
- Fixed `show`, `hide` methods and `hidden` setting for `InAppBrowser`

## 1.1.2

- Updated flutter_inappwebview_platform_interface version to ^1.3.0

## 1.1.1

- Updated flutter_inappwebview_platform_interface version to ^1.2.0

## 1.1.0+3

- Updated flutter_inappwebview_platform_interface version

## ## 1.1.0+2

- Updated pubspec.yaml

## 1.1.0+1 

- Fixed "v6.1.0 fails to compile on Xcode 15" [#2288](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2288)

## 1.1.0

- Fixed XCode 16 build
- Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.
- Merged "Add privacy manifest for iOS" [#2029](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2029) (thanks to [ueman](https://github.com/ueman))

## 1.0.13

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.10`

## 1.0.12

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.9`
- Fix typos and other code improvements (thanks to [michalsrutek](https://github.com/michalsrutek))
- Fixed "runtime issue of SecTrustCopyExceptions 'This method should not be called on the main thread as it may lead to UI unresponsiveness.' when using onReceivedServerTrustAuthRequest" [#1924](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1924)
- Merged "💥 Fix iPad crash due to missing sourceView" [#1933](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1933) (thanks to [michalsrutek](https://github.com/michalsrutek))
- Merged "💥 Fix crash - remove force unwrapping from dispose method" [#1932](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1932) (thanks to [michalsrutek](https://github.com/michalsrutek))

## 1.0.11

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.8`

## 1.0.10

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.7`

## 1.0.9

- Implemented `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests`
- Updated `useShouldInterceptAjaxRequest` automatic infer logic
- Updated `CookieManager` methods return value
- Fixed "iOS crash at public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)" [#1912](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1912)

## 1.0.8

- Fixed error in InterceptAjaxRequestJS 'Failed to set responseType property'
- Fixed shouldInterceptAjaxRequest javascript code when overriding XMLHttpRequest.open method parameters

## 1.0.7

- Fixed "getFavicons: _TypeError: type '_Map<String, dynamic>' is not a subtype of type 'Iterable<dynamic>'" [#1897](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1897)

## 1.0.6

- Possible fix for "iOS Fatal Crash" [#1894](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1894)

## 1.0.5

- Call `super.dispose();` on `InAppBrowser` and `ChromeSafari` implementations

## 1.0.4

- Fixed "Cloudflare Turnstile failure" [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)

## 1.0.3

- Fixed `InAppBrowserMenuItem.iconColor` not working

## 1.0.2

- Added `PlatformPrintJobController.onComplete` setter
- Updated `flutter_inappwebview_platform_interface` version dependency to `1.0.2`

## 1.0.1

- Updated README

## 1.0.0

Initial release.
