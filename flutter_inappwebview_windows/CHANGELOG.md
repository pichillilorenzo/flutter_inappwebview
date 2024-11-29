## 0.7.0-beta.3

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.3
- Merged "windows: fix WebViewEnvironment dispose crash" [#2433](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2433) (thanks to [GooRingX](https://github.com/GooRingX))

## 0.7.0-beta.2

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.2
- Updated Microsoft.Web.WebView2 SDK version from `1.0.2792.45` to `1.0.2849.39`
- Implemented `disableDefaultErrorPage`, `statusBarEnabled`, `browserAcceleratorKeysEnabled`, `generalAutofillEnabled`, `passwordAutosaveEnabled`, `isPinchZoomEnabled`, `allowsBackForwardNavigationGestures`, `hiddenPdfToolbarItems`, `reputationCheckingRequired`, `nonClientRegionSupportEnabled` properties of `InAppWebViewSettings`
- Implemented `isInterfaceSupported`, `getProcessInfos`, `getFailureReportFolderPath` WebViewEnvironment methods
- Implemented `isInterfaceSupported`, `getZoomScale` InAppWebViewController method
- Implemented `onDownloadStarting`, `onAcceleratorKeyPressed` WebView event
- Implemented `exclusiveUserDataFolderAccess`, `isCustomCrashReportingEnabled`, `enableTrackingPrevention`, `areBrowserExtensionsEnabled`, `channelSearchKind`, `releaseChannels`, `scrollbarStyle` properties of `WebViewEnvironmentSettings`
- Implemented `onNewBrowserVersionAvailable`, `onBrowserProcessExited`, `onProcessInfosChanged` WebViewEnvironment events
- Send mouse leave region event to native view
- Fixed wrong channel name when creating a `WebViewEnvironment` instance
- Fixed "[Windows] Has an overlay on the desktop when the application is minimized" [#2402](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2402)
- Fixed "[Windows] missing implementation of onPermissionRequest event will cause crash when requested by the webpage" [#2404](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2404)
- Fixed "Windows: getCookies return empty list" [#2314](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2314)

## 0.7.0-beta.1

- Updated flutter_inappwebview_platform_interface version to ^1.4.0-beta.1
- Updated `scrollMultiplier` default value from 6 to 1
- Added support for `UserScript.allowedOriginRules` and `UserScript.forMainFrameOnly` parameters
- Implemented `onReceivedHttpAuthRequest`, `onReceivedClientCertRequest`, `onReceivedServerTrustAuthRequest`, `onRenderProcessGone`, `onRenderProcessUnresponsive`, `onWebContentProcessDidTerminate`, `onProcessFailed` WebView events
- Implemented `clearSslPreferences` WebView method
- Fixed `get_optional_fl_map_value` implementation in `utils/flutter.h`
- Fixed "Error in transparentBackground handling in Windows" [#2391](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2391)

## 0.6.0

- Updated code to support multiple flutter windows

## 0.5.0+2

- Fixed `InAppWebViewController.callAsyncJavaScript` not working with JSON objects

## 0.5.0+1

- Fixed `onLoadResourceWithCustomScheme` WebView event called every time

## 0.5.0

- Implemented `shouldInterceptRequest`, `onLoadResourceWithCustomScheme` WebView events
- Updated flutter_inappwebview_platform_interface version to ^1.3.0

## 0.4.1

- Implemented `incognito` for `InAppWebViewSettings`

## 0.4.0

- Updated `shouldOverrideUrlLoading` implementation using the Chrome DevTools Protocol API Fetch.requestPaused event
- Updated flutter_inappwebview_platform_interface version to ^1.2.0

## 0.3.0+1

- Removed unwanted debug log

## 0.3.0

- Implemented `pause`, `resume`, `getCertificate` methods for `InAppWebViewController`
- Implemented `onPermissionRequest` WebView event

## 0.2.0+1

- Fixed `InAppWebViewController.evaluateJavascript` not working with JSON objects
- Fixed `InAppWebViewManager::METHOD_CHANNEL_NAME` c++ value
- Fixed `InAppWebViewController.takeScreenshot` to behave consistently with the other platforms

## 0.2.0

- Added support for keeping alive InAppWebView widgets
- Added onProgressChanged, onCreateWindow, onCloseWindow support
- Updated Microsoft.Web.WebView2 SDK version from `1.0.2210.55` to `1.0.2792.45`
- Updated pubspec.yaml
- Fixed `CookieManager.setCookie`

## 0.1.0

- Initial release
