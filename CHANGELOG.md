## 2.0.0

- Merge "Avoid null pointer exception after webview is disposed" [#116](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/116) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merge "Remove async call in close" [#119](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/119) (thanks to [benfingo](https://github.com/benfingo))
- Merge "Android takeScreenshot does not work properly." [#122](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/122) (thanks to [PauloMelo](https://github.com/PauloMelo))
- Merge "Resolving gradle error." [#144](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/144) (thanks to [Klingens13](https://github.com/Klingens13))
- Merge "Create issue and pull request templates" [#150](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/150) (thanks to [deandreamatias](https://github.com/deandreamatias))
- Merge "Fix abstract method error && swift version error" [#155](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/155) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Merge "migrating to swift 5.0" [#162](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/162) (thanks to [fattiger00](https://github.com/fattiger00))
- Merge "Update readme example" [#178](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/178) (thanks to [SebastienBtr](https://github.com/SebastienBtr))
- Merge "handle choose file callback in android" [#183](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/183) (thanks to [crazecoder](https://github.com/crazecoder))
- Merge "add initialScale in android" [#186](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/186) (thanks to [crazecoder](https://github.com/crazecoder))
- Added `horizontalScrollBarEnabled` and `verticalScrollBarEnabled` options to enable/disable the corresponding scrollbar of the WebView [#165](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/165)
- Added `onDownloadStart` event and `useOnDownloadStart` option: event fires when the WebView recognizes and starts a downloadable file.
- Added `onLoadResourceCustomScheme` event and `resourceCustomSchemes` option to set custom schemes that WebView must handle to load resources
- Added `onTargetBlank` event and `useOnTargetBlank` option to manage links with `target="_blank"`
- Added `ContentBlocker`, `ContentBlockerTrigger` and `ContentBlockerAction` classes and the `contentBlockers` option that allows to define a set of rules to use to block content in the WebView
- Added new WebView options: `minimumFontSize`, `debuggingEnabled`, `preferredContentMode`, `applicationNameForUserAgent`, `incognito`, `cacheEnabled`, `disableVerticalScroll`, `disableHorizontalScroll`
- Added new Android WebView options: `allowContentAccess`, `allowFileAccess`, `allowFileAccessFromFileURLs`, `allowUniversalAccessFromFileURLs`, `appCachePath`, `blockNetworkImage`, `blockNetworkLoads`, `cacheMode`, `cursiveFontFamily`, `defaultFixedFontSize`, `defaultFontSize`, `defaultTextEncodingName`, `disabledActionModeMenuItems`, `fantasyFontFamily`, `fixedFontFamily`, `forceDark`, `geolocationEnabled`, `layoutAlgorithm`, `loadWithOverviewMode`, `loadsImagesAutomatically`, `minimumLogicalFontSize`, `needInitialFocus`, `offscreenPreRaster`, `sansSerifFontFamily`, `serifFontFamily`, `standardFontFamily`, `saveFormData`, `thirdPartyCookiesEnabled`, `hardwareAcceleration`
- Added new iOS WebView options: `isFraudulentWebsiteWarningEnabled`, `selectionGranularity`, `dataDetectorTypes`, `sharedCookiesEnabled`
- Added `onGeolocationPermissionsShowPrompt` event and `GeolocationPermissionShowPromptResponse` class (available only for Android)
- Added `startSafeBrowsing`, `setSafeBrowsingWhitelist` and `getSafeBrowsingPrivacyPolicyUrl` methods (available only for Android)
- Added `clearSslPreferences` and `clearClientCertPreferences` methods (available only for Android)
- Added `onSafeBrowsingHit` event (available only for Android)
- Added `onJsAlert`, `onJsConfirm` and `onJsPrompt` events to manage javascript popup dialogs
- Added `onReceivedHttpAuthRequest` event
- Added `clearCache`, `scrollTo`, `scrollBy`, `getHtml`, `injectJavascriptFileFromAsset` and `injectCSSFileFromAsset` methods method
- Added `HttpAuthCredentialDatabase` class
- Added `onReceivedServerTrustAuthRequest` and `onReceivedClientCertRequest` events to manage SSL requests
- Added `onFindResultReceived` event, `findAllAsync`, `findNext` and `clearMatches` methods 
- Added `shouldInterceptAjaxRequest`, `onAjaxReadyStateChange`, `onAjaxProgress` and `shouldInterceptFetchRequest` events with `useShouldInterceptAjaxRequest` and `useShouldInterceptFetchRequest` webview options
- Added `onNavigationStateChange` and `onLoadHttpError` events
- Fun: added `getTRexRunnerHtml` and `getTRexRunnerCss` methods to get html (with javascript) and css to recreate the Chromium's t-rex runner game 

### BREAKING CHANGES
- Deleted `WebResourceRequest` class
- Updated `WebResourceResponse` class
- Updated `ConsoleMessage` class
- Updated `ConsoleMessageLevel` class
- Updated `onLoadResource` event
- Updated `CookieManager` class
- WebView options are now available with the new corresponding classes: `InAppWebViewOptions`, `AndroidInAppWebViewOptions`, `iOSInAppWebViewOptions`, `InAppBrowserOptions`, `AndroidInAppBrowserOptions`, `iOSInAppBrowserOptions`, `AndroidChromeCustomTabsOptions` and `iOSSafariOptions`
- Renamed `getFavicon` to `getFavicons`, now it returns a list of all favicons (`List<Favicon>`) found
- Renamed `injectScriptFile` to `injectJavascriptFileFromUrl`
- Renamed `injectScriptCode` to `evaluateJavascript`
- Renamed `injectStyleCode` to `injectCSSCode`
- Renamed `injectStyleFile` to `injectCSSFileFromUrl`

## 1.2.2

- Merge "added a shared WKProcessPool for webview instances" [#198](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/198) (thanks to [robertcnst](https://github.com/robertcnst))
- Fixed iOS setCookie.

## 1.2.1

- Merge "Add new option to control the contentMode in Android platform" [#101](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/101) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Merge "Fix crash on xcode 10.2" [#107](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/107) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merge "Remove headers_build_phase from example's Podfile" [#108](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/108) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Fixed "Make html5 video fullscreen" for Android [#43](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/43)
- Fixed "AllowsInlineMediaPlayback not working" for iOS [#73](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/73)

## 1.2.0

- Merge "Adds a transparentBackground option for iOS and Android" [#86](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/86) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merge "The 'open' method requires an options dictionary" [#87](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/87) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merge "iOS: Call setNeedsLayout() in scrollViewDidScroll()" [#88](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/88) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Fixed "java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread." [#98](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/98) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Fixed "app force close/crash when enabling zoom and repeatedly changing orientation and zoomin zoomout" [#93](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/93)
- Added `displayZoomControls` webview option for Android
- Fixed "Compatibility with other plugins" [#80](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/80)

## 1.1.3

- Merge "Add null checks around calls to InAppWebView callbacks" [#85](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/85) (thanks to [matthewlloyd](https://github.com/matthewlloyd))

## 1.1.2

- Fix InAppBrowser crashes the app when i change the page "Lost connection" [#74](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/74)
- Fix javascript `...args` parameter of `window.flutter_inappbrowser.callHandler()`
- Merge Enable setTextZoom function of Android WebViewSetting [#81](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/81) (thanks to [YouCii](https://github.com/YouCii))
- Merge bug fix for android build: Android dependency 'androidx.core:core' has different version for the compile (1.0.0) and runtime (1.0.1) classpath [#83](https://github.com/pichillilorenzo/flutter_inappbrowser/pull/83) (thanks to [cinos1](https://github.com/cinos1))

## 1.1.1

- Fixed README.md and `addJavaScriptHandler` method documentation

## 1.1.0

- Breaking change for `addJavaScriptHandler` and `removeJavaScriptHandler` methods.
- `addJavaScriptHandler` method can return data to JavaScript using `Promise` [#46](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/46)
- added `flutterInAppBrowserPlatformReady` JavaScript event to wait until the platform is ready [#64](https://github.com/pichillilorenzo/flutter_inappbrowser/issues/64)

## 1.0.1

- Fixed Unable to load initialFile on iOS #56
- Some code cleanup

## 1.0.0

Breaking changes:
- Fixed [Flutter AndroidX compatibility](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility), the latest version that doesn't use `AndroidX` is `0.6.0` (thanks to [juicycleff](https://github.com/juicycleff)).

## 0.6.0

- added support for **iOS** inline native WebView integrated in the flutter widget tree
- updated example folder (thanks to [marquesinijatinha](https://github.com/marquesinijatinha))
- Fixed bug where passing null to expiresDate failed (thanks to [Sense545](https://github.com/Sense545)) 
- Fixed iOS error: encode resourceURL (thanks to [igtm](https://github.com/igtm))
- Fixed iOS error: Double value cannot be converted to Int because the result would be greater than Int.max in 32-bit devices (thanks to [huzhiren](https://github.com/huzhiren))
- Fixed iOS error: problem in ChromeSafariBrowser (thanks to [marquesinijatinha](https://github.com/marquesinijatinha))
- Fixed Android build error caused by gradle and build gradle versions (thanks to [tje3d](https://github.com/tje3d))
- Updated `uuid` dependency to `^2.0.0`

## 0.5.51

- updated `pubspec.yaml`
- updated `README.md`

## 0.5.5

- added `getUrl` method for the `InAppWebViewController` class
- added `getTitle` method for the `InAppWebViewController` class
- added `getProgress` method for the `InAppWebViewController` class
- added `getFavicon` method for the `InAppWebViewController` class
- added `onScrollChanged` event for the `InAppWebViewController` and `InAppBrowser` class
- added `onBrowserCreated` event for the `InAppBrowser` class
- added `openData` method for the `InAppBrowser` class
- added `initialData` property for the `InAppWebView` widget

## 0.5.4

- added `WebHistory` and `WebHistoryItem` class
- added `getCopyBackForwardList`, `goBackOrForward`, `canGoBackOrForward` and `goTo` methods for the `InAppWebViewController` class

## 0.5.3

- added `CookieManager` class

## 0.5.2

- fixed some missing `result.success()` on Android and iOS
- added `postUrl()` method for the `InAppWebViewController` class
- added `loadData()` method for the `InAppWebViewController` class

## 0.5.1

- updated README.md

## 0.5.0

- added initial support for Inline WebViews using the `InAppWebView` widget
- added `InAppBrowser.openFile()` method
- added `InAppBrowser.onProgressChanged()` event
- moved `InAppBrowser` WebView related functions on the `InAppWebViewController` class
- added `InAppLocalhostServer` class
- added `InAppWebView.canGoBack()` and `InAppWebView.canGoForward()` methods
- removed `openWithSystemBrowser` and `isLocalFile` option. Now use the corresponding method
- code refactoring

## 0.4.1

- added `InAppBrowser.takeScreenshot()`
- added `InAppBrowser.setOptions()`
- added `InAppBrowser.getOptions()`

## 0.4.0

- removed `target` parameter to `InAppBrowser.open()` method. To open the url on the system browser, use the `openWithSystemBrowser: true` option
- fixes for the `_ChannelManager` private class
- fixed `EXC_BAD_INSTRUCTION` onLoadStart in Swift
- added `openWithSystemBrowser` and `isLocalFile` options
- added `InAppBrowser.openWithSystemBrowser` method
- added `InAppBrowser.openOnLocalhost` method
- added `InAppBrowser.loadFile` method
- added `InAppBrowser.isOpened` method

## 0.3.2

- fixed WebView.storyboard path for iOS

## 0.3.1

- fixed README.md example

## 0.3.0

- fixed WebView.storyboard to deployment target 8.0
- added `InAppBrowser.onLoadResource()` method. The event fires when the InAppBrowser webview loads a resource
- added `InAppBrowser.addJavaScriptHandler()` and `InAppBrowser.removeJavaScriptHandler()` methods to add/remove javascript message handlers
- removed `keyboardDisplayRequiresUserAction` from iOS available options
- now the `url` parameter of `InAppBrowser.open()` is optional. The default value is `about:blank`

## 0.2.1

- added `InAppBrowser.onConsoleMessage()` method to manage console messages
- fixed `InAppBrowser.injectScriptCode()` method when there is not a return value

## 0.2.0

- added support of Chrome CustomTabs for Android
- added support of SFSafariViewController for iOS
- added the ability to create multiple instances of browsers

## 0.1.1

- updated/added new methods
- updated UI of android/iOS in-app browser
- code cleanup
- added new options when opening the in-app browser

## 0.0.1

Initial release.
