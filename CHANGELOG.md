## 4.0.0+4

- Reverted calling `handler.post` on Android when a WebView is created
- Fixed iOS extra bottom padding when opening the keyboard
- Fixed "Build for web not working – The integer literal 9223372036854775807 can't be represented exactly in JavaScript" [#429](https://github.com/pichillilorenzo/flutter_inappwebview/issues/429)
- Fixed iOS userContentController didReceive WKScriptMessage event when using a WebView created with a `windowId`

## 4.0.0

- Updated `onCreateWindow`, `onJsAlert`, `onJsConfirm`, `onJsPrompt` webview events
- Added `onCloseWindow`, `onTitleChanged`, `onWindowFocus`, `onWindowBlur` webview events
- Added `androidOnRequestFocus`, `androidOnReceivedIcon`, `androidOnReceivedTouchIconUrl`, `androidOnJsBeforeUnload`, `androidOnReceivedLoginRequest` Android-specific webview events
- Added `disableDefaultErrorPage` Android-specific webview option
- Added `isAvailable` ChromeSafariBrowser static method
- Fixed "SFSafariViewController doesn't open like a native iOS modal" [#403](https://github.com/pichillilorenzo/flutter_inappwebview/issues/403)

### BREAKING CHANGES

- Updated `onCreateWindow`, `onJsAlert`, `onJsConfirm`, `onJsPrompt` webview event
- Renamed `OnCreateWindowRequest` class to `CreateWindowRequest`

## 3.4.0+2

- Reverted default `InAppWebView.gestureRecognizers` value to null on Android

## 3.4.0+1

- Updated README.md
- Updated missing docs
- Fixed pub.dev Health suggestions and Analysis suggestions

## 3.4.0

- Added `requestFocusNodeHref`, `requestImageRef`, `getMetaTags`, `getMetaThemeColor`, `getScrollX`, `getScrollY`, `getCertificate` webview methods
- Added `WebStorage`, `LocalStorage` and `SessionStorage` class to manage `window.localStorage` and `window.sessionStorage` JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API)
- Added `supportZoom` webview option also on iOS
- Added `HttpOnly`, `SameSite` cookie options
- Updated `Cookie` class
- Added `animated` option to `scrollTo` and `scrollBy` webview methods
- Added error and message to the `ServerTrustChallenge` class for iOS (class used by the `onReceivedServerTrustAuthRequest` event)
- Added `contentInsetAdjustmentBehavior` webview iOS-specific option
- Added `copy` methods for webview options class
- Added `SslCertificate` class and `X509Certificate` class and parser
- Added `values` property for all the custom Enums
- Updated Android workaround to hide the Keyboard when the user click outside on something not focusable such as input or a textarea.
- Fixed `zoomBy`, `setOptions` webview methods on Android
- Fixed `databaseEnabled` android webview option default value to `true`
- Fixed `verticalScrollBarEnabled` and `horizontalScrollBarEnabled` on Android
- Fixed error caused by `pauseTimers` on iOS when the WebView has been disposed
- Fixed `ignoresViewportScaleLimits`, `dataDetectorTypes`, `suppressesIncrementalRendering`, `selectionGranularity` iOS-specific option when used in `initialOptions`
- Fixed `getFavicons` method
- Fixed `HttpAuthCredentialDatabase.removeHttpAuthCredential` on Android
- Fixed some cases where `takeScreenshot` was not working on Android
- Fixed `After upgrade to Android embedding V2, still get Shared.activity is null / NullPointerException on android.content.Context.getResources()` [#390](https://github.com/pichillilorenzo/flutter_inappwebview/issues/390)

### BREAKING CHANGES

- `evaluateJavascript` webview method now returns `null` on iOS if the evaluated JavaScript source returns `null`
- `getHtml` webview method now could return `null` if it was unable to get it.
- Moved `supportZoom` webview option to cross-platform
- `builtInZoomControls` android webview options changed default value to `true`
- Updated `ServerTrustChallenge` class used by the `onReceivedServerTrustAuthRequest` event
- The method `getOptions` could return null now
- Updated `HttpAuthCredentialDatabase.getAllAuthCredentials` method return type

## 3.3.0+3

- Updated Android build.gradle version and some androidx properties
- Fixed `Multiple sessions` [#371](https://github.com/pichillilorenzo/flutter_inappwebview/issues/371)
- Fixed `incognito mode is broken swift` [#320](https://github.com/pichillilorenzo/flutter_inappwebview/issues/320)

## 3.3.0

- Updated API docs
- Updated Android context menu workaround
- Calling `onCreateContextMenu` event on iOS also when the context menu is disabled in order to have the same effect as Android
- Added `options` attribute to `ContextMenu` class and created `ContextMenuOptions` class
- Added Android keyboard workaround to hide the keyboard when clicking other HTML elements, losing the focus on the previous input
- Added `onEnterFullscreen`, `onExitFullscreen` webview events [#275](https://github.com/pichillilorenzo/flutter_inappwebview/issues/275)
- Added Android support to use camera on HTML inputs that requires it, such as `<input type="file" accept="image/*" capture>` [#353](https://github.com/pichillilorenzo/flutter_inappwebview/issues/353)
- Added `overScrollMode`, `networkAvailable`, `scrollBarStyle`, `verticalScrollbarPosition`, `scrollBarDefaultDelayBeforeFade`, `scrollbarFadingEnabled`, `scrollBarFadeDuration`, `rendererPriorityPolicy`, `useShouldInterceptRequest`, `useOnRenderProcessGone` webview options on Android
- Added `pageDown`, `pageUp`, `saveWebArchive`, `zoomIn`, `zoomOut`, `clearHistory` webview methods on Android
- Added `getCurrentWebViewPackage` static webview method on Android
- Added `setContextMenu`, `clearFocus` methods to webview controller
- Added `onPageCommitVisible` webview event
- Added `androidShouldInterceptRequest`, `androidOnRenderProcessUnresponsive`, `androidOnRenderProcessResponsive`, `androidOnRenderProcessGone`, `androidOnFormResubmission`, `androidOnScaleChanged` Android events
- Added `toString()` method to various classes in order to have a better output instead of simply `Instance of ...`
- Fixed `Print preview is not working? java.lang.IllegalStateException: Can print only from an activity` [#128](https://github.com/pichillilorenzo/flutter_inappwebview/issues/128)
- Fixed `onJsAlert`, `onJsConfirm`, `onJsPrompt` for `InAppBrowser` on Android
- Fixed `onActivityResult` for `InAppBrowser` on Android
- Fixed `InAppBrowser.openWithSystemBrowser crash on iOS` [#358](https://github.com/pichillilorenzo/flutter_inappwebview/issues/358)
- Fixed `Attempt to invoke virtual method 'java.util.Set java.util.HashMap.entrySet()' on a null object reference` [#367](https://github.com/pichillilorenzo/flutter_inappwebview/issues/367)
- Fixed missing `allowsAirPlayForMediaPlayback` iOS webview options implementation

### BREAKING CHANGES

- Android `clearClientCertPreferences`, `getSafeBrowsingPrivacyPolicyUrl`, `setSafeBrowsingWhitelist` webview methods are static now
- Removed iOS event `onDidCommit`; it has been renamed to `onPageCommitVisible` and made cross-platform
- `contextMenu` webview attribute is `final` now

## 3.2.0

- Added `ContextMenu` and `ContextMenuItem` classes [#235](https://github.com/pichillilorenzo/flutter_inappwebview/issues/235)
- Added `onCreateContextMenu`, `onHideContextMenu`, `onContextMenuActionItemClicked` context menu events
- Added `contextMenu` to WebView
- Added `disableContextMenu` WebView option
- Added `getSelectedText`, `getHitTestResult` methods to WebView Controller
- Fixed `Confirmation dialog (onbeforeunload) displayed after popped from webview page` [#337](https://github.com/pichillilorenzo/flutter_inappwebview/issues/337)
- Fixed `CookieManager.setCookie` `expiresDate` option
- Fixed `Scrolling not smooth on iOS` [#341](https://github.com/pichillilorenzo/flutter_inappwebview/issues/341)

### BREAKING CHANGES

- Renamed `LongPressHitTestResult` to `InAppWebViewHitTestResult`.
- Renamed `LongPressHitTestResultType` to `InAppWebViewHitTestResultType`.

## 3.1.0

- Added `HeadlessInAppWebView` class to be able to use WebView in headless mode
- Added `close`, `addMenuItem`, `addMenuItems` methods to `ChromeSafariBrowser`
- Added `ChromeSafariBrowserMenuItem` class in order to create custom menu item for `ChromeSafariBrowser`
- Fixed `InAppWebView.channel` null when used by `InAppBrowserActivity` on android
- Fixed iOS presentationStyle affecting only dismiss animation [#305](https://github.com/pichillilorenzo/flutter_inappwebview/issues/305)

### BREAKING CHANGES

- Renamed `InAppWebViewWidgetOptions` to `InAppWebViewGroupOptions`.

## 3.0.0

- Added `Promise` javascript [polyfill](https://github.com/tildeio/rsvp.js) for webviews that doesn't support it for `window.flutter_inappwebview.callHandler`
- Added `getDefaultUserAgent` static method to `InAppWebViewController`
- Added `onUpdateVisitedHistory`, `onPrint`, `onLongPressHitTestResult` event
- Added `androidOnGeolocationPermissionsHidePrompt` event for Android webview
- Added `iosOnWebContentProcessDidTerminate`, `iosOnDidCommit`, `iosOnDidReceiveServerRedirectForProvisionalNavigation` events for iOS webview
- Added `supportMultipleWindows` webview option for Android
- Added `regexToCancelSubFramesLoading` webview option for Android to cancel subframe requests on `shouldOverrideUrlLoading` event based on a Regular Expression
- Added `getContentHeight`, `zoomBy`, `printCurrentPage`, `getScale` methods
- Added `getOriginalUrl` webview method for Android
- Added `reloadFromOrigin`, `hasOnlySecureContent` webview methods for iOS
- Added `automaticallyAdjustsScrollIndicatorInsets`, `accessibilityIgnoresInvertColors`, `decelerationRate`, `alwaysBounceVertical`, `alwaysBounceHorizontal`, `scrollsToTop`, `isPagingEnabled`, `maximumZoomScale`, `minimumZoomScale` webview options for iOS
- Added `WebStorageManager` class which manages the web storage used by WebView instances
- Added `packageName` [#229](https://github.com/pichillilorenzo/flutter_inappwebview/issues/229) and `keepAliveEnabled` ChromeCustomTab options for Android
- Updated for Flutter 1.12 new Java Embedding API (Android)
- Updated `clearCache` for Android
- Updated default value for `domStorageEnabled` and `databaseEnabled` options to `true` for Android
- Merge "Fixes null error when calling getOptions for InAppBrowser class" [#214](https://github.com/pichillilorenzo/flutter_inappwebview/pull/214) (thanks to [panndoraBoo](https://github.com/panndoraBoo))
- Merge "Fixes crash onConsoleMessage iOS forced unwrapping" [#228](https://github.com/pichillilorenzo/flutter_inappwebview/pull/228) (thanks to [tokonu](https://github.com/tokonu))
- Merge "Fix HTTPCookie.secure" [#311](https://github.com/pichillilorenzo/flutter_inappwebview/pull/311) (thanks to [xtyxtyx](https://github.com/xtyxtyx))
- Merge "Fix config options for Android release builds" [#295](https://github.com/pichillilorenzo/flutter_inappwebview/pull/295) (thanks to [wwwdata](https://github.com/wwwdata))
- Merge "fix scrollbar on iOS always show if not disable scroll" [#256](https://github.com/pichillilorenzo/flutter_inappwebview/pull/256) (thanks to [phamnhuvu-dev](https://github.com/phamnhuvu-dev))
- Merge "Fix crash on nil/invalid URL (iOS)" [#262](https://github.com/pichillilorenzo/flutter_inappwebview/pull/262) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Merge "Fix crash when `prompt` was called on Android Q." [#262](https://github.com/pichillilorenzo/flutter_inappwebview/pull/263) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Fix for Android and iOS `InAppBrowser` for some controller methods not exposed.
- Fixed "App Crashes after clicking on dropdown (Using inappwebview)" [#182](https://github.com/pichillilorenzo/flutter_inappwebview/issues/182)
- Fixed "webview can not be released when in ios" [#225](https://github.com/pichillilorenzo/flutter_inappwebview/issues/225). Now the iOS WebView is released from memory when it is disposed from Flutter.
- Fixed "Setting of presentationStyle not working on iOS" [#213](https://github.com/pichillilorenzo/flutter_inappwebview/issues/213)
- Fixed "Android zoom issues" [#270](https://github.com/pichillilorenzo/flutter_inappwebview/issues/270)

### BREAKING CHANGES

- Updated `shouldOverrideUrlLoading` event: 
  - the `url` parameter has been moved inside an instance of `ShouldOverrideUrlLoadingRequest` class
  - it has a return type `ShouldOverrideUrlLoadingAction` to allow or cancel navigation instead of cancel every time the request
- Renamed `onTargetBlank` to `onCreateWindow`
- Deleted `useOnTargetBlank` webview option
- Making methods available only for the specific platform more explicit: moved all the webview's controller methods for Android inside `controller.android` and all the webview's controller methods for iOS inside `controller.ios`
- Making events available only for the specific platform more explicit:
  - Renamed `onSafeBrowsingHit` to `androidOnSafeBrowsingHit`
  - Renamed `onGeolocationPermissionsShowPrompt` to `androidOnGeolocationPermissionsShowPrompt` 
  - Renamed `onPermissionRequest` to `androidOnPermissionRequest`  
- Updated attribute names for `InAppWebViewWidgetOptions`, `InAppBrowserClassOptions` and `ChromeSafariBrowserClassOptions` classes
- Renamed and updated `onNavigationStateChange` to `onUpdateVisitedHistory`
- Renamed all iOS and Android webview options class
- Renamed Chrome Custom Tab `addShareButton` option to `addDefaultShareMenuItem`
- Renamed ChromeSafariBrowser `onLoaded` to `onCompletedInitialLoad`

## 2.1.0+1

- Fix docs

## 2.1.0

- Added `pause` and `resume` methods for Android.
- Added `pauseTimers` and `resumeTimers` methods.
- Added new `historyUrl` optional parameter for `loadData` and `openData` methods and `InAppWebViewInitialData` class. It is used only on Android.
- Fix "problems with onReceivedHttpAuthRequest when initialData is used" [#201](https://github.com/pichillilorenzo/flutter_inappwebview/issues/201)
- Fix "System ui (status bar and navigation bar) doesn't hide automatically" [#202](https://github.com/pichillilorenzo/flutter_inappwebview/issues/202)

## 2.0.1+1

- Fixed error "java.lang.ClassCastException: $Proxy1 cannot be cast to android.view.WindowManagerImpl" on Android when using native alert dialogs

## 2.0.1

- Added `onPermissionRequest` event. This event is fired when the webview is requesting permission to access the specified resources and the permission currently isn't granted or denied (available only on Android).

## 2.0.0

- Merge "Avoid null pointer exception after webview is disposed" [#116](https://github.com/pichillilorenzo/flutter_inappwebview/pull/116) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merge "Remove async call in close" [#119](https://github.com/pichillilorenzo/flutter_inappwebview/pull/119) (thanks to [benfingo](https://github.com/benfingo))
- Merge "Android takeScreenshot does not work properly." [#122](https://github.com/pichillilorenzo/flutter_inappwebview/pull/122) (thanks to [PauloMelo](https://github.com/PauloMelo))
- Merge "Resolving gradle error." [#144](https://github.com/pichillilorenzo/flutter_inappwebview/pull/144) (thanks to [Klingens13](https://github.com/Klingens13))
- Merge "Create issue and pull request templates" [#150](https://github.com/pichillilorenzo/flutter_inappwebview/pull/150) (thanks to [deandreamatias](https://github.com/deandreamatias))
- Merge "Fix abstract method error && swift version error" [#155](https://github.com/pichillilorenzo/flutter_inappwebview/pull/155) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Merge "migrating to swift 5.0" [#162](https://github.com/pichillilorenzo/flutter_inappwebview/pull/162) (thanks to [fattiger00](https://github.com/fattiger00))
- Merge "Update readme example" [#178](https://github.com/pichillilorenzo/flutter_inappwebview/pull/178) (thanks to [SebastienBtr](https://github.com/SebastienBtr))
- Merge "handle choose file callback in android" [#183](https://github.com/pichillilorenzo/flutter_inappwebview/pull/183) (thanks to [crazecoder](https://github.com/crazecoder))
- Merge "add initialScale in android" [#186](https://github.com/pichillilorenzo/flutter_inappwebview/pull/186) (thanks to [crazecoder](https://github.com/crazecoder))
- Added `horizontalScrollBarEnabled` and `verticalScrollBarEnabled` options to enable/disable the corresponding scrollbar of the WebView [#165](https://github.com/pichillilorenzo/flutter_inappwebview/issues/165)
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

- Merge "added a shared WKProcessPool for webview instances" [#198](https://github.com/pichillilorenzo/flutter_inappwebview/pull/198) (thanks to [robertcnst](https://github.com/robertcnst))
- Fixed iOS setCookie.

## 1.2.1

- Merge "Add new option to control the contentMode in Android platform" [#101](https://github.com/pichillilorenzo/flutter_inappwebview/pull/101) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Merge "Fix crash on xcode 10.2" [#107](https://github.com/pichillilorenzo/flutter_inappwebview/pull/107) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merge "Remove headers_build_phase from example's Podfile" [#108](https://github.com/pichillilorenzo/flutter_inappwebview/pull/108) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Fixed "Make html5 video fullscreen" for Android [#43](https://github.com/pichillilorenzo/flutter_inappwebview/issues/43)
- Fixed "AllowsInlineMediaPlayback not working" for iOS [#73](https://github.com/pichillilorenzo/flutter_inappwebview/issues/73)

## 1.2.0

- Merge "Adds a transparentBackground option for iOS and Android" [#86](https://github.com/pichillilorenzo/flutter_inappwebview/pull/86) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merge "The 'open' method requires an options dictionary" [#87](https://github.com/pichillilorenzo/flutter_inappwebview/pull/87) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merge "iOS: Call setNeedsLayout() in scrollViewDidScroll()" [#88](https://github.com/pichillilorenzo/flutter_inappwebview/pull/88) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Fixed "java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread." [#98](https://github.com/pichillilorenzo/flutter_inappwebview/issues/98) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Fixed "app force close/crash when enabling zoom and repeatedly changing orientation and zoomin zoomout" [#93](https://github.com/pichillilorenzo/flutter_inappwebview/issues/93)
- Added `displayZoomControls` webview option for Android
- Fixed "Compatibility with other plugins" [#80](https://github.com/pichillilorenzo/flutter_inappwebview/issues/80)

## 1.1.3

- Merge "Add null checks around calls to InAppWebView callbacks" [#85](https://github.com/pichillilorenzo/flutter_inappwebview/pull/85) (thanks to [matthewlloyd](https://github.com/matthewlloyd))

## 1.1.2

- Fix InAppBrowser crashes the app when i change the page "Lost connection" [#74](https://github.com/pichillilorenzo/flutter_inappwebview/issues/74)
- Fix javascript `...args` parameter of `window.flutter_inappwebview.callHandler()`
- Merge Enable setTextZoom function of Android WebViewSetting [#81](https://github.com/pichillilorenzo/flutter_inappwebview/pull/81) (thanks to [YouCii](https://github.com/YouCii))
- Merge bug fix for android build: Android dependency 'androidx.core:core' has different version for the compile (1.0.0) and runtime (1.0.1) classpath [#83](https://github.com/pichillilorenzo/flutter_inappwebview/pull/83) (thanks to [cinos1](https://github.com/cinos1))

## 1.1.1

- Fixed README.md and `addJavaScriptHandler` method documentation

## 1.1.0

- Breaking change for `addJavaScriptHandler` and `removeJavaScriptHandler` methods.
- `addJavaScriptHandler` method can return data to JavaScript using `Promise` [#46](https://github.com/pichillilorenzo/flutter_inappwebview/issues/46)
- added `flutterInAppBrowserPlatformReady` JavaScript event to wait until the platform is ready [#64](https://github.com/pichillilorenzo/flutter_inappwebview/issues/64)

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
