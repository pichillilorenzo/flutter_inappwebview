## 1.0.11

- Added `PlatformWebViewEnvironment` class

## 1.0.10

- Merged "Added == operator and hashCode to WebUri" [#1941](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1941) (thanks to [daisukeueta](https://github.com/daisukeueta))

## 1.0.9

- Fix typos (thanks to [michalsrutek](https://github.com/michalsrutek))

## 1.0.8

- Added `PlatformCustomPathHandler` class to be able to implement custom path handlers for `WebViewAssetLoader`

## 1.0.7

- Added `InAppBrowser.onMainWindowWillClose` event
- Added `WindowType.WINDOW` for `InAppBrowserSettings.windowType`

## 1.0.6

- Added `InAppWebViewSettings.interceptOnlyAsyncAjaxRequests` [#1905](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1905)
- Added `PlatformInAppWebViewController.clearFormData` method
- Added `PlatformCookieManager.removeSessionCookies` method
- Updated `InAppWebViewSettings.useShouldInterceptAjaxRequest` docs
- Updated `PlatformCookieManager` methods return value

## 1.0.5

- Must call super `dispose` method for `PlatformInAppBrowser` and `PlatformChromeSafariBrowser` 

## 1.0.4

- Expose missing `InAppBrowserSettings.menuButtonColor` option

## 1.0.3

- Expose missing old `AndroidInAppWebViewOptions` and `IOSInAppWebViewOptions` classes

## 1.0.2

- Added `PlatformPrintJobController.onComplete` setter

## 1.0.1

- Updated README 

## 1.0.0

Initial release.
