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
