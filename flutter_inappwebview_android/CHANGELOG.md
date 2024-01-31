## 1.0.13

- Fixed "Android emulator using API 34 fails to draw on resume sometimes" [#1981](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1981)

## 1.0.12

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.10`

## 1.0.11

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.9`
- Fix typos (thanks to [michalsrutek](https://github.com/michalsrutek))

## 1.0.10

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.8`
- Implemented `PlatformCustomPathHandler` class

## 1.0.9

- Updated `flutter_inappwebview_platform_interface` version dependency to `^1.0.7`
- Fixed "Cloudflare Turnstile failure" [#1738](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)
- Fixed `InAppWebViewController.callAsyncJavaScript` issue when the last line of the `functionBody` parameter includes a code comment

## 1.0.8

- Implemented `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests`
- Implemented `PlatformInAppWebViewController.clearFormData` method
- Implemented `PlatformCookieManager.removeSessionCookies` method
- Updated `useShouldInterceptAjaxRequest` automatic infer logic
- Updated `CookieManager` methods return value

## 1.0.7

- Merged "Fixed error in InterceptAjaxRequestJS 'Failed to set responseType property'" [#1904](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1904) (thanks to [EArminjon](https://github.com/EArminjon))
- Fixed shouldInterceptAjaxRequest javascript code when overriding XMLHttpRequest.open method parameters

## 1.0.6

- Fixed "getFavicons: _TypeError: type '_Map<String, dynamic>' is not a subtype of type 'Iterable<dynamic>'" [#1897](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1897)
- Fixed "onClosed not considering back navigation or up button / close button in ChromeSafariBrowser when using noHistory: true" [#1882](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1882)

## 1.0.5

- Call `super.dispose();` on `InAppBrowser` and `ChromeSafari` implementations 

## 1.0.4

- Throw platform exception when ProcessGlobalConfig.apply throws an error on the native side to be able to catch it on Flutter side

## 1.0.3

- Updated `ContentBlockerHandler` CSS_DISPLAY_NONE action type and `JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_SOURCE` javascript implementation code

## 1.0.2

- Updated `flutter_inappwebview_platform_interface` version dependency to `1.0.2` 
- Fixed "Crash when starting ChromeSafariBrowser on Android java.lang.NoSuchMethodError: No virtual method isEngagementSignalsApiAvailable" [#1881](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1881)

## 1.0.1

- Updated README

## 1.0.0

Initial release.
