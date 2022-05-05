## 5.4.3+7

- Fixed possible Android java.lang.NullPointerException in "InAppBrowserActivity.onCreateOptionsMenu" about "webView.getTitle()"

## 5.4.3+6

- Fixed "iOS flutter_inappwebview/URLRequest.swift:13: Fatal error: Unexpectedly found nil while unwrapping an Optional value" [#1173](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1173)

## 5.4.3+5

- Fixed possible java.lang.NullPointerException in `Runnable` of `InputAwareWebView.setInputConnectionTarget` method
- Fixed "Android Crash in latest 5.4.3+4 - java.lang.NullPointerException: Attempt to invoke virtual method java.lang.String android.webkit.WebView.getUrl()" [#1168](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1168)

## 5.4.3+4

- Updated docs for `ChromeSafariBrowser.open` and throw error on iOS if the `url` parameter use a different scheme then `http` or `https`

## 5.4.3+3

- Fixed "Android error: package org.jetbrains.annotations does not exist import org.jetbrains.annotations.NotNull;" [#1166](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1166)

## 5.4.3+2

- Fixed "Latest version 5.4.3 crashes on Android" [#1159](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1159)

## 5.4.3+1

- Try to fix "Latest version 5.4.3 crashes on Android" [#1159](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1159)

## 5.4.3

- Added Bitwise OR operator support for `AndroidActionModeMenuItem` class

## 5.4.2+1

- Try to fix "Latest version 5.4.2 crashes on Android - HeadlessInAppWebView.dispose" [#1155](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1155)

## 5.4.2

- Added `setActionButton` method to `ChromeSafariBrowser` class

## 5.4.1+2

- Fixed "Android ServiceWorkerControllerCompat.setServiceWorkerClient(null) makes Webivew Plugin Crashes" [#1151](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1151)

## 5.4.1+1

- Fixed Android default context menu over custom context menu on API Level 31+ 

## 5.4.1

- Managed iOS native `detachFromEngine` flutter plugin event and updated `dispose` methods
- Updated Android native `HeadlessInAppWebViewManager.dispose` and `HeadlessInAppWebView.dispose` methods

## 5.4.0+3

- Fixed Android error in some cases when calling `setServiceWorkerClient` java method on `ServiceWorkerManager` initialization

## 5.4.0+2

- Fixed Android `ChromeCustomTabsActivity` not responding to the `ActionBroadcastReceiver`

## 5.4.0+1

- Merged "[Android] Explicitly export for the receiver defined in AndroidManifest" [#1147](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1147) (thanks to [AlexV525](https://github.com/AlexV525))

## 5.4.0

- `getOriginalUrl` method is cross-platform now
- Updated Android `compileSdkVersion` to 31
- Updated Flutter environment: sdk to `>=2.14.0 <3.0.0` and flutter version to `>=2.5.0`
- Added `singleInstance` option for Android `ChromeSafariBrowser` implementation
- Added `onDownloadStartRequest` event and deprecated old `onDownloadStart` event
- Added `shareState` Android option for `ChromeSafariBrowser` class
- Added support for Android TWA (Trusted Web Activity)
- Fixed missing `onZoomScaleChanged` call for `InAppBrowser` class
- Fixed `requestImageRef` method always `null` on iOS
- Fixed "applicationNameForUserAgent is not work in ios" [#525](https://github.com/pichillilorenzo/flutter_inappwebview/issues/525)
- Fixed "Crash when try select file from webview input on Android" [#867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/867)
- Fixed "NavigationAction.request should use toMap method" [#878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/878)
- Fixed "Missing body field in URLRequest toMap method" [#990](https://github.com/pichillilorenzo/flutter_inappwebview/issues/990)
- Fixed "iOS : createWindowAction.request.body in onCreateWindow() is NULL" [#994](https://github.com/pichillilorenzo/flutter_inappwebview/issues/994)
- Fixed "Crash at HeadlessInAppWebView dispose" [#881](https://github.com/pichillilorenzo/flutter_inappwebview/issues/881)
- Fixed "Crash happens when HeadlessInAppWebView's dispose function is called in iOS" [#972](https://github.com/pichillilorenzo/flutter_inappwebview/issues/972)
- Fixed "In android, when click a href with img returns img src on onCreateWindow" [#951](https://github.com/pichillilorenzo/flutter_inappwebview/issues/951)
- Fixed "crash at com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView$11.run (InAppWebView.java:1307)" [#1040](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1040)
- Fixed "Unexpected behavior when using a null initialUrlRequest" [#1063](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1063)
- Fixed "Local storage & cookie didn't persist when sharedCookie and cache both enabled" [#1092](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1092)
- Fixed "ios zoomBy crash: Foundation/NSNumber.swift:467: Fatal error: Unable to bridge NSNumber to Float" [#873](https://github.com/pichillilorenzo/flutter_inappwebview/issues/873)
- Fixed "In App Browser Crashing in Android - Action Bar is null" [#1137](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1137)
- Fixed "Cannot load Javascript on some Android devices - Uncaught TypeError: Cannot read property 'appendChild' of null" [#888](https://github.com/pichillilorenzo/flutter_inappwebview/issues/888)
- Merged "Update Options.swift" [#889](https://github.com/pichillilorenzo/flutter_inappwebview/pull/889) (thanks to [cloudygeek](https://github.com/cloudygeek))
- Merged "fix: Applicatio nNameForUserAgent is not working in iOS" [#1095](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1095) (thanks to [sunalwaysknows](https://github.com/sunalwaysknows))
- Merged "Make sure we open a new instance of a custom chrome chrome tab" [#812](https://github.com/pichillilorenzo/flutter_inappwebview/pull/812) (thanks to [savy-91](https://github.com/savy-91))
- Merged "fix bug when in String[] array come null" [#868](https://github.com/pichillilorenzo/flutter_inappwebview/pull/868) (thanks to [Ser1ous](https://github.com/Ser1ous))
- Merged "fix: use in NavigationAction request toMap method" [#879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/879) (thanks to [chreck](https://github.com/chreck))
- Merged "switch android mockserver dependency with okhttp" [#946](https://github.com/pichillilorenzo/flutter_inappwebview/pull/946) (thanks to [randysecrist](https://github.com/randysecrist))
- Merged "Adds missing body to URLRequest mapping." [#991](https://github.com/pichillilorenzo/flutter_inappwebview/pull/991) (thanks to [Miiha](https://github.com/Miiha))
- Merged "fix. Crash happens when HeadlessInAppWebView's dispose function is called in iOS" [#1017](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1017) (thanks to [hoanglm4](https://github.com/hoanglm4))
- Merged "Fixes URL returned when taping image with href in onCreateWindow [Android]" [#1042](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1042) (thanks to [Manuito83](https://github.com/Manuito83))
- Merged "Fix Android Sometimes crash after close webpage and return to platform code." [#1050](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1050) (thanks to [rsydor](https://github.com/rsydor))
- Merged "Add application/wasm MimeType with InAppLocalhostServer" [#1054](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1054) (thanks to [foxstream528](https://github.com/foxstream528))
- Merged "Fixed the unexpected behavior of InAppWebView and HeadlessInAppWebView when initialUrlRequest was set as null." [#1064](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1064) (thanks to [RodXander](https://github.com/RodXander))
- Merged "updated com.android.tools.build:gradle" [#1066](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1066) (thanks to [chownation](https://github.com/chownation))
- Merged "WIP - expose content-disposition and content-length from android" [#1088](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1088) (thanks to [ashank96](https://github.com/ashank96))
- Merged "Fix ios persistance when using sharedCookie" [#1093](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1093) (thanks to [EA-YOUHOU](https://github.com/EA-YOUHOU))
- Merged "Fixes zoomBy with floats (iOS)" [#1109](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1109) (thanks to [Manuito83](https://github.com/Manuito83))
- Merged "Build on and support Android 12 SDK 31" [#1111](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1111) (thanks to [carloserazo47](https://github.com/carloserazo47))
- Merged "Fix takeScreenshot Crash on iOS" [#1123](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1123) (thanks to [a00012025](https://github.com/a00012025))
- Merged "Feature. Possibility to disable iOS above keyboard inputAccessoryView" [#1124](https://github.com/pichillilorenzo/flutter_inappwebview/pull/1124) (thanks to [cutzmf](https://github.com/cutzmf))

## 5.3.2

- Added `onLoad` and `onError` callbacks in `ScriptHtmlTagAttributes` class used by `InAppWebViewController.injectJavascriptFileFromUrl`
- `InAppWebViewController.injectJavascriptFileFromAsset` returns a `Future<dynamic>` type now

## 5.3.1+1

- Removed duplicate lib exports
- Fixed some rare cases when iOS WKWebView `scrollViewDidEndDragging` event blocks the scroll gesture

## 5.3.1

- Added support of `allowingReadAccessTo` iOS-specific WebView option for the WebView `initialData` parameter
- Added `iosAllowingReadAccessTo` iOS-specific parameter to the `loadData` WebView method
- Fixed "iOS webview showing blank page in specific URL" [#776](https://github.com/pichillilorenzo/flutter_inappwebview/issues/776)
- Fixed "unable to access ApplicationDocumentsDirectory in real Ios devices" [#748](https://github.com/pichillilorenzo/flutter_inappwebview/issues/748)

## 5.3.0+1

- Fixed "Android - Pull to refresh triggered when scrolling container inside a website" [#765](https://github.com/pichillilorenzo/flutter_inappwebview/issues/765)
- Fixed "InAppWebViewController.getHitTestResult" wrong type mapping

## 5.3.0

- Added `initialSize` property to the `HeadlessInAppWebView` class
- Added `setSize` and `getSize` methods to the `HeadlessInAppWebView` class
- `androidOnScaleChanged` WebView event is now deprecated. Use the new `onZoomScaleChanged` WebView event, that is available for both Android and iOS
- `getScale` WebView method is now deprecated. Use the new `getZoomScale` WebView method
- Removed `final` keyword for all `HeadlessInAppWebView` events
- Fixed wrong usage of Android WebView scale property
- Fixed "java.lang.NullPointerException: com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewRenderProcessClient$1.success(InAppWebViewRenderProcessClient.java:37)" [#757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/757)
- Fixed "In a multi-activity app, the plugin doesn't reattach to the first activity" [#732](https://github.com/pichillilorenzo/flutter_inappwebview/issues/732)
- Fixed "ChromeSafariBrowser isn't calling its events, and not keeping track of isOpen properly" [#759](https://github.com/pichillilorenzo/flutter_inappwebview/issues/759)
- Fixed Android ChromeSafariBrowser menu item callback not called because of PendingIntents extra were cached

## 5.2.1+1

- Fixed iOS "Unexpectedly found nil while unwrapping an Optional value: file flutter_inappwebview/WKUserContentController.swift, line 36" error when `applePayAPIEnabled` iOS-specific WebView option is enabled

## 5.2.1

- Added `isRunning` method to the `HeadlessInAppWebView` class
- Added `isRunning` method to the `InAppLocalhostServer` class
- Added `allowGoBackWithBackButton` and `shouldCloseOnBackButtonPressed` Android-specific InAppBrowser options
- Fixed iOS `WebMessageListener` javascript implementation not calling event listeners when `onmessage` is set
- Fixed `onCreateContextMenu` event on Android where `hitTestResult` has always `null` values
- Fixed "java.lang.NullPointerException: Attempt to invoke virtual method 'void android.widget.SearchView.setQuery(java.lang.CharSequence, boolean)' on a null object reference" [#742](https://github.com/pichillilorenzo/flutter_inappwebview/issues/742)
- Fixed Android js error in some very rare case where `window.flutter_inappwebview` is `undefined` when loading plugin scripts

## 5.2.0

- Added `WebMessageChannel` and `WebMessageListener` features
- Added `canScrollVertically` and `canScrollHorizontally` webview methods
- Added Android pull-to-refresh `setSize` method and `size` option
- Added `onOverScrolled` WebView event
- `AndroidInAppWebViewController.getCurrentWebViewPackage` is available now starting from Android API 21+
- Updated Android Gradle distributionUrl version to `5.6.4`
- Updated Android `androidx.webkit:webkit` to `1.4.0`, `androidx.browser:browser` to `1.3.0`, `androidx.appcompat:appcompat` to `1.2.0`
- Attempt to fix "InAppBrowserActivity.onCreate NullPointerException - Attempt to invoke virtual method 'java.lang.String android.os.Bundle.getString(java.lang.String)' on a null object reference" [#665](https://github.com/pichillilorenzo/flutter_inappwebview/issues/665)
- Fixed "[iOS] Application crashes when processing onCreateWindow" [#579](https://github.com/pichillilorenzo/flutter_inappwebview/issues/579)
- Fixed wrong mapping of `NavigationAction` class on Android for `androidHasGesture` and `androidIsRedirect` properties
- Fixed "Pull to refresh creating problem in some webpages on Android" [#719](https://github.com/pichillilorenzo/flutter_inappwebview/issues/719)
- Fixed iOS sometimes `scrollView.contentSize` doesn't fit all the `frame.size` available
- Fixed ajax and fetch interceptor when the data/body sent is not a string
- Fixed "InAppLocalhostServer - Error: type 'List<dynamic>' is not a subtype of type 'List<int>' in type cast" [#724](https://github.com/pichillilorenzo/flutter_inappwebview/issues/724)
- Merged "fix proguard" [#737](https://github.com/pichillilorenzo/flutter_inappwebview/pull/737) (thanks to [myroid](https://github.com/myroid))

### BREAKING CHANGES

- `FetchRequest.body` is a dynamic type now

## 5.1.0+4

- Fixed "IOS scrolling crash the application" [#707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/707)

## 5.1.0+3

- Fixed "Unsupported operation: Platform._operatingSystem" when compiling for Web again [#507](https://github.com/pichillilorenzo/flutter_inappwebview/issues/507)

## 5.1.0+2

- Fixed missing MATCH_PARENT layout params to the WebView on Android when it is wrapped by PullToRefreshLayout

## 5.1.0+1

- Added a test for the pull-to-refresh feature when used on Android. It requires the `useHybridComposition: true` Android-specific option, otherwise it will throw an exception.

## 5.1.0

- Added support for pull-to-refresh feature [#395](https://github.com/pichillilorenzo/flutter_inappwebview/issues/395)
- Fixed issue not rendering WebView content when scrolling on iOS [#703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/703)
- Fixed `InAppBrowser.openData` method
- `InAppBrowser.initialUserScripts`, `InAppBrowser.id`, `HeadlessInAppWebView.id` properties are `final` now

## 5.0.5+3

- Fixed Android `evaluateJavascript` method when using `contentWorld: ContentWorld.PAGE`

## 5.0.5+2

- Updated docs for iOS-specific options `alwaysBounceVertical` and `alwaysBounceHorizontal`

## 5.0.5+1

- Fixed "No bounce in inappwebview iOS" [#696](https://github.com/pichillilorenzo/flutter_inappwebview/issues/696)

## 5.0.5

- Updated Android `WebChromeClient.getDefaultVideoPoster`
- Removed all the dependencies: `uuid`, `device_info`, `intl`, and `mime`

## 5.0.4-nullsafety.1

- Added `headers` and `statusCode` properties to IOSURLResponse class

## 5.0.3-nullsafety.1

- Fixed Android screenshot out of memory error
- Fixed `getFavicons` WebView method

## 5.0.2-nullsafety.1

- Fixed missing `verticalScrollbarThumbColor`, `verticalScrollbarTrackColor`, `horizontalScrollbarThumbColor`, `horizontalScrollbarTrackColor` Android-specific WebView options when calling native java `setOptions()` method on Android

## 5.0.1-nullsafety.1

- Added `verticalScrollbarThumbColor`, `verticalScrollbarTrackColor`, `horizontalScrollbarThumbColor`, `horizontalScrollbarTrackColor` Android-specific WebView options
- Fixed some null types and wrong casting

## 5.0.0-nullsafety.0

- Added support for Dart null-safety feature
- Added Android Hybrid Composition support "Use PlatformViewLink widget for Android WebView" [#462](https://github.com/pichillilorenzo/flutter_inappwebview/pull/462) (thanks to [plateaukao](https://github.com/plateaukao) and [tneotia](https://github.com/tneotia))
- Added `allowUniversalAccessFromFileURLs` and `allowFileAccessFromFileURLs` WebView options also for iOS (also thanks to [liranhao](https://github.com/liranhao))
- Added limited cookies support on iOS below 11.0 using JavaScript
- Added `IOSCookieManager` class and `CookieManager.instance().ios.getAllCookies` iOS-specific method
- Added `UserScript`, `UserScriptInjectionTime`, `ContentWorld`, `AndroidWebViewFeature`, `AndroidServiceWorkerController`, `AndroidServiceWorkerClient`, `ScreenshotConfiguration`, `IOSWKPDFConfiguration`, `URLRequest` classes
- Added `initialUserScripts` WebView option
- Added `addUserScript`, `addUserScripts`, `removeUserScript`, `removeUserScripts`, `removeUserScriptsByGroupName`, `removeAllUserScripts`, `callAsyncJavaScript`, `isSecureContext` WebView methods
- Added `contentWorld` argument to `evaluateJavascript` WebView method
- Added `isDirectionalLockEnabled`, `mediaType`, `pageZoom`, `limitsNavigationsToAppBoundDomains`, `useOnNavigationResponse`, `applePayAPIEnabled`, `allowingReadAccessTo`, `disableLongPressContextMenuOnLinks` iOS-specific WebView options
- Added `handlesURLScheme`, `createPdf`, `createWebArchiveData` iOS-specific WebView methods
- Added `iosOnNavigationResponse` and `iosShouldAllowDeprecatedTLS` iOS-specific WebView events
- Added `iosAnimated` optional argument to `zoomBy` WebView method
- Added `screenshotConfiguration` optional argument to `takeScreenshot` WebView method
- Added `scriptHtmlTagAttributes` optional argument to `injectJavascriptFileFromUrl` WebView method
- Added `cssLinkHtmlTagAttributes` optional argument to `injectCSSFileFromUrl` WebView method
- Added `iosAllowingReadAccessTo` iOS-specific optional argument to `loadUrl` WebView method
- Added new iOS-specific attributes to `ShouldOverrideUrlLoadingRequest` and `CreateWindowRequest` classes
- Added `toolbarTopTranslucent`, `toolbarTopTintColor`, `toolbarBottomTintColor`, `toolbarTopBarTintColor` ios-specific InAppBrowser options
- Updated integration tests
- Merged "Upgraded appcompat to 1.2.0-rc-02" [#465](https://github.com/pichillilorenzo/flutter_inappwebview/pull/465) (thanks to [andreidiaconu](https://github.com/andreidiaconu))
- Merged "Added missing field 'headers' which returned by WebResourceResponse.toMap()" [#490](https://github.com/pichillilorenzo/flutter_inappwebview/pull/490) (thanks to [Doflatango](https://github.com/Doflatango))
- Merged "Fix: added iOS fallback module import" [#466](https://github.com/pichillilorenzo/flutter_inappwebview/pull/466) (thanks to [Eddayy](https://github.com/Eddayy))
- Merged "Fix NullPointerException after taking a photo by a camera app on Android" [#492](https://github.com/pichillilorenzo/flutter_inappwebview/pull/492) (thanks to [AAkira](https://github.com/AAkira))
- Merged "iOS CookieManager.getCookies - Check that URL has suffix of cookie do…" [#658](https://github.com/pichillilorenzo/flutter_inappwebview/pull/658) (thanks to [arneke](https://github.com/arneke))
- Merged "Add NTLM Auth" [#634](https://github.com/pichillilorenzo/flutter_inappwebview/pull/634) (thanks to [albatrosify](https://github.com/albatrosify))
- Merged "iOS ChromeSafariBrowserManager - Fixing unnecessary casting of rootViewController to FlutterViewController" [#567](https://github.com/pichillilorenzo/flutter_inappwebview/pull/567) (thanks to [gunantosteven](https://github.com/gunantosteven))
- Merged "Fix _channel.invokeMethod name for injectCSSFileFromUrl method" [#645](https://github.com/pichillilorenzo/flutter_inappwebview/pull/645) (thanks to [omralcrt](https://github.com/omralcrt))
- Merged "Add android media intents on wildcard input accept" [#620](https://github.com/pichillilorenzo/flutter_inappwebview/pull/620) (thanks to [cbodin](https://github.com/cbodin))
- Merged "Add ChromeSafariBrowser support for Android 11" [#538](https://github.com/pichillilorenzo/flutter_inappwebview/pull/538) (thanks to [DRSchlaubi](https://github.com/DRSchlaubi))
- Merged "fix(iOS): missing implementation of method zoomBy" [#670](https://github.com/pichillilorenzo/flutter_inappwebview/pull/670) (thanks to [pcqpcq](https://github.com/pcqpcq))
- Merged "[mod] Fix all issues relate to long click in Android version 7.0 (#657, #527)" [#671](https://github.com/pichillilorenzo/flutter_inappwebview/pull/671) (thanks to [MrNinja](https://github.com/MrNinja))
- Merged "Fix ViewGroup.removeView NullPointerException (#450)" [#683](https://github.com/pichillilorenzo/flutter_inappwebview/pull/683) (thanks to [toda-bps](https://github.com/toda-bps))
- Fixed missing properties initialization when using InAppWebViewController.fromInAppBrowser
- Fixed "Issue in Flutter web: 'Unsupported operation: Platform._operatingSystem'" [#507](https://github.com/pichillilorenzo/flutter_inappwebview/issues/507)
- Fixed "window.flutter_inappwebview.callHandler is not a function" [#218](https://github.com/pichillilorenzo/flutter_inappwebview/issues/218)
- Fixed "Android ContentBlocker - java.lang.NullPointerException ContentBlockerTrigger resource type" [#506](https://github.com/pichillilorenzo/flutter_inappwebview/issues/506)
- Fixed "Android CookieManager throws error caused by websites that are sending back illegal/invalid cookies." [#476](https://github.com/pichillilorenzo/flutter_inappwebview/issues/476)
- Fixed missing `clearHistory` webview method implementation on Android
- Fixed iOS crash when using CookieManager getCookies for an URL and the host URL is `null`
- Fixed "IOS does not support allowUniversalAccessFromFileURLs" [#654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/654)
- Fixed "Failed to load WebView provider: No WebView installed" [#642](https://github.com/pichillilorenzo/flutter_inappwebview/issues/642)
- Fixed "java.net.MalformedURLException: unknown protocol: wss - Error using library sipml5 in flutter_inappwebview" [#614](https://github.com/pichillilorenzo/flutter_inappwebview/issues/614)
- Fixed "Android 10 clipboard not working properly" [#678](https://github.com/pichillilorenzo/flutter_inappwebview/issues/678) (thanks to [armadastate](https://github.com/armadastate))

### BREAKING CHANGES

- Minimum Flutter version required is `1.22.2` and Dart SDK `>=2.12.0-0 <3.0.0`
- iOS Xcode version `>= 12`
- `allowUniversalAccessFromFileURLs` and `allowFileAccessFromFileURLs` WebView options moved from Android-specific options to cross-platform options
- Added `callAsyncJavaScript` name to the list of javaScriptHandlerForbiddenNames
- Moved `saveWebArchive` WebView method from Android-specific to cross-platform
- Moved `progressBar` InAppBroswer from Android-specific option to cross-platform option and renamed to `hideProgressBar`
- Renamed `HttpAuthChallenge` to `URLAuthenticationChallenge`
- Updated `basicConstraints`, `subjectKeyIdentifier`, `authorityKeyIdentifier`, `certificatePolicies`, `cRLDistributionPoints`, `authorityInfoAccess` attributes type of `X509Certificate`
- Updated "WebView.storyboard" for InAppBrowser iOS representation
- Renamed `ShouldOverrideUrlLoadingAction` class to `NavigationActionPolicy`
- Renamed `ProtectionSpace` class to `URLProtectionSpace`
- Renamed `ProtectionSpaceHttpAuthCredentials` to `URLProtectionSpaceHttpAuthCredentials`
- Renamed `CreateWindowRequest` class to `CreateWindowAction`
- Renamed `initialUrl` to `initialUrlRequest` WebView attribute and made it of type `URLRequest`
- Renamed `toolbarTop` InAppBrowser cross-platform option to `hideToolbarTop`
- Renamed `toolbarBottom` InAppBrowser ios-specific option to `hideToolbarBottom`
- Removed `debuggingEnabled` WebView option; on Android you should use now the `AndroidInAppWebViewController.setWebContentsDebuggingEnabled(bool debuggingEnabled)` static method; on iOS, debugging is always enabled
- Removed `androidOnRequestFocus` event because it is never called
- Removed `initialHeaders` WebView attribute. Use `URLRequest.headers` attribute
- Removed `headers` argument from `loadFile` WebView method
- Removed `headers` argument from `openFile` InAppBrowser method
- Removed `headers` argument from `loadUrl` WebView method, renamed the `url` argument to `urlRequest` and made it of type `URLRequest`
- Removed `headers` argument from `openFile` InAppBrowser method
- Removed `headers` argument from `openUrl` InAppBrowser method, renamed the `url` argument to `urlRequest` and made it of type `URLRequest`
- Removed `fallback` argument from `ChromeSafariBrowser` constructor. Check for availability of `ChromeSafariBrowser` if you want show one or the other.
- Removed `scheme` argument from `onLoadResourceCustomScheme` WebView event. Use the `Uri url` parameter now.
- Removed `ShouldOverrideUrlLoadingRequest` class and replaced with `NavigationAction`
- Changed `zoomBy` WebView method signature
- Changed type of `urlFile` argument of `injectCSSFileFromUrl` WebView method to `Uri`
- Changed type of `urlFile` argument of `injectJavascriptFileFromUrl` WebView method to `Uri`
- Changed return type of `getOriginalUrl` Android-specific WebView method to `Uri`
- Changed return type of `getSafeBrowsingPrivacyPolicyUrl` Android-specific WebView method to `Uri`
- Changed type of `url` argument of `onLoadStart`, `onLoadStop`, `onLoadError`, `onLoadHttpError`, `onLoadResourceCustomScheme`, `onUpdateVisitedHistory`, `onPrint`, `onPageCommitVisible`, `androidOnSafeBrowsingHit`, `androidOnRenderProcessUnresponsive`, `androidOnRenderProcessResponsive`, `androidOnFormResubmission`, `androidOnReceivedTouchIconUrl` WebView events to `Uri`
- Changed type of `baseUrl` and `androidHistoryUrl` arguments of `loadData` WebView method and `openData` InAppBrowser method
- Changed `openUrl` InAppBrowser method to `openUrlRequest`
- Changed type of `url` argument of `openWithSystemBrowser` InAppBrowser method to `Uri`
- Changed all InAppBrowser color options type from `String` to `Color`
- Changed all ChromeSafariBrowser color options type from `String` to `Color`
- Updated attributes of `ShouldOverrideUrlLoadingRequest`, `ServerTrustChallenge` and `ClientCertChallenge` classes
- Changed type of `url` attribute to `Uri` for `JsAlertRequest`, `JsAlertConfirm`, `JsPromptRequest` classes

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
- Merged "Fixes null error when calling getOptions for InAppBrowser class" [#214](https://github.com/pichillilorenzo/flutter_inappwebview/pull/214) (thanks to [panndoraBoo](https://github.com/panndoraBoo))
- Merged "Fixes crash onConsoleMessage iOS forced unwrapping" [#228](https://github.com/pichillilorenzo/flutter_inappwebview/pull/228) (thanks to [tokonu](https://github.com/tokonu))
- Merged "Fix HTTPCookie.secure" [#311](https://github.com/pichillilorenzo/flutter_inappwebview/pull/311) (thanks to [xtyxtyx](https://github.com/xtyxtyx))
- Merged "Fix config options for Android release builds" [#295](https://github.com/pichillilorenzo/flutter_inappwebview/pull/295) (thanks to [wwwdata](https://github.com/wwwdata))
- Merged "fix scrollbar on iOS always show if not disable scroll" [#256](https://github.com/pichillilorenzo/flutter_inappwebview/pull/256) (thanks to [phamnhuvu-dev](https://github.com/phamnhuvu-dev))
- Merged "Fix crash on nil/invalid URL (iOS)" [#262](https://github.com/pichillilorenzo/flutter_inappwebview/pull/262) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Merged "Fix crash when `prompt` was called on Android Q." [#262](https://github.com/pichillilorenzo/flutter_inappwebview/pull/263) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
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

- Merged "Avoid null pointer exception after webview is disposed" [#116](https://github.com/pichillilorenzo/flutter_inappwebview/pull/116) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merged "Remove async call in close" [#119](https://github.com/pichillilorenzo/flutter_inappwebview/pull/119) (thanks to [benfingo](https://github.com/benfingo))
- Merged "Android takeScreenshot does not work properly." [#122](https://github.com/pichillilorenzo/flutter_inappwebview/pull/122) (thanks to [PauloMelo](https://github.com/PauloMelo))
- Merged "Resolving gradle error." [#144](https://github.com/pichillilorenzo/flutter_inappwebview/pull/144) (thanks to [Klingens13](https://github.com/Klingens13))
- Merged "Create issue and pull request templates" [#150](https://github.com/pichillilorenzo/flutter_inappwebview/pull/150) (thanks to [deandreamatias](https://github.com/deandreamatias))
- Merged "Fix abstract method error && swift version error" [#155](https://github.com/pichillilorenzo/flutter_inappwebview/pull/155) (thanks to [AlexVincent525](https://github.com/AlexVincent525))
- Merged "migrating to swift 5.0" [#162](https://github.com/pichillilorenzo/flutter_inappwebview/pull/162) (thanks to [fattiger00](https://github.com/fattiger00))
- Merged "Update readme example" [#178](https://github.com/pichillilorenzo/flutter_inappwebview/pull/178) (thanks to [SebastienBtr](https://github.com/SebastienBtr))
- Merged "handle choose file callback in android" [#183](https://github.com/pichillilorenzo/flutter_inappwebview/pull/183) (thanks to [crazecoder](https://github.com/crazecoder))
- Merged "add initialScale in android" [#186](https://github.com/pichillilorenzo/flutter_inappwebview/pull/186) (thanks to [crazecoder](https://github.com/crazecoder))
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

- Merged "added a shared WKProcessPool for webview instances" [#198](https://github.com/pichillilorenzo/flutter_inappwebview/pull/198) (thanks to [robertcnst](https://github.com/robertcnst))
- Fixed iOS setCookie.

## 1.2.1

- Merged "Add new option to control the contentMode in Android platform" [#101](https://github.com/pichillilorenzo/flutter_inappwebview/pull/101) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Merged "Fix crash on xcode 10.2" [#107](https://github.com/pichillilorenzo/flutter_inappwebview/pull/107) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Merged "Remove headers_build_phase from example's Podfile" [#108](https://github.com/pichillilorenzo/flutter_inappwebview/pull/108) (thanks to [robsonfingo](https://github.com/robsonfingo))
- Fixed "Make html5 video fullscreen" for Android [#43](https://github.com/pichillilorenzo/flutter_inappwebview/issues/43)
- Fixed "AllowsInlineMediaPlayback not working" for iOS [#73](https://github.com/pichillilorenzo/flutter_inappwebview/issues/73)

## 1.2.0

- Merged "Adds a transparentBackground option for iOS and Android" [#86](https://github.com/pichillilorenzo/flutter_inappwebview/pull/86) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merged "The 'open' method requires an options dictionary" [#87](https://github.com/pichillilorenzo/flutter_inappwebview/pull/87) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Merged "iOS: Call setNeedsLayout() in scrollViewDidScroll()" [#88](https://github.com/pichillilorenzo/flutter_inappwebview/pull/88) (thanks to [matthewlloyd](https://github.com/matthewlloyd))
- Fixed "java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread." [#98](https://github.com/pichillilorenzo/flutter_inappwebview/issues/98) (thanks to [DreamBuddy](https://github.com/DreamBuddy))
- Fixed "app force close/crash when enabling zoom and repeatedly changing orientation and zoomin zoomout" [#93](https://github.com/pichillilorenzo/flutter_inappwebview/issues/93)
- Added `displayZoomControls` webview option for Android
- Fixed "Compatibility with other plugins" [#80](https://github.com/pichillilorenzo/flutter_inappwebview/issues/80)

## 1.1.3

- Merged "Add null checks around calls to InAppWebView callbacks" [#85](https://github.com/pichillilorenzo/flutter_inappwebview/pull/85) (thanks to [matthewlloyd](https://github.com/matthewlloyd))

## 1.1.2

- Fix InAppBrowser crashes the app when i change the page "Lost connection" [#74](https://github.com/pichillilorenzo/flutter_inappwebview/issues/74)
- Fix javascript `...args` parameter of `window.flutter_inappwebview.callHandler()`
- Merged Enable setTextZoom function of Android WebViewSetting [#81](https://github.com/pichillilorenzo/flutter_inappwebview/pull/81) (thanks to [YouCii](https://github.com/YouCii))
- Merged bug fix for android build: Android dependency 'androidx.core:core' has different version for the compile (1.0.0) and runtime (1.0.1) classpath [#83](https://github.com/pichillilorenzo/flutter_inappwebview/pull/83) (thanks to [cinos1](https://github.com/cinos1))

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
